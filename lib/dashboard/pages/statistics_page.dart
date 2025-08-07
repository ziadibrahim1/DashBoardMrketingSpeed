import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تدرج لوني للخلفية (فاتح أو داكن حسب الوضع)
    final cardGradient = isDark
        ? LinearGradient(
      colors: [Colors.grey.shade900, Colors.grey.shade800],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.white, Colors.grey.shade100],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // تظليل متدرج ومتعدد الطبقات للتميز
    final shadowList = [
      BoxShadow(
        color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.25),
        blurRadius: 12,
        offset: const Offset(4, 6),
      ),
      BoxShadow(
        color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.15),
        blurRadius: 6,
        offset: const Offset(-2, -2),
      ),
    ];

    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87);

    // بيانات إحصائيات وهمية (يمكن تغييرها للبيانات الحقيقية)
    const totalUsers = '2500';
    const totalAdmins = '15';
    const totalAnnualSubscribers = '120';
    const whatsappMessages = '8500';
    const telegramMessages = '3900';
    const totalGroups = '120';
    const totalChannels = '75';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // الصف الأول: المستخدمين، المشتركين، المسؤولين
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'عدد المستخدمين',
                  totalUsers,
                  Icons.people,
                  Color(0xFF65C4F8),
                  gradient: cardGradient,
                  shadows: shadowList,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'عدد المشتركين سنويًا',
                  totalAnnualSubscribers,
                  Icons.subscriptions,
                  Colors.deepOrange.shade700,
                  gradient: cardGradient,
                  shadows: shadowList,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'عدد المسؤولين',
                  totalAdmins,
                  Icons.admin_panel_settings,
                  Color(0xFF65C4F8),
                  gradient: cardGradient,
                  shadows: shadowList,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // الصف الثاني: عدد الرسائل (واتساب وتليجرام)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'عدد الرسائل المرسلة (واتساب)',
                  whatsappMessages,
                  Icons.message,
                  Colors.green.shade700,
                  gradient: cardGradient,
                  shadows: shadowList,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'عدد الرسائل المرسلة (تليجرام)',
                  telegramMessages,
                  Icons.message,
                  Color(0xFF65C4F8),
                  gradient: cardGradient,
                  shadows: shadowList,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // الصف الثالث: جروبات الواتساب وقنوات التليجرام جنب بعض
          Row(
            children: [
              Expanded(
                child: _build3DCard(
                  context,
                  title: 'عدد جروبات الواتساب',
                  width: double.infinity,
                  height: 120,
                  cardColor: null,
                  gradient: cardGradient,
                  shadows: shadowList,
                  titleStyle: titleStyle,
                  child: Center(
                    child: Text(
                      totalGroups,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.green.shade200.withOpacity(0.8),
                            blurRadius: 6,
                            offset: const Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _build3DCard(
                  context,
                  title: 'عدد قنوات التليجرام',
                  width: double.infinity,
                  height: 120,
                  cardColor: null,
                  gradient: cardGradient,
                  shadows: shadowList,
                  titleStyle: titleStyle,
                  child: Center(
                    child: Text(
                      totalChannels,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF65C4F8),
                        shadows: [
                          Shadow(
                            color: Colors.blue.shade200.withOpacity(0.8),
                            blurRadius: 6,
                            offset: const Offset(1, 1),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // باقي الكروت الكبيرة (Pie, Bar, Line Charts)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _build3DCard(
                  context,
                  title: 'نسب الاستخدام',
                  width: double.infinity,
                  height: 350,
                  child: _buildPieChart(context),
                  cardColor: null,
                  gradient: cardGradient,
                  shadows: shadowList,
                  titleStyle: titleStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _build3DCard(
                  context,
                  title: 'إحصائيات المنصات',
                  width: double.infinity,
                  height: 320,
                  child: _buildBarChart(),
                  cardColor: null,
                  gradient: cardGradient,
                  shadows: shadowList,
                  titleStyle: titleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _build3DCard(
            context,
            title: 'اشتراكات المستخدمين',
            width: double.infinity,
            height: 300,
            child: _buildLineChart(),
            cardColor: null,
            gradient: cardGradient,
            shadows: shadowList,
            titleStyle: titleStyle,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _build3DCard(
      BuildContext context, {
        required String title,
        required Widget child,
        required double width,
        required double height,
        Color? cardColor,
        Gradient? gradient,
        List<BoxShadow>? shadows,
        required TextStyle titleStyle,
      }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(6, 6),
              ),
            ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color, {
        Gradient? gradient,
        List<BoxShadow>? shadows,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(3, 4),
              ),
            ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              icon,
              color: color,
              size: 28,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Droid',
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Droid',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 5,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // باقي الرسمات كما هي بدون تعديل

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const platforms = [
                  'واتساب', 'تليجرام', 'حراج', 'فيسبوك',
                  'تيك توك', 'إنستقرام', 'إكس', 'SMS', 'البريد'
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    platforms[value.toInt() % platforms.length],
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: List.generate(9, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (5 + i).toDouble(),
                color: Color(0xFF65C4F8),
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final sections = [
      {'title': 'واتساب', 'value': 25.0, 'color': Colors.green},
      {'title': 'تليجرام', 'value': 20.0, 'color': Colors.blue},
      {'title': 'حراج', 'value': 10.0, 'color': Colors.orange},
      {'title': 'فيسبوك', 'value': 15.0, 'color': Colors.indigo},
      {'title': 'تيك توك', 'value': 10.0, 'color': Colors.deepPurple},
      {'title': 'إنستقرام', 'value': 10.0, 'color': Colors.pink},
      {'title': 'إكس', 'value': 5.0, 'color': Colors.black},
      {'title': 'SMS', 'value': 3.0, 'color': Colors.teal},
      {'title': 'البريد', 'value': 2.0, 'color': Colors.brown},
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections.map((e) {
              final percentage = e['value'] as double;
              final isSmall = percentage < 5;

              return PieChartSectionData(
                color: e['color'] as Color,
                value: percentage,
                title: isSmall ? '' : '${percentage.toInt()}%',
                radius: 70,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
                badgeWidget: isSmall
                    ? null
                    : Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    e['title'].toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                badgePositionPercentageOffset: 1.2,
              );
            }).toList(),
            sectionsSpace: 3,
            centerSpaceRadius: 40,
            startDegreeOffset: -90,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        // يمكن تعديل maxY حسب أعلى قيمة لديك مثلاً:
        maxY: 20,

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // عرض شهر لكل نقطة
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                const months = [
                  'يناير', 'فبراير', 'مارس', 'أبريل',
                  'مايو', 'يونيو', 'يوليو', 'أغسطس',
                  'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                ];

                // نعرض فقط إذا كانت قيمة صحيحة وضمن النطاق
                if (value % 1 == 0 && value >= 0 && value < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 5),
              FlSpot(1, 8),
              FlSpot(2, 6),
              FlSpot(3, 10),
              FlSpot(4, 12),
              FlSpot(5, 9),
              FlSpot(6, 14),
              FlSpot(7, 11),
              FlSpot(8, 13),
              FlSpot(9, 16),
              FlSpot(10, 14),
              FlSpot(11, 18),
            ],
            isCurved: true,
            color: Colors.blue.shade600,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.blue.shade800,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withOpacity(0.2),
                  Colors.transparent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),

    );
  }


}
