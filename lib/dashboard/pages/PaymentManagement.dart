import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'PaymentStatsDashboard.dart';

enum UserRole { admin, manager, viewer }

class PaymentManagementSection extends StatefulWidget {
  const PaymentManagementSection({super.key});

  @override
  State<PaymentManagementSection> createState() =>
      _PaymentManagementSectionState();
}
class _PaymentManagementSectionState extends State<PaymentManagementSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserRole currentRole = UserRole.admin;

  final List<Tab> tabs = const [
    Tab(text: 'لوحة الإحصائيات'),
    Tab(text: 'سجل المدفوعات'),
    Tab(text: 'مدفوعات العملاء'),
    Tab(text: 'بوابات الدفع'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    void toggleTheme() {
      setState(() => isDark = !isDark);
    }
    Locale locale = const Locale('ar');
    void toggleLocale() {
      setState(() {
        locale = locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
      });
    }
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        title: const Text(
          'إدارة الدفع',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: theme.colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: tabs,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: Colors.amber.shade200),
                insets: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: TabBarView(
          controller: _tabController,
          children: [
          PaymentStatsDashboard(),
            const PaymentHistoryScreen(),
            const CustomerPaymentsScreen(),
            const GatewaysScreen(),
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'ابحث باسم العميل أو رقم العملية',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('تصدير'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('المستخدم')),
                  DataColumn(label: Text('الباقة')),
                  DataColumn(label: Text('المبلغ')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('الوسيلة')),
                  DataColumn(label: Text('التاريخ')),
                  DataColumn(label: Text('الإجراء')),
                ],
                rows: List.generate(5, (index) {
                  return DataRow(cells: [
                    const DataCell(Text('أحمد محمد')),
                    const DataCell(Text('باقة شهرية')),
                    const DataCell(Text('100 ر.س')),
                    DataCell(
                      Chip(
                        label: const Text('تم'),
                        backgroundColor: Colors.green.shade100,
                        labelStyle: const TextStyle(color: Colors.green),
                      ),
                    ),
                    const DataCell(Text('بطاقة')),
                    const DataCell(Text('2025-08-05')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {},
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() =>
      _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  final List<CustomerSubscription> subscriptions = [
    CustomerSubscription(
      name: 'محمد أحمد',
      packageName: 'باقة شهرية',
      endDate: DateTime(2025, 9, 1),
      isActive: true,
    ),
    CustomerSubscription(
      name: 'ليلى خالد',
      packageName: 'باقة سنوية',
      endDate: DateTime(2025, 12, 31),
      isActive: true,
    ),
    CustomerSubscription(
      name: 'عبدالله يوسف',
      packageName: 'باقة تجريبية',
      endDate: DateTime(2025, 7, 1),
      isActive: false,
    ),
    // أضف المزيد لاختبار الصفحات
  ];

  String searchQuery = '';
  int currentPage = 0;
  final int itemsPerPage = 5;
  String statusFilter = 'الكل';
  bool sortAscending = true; // true = تصاعدي، false = تنازلي
  void _renewSubscription(int index) {
    final realIndex = filteredSubscriptions.indexOf(paginatedSubscriptions[index]);
    final subscriptionIndex = subscriptions.indexOf(filteredSubscriptions[realIndex]);

    setState(() {
      subscriptions[subscriptionIndex] = subscriptions[subscriptionIndex].copyWith(
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تجديد اشتراك ${subscriptions[subscriptionIndex].name} لمدة 30 يوم.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<CustomerSubscription> get filteredSubscriptions {
    List<CustomerSubscription> result = subscriptions;

    // بحث بالاسم
    if (searchQuery.isNotEmpty) {
      result = result.where((sub) => sub.name.contains(searchQuery)).toList();
    }

    // فلترة بالحالة
    if (statusFilter == 'نشط') {
      result = result.where((sub) => sub.isActive && sub.endDate.isAfter(DateTime.now())).toList();
    } else if (statusFilter == 'منتهي') {
      result = result.where((sub) => !sub.isActive || sub.endDate.isBefore(DateTime.now())).toList();
    }

    // ترتيب حسب تاريخ الانتهاء
    result.sort((a, b) => sortAscending
        ? a.endDate.compareTo(b.endDate)
        : b.endDate.compareTo(a.endDate));

    return result;
  }



  List<CustomerSubscription> get paginatedSubscriptions {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredSubscriptions.sublist(
      startIndex,
      endIndex > filteredSubscriptions.length
          ? filteredSubscriptions.length
          : endIndex,
    );
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  void _goToNextPage() {
    final totalPages = (filteredSubscriptions.length / itemsPerPage).ceil();
    if (currentPage < totalPages - 1) {
      setState(() => currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اشتراكات العملاء',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // صف البحث والفلترة والفرز
            Row(
              children: [
                // بحث (يوسع تلقائيًا)
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'ابحث عن عميل',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        currentPage = 0;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // فلتر الحالة
                const Text('عرض الحالة: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: statusFilter,
                  items: ['الكل', 'نشط', 'منتهي'].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value!;
                      currentPage = 0;
                    });
                  },
                ),

                const SizedBox(width: 24),

                // زر الفرز حسب تاريخ الانتهاء
                const Text('ترتيب حسب تاريخ الانتهاء: '),
                IconButton(
                  icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      sortAscending = !sortAscending;
                      currentPage = 0;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // القائمة أو رسالة لا يوجد نتائج
            Expanded(
              child: paginatedSubscriptions.isEmpty
                  ? const Center(child: Text('لا يوجد نتائج'))
                  : ListView.builder(
                itemCount: paginatedSubscriptions.length,
                itemBuilder: (context, index) {
                  final sub = paginatedSubscriptions[index];
                  final isExpired = sub.endDate.isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: Text(sub.name.characters.first),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    '${sub.packageName} - تنتهي في ${DateFormat('yyyy-MM-dd').format(sub.endDate)}'),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  sub.isActive && !isExpired ? 'نشط' : 'منتهي',
                                  style: TextStyle(
                                    color: sub.isActive && !isExpired
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                backgroundColor: sub.isActive && !isExpired
                                    ? Colors.green[50]
                                    : Colors.red[50],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _renewSubscription(index),
                                child: const Text('تجديد يدوي'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // شريط التنقل بين الصفحات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('صفحة ${currentPage + 1} من ${(filteredSubscriptions.length / itemsPerPage).ceil()}'),
                Row(
                  children: [
                    IconButton(
                      onPressed: _goToPreviousPage,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      onPressed: _goToNextPage,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class CustomerSubscription {
  final String name;
  final String packageName;
  final DateTime endDate;
  final bool isActive;

  CustomerSubscription({
    required this.name,
    required this.packageName,
    required this.endDate,
    required this.isActive,
  });

  CustomerSubscription copyWith({
    String? name,
    String? packageName,
    DateTime? endDate,
    bool? isActive,
  }) {
    return CustomerSubscription(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}


class GatewaysScreen extends StatelessWidget {
  const GatewaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('بوابة PayTabs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Merchant ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Server Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text('حفظ الإعدادات'),
          ),
        ],
      ),
    );
  }
}
