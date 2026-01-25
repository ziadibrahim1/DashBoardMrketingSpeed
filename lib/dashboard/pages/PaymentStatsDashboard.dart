import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../Models/Payment.dart';
import '../../providers/app_providers.dart';

class PaymentStatsDashboard extends StatelessWidget {
  const PaymentStatsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentStatsViewModel()..loadStats(),
      child: const PaymentStatsDashboardBody(),
    );
  }
}

class PaymentStatsDashboardBody extends StatelessWidget {
  const PaymentStatsDashboardBody({super.key});

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
        'success': const Color(0xFF4CAF50),       // نجاح
        'warning': Colors.orange,                // تحذير
        'error': Colors.redAccent,               // خطأ
        'greenLight': const Color(0xFF81C784),   // أخضر فاتح
        'greenDark': const Color(0xFF2E7D32),    // أخضر داكن
      };
    } else {
      // ألوان زرقاء للوضع الفاتح
      return {
        'primary': const Color(0xFF1E293B),           // أزرق داكن
        'secondary': const Color(0xFF334155),         // أزرق داكن متوسط
        'accent': const Color(0xFF3B82F6),           // أزرق فاتح
        'light': const Color(0xFF60A5FA),          // أزرق فاتح جداً
        'background': Colors.white,                // خلفية فاتحة
        'card': Colors.white,                     // كارت أبيض
        'surface': const Color(0xFFF5F7FA),       // سطح فاتح
        'text': const Color(0xFF1E293B),          // نص داكن
        'textSecondary': const Color(0xFF64748B), // نص ثانوي
        'success': Colors.green,                 // نجاح
        'warning': Colors.orange,                // تحذير
        'error': Colors.redAccent,               // خطأ
        'greenLight': Colors.green.shade300,     // أخضر فاتح
        'greenDark': Colors.green.shade700,      // أخضر داكن
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final vm = context.watch<PaymentStatsViewModel>();
    final colors = _getColors(context);

    return Scaffold(
      backgroundColor: colors['background'],
      body: Column(
        children: [
          // شريط التحكم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: isArabic ? 'تحديث البيانات' : 'Refresh Data',
                  icon: Icon(Icons.refresh, color: colors['text']),
                  onPressed: () => vm.loadStats(),
                ),
              ],
            ),
          ),

          // آخر تحديث
          if (vm.lastUpdate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                isArabic
                    ? 'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm').format(vm.lastUpdate!)}'
                    : 'Last Update: ${DateFormat('yyyy-MM-dd HH:mm').format(vm.lastUpdate!)}',
                style: TextStyle(color: colors['textSecondary'], fontSize: 12),
              ),
            ),

          // المحتوى الرئيسي
          Expanded(
            child: _buildContent(context, vm, isArabic, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentStatsViewModel vm, bool isArabic, Map<String, Color> colors) {
    // حالة التحميل
    if (vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors['accent']),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'جاري تحميل الإحصائيات...' : 'Loading statistics...',
              style: TextStyle(color: colors['text']),
            ),
          ],
        ),
      );
    }

    // حالة الخطأ
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: colors['error']),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'حدث خطأ في تحميل الإحصائيات' : 'Error loading statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors['text'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vm.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors['textSecondary']),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.loadStats(),
              icon: Icon(Icons.refresh, color: colors['card']),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['accent'],
                foregroundColor: colors['card'],
              ),
            ),
          ],
        ),
      );
    }

    // لا توجد بيانات
    if (vm.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 60,
              color: colors['textSecondary'],
            ),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'لا توجد بيانات حالياً\nاضغط على "تحديث" لجلب البيانات'
                  : 'No data available\nPress "Refresh" to load data',
              style: TextStyle(
                color: colors['textSecondary'],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // عرض البطاقات الإحصائية
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 3,
        children: [
          StatCard(
            title: isArabic ? 'إجمالي الإيرادات' : 'Total Revenue',
            value: vm.stats!.totalRevenue,
            icon: Icons.attach_money,
            color: colors['success']!,
            isRevenue: true,
            isArabic: isArabic,
            colors: colors,
          ),
          StatCard(
            title: isArabic ? 'عدد العمليات' : 'Total Payments',
            value: vm.stats!.totalPayments.toDouble(),
            icon: Icons.check_circle_outline,
            color: colors['accent']!,
            isRevenue: false,
            isArabic: isArabic,
            colors: colors,
          ),
          StatCard(
            title: isArabic ? 'الاشتراكات النشطة' : 'Active Subscriptions',
            value: vm.stats!.activeSubscriptions.toDouble(),
            icon: Icons.subscriptions,
            color: Colors.purple,
            isRevenue: false,
            isArabic: isArabic,
            colors: colors,
          ),
          StatCard(
            title: isArabic ? 'المدفوعات المعلقة' : 'Pending Payments',
            value: vm.stats!.pendingPayments.toDouble(),
            icon: Icons.pending_actions,
            color: colors['warning']!,
            isRevenue: false,
            isArabic: isArabic,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isRevenue;
  final bool isArabic;
  final Map<String, Color> colors;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isRevenue,
    required this.isArabic,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _StatDetailsSheet(
            title: title,
            currentValue: value,
            isArabic: isArabic,
            colors: colors,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                color.withOpacity(.3),
                color.withOpacity(.4),
                color.withOpacity(.5),
                color.withOpacity(.6),
                color.withOpacity(.7),
              ]
                  : [
                color.withOpacity(.2),
                color.withOpacity(.3),
                color.withOpacity(.4),
                color.withOpacity(.5),
                color.withOpacity(.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isRevenue
                    ? '${value.toStringAsFixed(2)} ${isArabic ? "ر.س" : "SAR"}'
                    : value.round().toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet لعرض التفاصيل
class _MonthData {
  final String month;
  final double value;
  _MonthData(this.month, this.value);
}

class _StatDetailsSheet extends StatelessWidget {
  final String title;
  final double currentValue;
  final bool isArabic;
  final Map<String, Color> colors;

  const _StatDetailsSheet({
    required this.title,
    required this.currentValue,
    required this.isArabic,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rand = Random();

    // بيانات تجريبية لـ 6 أشهر (يمكن استبدالها بـ API call)
    final data = List.generate(6, (index) {
      final monthDate = DateTime(now.year, now.month - (5 - index), 1);
      double val = currentValue * (0.7 + rand.nextDouble() * 0.6);
      return _MonthData(
        DateFormat('MMM', isArabic ? 'ar' : 'en').format(monthDate),
        val,
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      height: 350,
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isArabic ? 'تطور $title' : '$title Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors['text'],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(child: _BarChart(data: data, colors: colors)),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'عرض بيانات لـ 6 أشهر' : 'Display data for 6 months',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors['textSecondary'], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<_MonthData> data;
  final Map<String, Color> colors;

  const _BarChart({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.value).reduce(max) * 1.2;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].month,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors['text'],
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors['text'],
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final idx = entry.key;
          final val = entry.value.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: val,
                color: isDark ? colors['accent']! : Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colors['surface']!.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: colors['surface']!.withOpacity(0.5),
            width: 1,
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}