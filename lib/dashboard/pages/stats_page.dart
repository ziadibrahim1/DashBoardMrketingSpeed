import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OurGroupsManagementScreen.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<GroupRequest> groupRequests = [
    GroupRequest(
      name: 'جروب واتساب التسويق العقاري - السعودية',
      link: 'https://chat.whatsapp.com/example123',
      isApproved: false,
    ),
    GroupRequest(
      name: 'جروب تليجرام التسويق الرقمي - مصر',
      link: 'https://t.me/example456',
      isApproved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // كروت الواتساب والجروبات
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'واتساب',
                    icon: FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                    onTap: () {
                      // وظيفة فتح صفحة واتساب
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DashboardCard(
                    title: 'جروباتنا',
                    icon: Icons.groups,
                    color: primaryColor,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const OurGroupsManagementScreen(),
                      ));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // بطاقات الإحصائيات
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildStatCard("رسائل الجروبات", 3280, primaryColor, cardColor),
                _buildStatCard("رسائل الدردشات", 1850, primaryColor, cardColor),
                _buildStatCard("رسائل الأعضاء", 920, primaryColor, cardColor),
                _buildStatCard("جروباتنا الخاصة", 36, primaryColor, cardColor),
              ],
            ),
            const SizedBox(height: 40),

            // الرسوم البيانية
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildBarChart(cardColor)),
                const SizedBox(width: 24),
                Expanded(child: _buildPieChart(cardColor)),
              ],
            ),
            const SizedBox(height: 40),

            // جدول طلبات الجروبات مع تحسين التصميم
            _buildGroupRequestsTable(cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color primary, Color cardColor) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              )),
          const SizedBox(height: 20),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color cardColor) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 500,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
                  return Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 14));
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
                width: 24,
                borderRadius: BorderRadius.circular(8),
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
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 6,
          centerSpaceRadius: 48,
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: 'السعودية', radius: 80),
            PieChartSectionData(value: 30, color: Colors.orange, title: 'مصر', radius: 70),
            PieChartSectionData(value: 20, color: Colors.green, title: 'الإمارات', radius: 60),
            PieChartSectionData(value: 10, color: Colors.purple, title: 'أخرى', radius: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupRequestsTable(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "طلبات إضافة الجروبات",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.7),
          ),
          const Divider(height: 36, thickness: 2),
          SizedBox(
            height: 300,
            child: ListView.separated(
              itemCount: groupRequests.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final request = groupRequests[index];
                return _buildRequestRow(request);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRequestRow(GroupRequest request) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        request.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                request.link,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  decoration: TextDecoration.underline,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            // زر نسخ الرابط
            Tooltip(
              message: 'نسخ الرابط',
              child: IconButton(
                icon: const Icon(Icons.copy, size: 22),
                color: Colors.grey.shade700,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: request.link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ الرابط إلى الحافظة')),
                  );
                },
              ),
            ),

            // زر فتح الرابط
            Tooltip(
              message: 'فتح الرابط',
              child: IconButton(
                icon: const Icon(Icons.open_in_new, size: 22),
                color: Colors.blue.shade700,
                onPressed: () async {
                  final url = Uri.parse(request.link);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تعذر فتح الرابط')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      trailing: request.isApproved
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 22),
            SizedBox(width: 8),
            Text(
              "تمت الموافقة",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          : ElevatedButton.icon(
        onPressed: () {
          setState(() {
            request.isApproved = true;
          });
        },
        icon: const Icon(Icons.check, size: 20),
        label: const Text("موافقة"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GroupRequest {
  final String name;
  final String link;
  bool isApproved;

  GroupRequest({
    required this.name,
    required this.link,
    this.isApproved = false,
  });
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
