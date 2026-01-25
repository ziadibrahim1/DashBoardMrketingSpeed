import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/DashboardMainStats.dart';
import '../../providers/app_providers.dart';
import '../../services/api_service.dart';

class DashboardStatsSection extends StatefulWidget {
  const DashboardStatsSection({super.key});

  @override
  State<DashboardStatsSection> createState() => _DashboardStatsSectionState();
}

class _DashboardStatsSectionState extends State<DashboardStatsSection> {
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
      'months': 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
      'loading': 'Loading...',
      'error': 'Error loading data',
      'retry': 'Retry',
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
      'months': 'ينا,فبر,مار,أبر,ماي,يون,يول,أغس,سبت,أكت,نوف,ديس',
      'loading': 'جاري التحميل...',
      'error': 'خطأ في تحميل البيانات',
      'retry': 'إعادة المحاولة',
    },
  };

  late Future<DashboardMainStats> _statsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _statsFuture = _apiService.fetchDashboardStats();
    });
  }

  // دالة للحصول على اللون بناءً على الوضع
  Color _getTextColor(bool isDark) => isDark ? Colors.grey[300]! : Colors.grey[800]!;
  Color _getSubTextColor(bool isDark) => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color _getCardColor(bool isDark) => isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color _getBackgroundColor(bool isDark) => isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

  // ألوان خاصة بالوضع الداكن (أخضر)
  Color _getDarkPrimaryColor(bool isDark) => isDark ? const Color(0xFF4CAF50) : Colors.blue.shade700;
  Color _getDarkSecondaryColor(bool isDark) => isDark ? const Color(0xFF66BB6A) : Colors.blue.shade300;
  Color _getDarkAccentColor(bool isDark) => isDark ? const Color(0xFF81C784) : const Color(0xFFF59E0B);
  Color _getChartColor(bool isDark) => isDark ? const Color(0xFF4CAF50) : const Color(0xFF0C4AC6);
  Color _getChartGradientStart(bool isDark) => isDark ? const Color(0xFF4CAF50) : const Color(0xFF0C4AC6);
  Color _getChartGradientEnd(bool isDark) => isDark ? const Color(0xFF66BB6A) : const Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final langCode = isArabic ? 'ar' : 'en';
    final strings = localizedStrings[langCode]!;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: FutureBuilder<DashboardMainStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: isDark ? const Color(0xFF4CAF50) : Colors.blue.shade600
                )
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(isDark, strings, snapshot.error.toString());
          }
          if (!snapshot.hasData) return const SizedBox.shrink();

          final stats = snapshot.data!;
          return _buildContent(context, stats, isDark, isArabic, strings);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardMainStats stats, bool isDark, bool isArabic, Map<String, String> strings) {
    final platformsList = strings['platforms']!.split(',');
    final monthsList = strings['months']!.split(',');

    return Container(
      color: _getBackgroundColor(isDark),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الصف الأول: كروت رئيسية بتدرجات حيوية
            Row(
              children: [
                _buildStatCard(
                  isDark,
                  strings['number_of_users']!,
                  stats.totalUsers.toString(),
                  Icons.people_rounded,
                  isDark
                      ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                      : [Colors.blue.shade700, Colors.blue.shade900],
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  isDark,
                  strings['annual_subscribers']!,
                  stats.annualSubscribers.toString(),
                  Icons.auto_graph_rounded,
                  isDark
                      ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
                      : [Colors.blue.shade300, Colors.blue.shade700],
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  isDark,
                  strings['total_admins']!,
                  stats.totalAdmins.toString(),
                  Icons.shield_rounded,
                  isDark
                      ? [const Color(0xFF8BC34A), const Color(0xFF689F38)]
                      : [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الصف الثاني: عدد الرسائل (تصميم نيون خفيف)
            Row(
              children: [
                Expanded(
                  child: _buildModernDetailCard(
                    isDark,
                    strings['whatsapp_messages']!,
                    stats.whatsappMessages.toString(),
                    Icons.chat_bubble_rounded,
                    isDark ? const Color(0xFF4CAF50) : const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernDetailCard(
                    isDark,
                    strings['telegram_messages']!,
                    stats.telegramMessages.toString(),
                    Icons.send_rounded,
                    isDark ? const Color(0xFF66BB6A) : const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الصف الثالث: الجروبات والقنوات
            Row(
              children: [
                Expanded(
                  child: _buildSimpleActionCard(
                    isDark,
                    strings['whatsapp_groups']!,
                    stats.whatsappGroups.toString(),
                    Icons.groups_2_rounded,
                    isDark ? const Color(0xFF81C784) : const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleActionCard(
                    isDark,
                    strings['telegram_channels']!,
                    stats.telegramChannels.toString(),
                    Icons.campaign_rounded,
                    isDark ? const Color(0xFFA5D6A7) : const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الرسوم البيانية
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildChartCard(isDark, strings['usage_percentages']!, 400, _buildPieChart(context, isDark, stats, isArabic)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChartCard(isDark, strings['platform_stats']!, 400, _buildBarChart(isDark, platformsList, stats)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildChartCard(isDark, strings['user_subscriptions']!, 350, _buildLineChart(isDark, monthsList, stats)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // الكرت الرئيسي الملون (Gradient)
  Widget _buildStatCard(bool isDark, String title, String value, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // كروت الرسائل الحديثة
  Widget _buildModernDetailCard(bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: _getSubTextColor(isDark), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: _getTextColor(isDark), fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // كروت الجروبات والقنوات
  Widget _buildSimpleActionCard(bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: _getSubTextColor(isDark))),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(bool isDark, String title, double height, Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: height,
      decoration: BoxDecoration(
        color: _getCardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getTextColor(isDark)
          )),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark, List<String> platformsList, DashboardMainStats stats) {
    final values = stats.platformMessages.values.map((e) => e.toDouble()).toList();
    final maxValue = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final double maxY = maxValue == 0 ? 10 : maxValue * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: List.generate(platformsList.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (stats.platformMessages[(i + 1).toString()] ?? 0).toDouble(),
                gradient: LinearGradient(
                    colors: [_getChartGradientStart(isDark), _getChartGradientEnd(isDark)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter
                ),
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final text = platformsList[val.toInt()];
                final short = text.characters.take(3).toString();

                return Text(
                  short,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getSubTextColor(isDark),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, bool isDark, DashboardMainStats stats, bool isArabic) {
    final values = stats.platformMessages.values.map((e) => e.toDouble()).toList();
    final maxValue = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 10 : maxValue * 1.2;

    final totalMessages = stats.platformMessages.values.fold(0, (sum, count) => sum + count);
    if (totalMessages == 0) return Center(child: Text("No Data", style: TextStyle(color: _getTextColor(isDark))));

    // تحديث الألوان للوضع الداكن مع الحفاظ على درجات الأخضر
    final platformColors = {
      '1': isDark ? const Color(0xFF4CAF50) : const Color(0xFF25D366), // WhatsApp
      '2': isDark ? const Color(0xFF66BB6A) : const Color(0xFF26A5E4), // Telegram
      '3': isDark ? const Color(0xFF81C784) : const Color(0xFF3B82F6), // Haraj
      '4': isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1877F2), // Facebook
      '5': isDark ? const Color(0xFFC8E6C9) : const Color(0xFF000000), // TikTok
      '6': isDark ? const Color(0xFF4CAF50) : const Color(0xFFE4405F), // Instagram
      '7': isDark ? const Color(0xFF66BB6A) : const Color(0xFF1DA1F2), // X
      '8': isDark ? const Color(0xFF81C784) : const Color(0xFF64748B), // SMS
      '9': isDark ? const Color(0xFFA5D6A7) : const Color(0xFFEA4335), // Email
    };

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: stats.platformMessages.entries.map((entry) {
          return PieChartSectionData(
            color: platformColors[entry.key] ?? (isDark ? Colors.grey[700]! : Colors.grey),
            value: (entry.value / totalMessages) * 100,
            radius: 60,
            title: '',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(bool isDark, List<String> monthsList, DashboardMainStats stats) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: _getSubTextColor(isDark).withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getSubTextColor(isDark),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(
                  monthsList[val.toInt()],
                  style: TextStyle(
                      fontSize: 10,
                      color: _getSubTextColor(isDark)
                  )
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(12, (i) => FlSpot(i.toDouble(), (stats.monthlySubscriptions[i + 1] ?? 0).toDouble())),
            isCurved: true,
            color: _getChartColor(isDark),
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                  colors: [_getChartColor(isDark).withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Map<String, String> strings, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: isDark ? const Color(0xFF4CAF50) : Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(strings['error']!, style: TextStyle(color: _getTextColor(isDark))),
          TextButton(
            onPressed: _loadData,
            child: Text(strings['retry']!, style: TextStyle(color: isDark ? const Color(0xFF4CAF50) : Colors.blue)),
          ),
        ],
      ),
    );
  }
}