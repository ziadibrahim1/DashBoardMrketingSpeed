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
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final vm = context.watch<PaymentStatsViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
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
                  icon: const Icon(Icons.refresh),
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
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

          // المحتوى الرئيسي
          Expanded(
            child: _buildContent(context, vm, isArabic, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentStatsViewModel vm, bool isArabic, bool isDark) {
    // حالة التحميل
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الإحصائيات...'),
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
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'حدث خطأ في تحميل الإحصائيات' : 'Error loading statistics',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(vm.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.loadStats(),
              icon: const Icon(Icons.refresh),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
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
            Icon(Icons.analytics_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'لا توجد بيانات حالياً\nاضغط على "تحديث" لجلب البيانات'
                  : 'No data available\nPress "Refresh" to load data',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
            color: Colors.green,
            isRevenue: true,
            isArabic: isArabic,
            isDark: isDark,
          ),
          StatCard(
            title: isArabic ? 'عدد العمليات' : 'Total Payments',
            value: vm.stats!.totalPayments.toDouble(),
            icon: Icons.check_circle_outline,
            color: Colors.blue,
            isRevenue: false,
            isArabic: isArabic,
            isDark: isDark,
          ),
          StatCard(
            title: isArabic ? 'الاشتراكات النشطة' : 'Active Subscriptions',
            value: vm.stats!.activeSubscriptions.toDouble(),
            icon: Icons.subscriptions,
            color: Colors.purple,
            isRevenue: false,
            isArabic: isArabic,
            isDark: isDark,
          ),
          StatCard(
            title: isArabic ? 'المدفوعات المعلقة' : 'Pending Payments',
            value: vm.stats!.pendingPayments.toDouble(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            isRevenue: false,
            isArabic: isArabic,
            isDark: isDark,
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
  final bool isDark;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isRevenue,
    required this.isArabic,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                Colors.green.shade700.withOpacity(.3),
                Colors.green.shade500.withOpacity(.3),
                const Color(0xFFB3A664).withOpacity(.3),
                Colors.green.shade600.withOpacity(.3),
                Colors.green[900]!.withOpacity(.3),
              ]
                  : [
                Colors.blue.shade700.withOpacity(.4),
                Colors.blue.shade500.withOpacity(.4),
                Colors.blue.shade300.withOpacity(.4),
                Colors.blue.shade600.withOpacity(.4),
                Colors.blue[900]!,
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

  const _StatDetailsSheet({
    required this.title,
    required this.currentValue,
    required this.isArabic,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isArabic ? 'تطور $title' : '$title Trend',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(child: _BarChart(data: data)),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'عرض بيانات لـ 6 أشهر' : 'Display data for 6 months',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<_MonthData> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.value).reduce(max) * 1.2;

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
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}