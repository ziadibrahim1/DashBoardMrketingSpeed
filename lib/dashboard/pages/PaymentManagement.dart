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

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // ألوان خضراء للوضع الداكن
      return {
        'primary': const Color(0xFF1B5E20),           // أخضر داكن جداً
        'secondary': const Color(0xFF2E7D32),         // أخضر داكن
        'accent': const Color(0xFF4CAF50),           // أخضر متوسط
        'light': const Color(0xFF81C784),           // أخضر فاتح
        'background': const Color(0xFF121212),      // خلفية داكنة
        'card': const Color(0xFF1E1E1E),           // كارت داكن
        'surface': const Color(0xFF2D2D2D),        // سطح داكن
        'text': const Color(0xFFE0E0E0),          // نص فاتح
        'textSecondary': const Color(0xFFB0B0B0), // نص ثانوي
        'gradientStart': const Color(0xFF1B5E20), // تدرج بداية
        'gradientEnd': const Color(0xFF2E7D32),   // تدرج نهاية
        'success': const Color(0xFF4CAF50),       // نجاح
        'warning': Colors.orange,                // تحذير
        'error': Colors.redAccent,               // خطأ
      };
    } else {
      // ألوان زرقاء للوضع الفاتح
      return {
        'primary': const Color(0xFF1E293B),           // أزرق داكن
        'secondary': const Color(0xFF334155),         // أزرق داكن متوسط
        'accent': const Color(0xFF3B82F6),           // أزرق فاتح
        'light': const Color(0xFF60A5FA),          // أزرق فاتح جداً
        'background': const Color(0xFFF5F7FA),     // خلفية فاتحة
        'card': Colors.white,                     // كارت أبيض
        'surface': Colors.white,                  // سطح أبيض
        'text': const Color(0xFF1E293B),          // نص داكن
        'textSecondary': const Color(0xFF64748B), // نص ثانوي
        'gradientStart': const Color(0xFF4FB5F5), // تدرج بداية
        'gradientEnd': const Color(0xFF1B367A),   // تدرج نهاية
        'success': Colors.green,                 // نجاح
        'warning': Colors.orange,                // تحذير
        'error': Colors.redAccent,               // خطأ
      };
    }
  }

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
    final colors = _getColors(context);

    return Scaffold(
      backgroundColor: colors['background'],
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
                      colors: [colors['gradientStart']!, colors['gradientEnd']!],
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
                                isArabic ? 'إدارة الدفع' : 'Payment Management',
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

                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white30.withOpacity(0.8),
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

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return {
        'primary': const Color(0xFF1B5E20),
        'secondary': const Color(0xFF2E7D32),
        'accent': const Color(0xFF4CAF50),
        'background': const Color(0xFF121212),
        'card': const Color(0xFF1E1E1E),
        'surface': const Color(0xFF2D2D2D),
        'text': const Color(0xFFE0E0E0),
        'textSecondary': const Color(0xFFB0B0B0),
        'success': const Color(0xFF4CAF50),
        'warning': Colors.orange,
        'error': Colors.redAccent,
      };
    } else {
      return {
        'primary': const Color(0xFF1E293B),
        'secondary': const Color(0xFF334155),
        'accent': const Color(0xFF3B82F6),
        'background': const Color(0xFFF5F7FA),
        'card': Colors.white,
        'surface': Colors.white,
        'text': const Color(0xFF1E293B),
        'textSecondary': const Color(0xFF64748B),
        'success': Colors.green,
        'warning': Colors.orange,
        'error': Colors.redAccent,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final vm = context.watch<PaymentViewModel>();
    final colors = _getColors(context);

    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors['card'],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: CircularProgressIndicator(color: colors['accent']),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: colors['textSecondary'],
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
            color: colors['card'],
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
                  color: colors['error']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 48, color: colors['error']),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors['text'],
                ),
              ),
              const SizedBox(height: 8),
              Text(vm.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors['textSecondary']),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => vm.loadPayments(refresh: true),
                icon: Icon(Icons.refresh, color: colors['card']),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['accent'],
                  foregroundColor: colors['card'],
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
              color: colors['card'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colors['surface']!.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors['background'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: vm.updateSearchQuery,
                      style: TextStyle(color: colors['text']),
                      decoration: InputDecoration(
                        hintText: isArabic ? 'ابحث باسم العميل...' : 'Search by client name...',
                        hintStyle: TextStyle(color: colors['textSecondary']),
                        prefixIcon: Icon(Icons.search, color: colors['accent']),
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
                              Icon(Icons.check_circle, color: colors['card']),
                              const SizedBox(width: 12),
                              Text(isArabic ? 'تم حفظ ملف CSV بنجاح' : 'CSV file saved successfully'),
                            ],
                          ),
                          backgroundColor: colors['success'],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.download_rounded, color: colors['card']),
                  label: Text(isArabic ? 'تصدير CSV' : 'Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors['success'],
                    foregroundColor: colors['card'],
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
              color: colors['card'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colors['surface']!.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors['surface']!.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: colors['accent']),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'عمليات الدفع' : 'Payment Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors['text'],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors['accent']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${vm.payments.length} ${isArabic ? 'عملية' : 'transactions'}',
                          style: TextStyle(
                            color: colors['accent'],
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
                    color: colors['surface']!.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final payment = vm.payments[index];
                    return _PaymentRow(payment: payment, isArabic: isArabic, colors: colors);
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
              color: colors['card'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colors['surface']!.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? 'صفحة ${vm.currentPage} من ${vm.totalPages}'
                      : 'Page ${vm.currentPage} of ${vm.totalPages}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors['text'],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: vm.currentPage > 1 ? () => vm.previousPage() : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage > 1
                            ? colors['accent']!.withOpacity(0.1)
                            : colors['surface']!.withOpacity(0.1),
                        foregroundColor: vm.currentPage > 1 ? colors['accent'] : colors['textSecondary'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage < vm.totalPages
                            ? colors['accent']!.withOpacity(0.1)
                            : colors['surface']!.withOpacity(0.1),
                        foregroundColor: vm.currentPage < vm.totalPages ? colors['accent'] : colors['textSecondary'],
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
  final Map<String, Color> colors;

  const _PaymentRow({
    required this.payment,
    required this.isArabic,
    required this.colors,
  });

  Color _getStatusColor() {
    if (payment.status == 'تم' || payment.status == 'completed') {
      return colors['success']!;
    } else if (payment.status == 'معلق' || payment.status == 'pending') {
      return colors['warning']!;
    }
    return colors['error']!;
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
                  colors['accent']!.withOpacity(0.2),
                  colors['secondary']!.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                payment.username.isNotEmpty ? payment.username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors['accent'],
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors['text'],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 14,
                      color: colors['textSecondary'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.plan,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors['textSecondary'],
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
                color: colors['accent']!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${payment.amount.toStringAsFixed(2)} ${isArabic ? "ر.س" : "SAR"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors['accent'],
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
              color: colors['surface']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getMethodIcon(),
                    size: 16,
                    color: colors['textSecondary']
                ),
                const SizedBox(width: 6),
                Text(
                  payment.method,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors['text'],
                  ),
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
                    color: colors['textSecondary'],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(payment.date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors['text'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(payment.date),
                style: TextStyle(
                  fontSize: 12,
                  color: colors['textSecondary'],
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

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return {
        'primary': const Color(0xFF1B5E20),
        'secondary': const Color(0xFF2E7D32),
        'accent': const Color(0xFF4CAF50),
        'background': const Color(0xFF121212),
        'card': const Color(0xFF1E1E1E),
        'surface': const Color(0xFF2D2D2D),
        'text': const Color(0xFFE0E0E0),
        'textSecondary': const Color(0xFFB0B0B0),
        'success': const Color(0xFF4CAF50),
        'warning': Colors.orange,
        'error': Colors.redAccent,
      };
    } else {
      return {
        'primary': const Color(0xFF1E293B),
        'secondary': const Color(0xFF334155),
        'accent': const Color(0xFF3B82F6),
        'background': const Color(0xFFF5F7FA),
        'card': Colors.white,
        'surface': Colors.white,
        'text': const Color(0xFF1E293B),
        'textSecondary': const Color(0xFF64748B),
        'success': Colors.green,
        'warning': Colors.orange,
        'error': Colors.redAccent,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final vm = context.watch<CustomerSubscriptionViewModel>();
    final colors = _getColors(context);

    final statusOptions = isArabic ? ['الكل', 'نشط', 'منتهي'] : ['All', 'Active', 'Expired'];

    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors['card'],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: CircularProgressIndicator(color: colors['accent']),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: colors['textSecondary'],
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
            color: colors['card'],
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
                  color: colors['error']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 48, color: colors['error']),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors['text'],
                ),
              ),
              const SizedBox(height: 8),
              Text(vm.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors['textSecondary']),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => vm.loadSubscriptions(refresh: true),
                icon: Icon(Icons.refresh, color: colors['card']),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['accent'],
                  foregroundColor: colors['card'],
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
              color: colors['card'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colors['surface']!.withOpacity(0.1),
                width: 1,
              ),
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
                      color: colors['background'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: TextStyle(color: colors['text']),
                      decoration: InputDecoration(
                        hintText: isArabic ? 'ابحث عن عميل...' : 'Search for client...',
                        hintStyle: TextStyle(color: colors['textSecondary']),
                        prefixIcon: Icon(Icons.search, color: colors['accent']),
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
                    color: colors['background'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, color: colors['accent'], size: 14),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'الحالة:' : 'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors['text'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: statusOptions.contains(vm.statusFilter)
                            ? vm.statusFilter
                            : statusOptions[0],
                        items: statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(color: colors['text']),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) vm.updateStatusFilter(value);
                        },
                        underline: const SizedBox(),
                        dropdownColor: colors['card'],
                      ),
                    ],
                  ),
                ),

                // Sort Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.7),
                  decoration: BoxDecoration(
                    color: colors['accent']!.withOpacity(0.1),
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
                              color: colors['accent'],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'تاريخ الانتهاء' : 'End Date',
                              style: TextStyle(
                                color: colors['accent'],
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
                color: colors['card'],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors['surface']!.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: colors['textSecondary'],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'لا يوجد نتائج' : 'No results',
                      style: TextStyle(
                        fontSize: 18,
                        color: colors['textSecondary'],
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
                  color: colors['card'],
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
                        ? colors['success']!.withOpacity(0.3)
                        : colors['surface']!.withOpacity(0.1),
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
                                ? [colors['success']!, colors['success']!.withOpacity(0.8)]
                                : [colors['error']!, colors['error']!.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (sub.isActive && !isExpired
                                  ? colors['success']!
                                  : colors['error']!)
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colors['text'],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (sub.isActive && !isExpired
                                        ? colors['success']!
                                        : colors['error']!)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (sub.isActive && !isExpired
                                          ? colors['success']!
                                          : colors['error']!)
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
                                              ? colors['success']!
                                              : colors['error']!,
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
                                              ? colors['success']!
                                              : colors['error']!,
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
                                  color: colors['textSecondary'],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  sub.packageName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors['textSecondary'],
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: colors['textSecondary'],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${isArabic ? 'ينتهي في' : 'Ends'} ${DateFormat('yyyy-MM-dd').format(sub.endDate)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors['textSecondary'],
                                  ),
                                ),
                                if (!isExpired && daysLeft <= 7) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colors['warning']!.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$daysLeft ${isArabic ? 'أيام متبقية' : 'days left'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors['warning'],
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
              color: colors['card'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colors['surface']!.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic
                      ? 'صفحة ${vm.currentPage} من ${vm.totalPages}'
                      : 'Page ${vm.currentPage} of ${vm.totalPages}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors['text'],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: vm.currentPage > 1 ? () => vm.previousPage() : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage > 1
                            ? colors['accent']!.withOpacity(0.1)
                            : colors['surface']!.withOpacity(0.1),
                        foregroundColor: vm.currentPage > 1 ? colors['accent'] : colors['textSecondary'],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: vm.currentPage < vm.totalPages
                            ? colors['accent']!.withOpacity(0.1)
                            : colors['surface']!.withOpacity(0.1),
                        foregroundColor: vm.currentPage < vm.totalPages ? colors['accent'] : colors['textSecondary'],
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