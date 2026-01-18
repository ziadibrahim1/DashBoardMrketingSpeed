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
            return Center(child: CircularProgressIndicator(color: Colors.blue.shade600));
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
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الصف الأول: كروت رئيسية بتدرجات حيوية
            Row(
              children: [
                _buildStatCard(
                  isDark, strings['number_of_users']!, stats.totalUsers.toString(),
                  Icons.people_rounded, [Colors.blue.shade700, Colors.blue.shade900],
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  isDark, strings['annual_subscribers']!, stats.annualSubscribers.toString(),
                  Icons.auto_graph_rounded, [Colors.blue.shade300, Colors.blue.shade700],
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  isDark, strings['total_admins']!, stats.totalAdmins.toString(),
                  Icons.shield_rounded, [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الصف الثاني: عدد الرسائل (تصميم نيون خفيف)
            Row(
              children: [
                Expanded(
                  child: _buildModernDetailCard(
                    isDark, strings['whatsapp_messages']!, stats.whatsappMessages.toString(),
                    Icons.chat_bubble_rounded, const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernDetailCard(
                    isDark, strings['telegram_messages']!, stats.telegramMessages.toString(),
                    Icons.send_rounded, const Color(0xFF0EA5E9),
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
                    isDark, strings['whatsapp_groups']!, stats.whatsappGroups.toString(),
                    Icons.groups_2_rounded, const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleActionCard(
                    isDark, strings['telegram_channels']!, stats.telegramChannels.toString(),
                    Icons.campaign_rounded, const Color(0xFF0284C7),
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // كروت الجروبات والقنوات
  Widget _buildSimpleActionCard(bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // كرت الرسوم البيانية
  Widget _buildChartCard(bool isDark, String title, double height, Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark, List<String> platformsList, DashboardMainStats stats) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // يمكن تعديله ديناميكياً
        barGroups: List.generate(platformsList.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (stats.platformMessages[(i + 1).toString()] ?? 0).toDouble(),
                gradient: const LinearGradient(colors: [Color(0xFF0C4AC6), Color(0xFF60A5FA)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
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
              getTitlesWidget: (val, _) => Text(platformsList[val.toInt()].substring(0, 3), style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, bool isDark, DashboardMainStats stats, bool isArabic) {
    final totalMessages = stats.platformMessages.values.fold(0, (sum, count) => sum + count);
    if (totalMessages == 0) return const Center(child: Text("No Data"));

    final platformColors = {
      '1': const Color(0xFF25D366), '2': const Color(0xFF26A5E4), '3': const Color(0xFF3B82F6),
      '4': const Color(0xFF1877F2), '5': const Color(0xFF000000), '6': const Color(0xFFE4405F),
      '7': const Color(0xFF1DA1F2), '8': const Color(0xFF64748B), '9': const Color(0xFFEA4335),
    };

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: stats.platformMessages.entries.map((entry) {
          return PieChartSectionData(
            color: platformColors[entry.key] ?? Colors.grey,
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
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(monthsList[val.toInt()], style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(12, (i) => FlSpot(i.toDouble(), (stats.monthlySubscriptions[i + 1] ?? 0).toDouble())),
            isCurved: true,
            color: const Color(0xFF0C4AC6),
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [const Color(0xFF0C4AC6).withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(strings['error']!),
          TextButton(onPressed: _loadData, child: Text(strings['retry']!)),
        ],
      ),
    );
  }
}