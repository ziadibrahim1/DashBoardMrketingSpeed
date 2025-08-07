import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MaterialApp(home: PackagesPage()));

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
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  final List<Package> packages = [
    Package(
      name: 'فليكس وتساب',
      id:439750 ,
      price: 100,
      durationDays: 30,
      discount: 20,
      features: [
        'الإرسال على المجموعات',
        'الإرسال على الدردشات',
        'الوصول إلى 10000 عضو',
        'تنبيه توصيات تسويق',
      ],
      subscribers: 0,
    ),
    Package(
      name: 'فيسبوك شاملة',
      id:574186 ,
      price: 200,
      durationDays: 60,
      discount: null,
      features: ['الإعلانات المدفوعة', 'إدارة الصفحات'],
      subscribers: 3,
    ),
    Package(
      name: 'إنستجرام بلس',
      id: 772345,
      price: 150,
      durationDays: 45,
      discount: 15,
      features: ['تحليل البيانات', 'جدولة المنشورات'],
      subscribers: 12,
    ),
  ];

  String selectedFilter = 'الكل';
  String selectedSort = 'id';
  bool showArchived = false;

  int generateUniqueId() {
    final rand = Random();
    int newId;
    do {
      newId = 100000 + rand.nextInt(900000);
    } while (packages.any((p) => p.id == newId));
    return newId;
  }

  int get totalSubscribers => packages.fold(0, (sum, p) => sum + p.subscribers);

  List<Package> get filteredPackages {
    List<Package> list = [...packages];

    if (!showArchived) {
      list = list.where((p) => !p.isArchived).toList();
    }

    if (selectedFilter == 'باقات مخفضة') {
      list = list.where((p) => p.discount != null && p.discount! > 0).toList();
    } else if (selectedFilter == 'باقات بها مشتركين') {
      list = list.where((p) => p.subscribers > 0).toList();
    } else if (selectedFilter == 'مجدولة') {
      list = list.where((p) => p.isScheduledFuture).toList();
    }

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return PackageEditor(
          existing: existing,
          generateId: generateUniqueId,
          onSave: (pkg) {
            setState(() {
              if (index != null) {
                packages[index] = pkg;
                pkg.addLog('تم تعديل الباقة');
              } else {
                packages.add(pkg);
                pkg.addLog('تم إنشاء الباقة');
              }
            });
          },
        );
      },
    );
  }

  void _toggleArchive(int index) {
    setState(() {
      final p = packages[index];
      p.isArchived = !p.isArchived;
      p.addLog(p.isArchived ? 'أرشفة الباقة' : 'استرجاع الباقة');
    });
  }

  void _toggleStatus(int index) {
    setState(() {
      final p = packages[index];
      p.status = p.status == PackageStatus.active ? PackageStatus.paused : PackageStatus.active;
      p.addLog('تغيير الحالة إلى ${p.status == PackageStatus.active ? 'مفعلة' : 'معطله'}');
    });
  }

  void _openNotificationModal(Package package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        return NotificationModal(
          package: package,
          onSent: (method, title, content, scheduled) {
            setState(() {
              package.addLog(
                  'تم إرسال إشعار بعنوان "$title" عبر $method${scheduled != null ? ' (مجدول لـ ${DateFormat('yyyy/MM/dd').format(scheduled)})' : ''}');
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة الباقات'),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
      ),
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
                    items: const [
                      DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                      DropdownMenuItem(value: 'باقات مخفضة', child: Text('باقات مخفضة')),
                      DropdownMenuItem(value: 'باقات بها مشتركين', child: Text('باقات بها مشتركين')),
                      DropdownMenuItem(value: 'مجدولة', child: Text('مجموعة مجدولة')),
                    ],
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
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'id', child: Text('معرف')),
                      PopupMenuItem(value: 'price', child: Text('السعر')),
                      PopupMenuItem(value: 'duration', child: Text('مدة')),
                      PopupMenuItem(value: 'subscribers', child: Text('مشتركين')),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      const Text('عرض المؤرشفة'),
                      Switch(
                        value: showArchived,
                        onChanged: (val) => setState(() => showArchived = val),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _openPackageEditor(),
                    icon: const Icon(Icons.add_box),
                    label: const Text('إضافة باقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
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
                      title: 'عدد الباقات',
                      value: packages.where((p) => !p.isArchived).length.toString(),
                      icon: Icons.card_giftcard,
                      gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCardGradient(
                      title: 'إجمالي المشتركين',
                      value: totalSubscribers.toString(),
                      icon: Icons.people,
                      gradient: const LinearGradient(colors: [Colors.teal, Colors.greenAccent]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCardGradient(
                      title: 'باقات مجدولة مستقبلية',
                      value: packages.where((p) => p.isScheduledFuture).length.toString(),
                      icon: Icons.schedule,
                      gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]),
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
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

  const StatCardGradient({
  super.key,
  required this.title,
  required this.value,
  required this.icon,
  required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: gradient.colors.last.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 6))],
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
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

  const PackageCardAdvanced({
  super.key,
  required this.package,
  required this.onEdit,
  required this.onArchive,
  required this.onToggleStatus,
  required this.onNotify,
  required this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          shadowColor: Colors.deepPurple.withOpacity(0.5),
          clipBehavior: Clip.hardEdge,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بانر ذكي اذا الباقة بدون مشتركين مدة طويلة
                if (package.shouldShowInactiveBanner)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, size: 18, color: Colors.black87),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'لا يوجد مشتركين في هذه الباقة منذ أكثر من شهر. قد تحتاج تحديثها أو ترويجها.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
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
                    // حالة الباقة
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: package.status == PackageStatus.active
                            ? Colors.greenAccent.shade200
                            : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        package.status == PackageStatus.active ? 'مفعلة' : 'معطله',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                    _infoTag('السعر: ${package.price.toStringAsFixed(2)} ر.س'),
                    _infoTag('المدة: ${package.durationDays} يوم'),
                    if (package.discount != null)
                      _infoTag('خصم: ${package.discount!.toStringAsFixed(2)} ر.س',
                          background: Colors.redAccent.shade100),
                    if (package.isScheduledFuture)
                      _infoTag(
                        'تبدأ: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}',
                        background: Colors.orange.shade100,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('المميزات:', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: package.features
                          .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• $f',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'مشتركين: ${package.subscribers}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _smallAction(Icons.edit, 'تعديل', onEdit),
                    _smallAction(
                        package.isArchived ? Icons.unarchive : Icons.archive,
                        package.isArchived ? 'استرجاع' : 'أرشفة', onArchive),
                    _smallAction(
                        package.status == PackageStatus.active
                            ? Icons.pause_circle
                            : Icons.play_circle_fill,
                        package.status == PackageStatus.active
                            ? 'إيقاف'
                            : 'تفعيل', onToggleStatus),
                    _smallAction(Icons.notifications_active, 'إشعار', onNotify),
                    _smallAction(Icons.history, 'سجل', onViewLogs),
                  ],
                ),
              ],
            ),
          ),
        ),
        // علامة مؤرشفة صغيرة
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
              child: const Text(
                'مؤرشف',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
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

  const PackageEditor({
  super.key,
  this.existing,
  required this.generateId,
  required this.onSave,
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
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewPackage = Package(
      name: _name.text.trim().isEmpty ? 'اسم الباقة' : _name.text.trim(),
      id: id,
      price: double.tryParse(_price.text.trim()) ?? 0,
      durationDays: int.tryParse(_duration.text.trim()) ?? 0,
      discount: _discount.text.trim().isEmpty ? null : double.tryParse(_discount.text.trim()),
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
                  widget.existing == null ? 'إضافة باقة جديدة' : 'تعديل الباقة',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          decoration: const InputDecoration(labelText: 'اسم الباقة *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال اسم' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: status == PackageStatus.active
                                ? Colors.green.shade50
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Text('الحالة: '),
                            const SizedBox(width: 4),
                            Text(
                              status == PackageStatus.active ? 'مفعلة' : 'معطله',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: status == PackageStatus.active ? Colors.green : Colors.grey[700]),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  status = status == PackageStatus.active ? PackageStatus.paused : PackageStatus.active;
                                });
                              },
                              child: Icon(
                                status == PackageStatus.active ? Icons.pause_circle : Icons.play_circle_fill,
                                color: status == PackageStatus.active ? Colors.green : Colors.grey[700],
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
                          decoration: const InputDecoration(labelText: 'السعر *'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final d = double.tryParse(v ?? '');
                            if (d == null || d <= 0) return 'سعر غير صالح';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _duration,
                          decoration: const InputDecoration(labelText: 'مدة (يوم) *'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final d = int.tryParse(v ?? '');
                            if (d == null || d <= 0) return 'مدة غير صالحة';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _discount,
                    decoration: const InputDecoration(labelText: 'خصم (اختياري)'),
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
                              label: Text(f),
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
                          decoration: const InputDecoration(labelText: 'ميزة جديدة'),
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
                      const Text('تاريخ بداية (جدولة):'),
                      const SizedBox(width: 12),
                      Text(
                        startDate != null ? DateFormat('yyyy/MM/dd').format(startDate!) : 'غير محدد',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
              child: Text('معاينة الباقة', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),),
            ),
            const SizedBox(height: 8),
            PackageCardPreview(package: previewPackage),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final pkg = Package(
                    name: _name.text.trim(),
                    id: id,
                    price: double.parse(_price.text.trim()),
                    durationDays: int.parse(_duration.text.trim()),
                    discount: _discount.text.trim().isEmpty ? null : double.parse(_discount.text.trim()),
                    features: features,
                    subscribers: widget.existing?.subscribers ?? 0,
                    status: status,
                    startDate: startDate,
                    isArchived: widget.existing?.isArchived ?? false,
                    logs: widget.existing?.logs ?? [],
                    lastZeroSubscriberDetected: widget.existing?.lastZeroSubscriberDetected,
                  );
                  pkg.addLog(widget.existing == null ? 'إنشاء باقة جديدة' : 'تعديل باقة');
                  widget.onSave(pkg);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: Text(widget.existing == null ? 'أنشئ الباقة' : 'حفظ التعديل'),
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

  const PackageCardPreview({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF7B1FA2), Color(0xFF8E24AA)],
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
            Text(package.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text('ID: ${package.id}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('السعر: ${package.price} ر.س', style: const TextStyle(color: Colors.white70)),
            Text('المدة: ${package.durationDays} يوم', style: const TextStyle(color: Colors.white70)),
            if (package.discount != null)
              Text('خصم: ${package.discount}', style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: package.features.map((f) => Chip(label: Text(f), backgroundColor: Colors.white24)).toList(),
            ),
            const SizedBox(height: 6),
            Text('مشتركين: ${package.subscribers}', style: const TextStyle(color: Colors.white)),
            if (package.isScheduledFuture)
              Text('تبدأ: ${DateFormat('yyyy/MM/dd').format(package.startDate!)}',
                  style: const TextStyle(color: Colors.orangeAccent)),
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

  const NotificationModal({super.key, required this.package, required this.onSent});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String sendMethod = 'داخل التطبيق';
  DateTime? scheduledDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => scheduledDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final previewTitle = _titleController.text.trim().isEmpty ? 'عنوان تجريبي' : _titleController.text.trim();
    final previewContent = _contentController.text.trim().isEmpty ? 'محتوى الإشعار سيظهر هنا.' : _contentController.text.trim();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16, top: 16, left: 16, right: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('إرسال إشعار لـ "${widget.package.name}"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان الإشعار *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'محتوى الإشعار *'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sendMethod,
              decoration: const InputDecoration(labelText: 'طريقة الإرسال'),
              items: ['داخل التطبيق', 'رسائل الهاتف SMS', 'البريد الإلكتروني'].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => sendMethod = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('جدولة الإرسال:'),
                const SizedBox(width: 8),
                Text(scheduledDate != null
                    ? DateFormat('yyyy/MM/dd').format(scheduledDate!)
                    : 'غير مجدول'),
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
                    Text('معاينة الإشعار', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 8),
                    Text('العنوان: $previewTitle', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('المحتوى: $previewContent'),
                    const SizedBox(height: 6),
                    Text('الطريقة: $sendMethod'),
                    if (scheduledDate != null)
                      Text('مجدول لـ: ${DateFormat('yyyy/MM/dd').format(scheduledDate!)}',
                          style: const TextStyle(color: Colors.deepPurple)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('يرجى ملء عنوان ومحتوى الإشعار')));
                  return;
                }
                widget.onSent(sendMethod, _titleController.text.trim(), _contentController.text.trim(), scheduledDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: const Text('إرسال الإشعار'),
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

  const LogsViewer({super.key, required this.package});

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
                Text('سجل الباقة: ${package.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(DateFormat('yyyy/MM/dd').format(package.createdAt), style: const TextStyle(color: Colors.grey)),
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
                  subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
