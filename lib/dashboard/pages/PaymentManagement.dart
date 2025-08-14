import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'PaymentStatsDashboard.dart';
Future<void> exportToCSVFile(List<Payment> payments) async {
  try {
    final rows = <List<String>>[
      ['الاسم', 'الباقة', 'المبلغ', 'الحالة', 'الوسيلة', 'التاريخ'],
      ...payments.map((p) => [
        p.username,
        p.plan,
        p.amount.toString(),
        p.status,
        p.method,
        p.date.toIso8601String(),
      ]),
    ];

    final csvContent = const ListToCsvConverter().convert(rows);
    final bytes = csvContent.codeUnits;

    final fileName = 'سجل_المدفوعات.csv';

    final res = await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes),
      ext: 'csv',
      mimeType: MimeType.csv,
    );

    debugPrint("تم حفظ الملف: $res");

  } catch (e) {
    debugPrint('خطأ أثناء التصدير: $e');
  }
}
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
      backgroundColor:isDark?Colors.grey[900]: Colors.white,
      appBar: AppBar(
        elevation: 4,
        backgroundColor:isDark?Colors.grey[900]:Colors.blue.shade300,
        title:   Text(
          'إدارة الدفع',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color:   Colors.white ,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: isDark?Colors.grey[900]:Colors.blue.shade50,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: tabs,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              labelColor:isDark?Colors.white: Colors.blue.shade700,
              unselectedLabelColor: isDark?Colors.grey[300]:Colors.blue.shade900,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: Colors.white),
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

class Payment {
  final String username;
  final String plan;
  final double amount;
  final String status;
  final String method;
  final DateTime date;

  Payment({
    required this.username,
    required this.plan,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });
}

class PaymentViewModel extends ChangeNotifier {
  final List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  PaymentViewModel() {
    _generateInitialPayments();
  }

  void _generateInitialPayments() {
    _payments.addAll(List.generate(50, (i) {
      return Payment(
        username: 'مستخدم $i',
        plan: i % 2 == 0 ? 'شهري' : 'سنوي',
        amount: 100 + i * 10,
        status: i % 2 == 0 ? 'تم' : 'معلق',
        method: 'بطاقة',
        date: DateTime.now().subtract(Duration(days: i)),
      );
    }));
  }

  List<Payment> get filteredPayments {
    if (_searchQuery.isEmpty) return _payments;
    return _payments
        .where((p) => p.username.contains(_searchQuery))
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> exportToCSV() async {
    final List<List<String>> rows = [
      ['الاسم', 'الباقة', 'المبلغ', 'الحالة', 'الوسيلة', 'التاريخ'],
      ...filteredPayments.map((p) => [
        p.username,
        p.plan,
        p.amount.toString(),
        p.status,
        p.method,
        p.date.toIso8601String(),
      ])
    ];
    final csv = const ListToCsvConverter().convert(rows);
    await Clipboard.setData(ClipboardData(text: csv));
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(),
      child: Scaffold(

        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: PaymentHistoryBody(),
          ),
        ),
      ),
    );
  }
}

class PaymentHistoryBody extends StatelessWidget {
  const PaymentHistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentViewModel>();
    final payments = vm.filteredPayments;
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط البحث والتصدير
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: vm.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم العميل',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () async {
                final vm = context.read<PaymentViewModel>();
                await exportToCSVFile(vm.filteredPayments);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ ملف CSV')),
                );
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('تصدير'),
              style: FilledButton.styleFrom(
                backgroundColor:isDark?Colors.green: Colors.blue,
                foregroundColor: Colors.white, // لون النص والأيقونة
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: isDark ? Colors.grey[900] : Colors.grey[50], // خلفية ناعمة للطرفين
                width: constraints.maxWidth,
                child: PaginatedDataTable(
                  columns: const [
                    DataColumn(label: Text('المستخدم')),
                    DataColumn(label: Text('الباقة')),
                    DataColumn(label: Text('المبلغ')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('الوسيلة')),
                    DataColumn(label: Text('التاريخ')),
                  ],
                  source: PaymentDataSource(payments),
                  header: const Text('عمليات الدفع'),
                  rowsPerPage: 10,
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  showCheckboxColumn: false,
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) => isDark ? Colors.grey[850] : Colors.grey[200],
                  ),
                ),
              ),
            );
          },
        )


        // جدول البيانات بكامل عرض الشاشة

      ],
    );
  }
}

class PaymentDataSource extends DataTableSource {
  final List<Payment> payments;

  PaymentDataSource(this.payments);

  @override
  DataRow getRow(int index) {
    if (index >= payments.length) return const DataRow(cells: []);
    final p = payments[index];
    return DataRow(cells: [
      DataCell(Text(p.username)),
      DataCell(Text(p.plan)),
      DataCell(Text('${p.amount} ر.س')),
      DataCell(
        Chip(
          label: Text(p.status),

          labelStyle: TextStyle(
            color: p.status == 'تم' ? Colors.green : Colors.blue,
          ),
        ),
      ),
      DataCell(Text(p.method)),
      DataCell(Text(p.date.toString().split(' ').first)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => payments.length;

  @override
  int get selectedRowCount => 0;
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
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // بحث (يوسع تلقائيًا)
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText:  'ابحث عن عميل' ,
                      prefixIcon: const Icon(Icons.search),
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
                    color: isDark?Colors.grey.shade800:Colors.white,

                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor:isDark?Colors.green.shade200:Colors.blue.shade100,
                            child: Text(sub.name.characters.first),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub.name,
                                    style:   TextStyle(fontWeight: FontWeight.bold,color:isDark?Colors.green.shade200:Colors.blue.shade900)),
                                const SizedBox(height: 4),
                                Text(
                                    '${sub.packageName} - تنتهي في ${DateFormat('yyyy-MM-dd').format(sub.endDate)}',style:TextStyle(color:isDark?Colors.green.shade200:Colors.blue.shade900)),
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

                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _renewSubscription(index),
                                child:  Text('تجديد يدوي',style:TextStyle(color:isDark?Colors.green:Colors.blue)),
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
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
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
          FilledButton.icon(

            onPressed: () {},
            icon:   Icon(Icons.save,color:Colors.white),
            label:   Text('حفظ الإعدادات',style:TextStyle(color: Colors.white)),
            style: FilledButton.styleFrom(
              backgroundColor:isDark?Colors.green: Colors.blue,
              foregroundColor: Colors.white, // لون النص والأيقونة
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
