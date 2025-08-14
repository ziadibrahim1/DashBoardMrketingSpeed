import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart'; // تأكد من مسار الـ LocaleProvider عندك

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String selectedStatus = 'all';
  String selectedSubscriptionType = 'all'; // القيمة الافتراضية بالإنجليزية لأن سنترجمها لاحقًا
  String searchQuery = '';

  int rowsPerPage = 20;
  int currentPage = 0;

  final List<String> subscriptionTypesArabic = [
    'شهري',
    'ربع سنوي',
    'نصف سنوي',
    'سنوي',
    'مجاني',
  ];

  final List<String> subscriptionTypesEnglish = [
    'Monthly',
    'Quarterly',
    'Semi-Annual',
    'Annual',
    'Free',
  ];

  final List<Map<String, dynamic>> allSubscriptions = [
    {
      'user': 'أحمد علي',
      'email': 'ahmed@example.com',
      'type': 'شهري',
      'startDate': '2025-07-01',
      'endDate': '2025-07-31',
      'status': 'active',
    },
    {
      'user': 'Sara Khaled',
      'email': 'sara@example.com',
      'type': 'سنوي',
      'startDate': '2024-09-01',
      'endDate': '2025-09-01',
      'status': 'expired',
    },
    {
      'user': 'خالد يوسف',
      'email': 'khaled@example.com',
      'type': 'مجاني',
      'startDate': '2025-01-01',
      'endDate': 'دائم',
      'status': 'frozen',
    },
    // أضف بيانات أكثر لتجربة pagination
  ];

  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ترجمة النصوص حسب اللغة
    final subscriptionTypes = isArabic ? subscriptionTypesArabic : subscriptionTypesEnglish;
    final allTypeLabel = isArabic ? 'الكل' : 'All';
    final statusLabels = {
      'all': allTypeLabel,
      'active': isArabic ? 'نشط' : 'Active',
      'expired': isArabic ? 'منتهي' : 'Expired',
      'frozen': isArabic ? 'مجمد' : 'Frozen',
    };

    final statusTextForStatus = (String status) => statusLabels[status] ?? (isArabic ? 'غير معروف' : 'Unknown');

    // فلترة الاشتراكات
    final filtered = allSubscriptions.where((sub) {
      final matchesStatus = selectedStatus == 'all' || sub['status'] == selectedStatus;
      final matchesSearch = sub['user'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedSubscriptionType == 'all' || sub['type'] == selectedSubscriptionType;
      return matchesStatus && matchesSearch && matchesType;
    }).toList();

    final totalPages = (filtered.length / rowsPerPage).ceil();
    final paginated = filtered.skip(currentPage * rowsPerPage).take(rowsPerPage).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? '📋 إدارة الاشتراكات' : '📋 Subscriptions Management',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color:isDark ? const Color(0xFFD7EFDC) : Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 16),

          // فلترة الحالة باستخدام ChoiceChips مع الترجمة
          Wrap(
            spacing: 12,
            children: [
              buildFilterChip(statusLabels['all']!, 'all', theme.colorScheme.primary),
              buildFilterChip(statusLabels['active']!, 'active', Colors.green),
              buildFilterChip(statusLabels['expired']!, 'expired', Colors.red),
              buildFilterChip(statusLabels['frozen']!, 'frozen', Colors.orange),
            ],
          ),
          const SizedBox(height: 16),

          // البحث وفلترة النوع مع الترجمة
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: isArabic ? '🔍 ابحث عن مستخدم بالاسم' : '🔍 Search user by name',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      currentPage = 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedSubscriptionType == 'all' ? allTypeLabel : selectedSubscriptionType,
                items: [allTypeLabel, ...subscriptionTypes].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubscriptionType = value == allTypeLabel ? 'all' : value!;
                    currentPage = 0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // عداد النتائج
          Text(
            isArabic
                ? 'عدد النتائج: ${filtered.length} من أصل ${allSubscriptions.length}'
                : 'Results: ${filtered.length} of ${allSubscriptions.length}',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // الجدول بعرض الشاشة مع تمرير أفقي
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                        (states) => isDark ? Colors.grey[900] : Colors.grey[200],
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith(
                        (states) => isDark ? Colors.grey[850] : Colors.white,
                  ),
                  columns: [
                    DataColumn(label: Text(isArabic ? 'المستخدم' : 'User')),
                    DataColumn(label: Text(isArabic ? 'البريد الإلكتروني' : 'Email')),
                    DataColumn(label: Text(isArabic ? 'نوع الاشتراك' : 'Subscription Type')),
                    DataColumn(label: Text(isArabic ? 'البداية' : 'Start Date')),
                    DataColumn(label: Text(isArabic ? 'النهاية' : 'End Date')),
                    DataColumn(label: Text(isArabic ? 'الحالة' : 'Status')),
                    DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions')),
                  ],
                  rows: paginated.map((sub) => buildDataRow(sub, isArabic, subscriptionTypes)).toList(),
                ),
              ),
            ),
          ),

          // أزرار التنقل
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                child: Text(isArabic ? 'السابق' : 'Previous'),
              ),
              const SizedBox(width: 16),
              Text(
                '${isArabic ? 'صفحة' : 'Page'} ${currentPage + 1} ${isArabic ? 'من' : 'of'} $totalPages',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
                child: Text(isArabic ? 'التالي' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ChoiceChip buildFilterChip(String label, String value, Color color) {
    final selected = selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? color : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) {
        setState(() {
          selectedStatus = value;
          currentPage = 0;
        });
      },
    );
  }

  DataRow buildDataRow(Map<String, dynamic> sub, bool isArabic, List<String> subscriptionTypes) {
    Color statusColor;
    String statusText;

    switch (sub['status']) {
      case 'active':
        statusColor = Colors.green;
        statusText = isArabic ? 'نشط' : 'Active';
        break;
      case 'expired':
        statusColor = Colors.red;
        statusText = isArabic ? 'منتهي' : 'Expired';
        break;
      case 'frozen':
        statusColor = Colors.orange;
        statusText = isArabic ? 'مجمد' : 'Frozen';
        break;
      default:
        statusColor = Colors.grey;
        statusText = isArabic ? 'غير معروف' : 'Unknown';
    }

    return DataRow(cells: [
      DataCell(Text(sub['user'])),
      DataCell(Text(sub['email'])),
      DataCell(Text(sub['type'])),
      DataCell(Text(sub['startDate'])),
      DataCell(Text(sub['endDate'])),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          statusText,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: isArabic ? 'تعديل' : 'Edit',
            onPressed: () {
              _showEditDialog(sub, isArabic, subscriptionTypes);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            tooltip: isArabic ? 'تجديد الاشتراك' : 'Renew Subscription',
            onPressed: () {
              renewSubscription(sub);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () {
              setState(() {
                sub['status'] = 'frozen';
              });
            },
          ),
        ],
      )),
    ]);
  }

  void renewSubscription(Map<String, dynamic> subscription) {
    final now = DateTime.now();
    final type = subscription['type'];

    if (type == 'شهري' || type == 'Monthly') {
      final newEnd = DateTime(now.year, now.month + 1, now.day);
      subscription['startDate'] = dateFormat.format(now);
      subscription['endDate'] = dateFormat.format(newEnd);
    } else if (type == 'سنوي' || type == 'Annual') {
      final newEnd = DateTime(now.year + 1, now.month, now.day);
      subscription['startDate'] = dateFormat.format(now);
      subscription['endDate'] = dateFormat.format(newEnd);
    } else {
      subscription['startDate'] = dateFormat.format(now);
      subscription['endDate'] = 'دائم';
    }

    subscription['status'] = 'active';
    setState(() {});
  }
  void _showEditDialog(Map<String, dynamic> subscription, bool isArabic, List<String> subscriptionTypes) {
    // اجعل العناصر فريدة فقط
    final allTypesSet = isArabic
        ? subscriptionTypesArabic.toSet().toList()
        : subscriptionTypesEnglish.toSet().toList();

    // إذا لم تكن القيمة الحالية موجودة في القائمة، اضفها لتجنب الخطأ
    String selectedType = subscription['type'];
    if (!allTypesSet.contains(selectedType)) {
      allTypesSet.insert(0, selectedType);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isArabic ? 'تعديل نوع الاشتراك' : 'Edit Subscription Type'),
                content: DropdownButtonFormField<String>(
                  value: selectedType,
                  items: allTypesSet.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedType = val;
                      });
                    }
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        subscription['type'] = selectedType;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(isArabic ? 'حفظ' : 'Save'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

}
