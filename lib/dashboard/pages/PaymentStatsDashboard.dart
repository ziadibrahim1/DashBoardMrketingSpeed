import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PaymentStatsDashboard(),
  ));
}

class PaymentStatsDashboard extends StatefulWidget {
  const PaymentStatsDashboard({super.key});

  @override
  State<PaymentStatsDashboard> createState() => _PaymentStatsDashboardState();
}

class _PaymentStatsDashboardState extends State<PaymentStatsDashboard> {
  late Stream<Map<String, double>> _statsStream;
  Map<String, double> _previous = {};

  String _selectedPeriod = 'شهري';
  final List<String> _periodOptions = ['يومي', 'أسبوعي', 'شهري', 'سنوي'];

  final Map<String, String> localizedTitles = {
    'revenue': 'إجمالي الإيرادات',
    'success': 'عدد العمليات الناجحة',
    'activeSubs': 'عدد الاشتراكات النشطة',
    'failures': 'المحاولات الفاشلة',
  };

  @override
  void initState() {
    super.initState();
    _generateStream();
  }

  void _generateStream() {
    _statsStream = Stream.periodic(const Duration(seconds: 4), (_) {
      final rand = Random();
      double baseMultiplier;

      switch (_selectedPeriod) {
        case 'يومي':
          baseMultiplier = 1;
          break;
        case 'أسبوعي':
          baseMultiplier = 7;
          break;
        case 'شهري':
          baseMultiplier = 30;
          break;
        case 'سنوي':
          baseMultiplier = 365;
          break;
        default:
          baseMultiplier = 30;
      }

      return {
        localizedTitles['revenue']!: 200 * baseMultiplier + rand.nextInt(1000),
        localizedTitles['success']!: 25 * baseMultiplier + rand.nextInt(50),
        localizedTitles['activeSubs']!: 8 * baseMultiplier + rand.nextInt(20),
        localizedTitles['failures']!: rand.nextInt(5) * baseMultiplier / 10,
      };
    }).asBroadcastStream();
  }

  String formatValue(String title, double value) {
    if (title.contains('إيرادات')) {
      return '${value.toStringAsFixed(0)} ر.س';
    } else {
      return value.round().toString();
    }
  }

  double computeChange(String key, double current) {
    final prev = _previous[key];
    if (prev == null || prev == 0) return 0;
    return ((current - prev) / (prev == 0 ? 1 : prev)) * 100;
  }

  void _openDetailDialog(String title, double value) {
    // بيانات عشوائية للرسم البياني لتفاصيل هذا العنوان (7 أيام)
    final data = List.generate(7, (index) {
      return DataPoint(DateTime.now().subtract(Duration(days: 6 - index)), (value * (0.8 + Random().nextDouble() * 0.4)));
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل $title'),
        content: SizedBox(
          height: 240,
          width: double.maxFinite,
          child: BarChartWidget(data: data),
        ),
        actions: [
          TextButton(
            child: const Text('إغلاق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String title) {
    if (title.contains('إيرادات')) return Icons.attach_money;
    if (title.contains('ناجحة')) return Icons.check_circle;
    if (title.contains('نشطة')) return Icons.person_search;
    if (title.contains('فاشلة')) return Icons.error_outline;
    return Icons.bar_chart;
  }

  Color _startGradientFor(String title) {
    if (title.contains('إيرادات')) return Colors.green.shade400;
    if (title.contains('ناجحة')) return Colors.blue.shade400;
    if (title.contains('نشطة')) return Colors.purple.shade400;
    if (title.contains('فاشلة')) return Colors.red.shade400;
    return Colors.indigo.shade400;
  }

  Color _endGradientFor(String title) {
    if (title.contains('إيرادات')) return Colors.green.shade700;
    if (title.contains('ناجحة')) return Colors.blue.shade700;
    if (title.contains('نشطة')) return Colors.purple.shade700;
    if (title.contains('فاشلة')) return Colors.red.shade700;
    return Colors.indigo.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: _periodOptions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedPeriod = v;
                        _generateStream();
                      });
                    }
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'تحديث البيانات',
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _generateStream();
                        });
                      },
                    ),
                  
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StreamBuilder<Map<String, double>>(
                stream: _statsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, __) => _buildSkeletonCard(),
                    );
                  }

                  final data = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _previous = Map.from(data);
                  });

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 3,
                    children: data.entries.map((entry) {
                      final title = entry.key;
                      final raw = entry.value;
                      final formatted = formatValue(title, raw);
                      final change = computeChange(title, raw);

                      return GestureDetector(
                        onTap: () => _openDetailDialog(title, raw),
                        child: _LiveStatCard(
                          title: title,
                          value: formatted,
                          changePercent: change,
                          icon: _iconFor(title),
                          startGradient: _startGradientFor(title),
                          endGradient: _endGradientFor(title),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120, color: Colors.grey),
                const SizedBox(height: 10),
                Container(height: 22, width: 100, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 20, height: 20, color: Colors.grey),
        ],
      ),
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double changePercent;
  final IconData icon;
  final Color startGradient;
  final Color endGradient;

  const _LiveStatCard({
  required this.title,
  required this.value,
  required this.changePercent,
  required this.icon,
  required this.startGradient,
  required this.endGradient,
  super.key,
});

@override
Widget build(BuildContext context) {
  final positive = changePercent > 0;
  final neutral = changePercent.abs() < 0.5;
  final bgColor = positive
      ? Colors.green.shade50
      : (neutral ? Colors.grey.shade200 : Colors.red.shade50);
  final textColor = positive
      ? Colors.green.shade800
      : (neutral ? Colors.grey.shade800 : Colors.red.shade800);
  final iconChange = positive
      ? Icons.arrow_upward
      : (neutral ? Icons.remove : Icons.arrow_downward);

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startGradient.withOpacity(0.15), endGradient.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [startGradient, endGradient]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: endGradient.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(colors: [startGradient, endGradient])
                                .createShader(const Rect.fromLTWH(0, 0, 120, 0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconChange, size: 14, color: textColor),
                          const SizedBox(width: 4),
                          Text(
                            '${changePercent.abs().toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    ),
  );
}
}

class DataPoint {
  final DateTime time;
  final double value;

  DataPoint(this.time, this.value);
}

class BarChartWidget extends StatelessWidget {
  final List<DataPoint> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.value).reduce(max) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[group.x.toInt()].time;
              final formattedDate = DateFormat('dd MMM', 'ar').format(date);
              return BarTooltipItem(
                '$formattedDate\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxY / 5,
              getTitlesWidget: (val, meta) {
                return Text(val.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                final date = data[index].time;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('dd MMM', 'ar').format(date)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          int idx = entry.key;
          double val = entry.value.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: val,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
