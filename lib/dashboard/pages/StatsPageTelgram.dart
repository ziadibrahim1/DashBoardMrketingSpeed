import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/app_providers.dart';
import 'OurChannelsManagementScreen.dart'; // شاشة القنوات بدل الجروبات
import 'SelectTelegramUserScreen.dart';
import 'select_user_screen.dart';

class StatsPageTelegram extends StatefulWidget {
  const StatsPageTelegram({super.key});

  @override
  State<StatsPageTelegram> createState() => _StatsPageTelegramState();
}

enum BodyContentTelegram {
  mainDashboard,
  channels,
  marketing,
}

class _StatsPageTelegramState extends State<StatsPageTelegram> {
  BodyContentTelegram currentContent = BodyContentTelegram.mainDashboard;

  List<ChannelRequest> channelRequests = [
    ChannelRequest(
      name: 'قناة تليجرام التسويق العقاري - السعودية',
      link: 'https://t.me/example123',
      isApproved: false,
    ),
    ChannelRequest(
      name: 'قناة تليجرام التسويق الرقمي - مصر',
      link: 'https://t.me/example456',
      isApproved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD7EFDC) : const Color(0xFF0096FF);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF4D5D53) : Theme.of(context).cardColor;

    final titles = {
      'channelRequests': isArabic ? 'طلبات إضافة القنوات' : 'Channel Addition Requests',
      'copyLink': isArabic ? 'نسخ الرابط' : 'Copy Link',
      'openLink': isArabic ? 'فتح الرابط' : 'Open Link',
      'linkCopied': isArabic ? 'تم نسخ الرابط إلى الحافظة' : 'Link copied to clipboard',
      'linkOpenError': isArabic ? 'تعذر فتح الرابط' : 'Failed to open link',
      'approved': isArabic ? 'تمت الموافقة' : 'Approved',
      'approve': isArabic ? 'موافقة' : 'Approve',
    };

    Widget contentWidget;
    switch (currentContent) {
      case BodyContentTelegram.channels:
        contentWidget =  TelegramChannelsScreen();
        break;
      case BodyContentTelegram.marketing:
        contentWidget = SelectUserScreentele();
        break;
      case BodyContentTelegram.mainDashboard:
      default:
        contentWidget = _buildMainDashboard(
          isArabic,
          isDark,
          primaryColor,
          backgroundColor,
          cardColor,
          titles,
        );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          children: [
            Expanded(child: contentWidget),
            if (currentContent != BodyContentTelegram.mainDashboard)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                  ),
                  label: Text(
                    isArabic ? 'عودة للوحة التحكم' : 'Back to Dashboard',
                    style: TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                  ),
                  onPressed: () {
                    setState(() {
                      currentContent = BodyContentTelegram.mainDashboard;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboard(
      bool isArabic,
      bool isDark,
      Color primaryColor,
      Color backgroundColor,
      Color cardColor,
      Map<String, String> titles,
      ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: isArabic ? 'تليجرام' : 'Telegram',
                icon: FontAwesomeIcons.telegram,
                color: Colors.blue,
                onTap: () {
                  // وظيفة فتح صفحة تليجرام
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: DashboardCard(
                title: isArabic ? 'اضغط لعرض قنواتنا' : 'Press to show Our Channels',
                icon: Icons.campaign,
                color: primaryColor,
                onTap: () {
                  setState(() {
                    currentContent = BodyContentTelegram.channels;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildStatCard(
                isArabic ? 'رسائل القنوات' : 'Channel Messages',
                3280,
                primaryColor,
                cardColor,
                isDark,
                false),
            _buildStatCard(
                isArabic ? 'رسائل الدردشات' : 'Chat Messages',
                1850,
                primaryColor,
                cardColor,
                isDark,
                false),
            _buildStatCard(
                isArabic ? 'رسائل الأعضاء' : 'Member Messages',
                920,
                primaryColor,
                cardColor,
                isDark,
                false),
            _buildStatCard(
                isArabic ? 'قنواتنا الخاصة' : 'Our Private Channels',
                36,
                primaryColor,
                cardColor,
                isDark,
                false),
            _buildStatCard(
              isArabic ? 'اضغط للتسويق للعملاء' : 'Press to Customer Marketing',
              36,
              primaryColor,
              cardColor,
              isDark,
              true,
              onTap: () {
                setState(() {
                  currentContent = BodyContentTelegram.marketing;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBarChart(cardColor, isArabic ? ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'] : ['S', 'M', 'T', 'W', 'T', 'F', 'S'])),
            const SizedBox(width: 24),
            Expanded(child: _buildPieChart(cardColor, isArabic ? ['السعودية', 'مصر', 'الإمارات', 'أخرى'] : ['KSA', 'Egypt', 'UAE', 'Others'])),
          ],
        ),
        const SizedBox(height: 40),
        _buildChannelRequestsTable(cardColor, titles, isArabic, isDark),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      int value,
      Color primary,
      Color cardColor,
      bool isDark,
      bool isMarketing, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: isMarketing ? 400 : null,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4D5D53) : const Color(0xFFC1EAFF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.grey[900]! : Colors.black12,
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: isMarketing ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 20),
            if (!isMarketing)
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.start,
              )
            else
              Icon(
                Icons.campaign,
                size: 40,
                color: isDark ? Colors.white70 : Colors.blue.shade900,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Color cardColor, List<String> days) {
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

  Widget _buildPieChart(Color cardColor, List<String> countries) {
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
            PieChartSectionData(value: 40, color: Colors.blue, title: countries[0], radius: 80),
            PieChartSectionData(value: 30, color: Colors.orange, title: countries[1], radius: 70),
            PieChartSectionData(value: 20, color: Colors.green, title: countries[2], radius: 60),
            PieChartSectionData(value: 10, color: Colors.purple, title: countries[3], radius: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelRequestsTable(Color cardColor, Map<String, String> titles, bool isArabic, bool isDark) {
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
          Text(
            titles['channelRequests']!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.7),
          ),
          const Divider(height: 36, thickness: 2),
          SizedBox(
            height: 300,
            child: ListView.separated(
              itemCount: channelRequests.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final request = channelRequests[index];
                return _buildRequestRow(request, titles, isArabic, isDark);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRequestRow(ChannelRequest request, Map<String, String> titles, bool isArabic, bool isDark) {
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
            Tooltip(
              message: titles['copyLink']!,
              child: IconButton(
                icon: Icon(Icons.copy, size: 22, color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: request.link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(titles['linkCopied']!)),
                  );
                },
              ),
            ),
            Tooltip(
              message: titles['openLink']!,
              child: IconButton(
                icon: const Icon(Icons.open_in_new, size: 22),
                color: Colors.blue.shade700,
                onPressed: () async {
                  final url = Uri.parse(request.link);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(titles['linkOpenError']!)),
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
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
            const SizedBox(width: 8),
            Text(
              titles['approved']!,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
        label: Text(titles['approve']!),
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

class ChannelRequest {
  final String name;
  final String link;
  bool isApproved;

  ChannelRequest({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF4D5D53) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.grey[900]! : Colors.black12,
                blurRadius: 18,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 48, color: isDark ? const Color(0xFFD7EFDC) : color),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
