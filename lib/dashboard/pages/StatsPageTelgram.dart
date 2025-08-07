import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'OurChannelsManagementScreen.dart';
import 'OurGroupsManagementScreen.dart'; // يمكنك إعادة تسميتها لاحقًا

class StatsPageTele extends StatefulWidget {
  const StatsPageTele({super.key});

  @override
  State<StatsPageTele> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPageTele> {
  String selectedPlatform = 'Telegram';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 الكروت العلوية: تليجرام + قنواتنا
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'تليجرام',
                      icon: FontAwesomeIcons.telegram,
                      color: Colors.blue,
                      onTap: () {
                        // فتح صفحة تليجرام
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardCard(
                      title: 'قنواتنا',
                      icon: Icons.campaign,
                      color: primaryColor,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const OurChannelsManagementScreen(),
                        ));
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🔷 بطاقات الإحصائيات الرئيسية
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard("رسائل القنوات", 3280, primaryColor, cardColor),
                  _buildStatCard("رسائل الدردشات", 1850, primaryColor, cardColor),
                  _buildStatCard("رسائل الأعضاء", 920, primaryColor, cardColor),
                  _buildStatCard("قنواتنا الخاصة", 36, primaryColor, cardColor),
                ],
              ),

              const SizedBox(height: 24),

              // 🔷 الرسوم البيانية
              Row(
                children: [
                  Expanded(child: _buildBarChart(cardColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPieChart(cardColor)),
                ],
              ),

              const SizedBox(height: 24),

              // 🔷 طلبات القنوات المضافة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("طلبات إضافة القنوات",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    SizedBox(
                      height: 200, // ارتفاع محدد للقائمة لتجنب overflow
                      child: ListView(
                        children: [
                          _buildRequestRow("رابط قناة تليجرام - التسويق العقاري - السعودية", true),
                          _buildRequestRow("رابط قناة تليجرام - التسويق الرقمي - مصر", false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color primary, Color cardColor) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color cardColor) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 500,
                getTitlesWidget: (value, _) =>
                    Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
                  return Text(days[value.toInt() % 7],
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            final value = (i + 1) * 500;
            final color = value > 3000
                ? Colors.green
                : value > 2000
                ? Colors.orange
                : Colors.red;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                color: color,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              )
            ]);
          }),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildPieChart(Color cardColor) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: 'السعودية'),
            PieChartSectionData(value: 30, color: Colors.orange, title: 'مصر'),
            PieChartSectionData(value: 20, color: Colors.green, title: 'الإمارات'),
            PieChartSectionData(value: 10, color: Colors.purple, title: 'أخرى'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRow(String groupName, bool isApproved) {
    return ListTile(
      title: Text(groupName),
      trailing: isApproved
          ? const Text("تمت الموافقة ✅", style: TextStyle(color: Colors.green))
          : ElevatedButton.icon(
        onPressed: () {
          // تنفيذ عملية الموافقة
        },
        icon: const Icon(Icons.check),
        label: const Text("موافقة"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
  super.key,
  required this.title,
  required this.icon,
  required this.color,
  required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
