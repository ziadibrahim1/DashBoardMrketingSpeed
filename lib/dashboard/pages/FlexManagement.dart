import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;


enum PackageStatus { active, paused }

class LogEntry {
  final DateTime timestamp;
  final String message;

  LogEntry(this.message) : timestamp = DateTime.now();
}

class Package {
  String name;
  int id;
  double price;
  int durationDays;
  double? discount;
  List<String> features;
  int subscribers;
  bool isArchived;
  PackageStatus status;
  DateTime createdAt;
  DateTime? startDate; // للجدولة المستقبلية
  List<LogEntry> logs;
  DateTime? lastZeroSubscriberDetected; // لتتبع الإشعار الذكي

  Package({
    required this.name,
    required this.id,
    required this.price,
    required this.durationDays,
    this.discount,
    required this.features,
    required this.subscribers,
    this.isArchived = false,
    this.status = PackageStatus.active,
    DateTime? createdAt,
    this.startDate,
    List<LogEntry>? logs,
    this.lastZeroSubscriberDetected,
  })  : createdAt = createdAt ?? DateTime.now(),
        logs = logs ?? [] {
    if (subscribers == 0) {
      lastZeroSubscriberDetected = DateTime.now();
    }
  }

  void addLog(String msg) {
    logs.insert(0, LogEntry(msg));
  }

  bool get isScheduledFuture {
    if (startDate == null) return false;
    return startDate!.isAfter(DateTime.now());
  }

  bool get shouldShowInactiveBanner {
    if (subscribers > 0) return false;
    if (lastZeroSubscriberDetected == null) return true;
    final diff = DateTime.now().difference(lastZeroSubscriberDetected!);
    return diff.inDays >= 30;
  }
}

class PackagesPage extends StatefulWidget {
  final bool isArabic;

  const PackagesPage({super.key, required this.isArabic});
  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  // نخزن الباقات هنا بشكل داخلي، لإمكانية التعديل عليها
  late List<Package> _packages;

  late String selectedFilter;
  late String selectedSort;
  late bool showArchived;

  @override
  void initState() {
    super.initState();

    // تهيئة الباقات حسب اللغة
    _packages = [
      Package(
        name: widget.isArabic ? 'فليكس وتساب' : 'Flex WhatsApp',
        id: 439750,
        price: 100,
        durationDays: 30,
        discount: 20,
        features: widget.isArabic
            ? [
          'الإرسال على المجموعات',
          'الإرسال على الدردشات',
          'الوصول إلى 10000 عضو',
          'تنبيه توصيات تسويق',
        ]
            : [
          'Group sending',
          'Chat sending',
          'Access up to 10000 members',
          'Marketing recommendation alerts',
        ],
        subscribers: 0,
      ),
      Package(
        name: widget.isArabic ? 'فيسبوك شاملة' : 'Facebook Complete',
        id: 574186,
        price: 200,
        durationDays: 60,
        discount: null,
        features: widget.isArabic
            ? ['الإعلانات المدفوعة', 'إدارة الصفحات']
            : ['Paid Ads', 'Page Management'],
        subscribers: 3,
      ),
      Package(
        name: widget.isArabic ? 'إنستجرام بلس' : 'Instagram Plus',
        id: 772345,
        price: 150,
        durationDays: 45,
        discount: 15,
        features: widget.isArabic
            ? ['تحليل البيانات', 'جدولة المنشورات']
            : ['Data Analysis', 'Post Scheduling'],
        subscribers: 12,
      ),
    ];

    // تهيئة الفلاتر والترتيب والقيمة الافتراضية لعرض المؤرشفة حسب اللغة
    selectedFilter = widget.isArabic ? 'الكل' : 'All';
    selectedSort = 'id';
    showArchived = false;
  }

  int generateUniqueId() {
    final rand = Random();
    int newId;
    do {
      newId = 100000 + rand.nextInt(900000);
    } while (_packages.any((p) => p.id == newId));
    return newId;
  }

  int get totalSubscribers => _packages.fold(0, (sum, p) => sum + p.subscribers);

  List<Package> get filteredPackages {
    List<Package> list = [..._packages];

    if (!showArchived) {
      list = list.where((p) => !p.isArchived).toList();
    }

    // فلترة حسب النص المختار، مع مراعاة الترجمة
    if (selectedFilter == (widget.isArabic ? 'باقات مخفضة' : 'Discounted Packages')) {
      list = list.where((p) => p.discount != null && p.discount! > 0).toList();
    } else if (selectedFilter == (widget.isArabic ? 'باقات بها مشتركين' : 'Packages with Subscribers')) {
      list = list.where((p) => p.subscribers > 0).toList();
    } else if (selectedFilter == (widget.isArabic ? 'مجدولة' : 'Scheduled')) {
      list = list.where((p) => p.isScheduledFuture).toList();
    }
    // 'الكل' أو 'All' تعني الكل، لا حاجة لتغيير

    switch (selectedSort) {
      case 'price':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'duration':
        list.sort((a, b) => a.durationDays.compareTo(b.durationDays));
        break;
      case 'subscribers':
        list.sort((a, b) => a.subscribers.compareTo(b.subscribers));
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }
    return list;
  }

  int getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  void _openPackageEditor({Package? existing, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return PackageEditor(
          existing: existing,
          generateId: generateUniqueId,
          onSave: (pkg) {
            setState(() {
              if (index != null) {
                _packages[index] = pkg;
                pkg.addLog(widget.isArabic ? 'تم تعديل الباقة' : 'Package edited');
              } else {
                _packages.add(pkg);
                pkg.addLog(widget.isArabic ? 'تم إنشاء الباقة' : 'Package created');
              }
            });
          },isArabic: widget.isArabic
        );
      },
    );
  }

  void _toggleArchive(int index) {
    setState(() {
      final p = _packages[index];
      p.isArchived = !p.isArchived;
      p.addLog(p.isArchived
          ? (widget.isArabic ? 'أرشفة الباقة' : 'Package archived')
          : (widget.isArabic ? 'استرجاع الباقة' : 'Package restored'));
    });
  }

  void _toggleStatus(int index) {
    setState(() {
      final p = _packages[index];
      p.status = p.status == PackageStatus.active ? PackageStatus.paused : PackageStatus.active;
      p.addLog(widget.isArabic
          ? 'تغيير الحالة إلى ${p.status == PackageStatus.active ? 'مفعلة' : 'معطله'}'
          : 'Status changed to ${p.status == PackageStatus.active ? 'Active' : 'Paused'}');
    });
  }

  void _openNotificationModal(Package package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        return NotificationModal(
          package: package,
          onSent: (method, title, content, scheduled) {
            setState(() {
              package.addLog(
                '${widget.isArabic ? 'تم إرسال إشعار بعنوان' : 'Notification sent titled'} "$title" ${widget.isArabic ? 'عبر' : 'via'} $method${scheduled != null
                        ? (widget.isArabic
                        ? ' (مجدول لـ ${DateFormat('yyyy/MM/dd').format(scheduled)})'
                        : ' (Scheduled for ${DateFormat('yyyy/MM/dd').format(scheduled)})')
                        : ''}',
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = getCrossAxisCount(width);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // إعداد عناصر الفلتر مع دعم الترجمة
    final filterOptions = widget.isArabic
        ? ['الكل', 'باقات مخفضة', 'باقات بها مشتركين', 'مجدولة']
        : ['All', 'Discounted Packages', 'Packages with Subscribers', 'Scheduled'];

    // إعداد عناصر الترتيب مع دعم الترجمة
    final sortOptions = widget.isArabic
        ? {
      'id': 'معرف',
      'price': 'السعر',
      'duration': 'مدة',
      'subscribers': 'مشتركين',
    }
        : {
      'id': 'ID',
      'price': 'Price',
      'duration': 'Duration',
      'subscribers': 'Subscribers',
    };

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:isDark?Colors.grey[850]: Colors.grey[50],

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // فلتر/ترتيب + عرض المؤرشفة + إضافة
                Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedFilter,
                      items: filterOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selectedFilter = v);
                      },
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      onSelected: (val) {
                        setState(() {
                          selectedSort = val;
                        });
                      },
                      itemBuilder: (_) => sortOptions.entries
                          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Text(widget.isArabic ? 'عرض المؤرشفة' : 'Show Archived'),
                        Switch(
                          activeColor:isDark?Colors.green[400] : Colors.blue,
                          value: showArchived,
                          onChanged: (val) => setState(() => showArchived = val),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _openPackageEditor(),
                      icon: const Icon(Icons.add_box,color:Colors.white),
                      label: Text(widget.isArabic ? 'إضافة باقة' : 'Add Package',style:TextStyle(color:Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:isDark ? Colors.green.shade800 : Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // كروت إحصائيات
                Row(
                  children: [
                    Expanded(
                      child: StatCardGradient(
                        title: widget.isArabic ? 'عدد الباقات' : 'Number of Packages',
                        value: _packages.where((p) => !p.isArchived).length.toString(),
                        icon: Icons.card_giftcard,
                        gradient:
                         LinearGradient(colors:isDark?[Color(0xFF54D3B3), ?Colors.green[900]]: [?Colors.red[300]?.withOpacity(.3), Colors.blue.withOpacity(.3)]), isArabic:widget.isArabic,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCardGradient(
                        title: widget.isArabic ? 'إجمالي المشتركين' : 'Total Subscribers',
                        value: totalSubscribers.toString(),
                        icon: Icons.people,
                        gradient:  LinearGradient(colors:isDark?[Color(0xFF54D3B3), ?Colors.green[900]]: [?Colors.orange[300]?.withOpacity(.3), ?Colors.blue[800]?.withOpacity(.3)]),isArabic:widget.isArabic,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCardGradient(
                        title: widget.isArabic ? 'باقات مجدولة مستقبلية' : 'Scheduled Packages',
                        value: _packages.where((p) => p.isScheduledFuture).length.toString(),
                        icon: Icons.schedule,
                        gradient:
                         LinearGradient(colors:isDark?[Color(0xFF54D3B3), ?Colors.green[900]] :[?Colors.green[200]?.withOpacity(.3), ?Colors.blue[900]?.withOpacity(.3)] ),isArabic:widget.isArabic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // شبكة الباقات
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 400,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: filteredPackages.length,
                  itemBuilder: (context, i) {
                    final p = filteredPackages[i];
                    return PackageCardAdvanced(
                      package: p,
                      onEdit: () => _openPackageEditor(existing: p, index: i),
                      onArchive: () => _toggleArchive(i),
                      onToggleStatus: () => _toggleStatus(i),
                      onNotify: () => _openNotificationModal(p),
                      onViewLogs: () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                        builder: (_) => LogsViewer(package: p),
                      ),isArabic:widget.isArabic,
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// بطاقة إحصائيات مزودة بتدرج
class StatCardGradient extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final bool isArabic; // إضافة

  const StatCardGradient({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isArabic, // إضافة
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: gradient.colors.last.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                radius: 28,
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.1)),
                    const SizedBox(height: 6),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كارت باقة متقدم مع أرشفة وتغيير حالة ومعاينة ذكية
class PackageCardAdvanced extends StatelessWidget {
  final Package package;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onToggleStatus;
  final VoidCallback onNotify;
  final VoidCallback onViewLogs;
  final bool isArabic; // إضافة

  const PackageCardAdvanced({
    super.key,
    required this.package,
    required this.onEdit,
    required this.onArchive,
    required this.onToggleStatus,
    required this.onNotify,
    required this.onViewLogs,
    required this.isArabic, // إضافة
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =  LinearGradient(
      colors:isDark?[
        Colors.green.shade700.withOpacity(.3),
        Colors.green.shade500.withOpacity(.3),
        Color(0xFFB3A664).withOpacity(.3),
        Colors.green.shade600.withOpacity(.3),
        ?Colors.green[900]?.withOpacity(.3),
      ]: [
        Colors.blue.shade700.withOpacity(.4),
        Colors.blue.shade500.withOpacity(.4),
        Colors.blue.shade300.withOpacity(.4),
        Colors.blue.shade600.withOpacity(.4),
        ?Colors.blue[900],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 12,
            shadowColor:isDark?Colors.green.withOpacity(0.5): Colors.blue.withOpacity(0.5),
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color:isDark?Colors.green.withOpacity(0.3): Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (package.shouldShowInactiveBanner)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Colors.black87),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'لا يوجد مشتركين في هذه الباقة منذ أكثر من شهر. قد تحتاج تحديثها أو ترويجها.'
                                  : 'No subscribers in this package for over a month. You may need to update or promote it.',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: package.status == PackageStatus.active
                              ? Colors.green.shade400
                              : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          package.status == PackageStatus.active
                              ? (isArabic ? 'مفعلة' : 'Active')
                              : (isArabic ? 'معطله' : 'Paused'),
                          style: const TextStyle(fontWeight: FontWeight.bold,color:Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _infoTag('ID: ${package.id}'),
                      _infoTag(isArabic
                          ? 'السعر: ${package.price.toStringAsFixed(2)} ر.س'
                          : 'Price: ${package.price.toStringAsFixed(2)} SAR'),
                      _infoTag(isArabic
                          ? 'المدة: ${package.durationDays} يوم'
                          : 'Duration: ${package.durationDays} days'),
                      if (package.discount != null)
                        _infoTag(
                          isArabic
                              ? 'خصم: ${package.discount!.toStringAsFixed(2)} ر.س'
                              : 'Discount: ${package.discount!.toStringAsFixed(2)} SAR',
                          background: Colors.redAccent.shade200,
                        ),
                      if (package.isScheduledFuture)
                        _infoTag(
                          isArabic
                              ? 'تبدأ: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}'
                              : 'Starts: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}',
                          background: Colors.orange.shade100,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'المميزات:' : 'Features:',
                    style:  TextStyle(fontSize: 14, color:isDark?Colors.white:Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: package.features
                            .map(
                              (f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• $f',
                                style:
                                 TextStyle(color:isDark?Colors.white:Colors.white, fontSize: 13)),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isArabic
                              ? 'مشتركين: ${package.subscribers}'
                              : 'Subscribers: ${package.subscribers}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallAction(Icons.edit, isArabic ? 'تعديل' : 'Edit', onEdit),
                      _smallAction(
                          package.isArchived ? Icons.unarchive : Icons.archive,
                          package.isArchived ? (isArabic ? 'استرجاع' : 'Restore') : (isArabic ? 'أرشفة' : 'Archive'),
                          onArchive),
                      _smallAction(
                          package.status == PackageStatus.active
                              ? Icons.pause_circle
                              : Icons.play_circle_fill,
                          package.status == PackageStatus.active
                              ? (isArabic ? 'إيقاف' : 'Pause')
                              : (isArabic ? 'تفعيل' : 'Activate'),
                          onToggleStatus),
                      _smallAction(Icons.notifications_active, isArabic ? 'إشعار' : 'Notify', onNotify),
                      _smallAction(Icons.history, isArabic ? 'سجل' : 'Logs', onViewLogs),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (package.isArchived)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isArabic ? 'مؤرشف' : 'Archived',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTag(String text, {Color background = Colors.white24}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  Widget _smallAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }
}

// محرر الباقة (معاينة + جدولة)
class PackageEditor extends StatefulWidget {
  final Package? existing;
  final int Function() generateId;
  final void Function(Package) onSave;
  final bool isArabic;  // إضافة

  const PackageEditor({
    super.key,
    this.existing,
    required this.generateId,
    required this.onSave,
    required this.isArabic,  // إضافة
  });

  @override
  State<PackageEditor> createState() => _PackageEditorState();
}

class _PackageEditorState extends State<PackageEditor> {
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _duration;
  late TextEditingController _discount;
  List<String> features = [];
  String newFeature = '';
  late int id;
  DateTime? startDate;
  PackageStatus status = PackageStatus.active;

  final _formKey = GlobalKey<FormState>();

  final List<String> predefinedFeatures = [
    'الإرسال على المجموعات',
    'الإرسال على الدردشات',
    'الوصول إلى 10000 عضو',
    'تنبيه توصيات تسويق',
    'تحليل البيانات',
    'جدولة المنشورات',
    'إعلانات مدفوعة',
    'إدارة الصفحات',
  ];

  @override
  void initState() {
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _duration = TextEditingController(text: e?.durationDays.toString() ?? '');
    _discount = TextEditingController(text: e?.discount?.toString() ?? '');
    features = e?.features.toList() ?? [];
    id = e?.id ?? widget.generateId();
    startDate = e?.startDate;
    status = e?.status ?? PackageStatus.active;
    super.initState();
  }

  void addFeature() {
    if (newFeature.trim().isNotEmpty && !features.contains(newFeature.trim())) {
      setState(() {
        features.add(newFeature.trim());
        newFeature = '';
      });
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: Locale(widget.isArabic ? 'ar' : 'en'),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewPackage = Package(
      name: _name.text.trim().isEmpty
          ? (widget.isArabic ? 'اسم الباقة' : 'Package Name')
          : _name.text.trim(),
      id: id,
      price: double.tryParse(_price.text.trim()) ?? 0,
      durationDays: int.tryParse(_duration.text.trim()) ?? 0,
      discount: _discount.text.trim().isEmpty
          ? null
          : double.tryParse(_discount.text.trim()),
      features: features,
      subscribers: widget.existing?.subscribers ?? 0,
      status: status,
      startDate: startDate,
      isArchived: widget.existing?.isArchived ?? false,
      logs: widget.existing?.logs ?? [],
      lastZeroSubscriberDetected: widget.existing?.lastZeroSubscriberDetected,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // رأس
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null
                      ? (widget.isArabic ? 'إضافة باقة جديدة' : 'Add New Package')
                      : (widget.isArabic ? 'تعديل الباقة' : 'Edit Package'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                     color:isDark?Color(0xFFD7EFDC): Colors.blue[900],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? 'اسم الباقة *' : 'Package Name *',
                            labelStyle: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (widget.isArabic ? 'الرجاء إدخال اسم' : 'Please enter a name')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: status == PackageStatus.active
                              ? Colors.green.shade50
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.isArabic ? 'الحالة: ' : 'Status: ',
                              style: TextStyle(color:isDark? Colors.green: Colors.blue[900]),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status == PackageStatus.active
                                  ? (widget.isArabic ? 'مفعلة' : 'Active')
                                  : (widget.isArabic ? 'معطله' : 'Paused'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: status == PackageStatus.active
                                    ? Colors.green
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  status = status == PackageStatus.active
                                      ? PackageStatus.paused
                                      : PackageStatus.active;
                                });
                              },
                              child: Icon(
                                status == PackageStatus.active
                                    ? Icons.pause_circle
                                    : Icons.play_circle_fill,
                                color: status == PackageStatus.active
                                    ? Colors.green
                                    : Colors.grey[700],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _price,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? 'السعر *' : 'Price *',
                            labelStyle: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final d = double.tryParse(v ?? '');
                            if (d == null || d <= 0) {
                              return widget.isArabic ? 'سعر غير صالح' : 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _duration,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? 'مدة (يوم) *' : 'Duration (days) *',
                            labelStyle: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final d = int.tryParse(v ?? '');
                            if (d == null || d <= 0) {
                              return widget.isArabic ? 'مدة غير صالحة' : 'Invalid duration';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _discount,
                    decoration: InputDecoration(
                      labelText: widget.isArabic ? 'خصم (اختياري)' : 'Discount (optional)',
                      labelStyle: TextStyle(color: isDark?Color(0xFFD7EFDC):Colors.blue[900]),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: predefinedFeatures.map((f) {
                            final selected = features.contains(f);
                            return FilterChip(
                              label: Text(
                                f,
                                style: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                              ),
                              selected: selected,
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    features.add(f);
                                  } else {
                                    features.remove(f);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? 'ميزة جديدة' : 'New Feature',
                            labelStyle: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                          ),
                          onChanged: (v) => newFeature = v,
                          onFieldSubmitted: (_) {
                            if (newFeature.trim().isNotEmpty) {
                              setState(() {
                                features.add(newFeature.trim());
                                newFeature = '';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        widget.isArabic ? 'تاريخ بداية (جدولة):' : 'Start Date (Scheduled):',
                        style: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        startDate != null
                            ? DateFormat('yyyy/MM/dd').format(startDate!)
                            : (widget.isArabic ? 'غير محدد' : 'Not set'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:isDark?Color(0xFFD7EFDC): Colors.blue[900],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickStartDate),
                      if (startDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => startDate = null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // معاينة تفاعلية مباشرة
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.isArabic ? 'معاينة الباقة' : 'Package Preview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:isDark?Color(0xFFD7EFDC): Colors.blue[900],
                ),
              ),
            ),
            const SizedBox(height: 8),
            PackageCardPreview(
              package: previewPackage,
              isDark: isDark,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final pkg = Package(
                    name: _name.text.trim(),
                    id: id,
                    price: double.parse(_price.text.trim()),
                    durationDays: int.parse(_duration.text.trim()),
                    discount: _discount.text.trim().isEmpty
                        ? null
                        : double.parse(_discount.text.trim()),
                    features: features,
                    subscribers: widget.existing?.subscribers ?? 0,
                    status: status,
                    startDate: startDate,
                    isArchived: widget.existing?.isArchived ?? false,
                    logs: widget.existing?.logs ?? [],
                    lastZeroSubscriberDetected:
                    widget.existing?.lastZeroSubscriberDetected,
                  );
                  pkg.addLog(widget.existing == null
                      ? (widget.isArabic ? 'إنشاء باقة جديدة' : 'Created new package')
                      : (widget.isArabic ? 'تعديل باقة' : 'Edited package'));
                  widget.onSave(pkg);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.green[800] : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                widget.existing == null
                    ? (widget.isArabic ? 'أنشئ الباقة' : 'Create Package')
                    : (widget.isArabic ? 'حفظ التعديل' : 'Save Changes'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PackageCardPreview extends StatelessWidget {
  final Package package;
  final bool isArabic;
  final bool isDark;

  const PackageCardPreview({
    super.key,
    required this.package,
    this.isArabic = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      colors:isDark?[
        Colors.green.shade900,
        Colors.green.shade600,
        Colors.lightGreen.shade400,
      ]: [
        Colors.indigo.shade900.withOpacity(.3),
        Colors.blue.shade600.withOpacity(.3),
        Colors.lightBlue.shade400.withOpacity(.3),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:isDark?Color(0xFFD7EFDC): Colors.blue[900], // أزرق غامق
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic ? 'الرقم التعريفي: ${package.id}' : 'ID: ${package.id}',
              style: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic ? 'السعر: ${package.price} ر.س' : 'Price: ${package.price} SAR',
              style: TextStyle(color: isDark?Color(0xFFD7EFDC):Colors.blue[900]),
            ),
            Text(
              isArabic
                  ? 'المدة: ${package.durationDays} يوم'
                  : 'Duration: ${package.durationDays} days',
              style: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900]),
            ),
            if (package.discount != null)
              Text(
                isArabic
                    ? 'خصم: ${package.discount}'
                    : 'Discount: ${package.discount}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: package.features
                  .map(
                    (f) => Chip(
                  label: Text(f, style: TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue[900])),
                  backgroundColor: Colors.white24,
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? 'مشتركين: ${package.subscribers}'
                  : 'Subscribers: ${package.subscribers}',
              style: TextStyle(color: isDark?Color(0xFFD7EFDC):Colors.blue[900]),
            ),
            if (package.isScheduledFuture)
              Text(
                isArabic
                    ? 'تبدأ: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}'
                    : 'Starts: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}',
                style: const TextStyle(color: Colors.orangeAccent),
              ),
          ],
        ),
      ),
    );
  }
}

// مودال الإشعار مع معاينة
class NotificationModal extends StatefulWidget {
  final Package package;
  final void Function(String method, String title, String content, DateTime? scheduled) onSent;
  final bool isArabic;

  const NotificationModal({
    super.key,
    required this.package,
    required this.onSent,
    this.isArabic = true,
  });

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String sendMethod;
  DateTime? scheduledDate;

  @override
  void initState() {
    super.initState();
    sendMethod = widget.isArabic ? 'داخل التطبيق' : 'In-App';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: widget.isArabic ? const Locale('ar') : const Locale('en'),
    );
    if (picked != null) setState(() => scheduledDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewTitle = _titleController.text.trim().isEmpty
        ? (widget.isArabic ? 'عنوان تجريبي' : 'Sample Title')
        : _titleController.text.trim();

    final previewContent = _contentController.text.trim().isEmpty
        ? (widget.isArabic ? 'محتوى الإشعار سيظهر هنا.' : 'Notification content will appear here.')
        : _contentController.text.trim();

    final methods = widget.isArabic
        ? ['داخل التطبيق', 'رسائل الهاتف SMS', 'البريد الإلكتروني']
        : ['In-App', 'SMS', 'Email'];

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isArabic
                        ? 'إرسال إشعار لـ "${widget.package.name}"'
                        : 'Send Notification to "${widget.package.name}"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: widget.isArabic ? 'عنوان الإشعار *' : 'Notification Title *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: widget.isArabic ? 'محتوى الإشعار *' : 'Notification Content *'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sendMethod,
              decoration: InputDecoration(labelText: widget.isArabic ? 'طريقة الإرسال' : 'Send Method'),
              items: methods.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => sendMethod = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(widget.isArabic ? 'جدولة الإرسال:' : 'Schedule Send:'),
                const SizedBox(width: 8),
                Text(scheduledDate != null
                    ? DateFormat('yyyy/MM/dd').format(scheduledDate!)
                    : (widget.isArabic ? 'غير مجدول' : 'Not Scheduled')),
                IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                if (scheduledDate != null)
                  IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => scheduledDate = null)),
              ],
            ),
            const SizedBox(height: 16),
            // معاينة الترويسة
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'معاينة الإشعار' : 'Notification Preview',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text('${widget.isArabic ? 'العنوان' : 'Title'}: $previewTitle', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('${widget.isArabic ? 'المحتوى' : 'Content'}: $previewContent'),
                    const SizedBox(height: 6),
                    Text('${widget.isArabic ? 'الطريقة' : 'Method'}: $sendMethod'),
                    if (scheduledDate != null)
                      Text(
                        '${widget.isArabic ? 'مجدول لـ' : 'Scheduled for'}: ${DateFormat('yyyy/MM/dd').format(scheduledDate!)}',
                        style:   TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(widget.isArabic
                        ? 'يرجى ملء عنوان ومحتوى الإشعار'
                        : 'Please fill in the title and content of the notification',style:TextStyle(color:Colors.white)),
                  ));
                  return;
                }
                widget.onSent(sendMethod, _titleController.text.trim(), _contentController.text.trim(), scheduledDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:isDark?Colors.green: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(widget.isArabic ? 'إرسال الإشعار' : 'Send Notification',style:TextStyle(color:Colors.white)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// عارض السجل
class LogsViewer extends StatelessWidget {
  final Package package;
  final bool isArabic;

  const LogsViewer({
    super.key,
    required this.package,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic
                        ? 'سجل الباقة: ${package.name}'
                        : 'Package Logs: ${package.name}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  DateFormat('yyyy/MM/dd').format(package.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: package.logs.length,
              itemBuilder: (_, i) {
                final log = package.logs[i];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(log.message),
                  subtitle: Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
