import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({super.key});

  // خريطة النصوص باللغتين
  static final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'number_of_users': 'Number of users',
      'annual_subscribers': 'Annual Subscribers',
      'total_admins': 'Number of Admins',
      'whatsapp_messages': 'WhatsApp Messages Sent',
      'telegram_messages': 'Telegram Messages Sent',
      'whatsapp_groups': 'WhatsApp Groups',
      'telegram_channels': 'Telegram Channels',
      'usage_percentages': 'Usage Percentages',
      'platform_stats': 'Platform Statistics',
      'user_subscriptions': 'User Subscriptions',
      'platforms': 'WhatsApp,Telegram,Haraj,Facebook,TikTok,Instagram,X,SMS,Email',
      'months': 'January,February,March,April,May,June,July,August,September,October,November,December',
    },
    'ar': {
      'number_of_users': 'عدد المستخدمين',
      'annual_subscribers': 'عدد المشتركين سنويًا',
      'total_admins': 'عدد المسؤولين',
      'whatsapp_messages': 'عدد الرسائل المرسلة (واتساب)',
      'telegram_messages': 'عدد الرسائل المرسلة (تليجرام)',
      'whatsapp_groups': 'عدد جروبات الواتساب',
      'telegram_channels': 'عدد قنوات التليجرام',
      'usage_percentages': 'نسب الاستخدام',
      'platform_stats': 'إحصائيات المنصات',
      'user_subscriptions': 'اشتراكات المستخدمين',
      'platforms': 'واتساب,تليجرام,حراج,فيسبوك,تيك توك,إنستقرام,إكس,SMS,البريد',
      'months': 'يناير,فبراير,مارس,أبريل,مايو,يونيو,يوليو,أغسطس,سبتمبر,أكتوبر,نوفمبر,ديسمبر',
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final langCode = isArabic ? 'ar' : 'en';
    final strings = localizedStrings[langCode]!;

    // تدرج لوني للخلفية (فاتح أو داكن حسب الوضع)
    final cardGradient = isDark
        ? LinearGradient(
      colors: [const Color(0xFF313D35), const Color(0xFF4D5D53)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : LinearGradient(
      colors: [Colors.white, Colors.white],
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

    final titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    // بيانات إحصائيات وهمية (يمكن تغييرها للبيانات الحقيقية)
    const totalUsers = '2500';
    const totalAdmins = '15';
    const totalAnnualSubscribers = '120';
    const whatsappMessages = '8500';
    const telegramMessages = '3900';
    const totalGroups = '120';
    const totalChannels = '75';

    // استخراج قائمة المنصات والشهور من النصوص
    final platformsList = strings['platforms']!.split(',');
    final monthsList = strings['months']!.split(',');

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصف الأول: المستخدمين، المشتركين، المسؤولين
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark,
                    context,
                    strings['number_of_users']!,
                    totalUsers,
                    Icons.people,
                    isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                    gradient: cardGradient,
                    shadows: shadowList,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    isDark,
                    context,
                    strings['annual_subscribers']!,
                    totalAnnualSubscribers,
                    Icons.subscriptions,
                    isDark ? const Color(0xFFD7EFDC) : Colors.deepOrange.shade700,
                    gradient: cardGradient,
                    shadows: shadowList,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    isDark,
                    context,
                    strings['total_admins']!,
                    totalAdmins,
                    Icons.admin_panel_settings,
                    isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
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
                    isDark,
                    context,
                    strings['whatsapp_messages']!,
                    whatsappMessages,
                    Icons.message,
                    isDark ? const Color(0xFFD7EFDC) : Colors.green.shade700,
                    gradient: cardGradient,
                    shadows: shadowList,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    isDark,
                    context,
                    strings['telegram_messages']!,
                    telegramMessages,
                    Icons.message,
                    isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
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
                    title: strings['whatsapp_groups']!,
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
                          color: isDark ? const Color(0xFFD7EFDC) : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _build3DCard(
                    context,
                    title: strings['telegram_channels']!,
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
                          color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
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
                    title: strings['usage_percentages']!,
                    width: double.infinity,
                    height: 350,
                    child: _buildPieChart(context, isDark),
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
                    title: strings['platform_stats']!,
                    width: double.infinity,
                    height: 320,
                    child: _buildBarChart(isDark, platformsList),
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
              title: strings['user_subscriptions']!,
              width: double.infinity,
              height: 300,
              child: _buildLineChart(isDark, monthsList),
              cardColor: null,
              gradient: cardGradient,
              shadows: shadowList,
              titleStyle: titleStyle,
            ),
            const SizedBox(height: 16),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFFD7EFDC) : cardColor,
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
      bool isDark,
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
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Droid',
                  fontSize: 14,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Droid',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark, List<String> platformsList) {
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
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    platformsList[value.toInt() % platformsList.length],
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
                color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final sections = [
      {
        'title': isArabic ? 'واتساب' : 'WhatsApp',
        'value': 25.0,
        'color': Colors.green,
      },
      {
        'title': isArabic ? 'تليجرام' : 'Telegram',
        'value': 20.0,
        'color': Colors.blue,
      },
      {
        'title': isArabic ? 'حراج' : 'Haraj',
        'value': 10.0,
        'color': Colors.orange,
      },
      {
        'title': isArabic ? 'فيسبوك' : 'Facebook',
        'value': 15.0,
        'color': Colors.indigo,
      },
      {
        'title': isArabic ? 'تيك توك' : 'TikTok',
        'value': 10.0,
        'color': Colors.deepPurple,
      },
      {
        'title': isArabic ? 'إنستقرام' : 'Instagram',
        'value': 10.0,
        'color': Colors.pink,
      },
      {
        'title': isArabic ? 'إكس' : 'X',
        'value': 5.0,
        'color': Colors.black,
      },
      {
        'title': isArabic ? 'SMS' : 'SMS',
        'value': 3.0,
        'color': Colors.teal,
      },
      {
        'title': isArabic ? 'البريد' : 'Email',
        'value': 2.0,
        'color': Colors.brown,
      },
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFD7EFDC) : Colors.black54,
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

  Widget _buildLineChart(bool isDark, List<String> monthsList) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
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
                if (value % 1 == 0 && value >= 0 && value < monthsList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      monthsList[value.toInt()],
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
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.black54, width: 2),
            bottom: BorderSide(color: Colors.black54, width: 2),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 5),
              FlSpot(3, 4),
              FlSpot(4, 7),
              FlSpot(5, 9),
              FlSpot(6, 13),
              FlSpot(7, 10),
              FlSpot(8, 14),
              FlSpot(9, 15),
              FlSpot(10, 17),
              FlSpot(11, 19),
            ],
            isCurved: true,
            color: isDark ? const Color(0xFFD7EFDC) : Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: (isDark ? const Color(0xFFD7EFDC) : Colors.blue).withOpacity(0.3),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
