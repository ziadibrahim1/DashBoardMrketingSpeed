import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class PaymentStatsDashboard extends StatefulWidget {
  const PaymentStatsDashboard({super.key});

  @override
  State<PaymentStatsDashboard> createState() => _PaymentStatsDashboardState();
}

class _PaymentStatsDashboardState extends State<PaymentStatsDashboard> {
  Map<String, double> _stats = {};
  String _selectedPeriod = 'شهري';
  DateTime? _lastUpdate;

  final List<String> _periodOptionsAr = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];
  final List<String> _periodOptionsEn = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  final Map<String, Map<String, String>> localizedTitles = {
    'revenue': {'ar': 'إجمالي الإيرادات', 'en': 'Total Revenue'},
    'success': {'ar': 'عدد العمليات الناجحة', 'en': 'Successful Transactions'},
    'activeSubs': {'ar': 'عدد الاشتراكات النشطة', 'en': 'Active Subscriptions'},
    'failures': {'ar': 'المحاولات الفاشلة', 'en': 'Failed Attempts'},
  };

  final Map<String, double> _previousStats = {};

  void _refreshData() {
    final rand = Random();
    double multiplier;

    switch (_selectedPeriod) {
      case 'يومي':
      case 'Daily':
        multiplier = 1;
        break;
      case 'أسبوعي':
      case 'Weekly':
        multiplier = 7;
        break;
      case 'سنوي':
      case 'Yearly':
        multiplier = 365;
        break;
      default:
        multiplier = 30;
    }

    setState(() {
      _previousStats.clear();
      _previousStats.addAll(_stats);

      _stats = {
        localizedTitles['revenue']![isArabic ? 'ar' : 'en']!: 500 * multiplier + rand.nextInt(2000),
        localizedTitles['success']![isArabic ? 'ar' : 'en']!: 20 * multiplier + rand.nextInt(100),
        localizedTitles['activeSubs']![isArabic ? 'ar' : 'en']!: 10 * multiplier + rand.nextInt(50),
        localizedTitles['failures']![isArabic ? 'ar' : 'en']!: rand.nextInt(15) * multiplier / 10,
      };
      _lastUpdate = DateTime.now();
    });
  }

  double? computeChange(String key) {
    if (!_previousStats.containsKey(key) || !_stats.containsKey(key)) return null;
    final oldVal = _previousStats[key]!;
    final newVal = _stats[key]!;
    if (oldVal == 0) return null;
    return ((newVal - oldVal) / oldVal) * 100;
  }

  bool get isArabic {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;

    final periodOptions = isArabic ? _periodOptionsAr : _periodOptionsEn;
    if (!periodOptions.contains(_selectedPeriod)) {
      _selectedPeriod = periodOptions[2]; // 'شهري' أو 'Monthly'
    }
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: periodOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedPeriod = v);
                    }
                  },
                ),
                IconButton(
                  tooltip: isArabic ? 'تحديث البيانات' : 'Refresh Data',
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                ),
              ],
            ),
          ),
          if (_lastUpdate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                isArabic
                    ? 'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm').format(_lastUpdate!)}'
                    : 'Last Update: ${DateFormat('yyyy-MM-dd HH:mm').format(_lastUpdate!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _stats.isEmpty
                  ? Center(
                child: Text(
                  isArabic
                      ? 'لا توجد بيانات حالياً\nاضغط على "تحديث" لجلب البيانات'
                      : 'No data available\nPress "Refresh" to load data',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
                  : GridView.count(
                crossAxisCount:
                MediaQuery.of(context).size.width > 600 ? 2 : 1,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 3,
                children: _stats.entries.map((entry) {
                  final change = computeChange(entry.key);
                  return StatCard(
                    title: entry.key,
                    value: entry.value,
                    icon: _iconFor(entry.key),
                    color: _colorFor(entry.key),
                    changePercent: change,
                    subtitle: change == null
                        ? (isArabic
                        ? 'لا بيانات سابقة للمقارنة'
                        : 'No previous data for comparison')
                        : (change > 0
                        ? (isArabic
                        ? 'تحسن مقارنة بالفترة السابقة'
                        : 'Improved compared to previous period')
                        : (isArabic
                        ? 'تراجع مقارنة بالفترة السابقة'
                        : 'Declined compared to previous period')),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String title) {
    if (title.contains('إيرادات') || title.contains('Revenue')) {
      return Icons.attach_money;
    }
    if (title.contains('ناجحة') || title.contains('Successful')) {
      return Icons.check_circle_outline;
    }
    if (title.contains('نشطة') || title.contains('Active')) {
      return Icons.subscriptions;
    }
    if (title.contains('فاشلة') || title.contains('Failed')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.analytics;
  }

  Color _colorFor(String title) {
    if (title.contains('إيرادات') || title.contains('Revenue')) {
      return Colors.green;
    }
    if (title.contains('ناجحة') || title.contains('Successful')) {
      return Colors.blue;
    }
    if (title.contains('نشطة') || title.contains('Active')) {
      return Colors.purple;
    }
    if (title.contains('فاشلة') || title.contains('Failed')) {
      return Colors.red;
    }
    return Colors.teal;
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final double? changePercent;
  final String? subtitle;

  const StatCard({
  super.key,
  required this.title,
  required this.value,
  required this.icon,
  required this.color,
  this.changePercent,
  this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final bool isPositive = (changePercent ?? 0) >= 0;
    final bool hasChange = changePercent != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _StatDetailsSheet(title: title, currentValue: value),
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
              colors:isDark?[
                Colors.green.shade700.withOpacity(.3),
                Colors.green.shade500.withOpacity(.3),
                Color(0xFFB3A664).withOpacity(.3),
                Colors.green.shade600.withOpacity(.3),
                ?Colors.green[900]?.withOpacity(.3),
              ]: [
                Colors.blue.shade700.withOpacity(.4),
                Colors.blue.shade500.withOpacity(.4),
                Colors.blue.shade300.withOpacity(.4),
                Colors.blue.shade600.withOpacity(.4),
                ?Colors.blue[900],
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: LinearGradient(
                    colors:isDark?[
                      Colors.green.shade700.withOpacity(.3),
                      Colors.green.shade500.withOpacity(.3),
                      Color(0xFFB3A664).withOpacity(.3),
                      Colors.green.shade600.withOpacity(.3),
                      ?Colors.green[900]?.withOpacity(.3),
                    ]: [
                      Colors.blue.shade700.withOpacity(.4),
                      Colors.blue.shade500.withOpacity(.4),
                      Colors.blue.shade300.withOpacity(.4),
                      Colors.blue.shade600.withOpacity(.4),
                      ?Colors.blue[900],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).colors.last.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6))
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
                    child: Icon(icon, color:Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color:Colors.white),
                    ),
                  ),
                  if (hasChange)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${changePercent!.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title.contains(isArabic?'إيرادات':'Incomes')
                    ? '${value.toStringAsFixed(0)} ر.س'
                    : value.round().toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle( color:Colors.white, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthData {
  final String month;
  final double value;
  _MonthData(this.month, this.value);
}

class _StatDetailsSheet extends StatelessWidget {
  final String title;
  final double currentValue;

  const _StatDetailsSheet({required this.title, required this.currentValue, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rand = Random();
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final data = List.generate(6, (index) {
      final monthDate = DateTime(now.year, now.month - (5 - index), 1);
      double val = currentValue * (0.7 + rand.nextDouble() * 0.6);
      return _MonthData(DateFormat('MMM', 'ar').format(monthDate), val);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isArabic?'تطور $title':'Up $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Expanded(child: _BarChart(data: data)),
          Text(
            isArabic?'عرض بيانات لـ 6 أشهر':'Display data for 6 months ',
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
  const _BarChart({required this.data, Key? key}) : super(key: key);

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
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(data[index].month, style: const TextStyle(fontSize: 12)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final idx = entry.key;
          final val = entry.value.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(toY: val, color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
            ],
          );
        }).toList(),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }
}
