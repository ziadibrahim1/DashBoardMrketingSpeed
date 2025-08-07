import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String selectedStatus = 'all';
  String selectedSubscriptionType = 'الكل';
  String searchQuery = '';

  int rowsPerPage = 20;
  int currentPage = 0;

  final List<String> subscriptionTypes = [
    'شهري',
    'ربع سنوي',
    'نصف سنوي',
    'سنوي',
    'مجاني',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = allSubscriptions.where((sub) {
      final matchesStatus = selectedStatus == 'all' || sub['status'] == selectedStatus;
      final matchesSearch = sub['user'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedSubscriptionType == 'الكل' || sub['type'] == selectedSubscriptionType;
      return matchesStatus && matchesSearch && matchesType;
    }).toList();

    final totalPages = (filtered.length / rowsPerPage).ceil();
    final paginated = filtered.skip(currentPage * rowsPerPage).take(rowsPerPage).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 إدارة الاشتراكات',  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),),
          const SizedBox(height: 16),

          // فلترة الحالة
          Wrap(
            spacing: 12,
            children: [
              buildFilterChip('الكل', 'all', theme.colorScheme.primary),
              buildFilterChip('نشط', 'active', Colors.green),
              buildFilterChip('منتهي', 'expired', Colors.red),
              buildFilterChip('مجمد', 'frozen', Colors.orange),
            ],
          ),
          const SizedBox(height: 16),

          // البحث وفلترة النوع
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '🔍 ابحث عن مستخدم بالاسم',
                    border: OutlineInputBorder(),
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
                value: selectedSubscriptionType,
                items: ['الكل', ...subscriptionTypes].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubscriptionType = value!;
                    currentPage = 0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // عداد النتائج
          Text(
            'عدد النتائج: ${filtered.length} من أصل ${allSubscriptions.length}',
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
                  columns: const [
                    DataColumn(label: Text('المستخدم')),
                    DataColumn(label: Text('البريد الإلكتروني')),
                    DataColumn(label: Text('نوع الاشتراك')),
                    DataColumn(label: Text('البداية')),
                    DataColumn(label: Text('النهاية')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('إجراءات')),
                  ],
                  rows: paginated.map(buildDataRow).toList(),
                ),
              ),
            ),
          ),

          // أزرار التنقل مثل MessagesPage
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                child: const Text('السابق'),
              ),
              const SizedBox(width: 16),
              Text('صفحة ${currentPage + 1} من $totalPages', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
                child: const Text('التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFilterChip(String label, String value, Color color) {
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

  DataRow buildDataRow(Map<String, dynamic> sub) {
    Color statusColor;
    String statusText;

    switch (sub['status']) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'نشط';
        break;
      case 'expired':
        statusColor = Colors.red;
        statusText = 'منتهي';
        break;
      case 'frozen':
        statusColor = Colors.orange;
        statusText = 'مجمد';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير معروف';
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
            tooltip: 'تعديل',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            tooltip: 'تجديد الاشتراك',
            onPressed: () {
              renewSubscription(sub);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'إلغاء',
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

    if (type == 'شهري') {
      final newEnd = DateTime(now.year, now.month + 1, now.day);
      subscription['startDate'] = dateFormat.format(now);
      subscription['endDate'] = dateFormat.format(newEnd);
    } else if (type == 'سنوي') {
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
}
