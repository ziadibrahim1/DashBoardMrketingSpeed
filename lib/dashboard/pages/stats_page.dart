import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Models/DashboardStats.dart';
import '../../Models/api_service.dart';
import '../../core/app_config.dart';
import '../../providers/app_providers.dart';
import 'OurGroupsManagementScreen.dart';
import 'select_user_screen.dart';

// ألوان مخصصة للوضعين
class AppColors {
  // Colors for Light Mode
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightSecondary = Color(0xFF3B82F6);
  static const Color lightSurface = Color(0xFFF0F4F8);
  static const Color lightCardBg = Colors.white;
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightDanger = Color(0xFFEF4444);
  static const Color lightWarning = Color(0xFFF59E0B);

  // Colors for Dark Mode (Green Theme)
  static const Color darkPrimary = Color(0xFF2E7D32);
  static const Color darkSecondary = Color(0xFF4CAF50);
  static const Color darkSurface = Color(0xFF0A1628);
  static const Color darkCardBg = Color(0xFF1E1E2E);
  static const Color darkBorder = Color(0xFF2D2D3E);
  static const Color darkTextPrimary = Color(0xFFE4E6EB);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkDanger = Color(0xFFF44336);
  static const Color darkWarning = Color(0xFFFFB74D);
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Choose colors based on theme
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceGradient1 = isDark ? AppColors.darkSurface : Color(0xFFF0F4F8);
    final surfaceGradient2 = isDark ? Color(0xFF132A46) : Color(0xFFE3ECFF);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [surfaceGradient1, surfaceGradient2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: _MainDashboard(
            isArabic: isArabic,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _MainDashboard extends StatefulWidget {
  final bool isArabic;
  final bool isDark;

  const _MainDashboard({
    required this.isArabic,
    required this.isDark,
  });

  @override
  State<_MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<_MainDashboard> with SingleTickerProviderStateMixin {
  late Future<DashboardStats> dashboardFuture;
  late Future<List<GroupRequestModel>> groupRequestsFuture;
  List<dynamic> countries = [];
  List<dynamic> categories = [];
  bool loadingMeta = false;
  bool isPlatformActive = true;
  bool isTogglingPlatform = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<int> weeklyCounts = [];
  List<String> days = [];
  bool isLoadingChart = true;
  List<String> daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<String> daysAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  List<int> counts = [];
  bool isLoadingPie = true;
  List<CountryMessageStats> countryStats = [];

  // Get colors based on theme
  Color get primaryColor => widget.isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
  Color get secondaryColor => widget.isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
  Color get surfaceColor => widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardColor => widget.isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
  Color get borderColor => widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textPrimaryColor => widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondaryColor => widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get successColor => widget.isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
  Color get dangerColor => widget.isDark ? AppColors.darkDanger : AppColors.lightDanger;
  Color get warningColor => widget.isDark ? AppColors.darkWarning : AppColors.lightWarning;

  Future<void> loadWeeklyMessages() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}dashboard/weekly-messages'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;

        setState(() {
          weeklyCounts = data.map((e) => e['count'] as int).toList();

          days = data.map((e) {
            final dayIndex = e['day'] as int;
            return widget.isArabic
                ? daysAr[dayIndex]
                : daysEn[dayIndex];
          }).toList();

          isLoadingChart = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingChart = false;
      });
    }
  }

  Future<void> loadData() async {
    final stats = await fetchCountryStats();
    setState(() {
      countryStats = stats;
    });
  }

  Future<List<CountryMessageStats>> fetchCountryStats() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}dashboard/messages-by-country'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((item) => CountryMessageStats.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboardStats();
    groupRequestsFuture = fetchGroupRequests();
    loadPlatformStatus();
    loadWeeklyMessages();
    loadData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadCountriesAndCategories() async {
    loadingMeta = true;
    setState(() {});

    countries = await ApiService.getCountries();
    categories = await ApiService.getCategories();

    loadingMeta = false;
    setState(() {});
  }

  Future<void> loadPlatformStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}dashboard/platform-status'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isPlatformActive = data['isActive'] ?? true;
        });
      }
    } catch (e) {
      // في حالة الخطأ، نستخدم القيمة الافتراضية
      setState(() {
        isPlatformActive = true;
      });
    }
  }

  Future<void> togglePlatformStatus(bool value) async {
    setState(() {
      isTogglingPlatform = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}dashboard/toggle-platform'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isActive': value}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isPlatformActive = value;
          isTogglingPlatform = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? (widget.isArabic ? 'تم تفعيل المنصة بنجاح' : 'Platform activated successfully')
                  : (widget.isArabic ? 'تم إيقاف المنصة بنجاح' : 'Platform deactivated successfully'),
            ),
            backgroundColor: value ? successColor : warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        throw Exception('Failed to toggle platform');
      }
    } catch (e) {
      setState(() {
        isTogglingPlatform = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic ? 'فشل في تغيير حالة المنصة' : 'Failed to change platform status',
          ),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, GroupRequestModel request, bool isDark, bool isArabic) {
    final TextEditingController reasonController = TextEditingController();
    final Color bgColor = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.report_problem_rounded, color: dangerColor),
            SizedBox(width: 10),
            Text(
              isArabic ? "رفض الطلب" : "Reject Request",
              style: TextStyle(color: textPrimaryColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "سبب الرفض (اختياري):" : "Reason for rejection (Optional):",
              style: TextStyle(fontSize: 13, color: textSecondaryColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: TextStyle(color: textPrimaryColor),
              decoration: InputDecoration(
                hintText: isArabic ? "اكتب السبب هنا..." : "Write the reason here...",
                hintStyle: TextStyle(fontSize: 12, color: textSecondaryColor),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                isArabic ? "إلغاء" : "Cancel",
                style: TextStyle(color: textSecondaryColor)
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await rejectGroupRequest(request.id,reasonController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isArabic ? "تأكيد الرفض" : "Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Future<DashboardStats> fetchDashboardStats() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}dashboard/stats'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  Future<List<GroupRequestModel>> fetchGroupRequests() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}dashboard/group-requests'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => GroupRequestModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load group requests');
    }
  }

  Future<void> approveGroupRequest(
      int requestId,
      int countryId,
      int categoryId,
      )
  async {
    await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}dashboard/group-requests/$requestId/approve',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'countryId': countryId,
        'categoryId': categoryId,
      }),
    );
  }

  Future<void> rejectGroupRequest(
      int requestId,
      String adminNote,
      )
  async {
    await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}dashboard/group-requests/$requestId/reject',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'AdminNote': adminNote,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = {
      'groupRequests': widget.isArabic ? 'طلبات إضافة الجروبات' : 'Group Addition Requests',
      'copyLink': widget.isArabic ? 'نسخ الرابط' : 'Copy Link',
      'openLink': widget.isArabic ? 'فتح الرابط' : 'Open Link',
      'linkCopied': widget.isArabic ? 'تم نسخ الرابط إلى الحافظة' : 'Link copied to clipboard',
      'linkOpenError': widget.isArabic ? 'تعذر فتح الرابط' : 'Failed to open link',
      'approved': widget.isArabic ? 'تمت الموافقة' : 'Approved',
      'approve': widget.isArabic ? 'موافقة' : 'Approve',
      'dashboard': widget.isArabic ? 'لوحة التحكم' : 'Dashboard',
      'overview': widget.isArabic ? 'نظرة عامة' : 'Overview',
    };

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Quick Actions Cards
          _buildQuickActions(),
          const SizedBox(height: 32),

          // Statistics Cards
          _buildStatisticsSection(),
          const SizedBox(height: 32),

          // Charts Section
          _buildChartsSection(),
          const SizedBox(height: 32),

          // Group Requests Table
          _buildGroupRequestsTable(cardColor, titles, widget.isArabic, widget.isDark),
        ],
      ),
    );
  }


  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildPlatformToggleCard(),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildActionCard(
            title: widget.isArabic ? 'جروباتنا' : 'Our Groups',
            subtitle: widget.isArabic ? 'عرض وإدارة الجروبات' : 'View & Manage Groups',
            icon: Icons.groups_rounded,
            gradientColors: widget.isDark
                ? [AppColors.darkPrimary, AppColors.darkSecondary]
                : [AppColors.lightPrimary, AppColors.lightSecondary],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OurGroupsManagementScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformToggleCard() {
    final activeGradientColors = widget.isDark
        ? [Color(0xFF25D366), Color(0xFF128C7E)]
        : [Color(0xFF25D366), Color(0xFF128C7E)];

    final inactiveGradientColors = widget.isDark
        ? [AppColors.darkDanger, Color(0xFFDC2626)]
        : [Color(0xFFEF4444), Color(0xFFDC2626)];

    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPlatformActive ? activeGradientColors : inactiveGradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPlatformActive ? Color(0xFF25D366) : dangerColor).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPlatformActive ? FontAwesomeIcons.whatsapp : Icons.block_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isArabic ? 'حالة المنصة' : 'Platform Status',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPlatformActive
                      ? (widget.isArabic ? 'المنصة نشطة' : 'Platform Active')
                      : (widget.isArabic ? 'المنصة متوقفة' : 'Platform Inactive'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (isTogglingPlatform)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Transform.scale(
              scale: 1.2,
              child: Switch(
                value: isPlatformActive,
                onChanged: togglePlatformStatus,
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.5),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return FutureBuilder<DashboardStats>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading stats',
              style: TextStyle(color: dangerColor),
            ),
          );
        }

        final stats = snapshot.data!;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _buildStatCard(
              title: widget.isArabic ? 'رسائل الجروبات' : 'Group Messages',
              value: stats.groupMessages,
              icon: Icons.group_rounded,
              color: Color(0xFF3B82F6),
            ),
            _buildStatCard(
              title: widget.isArabic ? 'رسائل الدردشات' : 'Chat Messages',
              value: stats.chatMessages,
              icon: Icons.chat_bubble_rounded,
              color: Color(0xFF8B5CF6),
            ),
            _buildStatCard(
              title: widget.isArabic ? 'رسائل الأعضاء' : 'Member Messages',
              value: stats.memberMessages,
              icon: Icons.person_rounded,
              color: Color(0xFF06B6D4),
            ),
            _buildStatCard(
              title: widget.isArabic ? 'جروباتنا الخاصة' : 'Our Private Groups',
              value: stats.privateGroups,
              icon: Icons.lock_rounded,
              color: Color(0xFF10B981),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 124) / 4,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: successColor),
                    const SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        fontSize: 11,
                        color: successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 6,
            child: buildWeeklyChart()
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 4,
          child: _buildPieChart(countryStats, widget.isArabic),
        ),
      ],
    );
  }

  Widget buildWeeklyChart() {
    if (isLoadingChart) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (weeklyCounts.length < 7 || days.length < 7) {
      return Center(
        child: Text(
          widget.isArabic ? 'لا توجد بيانات كافية' : 'Not enough data available',
          style: TextStyle(color: textSecondaryColor),
        ),
      );
    }

    return _buildBarChart(days);
  }

  Widget _buildBarChart(List<String> days) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isArabic ? 'نشاط الأسبوع' : 'Weekly Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isArabic ? 'عدد الرسائل اليومية' : 'Daily Messages Count',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
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
                        style: TextStyle(fontSize: 12, color: textSecondaryColor),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt() % 7],
                            style: TextStyle(
                                fontSize: 12,
                                color: textSecondaryColor,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyCounts[i].toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: widget.isDark
                              ? [AppColors.darkSecondary, AppColors.darkPrimary]
                              : [AppColors.lightSecondary, AppColors.lightPrimary],
                        ),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      )
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: primaryColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: days[group.x.toInt()],
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<CountryMessageStats> stats, bool isArabic) {
    if (stats.isEmpty) {
      return Container(
        height: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Text(
            isArabic ? 'لا توجد بيانات' : 'No data available',
            style: TextStyle(color: textSecondaryColor),
          ),
        ),
      );
    }

    // الألوان
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'التوزيع الجغرافي' : 'Geographic Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? 'حسب الدولة' : 'By Country',
            style: TextStyle(
              fontSize: 12,
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: stats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  return PieChartSectionData(
                    value: stat.percentage,
                    color: colors[index % colors.length],
                    title: '${stat.percentage.toStringAsFixed(1)}%',
                    radius: 70 - (index * 3.0), // تدرج في الحجم
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic ? stat.countryNameAr : stat.countryNameEn,
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                    ),
                  ),
                  Text(
                    '${stat.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGroupRequestsTable(
      Color cardColor,
      Map<String, String> titles,
      bool isArabic,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles['groupRequests']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? 'إدارة طلبات الانضمام' : 'Manage Join Requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pending_actions_rounded, color: primaryColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<GroupRequestModel>>(
            future: groupRequestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: dangerColor),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load group requests',
                          style: TextStyle(color: dangerColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final requests = snapshot.data!;

              if (requests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_rounded, size: 48, color: textSecondaryColor),
                        const SizedBox(height: 16),
                        Text(
                          isArabic ? 'لا توجد طلبات' : 'No requests found',
                          style: TextStyle(color: textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
                    return _buildRequestRowFromApi(
                      requests[index],
                      titles,
                      isArabic,
                      isDark,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestRowFromApi(
      GroupRequestModel request,
      Map<String, String> titles,
      bool isArabic,
      bool isDark,
      ) {
    final themeColor = primaryColor;
    final rejectColor = dangerColor;
    final bgColor = cardColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        elevation: isDark ? 0 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchURL(request.groupLink),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // أيقونة المجموعة
                CircleAvatar(
                  radius: 18,
                  backgroundColor: themeColor.withOpacity(0.1),
                  child: Icon(Icons.link_rounded, color: themeColor, size: 18),
                ),
                const SizedBox(width: 12),

                // بيانات المجموعة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.groupName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${request.category} • ${request.country}",
                        style: TextStyle(
                          fontSize: 10,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // الأزرار أو حالة القبول
                if (request.isApproved)
                  Icon(Icons.verified_rounded, color: themeColor, size: 22)
                else if (request.status == 'pending')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر الرفض
                      _buildIconButton(
                        icon: Icons.close_rounded,
                        color: rejectColor,
                        onTap: () => _showRejectDialog(context, request, isDark, isArabic),
                      ),
                      const SizedBox(width: 8),
                      // زر القبول
                      _buildIconButton(
                        icon: Icons.check_rounded,
                        color: themeColor,
                        onTap: () => showApproveDialog(request),
                      ),
                    ],
                  ),
                if (request.status == 'rejected')
                  Icon(Icons.cancel_presentation, color: dangerColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت للأزرار الصغيرة لتقليل الارتفاع
  Widget _buildIconButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void showApproveDialog(GroupRequestModel request) async {
    await loadCountriesAndCategories();

    int? selectedCountryId;
    int? selectedCategoryId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: cardColor,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.approval_rounded, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isArabic ? 'تأكيد إضافة الجروب' : 'Approve Group',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
              content: loadingMeta
                  ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: widget.isArabic ? 'الدولة' : 'Country',
                      labelStyle: TextStyle(color: textSecondaryColor),
                      prefixIcon: Icon(Icons.location_on_rounded, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    ),
                    dropdownColor: cardColor,
                    items: countries.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name'], style: TextStyle(color: textPrimaryColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setLocalState(() => selectedCountryId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: widget.isArabic ? 'المجال' : 'Category',
                      labelStyle: TextStyle(color: textSecondaryColor),
                      prefixIcon: Icon(Icons.category_rounded, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    ),
                    dropdownColor: cardColor,
                    items: categories.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name'], style: TextStyle(color: textPrimaryColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setLocalState(() => selectedCategoryId = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    widget.isArabic ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: textSecondaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedCountryId == null || selectedCategoryId == null
                      ? null
                      : () async {
                    Navigator.pop(context);
                    await approveGroupRequest(
                      request.id,
                      selectedCountryId!,
                      selectedCategoryId!,
                    );
                    setState(() {
                      groupRequestsFuture = fetchGroupRequests();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(widget.isArabic ? 'موافقة' : 'Approve'),
                ),
              ],
            );
          },
        );
      },
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