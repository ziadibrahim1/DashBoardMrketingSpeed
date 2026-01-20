import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Models/Payment.dart';
import '../../providers/app_providers.dart';
import 'PaymentStatsDashboard.dart';


// ============= UI Components - REDESIGNED =============
class PaymentManagementSection extends StatefulWidget {
  const PaymentManagementSection({super.key});

  @override
  State<PaymentManagementSection> createState() => _PaymentManagementSectionState();
}

class _PaymentManagementSectionState extends State<PaymentManagementSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabsAR = const [
    Tab(icon: Icon(Icons.dashboard_outlined), text: 'لوحة الإحصائيات'),
    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'سجل المدفوعات'),
    Tab(icon: Icon(Icons.people_outline), text: 'مدفوعات العملاء'),
  ];

  final List<Tab> tabsEN = const [
    Tab(icon: Icon(Icons.dashboard_outlined), text: 'Stats Dashboard'),
    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Payment History'),
    Tab(icon: Icon(Icons.people_outline), text: 'Customer Payments'),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF5F7FA),
      body: Column(
        children: [

          /// ===== Elegant Header Card =====
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [
                        Color(0xFF1F2937),
                        Color(0xFF273449),
                      ]
                          : const [
                        Color(0xFF4FB5F5),
                        Color(0xFF1B367A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// ===== Header Row =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.payment_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'إدارة الدفع'
                                    : 'Payment Management',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ===== Glassmorphic Slim Tabs =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                tabs: isArabic ? tabsAR : tabsEN,

                                // ===== Slim & Glass =====
                                labelPadding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                indicatorPadding: EdgeInsets.zero,
                                indicatorSize: TabBarIndicatorSize.tab,

                                labelColor: isDark
                                    ?  Colors.white
                                    :  Colors.white,
                                unselectedLabelColor:
                                Colors.white30.withOpacity(0.8),
                                labelStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600),
                                unselectedLabelStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w500),

                                indicator: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ===== Content =====
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PaymentStatsDashboard(),
                PaymentHistoryScreen(),
                CustomerPaymentsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============= Payment History Screen - REDESIGNED =============
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentViewModel()..loadPayments(),
      child: const PaymentHistoryBody(),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2746) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2746) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(vm.error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => vm.loadPayments(refresh: true),
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Export Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2746) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: vm.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: isArabic ? 'ابحث باسم العميل...' : 'Search by client name...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF143E71)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await vm.exportToCSV();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(isArabic ? 'تم حفظ ملف CSV بنجاح' : 'CSV file saved successfully'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(isArabic ? 'تصدير CSV' : 'Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Modern Table
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2746) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2D3561).withOpacity(0.5)
                        : const Color(0xFFF5F7FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Color(0xFF143E71)),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'عمليات الدفع' : 'Payment Transactions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143E71).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${vm.payments.length} ${isArabic ? 'عملية' : 'transactions'}',
                          style: const TextStyle(
                            color: Color(0xFF143E71),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Body
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vm.payments.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final payment = vm.payments[index];
                    return _PaymentRow(payment: payment, isArabic: isArabic, isDark: isDark);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pagination
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2746) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? 'صفحة ${vm.currentPage} من ${vm.totalPages}'
                      : 'Page ${vm.currentPage} of ${vm.totalPages}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: vm.currentPage > 1 ? () => vm.previousPage() : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage > 1
                            ? const Color(0xFF143E71).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        foregroundColor: vm.currentPage > 1 ? const Color(0xFF143E71) : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage < vm.totalPages
                            ? const Color(0xFF143E71).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        foregroundColor: vm.currentPage < vm.totalPages ? const Color(0xFF143E71) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget للصف الواحد في الجدول
class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final bool isArabic;
  final bool isDark;

  const _PaymentRow({
    required this.payment,
    required this.isArabic,
    required this.isDark,
  });

  Color _getStatusColor() {
    if (payment.status == 'تم' || payment.status == 'completed') {
      return const Color(0xFF10B981);
    } else if (payment.status == 'معلق' || payment.status == 'pending') {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFFEF4444);
  }

  IconData _getMethodIcon() {
    if (payment.method.contains('بطاقة') || payment.method.toLowerCase().contains('card')) {
      return Icons.credit_card;
    } else if (payment.method.contains('تحويل') || payment.method.toLowerCase().contains('transfer')) {
      return Icons.account_balance;
    }
    return Icons.payment;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                payment.username.isNotEmpty ? payment.username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User & Plan Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.plan,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${payment.amount.toStringAsFixed(2)} ${isArabic ? "ر.س" : "SAR"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  payment.status,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Method
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getMethodIcon(), size: 16),
                const SizedBox(width: 6),
                Text(
                  payment.method,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(payment.date),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(payment.date),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============= Customer Payments Screen - REDESIGNED =============
class CustomerPaymentsScreen extends StatelessWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerSubscriptionViewModel()..loadSubscriptions(),
      child: const CustomerPaymentsBody(),
    );
  }
}

class CustomerPaymentsBody extends StatelessWidget {
  const CustomerPaymentsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final vm = context.watch<CustomerSubscriptionViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final statusOptions = isArabic ? ['الكل', 'نشط', 'منتهي'] : ['All', 'Active', 'Expired'];

    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2746) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2746) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(vm.error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => vm.loadSubscriptions(refresh: true),
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2746) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Search
                SizedBox(
                  width: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isArabic ? 'ابحث عن عميل...' : 'Search for client...',
                        prefixIcon: const Icon(Icons.search, color: Color(
                            0xFF235C88)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: vm.updateSearchQuery,
                    ),
                  ),
                ),

                // Status Filter
                Container(

                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.7),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xFF235C88), size: 14),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'الحالة:' : 'Status:',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: statusOptions.contains(vm.statusFilter)
                            ? vm.statusFilter
                            : statusOptions[0],
                        items: statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) vm.updateStatusFilter(value);
                        },
                        underline: const SizedBox(),
                      ),
                    ],
                  ),
                ),

                // Sort Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF235C88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: vm.toggleSortOrder,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              vm.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              color: const Color(0xFF235C88),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'تاريخ الانتهاء' : 'End Date',
                              style: const TextStyle(
                                color: Color(0xFF235C88),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Subscriptions List
          if (vm.subscriptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2746) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'لا يوجد نتائج' : 'No results',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...vm.subscriptions.map((sub) {
              final isExpired = sub.endDate.isBefore(DateTime.now());
              final daysLeft = sub.endDate.difference(DateTime.now()).inDays;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2746) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: (sub.isActive && !isExpired)
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: (sub.isActive && !isExpired)
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (sub.isActive && !isExpired
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            sub.name.isNotEmpty ? sub.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sub.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (sub.isActive && !isExpired
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444))
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (sub.isActive && !isExpired
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: sub.isActive && !isExpired
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        sub.isActive && !isExpired
                                            ? (isArabic ? 'نشط' : 'Active')
                                            : (isArabic ? 'منتهي' : 'Expired'),
                                        style: TextStyle(
                                          color: sub.isActive && !isExpired
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  size: 16,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  sub.packageName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${isArabic ? 'ينتهي في' : 'Ends'} ${DateFormat('yyyy-MM-dd').format(sub.endDate)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                                if (!isExpired && daysLeft <= 7) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$daysLeft ${isArabic ? 'أيام متبقية' : 'days left'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }).toList(),

          const SizedBox(height: 24),

          // Pagination
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2746) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? 'صفحة ${vm.currentPage} من ${vm.totalPages}'
                      : 'Page ${vm.currentPage} of ${vm.totalPages}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: vm.currentPage > 1 ? () => vm.previousPage() : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage > 1
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        foregroundColor: vm.currentPage > 1 ? const Color(0xFF6366F1) : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage < vm.totalPages
                            ? const Color(0xFF6366F1).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        foregroundColor: vm.currentPage < vm.totalPages ? const Color(0xFF6366F1) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}