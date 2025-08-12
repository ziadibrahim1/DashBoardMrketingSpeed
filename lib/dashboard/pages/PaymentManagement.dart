import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
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

  final List<Tab> tabsAR = const [
    Tab(text: 'لوحة الإحصائيات'),
    Tab(text: 'سجل المدفوعات'),
    Tab(text: 'مدفوعات العملاء'),
    Tab(text: 'بوابات الدفع'),
  ];
  final List<Tab> tabsEN = const [
    Tab(text: 'Stats Dashboard'),
    Tab(text: 'Payment History'),
    Tab(text: 'Customer Payments'),
    Tab(text: 'Payment Gateways'),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabsAR.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;


    return Scaffold(
      backgroundColor:isDark?Colors.grey[900]: Colors.white,
      appBar: AppBar(
        elevation: 4,
        backgroundColor:isDark?Colors.grey[900]:Colors.blue.shade300,
        title:   Text(
          isArabic?'إدارة الدفع':'Payment Management',
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
              tabs:isArabic? tabsAR:tabsEN,
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

  PaymentViewModel(isArabic) {
    _generateInitialPayments(isArabic);
  }

  void _generateInitialPayments(bool isArabic) {

    _payments.addAll(List.generate(50, (i) {
      return Payment(
        username: isArabic ? 'مستخدم $i' : 'User $i',
        plan: i % 2 == 0
            ? (isArabic ? 'شهري' : 'Monthly')
            : (isArabic ? 'سنوي' : 'Yearly'),
        amount: 100 + i * 10,
        status: i % 2 == 0
            ? (isArabic ? 'تم' : 'Completed')
            : (isArabic ? 'معلق' : 'Pending'),
        method: isArabic ? 'بطاقة' : 'Card',
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel(isArabic),
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
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
                  hintText: isArabic ? 'ابحث باسم العميل' : 'Search by client name',
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
                  SnackBar(content: Text(isArabic ? 'تم حفظ ملف CSV' : 'CSV file saved')),
                );
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: Text(isArabic ? 'تصدير' : 'Export'),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.green : Colors.blue,
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
                  columns: [
                    DataColumn(label: Text(isArabic ? 'المستخدم' : 'User')),
                    DataColumn(label: Text(isArabic ? 'الباقة' : 'Plan')),
                    DataColumn(label: Text(isArabic ? 'المبلغ' : 'Amount')),
                    DataColumn(label: Text(isArabic ? 'الحالة' : 'Status')),
                    DataColumn(label: Text(isArabic ? 'الوسيلة' : 'Method')),
                    DataColumn(label: Text(isArabic ? 'التاريخ' : 'Date')),
                  ],
                  source: PaymentDataSource(payments),
                  header: Text(isArabic ? 'عمليات الدفع' : 'Payment Transactions'),
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
        ),
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

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تم تجديد اشتراك ${subscriptions[subscriptionIndex].name} لمدة 30 يوم.'
              : 'Subscription for ${subscriptions[subscriptionIndex].name} renewed for 30 days.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<CustomerSubscription> get filteredSubscriptions {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    List<CustomerSubscription> result = subscriptions;

    // بحث بالاسم
    if (searchQuery.isNotEmpty) {
      result = result.where((sub) => sub.name.contains(searchQuery)).toList();
    }

    // فلترة بالحالة
    if (statusFilter == (isArabic ? 'نشط' : 'Active')) {
      result = result.where((sub) => sub.isActive && sub.endDate.isAfter(DateTime.now())).toList();
    } else if (statusFilter == (isArabic ? 'منتهي' : 'Expired')) {
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;

    // تحضير خيارات الفلتر حسب اللغة
    final statusOptions = isArabic ? ['الكل', 'نشط', 'منتهي'] : ['All', 'Active', 'Expired'];

    // ضبط statusFilter إذا لم يتطابق مع الخيارات الجديدة (مثلاً بعد تغيير اللغة)
    if (!statusOptions.contains(statusFilter)) {
      statusFilter = statusOptions[0];
    }

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
                      labelText: isArabic ? 'ابحث عن عميل' : 'Search for client',
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
                Text(isArabic ? 'عرض الحالة:' : 'Status:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: statusFilter,
                  items: statusOptions.map((status) {
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
                Text(isArabic ? 'ترتيب حسب تاريخ الانتهاء:' : 'Sort by end date:'),
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
                  ? Center(child: Text(isArabic ? 'لا يوجد نتائج' : 'No results'))
                  : ListView.builder(
                itemCount: paginatedSubscriptions.length,
                itemBuilder: (context, index) {
                  final sub = paginatedSubscriptions[index];
                  final isExpired = sub.endDate.isBefore(DateTime.now());

                  return Card(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: isDark ? Colors.green.shade200 : Colors.blue.shade100,
                            child: Text(sub.name.characters.first),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.green.shade200 : Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? '${sub.packageName} - تنتهي في ${DateFormat('yyyy-MM-dd').format(sub.endDate)}'
                                      : '${sub.packageName} - Ends on ${DateFormat('yyyy-MM-dd').format(sub.endDate)}',
                                  style: TextStyle(
                                    color: isDark ? Colors.green.shade200 : Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  sub.isActive && !isExpired ? (isArabic ? 'نشط' : 'Active') : (isArabic ? 'منتهي' : 'Expired'),
                                  style: TextStyle(
                                    color: sub.isActive && !isExpired ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _renewSubscription(index),
                                child: Text(
                                  isArabic ? 'تجديد يدوي' : 'Manual Renew',
                                  style: TextStyle(color: isDark ? Colors.green : Colors.blue),
                                ),
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
                Text(isArabic
                    ? 'صفحة ${currentPage + 1} من ${(filteredSubscriptions.length / itemsPerPage).ceil()}'
                    : 'Page ${currentPage + 1} of ${(filteredSubscriptions.length / itemsPerPage).ceil()}'),
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

class GatewaysScreen extends StatelessWidget {
  const GatewaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(
            isArabic ? 'بوابة PayTabs' : 'PayTabs Gateway',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: isArabic ? 'معرف التاجر' : 'Merchant ID',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: isArabic ? 'مفتاح الخادم' : 'Server Key',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              isArabic ? 'حفظ الإعدادات' : 'Save Settings',
              style: const TextStyle(color: Colors.white),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.green : Colors.blue,
              foregroundColor: Colors.white, // لون النص والأيقونة
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
