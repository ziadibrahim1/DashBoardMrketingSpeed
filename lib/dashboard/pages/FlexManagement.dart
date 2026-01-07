import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;

import '../../Models/PackageEditor.dart';
import '../../Models/packageNotificationModal.dart';
import '../../core/app_config.dart';
import '../../services/api_service.dart';
import 'Package.dart';



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
    _packages = [];
    selectedFilter = widget.isArabic ? 'الكل' : 'All';
    selectedSort = 'id';
    showArchived = false;
    _loadPackages();
  }
  int generateUniqueId() {
    final rand = Random();
    int newId;
    do {
      newId = 100000 + rand.nextInt(900000);
    } while (_packages.any((p) => p.id == newId));
    return newId;
  }
  Future<void> _loadPackages() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}admin/packages'),
    );

    final List data = jsonDecode(res.body);

    setState(() {
      _packages = data
          .map((e) => Package.fromJson(e, widget.isArabic))
          .toList();
    });
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

  Future<void> _toggleArchiveById(int packageId) async {
    try {
      final pkg = _packages.firstWhere((p) => p.id == packageId);

      final newValue = await ApiService.toggleArchive(pkg.id);

      setState(() {
        pkg.isArchived = newValue;
        pkg.addLog(
          newValue
              ? (widget.isArabic ? 'أرشفة الباقة' : 'Package archived')
              : (widget.isArabic ? 'استرجاع الباقة' : 'Package restored'),
        );
      });

      await _loadPackages(); // تحديث من السيرفر

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? (widget.isArabic ? 'تمت الأرشفة بنجاح' : 'Archived successfully')
                : (widget.isArabic ? 'تم الاسترجاع بنجاح' : 'Restored successfully'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(widget.isArabic ? 'فشل تنفيذ العملية' : 'Operation failed'),
        ),
      );
    }
  }

  Future<void> _toggleStatus(int index) async {
    final pkg = _packages.firstWhere((p) => p.id == index);
    try {
      // نرسل request للباك اند لتبديل الحالة
      final res = await http.patch(
        Uri.parse('${AppConfig.baseUrl}admin/packages/${pkg.id}/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        // السيرفر رجع الحالة الجديدة
        final newStatus = res.body.replaceAll('"', ''); // لو رجع string مرفوع بين " "
        setState(() {
          pkg.status = newStatus == 'active' ? PackageStatus.active : PackageStatus.paused;
          pkg.addLog(widget.isArabic
              ? 'تغيير الحالة إلى ${pkg.status == PackageStatus.active ? 'مفعلة' : 'معطله'}'
              : 'Status changed to ${pkg.status == PackageStatus.active ? 'Active' : 'Paused'}');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل تغيير الحالة' : 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'خطأ في الاتصال بالسيرفر' : 'Server error'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      onArchive: () => _toggleArchiveById(p.id),
                      onToggleStatus: () => _toggleStatus(p.id),
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
                            child: Text('• ${f.feature}',
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
                        package.isArchived
                            ? (isArabic ? 'استرجاع' : 'Restore')
                            : (isArabic ? 'أرشفة' : 'Archive'),
                        onArchive,
                      ),
                      _smallAction(
                          package.status == PackageStatus.active
                              ? Icons.pause_circle
                              : Icons.play_circle_fill,
                          package.status == PackageStatus.active
                              ? (isArabic ? 'إيقاف' : 'Pause')
                              : (isArabic ? 'تفعيل' : 'Activate'),
                          onToggleStatus),
                      _smallAction(Icons.notifications_active, isArabic ? 'إشعار' : 'Notify', onNotify),
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
