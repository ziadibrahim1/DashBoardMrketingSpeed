import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Models/SubscriptionModel.dart';
import '../../core/SubscriptionService.dart';
import '../../core/user_session.dart';
import '../../providers/app_providers.dart';

// ألوان مخصصة للوضعين
class AppColors {
  // Colors for Light Mode
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightSecondary = Color(0xFF42A5F5);
  static const Color lightSuccess = Color(0xFF4CAF50);
  static const Color lightWarning = Color(0xFFFF6F00);
  static const Color lightDanger = Color(0xFFE53935);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightCardBg = Colors.white;
  static const Color lightBorder = Color(0xFFE3F2FD);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Colors for Dark Mode (Green Theme)
  static const Color darkPrimary = Color(0xFF2E7D32);
  static const Color darkSecondary = Color(0xFF4CAF50);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkDanger = Color(0xFFEF5350);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E2E);
  static const Color darkBorder = Color(0xFF2D2D3E);
  static const Color darkTextPrimary = Color(0xFFE4E6EB);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
}

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with SingleTickerProviderStateMixin {
  String selectedStatus = 'all';
  String selectedSubscriptionType = 'all';
  String searchQuery = '';
  int rowsPerPage = 20;
  int currentPage = 0;
  bool loading = true;
  int totalCount = 0;
  List<SubscriptionModel> allSubscriptions = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> subscriptionTypesArabic = ['شهري', 'ربع سنوي', 'نصف سنوي', 'سنوي', 'مجاني'];
  final List<String> subscriptionTypesEnglish = ['Monthly', 'Quarterly', 'Semi-Annual', 'Annual', 'Free'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    final res = await SubscriptionService.fetchSubscriptions(
      status: selectedStatus,
      type: selectedSubscriptionType,
      search: searchQuery,
      page: currentPage + 1,
      pageSize: rowsPerPage,
    );
    totalCount = res['total'];
    allSubscriptions = (res['data'] as List).map((e) => SubscriptionModel.fromJson(e)).toList();
    setState(() => loading = false);
  }

  final dateFormat = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Choose colors based on theme
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBgColor = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final subscriptionTypes = isArabic ? subscriptionTypesArabic : subscriptionTypesEnglish;
    final allTypeLabel = isArabic ? 'الكل' : 'All';

    final filtered = allSubscriptions.where((sub) {
      final matchesStatus = selectedStatus == 'all' || sub.status == selectedStatus;
      final matchesSearch = sub.user!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedSubscriptionType == 'all' || sub.type == selectedSubscriptionType;
      return matchesStatus && matchesSearch && matchesType;
    }).toList();

    final totalPages = (filtered.length / rowsPerPage).ceil();
    final paginated = filtered.skip(currentPage * rowsPerPage).take(rowsPerPage).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isArabic, isDark, primaryColor, secondaryColor),
              const SizedBox(height: 32),
              _buildStatsCards(filtered, isArabic, isDark, successColor, dangerColor, warningColor, primaryColor, textSecondaryColor),
              const SizedBox(height: 32),
              _buildFiltersSection(isArabic, isDark, subscriptionTypes, allTypeLabel, primaryColor, textPrimaryColor, textSecondaryColor, cardBgColor, borderColor),
              const SizedBox(height: 32),
              _buildDataTable(
                  paginated, filtered, totalPages, isArabic, isDark, subscriptionTypes,
                  primaryColor, secondaryColor, successColor, dangerColor, warningColor,
                  cardBgColor, borderColor, textPrimaryColor, textSecondaryColor
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, bool isDark, Color primaryColor, Color secondaryColor) {
    final gradientColors = isDark
        ? [Color(0xFF2E7D32), Color(0xFF1B5E20)] // Green gradient for dark mode
        : [Color(0xFF4FB5F5), Color(0xFF1B367A)]; // Original gradient for light mode

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.subscriptions_outlined, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'إدارة الاشتراكات' : 'Subscriptions Management',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'إدارة ومتابعة جميع الاشتراكات والمستخدمين'
                      : 'Manage and monitor all subscriptions and users',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${allSubscriptions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
      List<SubscriptionModel> filtered,
      bool isArabic,
      bool isDark,
      Color successColor,
      Color dangerColor,
      Color warningColor,
      Color primaryColor,
      Color textSecondaryColor
      ) {
    final active = filtered.where((s) => s.status == 'active').length;
    final expired = filtered.where((s) => s.status == 'expired').length;
    final frozen = filtered.where((s) => s.status == 'frozen').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات نشطة' : 'Active Subscriptions',
              active.toString(),
              Icons.verified,
              successColor,
              isDark,
              textSecondaryColor: textSecondaryColor,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات منتهية' : 'Expired Subscriptions',
              expired.toString(),
              Icons.event_busy,
              dangerColor,
              isDark,
              textSecondaryColor: textSecondaryColor,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'اشتراكات مجمدة' : 'Frozen Subscriptions',
              frozen.toString(),
              Icons.pause_circle_outline,
              warningColor,
              isDark,
              textSecondaryColor: textSecondaryColor,
            )),
            const SizedBox(width: 24),
            Expanded(child: _buildStatCard(
              isArabic ? 'إجمالي الاشتراكات' : 'Total Subscriptions',
              filtered.length.toString(),
              Icons.analytics,
              primaryColor,
              isDark,
              textSecondaryColor: textSecondaryColor,
            )),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      bool isDark,
      {Color? textSecondaryColor}
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
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
                child: Icon(icon, color: color, size: 28),
              ),
              Icon(Icons.trending_up, color: color.withOpacity(0.5), size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(
      bool isArabic,
      bool isDark,
      List<String> subscriptionTypes,
      String allTypeLabel,
      Color primaryColor,
      Color textPrimaryColor,
      Color textSecondaryColor,
      Color cardBgColor,
      Color borderColor
      ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.filter_list, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                isArabic ? 'البحث والتصفية' : 'Search & Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.3) : Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'ابحث باسم المستخدم أو البريد الإلكتروني' : 'Search by username or email',
                      labelStyle: TextStyle(color: textSecondaryColor),
                      prefixIcon: Icon(Icons.search, color: primaryColor, size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        currentPage = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  // يمكن إضافة DropdownButton هنا إذا لزم الأمر
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterChip(isArabic ? 'جميع الحالات' : 'All Status', 'all', primaryColor, isArabic, isDark),
              _buildFilterChip(isArabic ? '✓ نشط' : '✓ Active', 'active', AppColors.lightSuccess, isArabic, isDark),
              _buildFilterChip(isArabic ? '✕ منتهي' : '✕ Expired', 'expired', AppColors.lightDanger, isArabic, isDark),
              _buildFilterChip(isArabic ? '⊗ مجمد' : '⊗ Frozen', 'frozen', AppColors.lightWarning, isArabic, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color, bool isArabic, bool isDark) {
    final selected = selectedStatus == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = value;
          currentPage = 0;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: selected ? null : (isDark ? Colors.black.withOpacity(0.3) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(
      List<SubscriptionModel> paginated,
      List<SubscriptionModel> filtered,
      int totalPages,
      bool isArabic,
      bool isDark,
      List<String> subscriptionTypes,
      Color primaryColor,
      Color secondaryColor,
      Color successColor,
      Color dangerColor,
      Color warningColor,
      Color cardBgColor,
      Color borderColor,
      Color textPrimaryColor,
      Color textSecondaryColor
      ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.table_chart, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isArabic ? 'قائمة الاشتراكات' : 'Subscriptions List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} ${isArabic ? 'نتيجة' : 'Results'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          if (loading)
            Container(
              height: 400,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64,
                ),
                child: DataTable(
                  columnSpacing: 40,
                  horizontalMargin: 28,
                  headingRowHeight: 60,
                  dataRowHeight: 72,
                  headingRowColor: MaterialStateProperty.all(
                    isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFF8FBFF),
                  ),
                  columns: [
                    DataColumn(label: _buildColumnHeader(isArabic ? 'المستخدم' : 'User', Icons.person_outline, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'البريد الإلكتروني' : 'Email', Icons.email_outlined, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'نوع الاشتراك' : 'Type', Icons.card_membership, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'تاريخ البداية' : 'Start Date', Icons.calendar_today, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'تاريخ النهاية' : 'End Date', Icons.event, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'المتبقي' : 'Remaining', Icons.account_balance_wallet, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'الحالة' : 'Status', Icons.info_outline, primaryColor)),
                    DataColumn(label: _buildColumnHeader(isArabic ? 'الإجراءات' : 'Actions', Icons.settings, primaryColor)),
                  ],
                  rows: paginated.map((sub) => _buildDataRow(
                      sub, isArabic, subscriptionTypes, isDark,
                      primaryColor, secondaryColor, successColor, dangerColor, warningColor,
                      textPrimaryColor, textSecondaryColor
                  )).toList(),
                ),
              ),
            ),
          const Divider(height: 1, thickness: 1),
          _buildPagination(totalPages, isArabic, isDark, primaryColor, secondaryColor, cardBgColor, borderColor, textPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String text, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(
      SubscriptionModel sub,
      bool isArabic,
      List<String> subscriptionTypes,
      bool isDark,
      Color primaryColor,
      Color secondaryColor,
      Color successColor,
      Color dangerColor,
      Color warningColor,
      Color textPrimaryColor,
      Color textSecondaryColor
      ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (sub.status) {
      case 'active':
        statusColor = successColor;
        statusText = isArabic ? 'نشط' : 'Active';
        statusIcon = Icons.check_circle;
        break;
      case 'expired':
        statusColor = dangerColor;
        statusText = isArabic ? 'منتهي' : 'Expired';
        statusIcon = Icons.cancel;
        break;
      case 'frozen':
        statusColor = warningColor;
        statusText = isArabic ? 'مجمد' : 'Frozen';
        statusIcon = Icons.pause_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = isArabic ? 'غير معروف' : 'Unknown';
        statusIcon = Icons.help_outline;
    }

    return DataRow(
      color: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.hovered)) {
          return isDark
              ? primaryColor.withOpacity(0.05)
              : Color(0xFFE3F2FD).withOpacity(0.5);
        }
        return null;
      }),
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), secondaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    sub.user![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                sub.user!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: textSecondaryColor),
              const SizedBox(width: 6),
              Text(sub.email, style: TextStyle(fontSize: 13, color: textPrimaryColor)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
            ),
            child: Text(
              sub.type!,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(Icons.login, size: 16, color: successColor),
              const SizedBox(width: 6),
              Text(sub.startDate!, style: TextStyle(fontSize: 13, color: textPrimaryColor)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(Icons.logout, size: 16, color: dangerColor),
              const SizedBox(width: 6),
              Text(sub.endDate!, style: TextStyle(fontSize: 13, color: textPrimaryColor)),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 16, color: primaryColor),
              const SizedBox(width: 6),
              Text(sub.RemainingCount!.toString(), style: TextStyle(fontSize: 13, color: textPrimaryColor)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                Icons.edit_outlined,
                primaryColor,
                isArabic ? 'تعديل' : 'Edit',
                    () => _showEditDialog(sub, isArabic, isDark, primaryColor),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.refresh,
                successColor,
                isArabic ? 'تجديد' : 'Renew',
                    () => renewSubscription(sub, isArabic),
              ),
              const SizedBox(width: 8),
              buildFreezeButton(sub, isArabic, successColor, dangerColor, textSecondaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget buildFreezeButton(SubscriptionModel sub, bool isArabic, Color successColor, Color dangerColor, Color textSecondaryColor) {
    final isFrozen = sub.status == 'frozen';

    return _buildActionButton(
      isFrozen ? Icons.lock_open : Icons.block,
      isFrozen ? successColor : dangerColor,
      isFrozen
          ? (isArabic ? 'فك التجميد' : 'Unfreeze')
          : (isArabic ? 'تجميد' : 'Freeze'),
          () async {
        try {
          if (isFrozen) {
            await SubscriptionService.unfreeze(sub.id);
            setState(() => sub.status = 'active');
          } else {
            await SubscriptionService.freeze(sub.id);
            setState(() => sub.status = 'frozen');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'حدث خطأ أثناء تنفيذ العملية'
                    : 'Operation failed',
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPagination(int totalPages, bool isArabic, bool isDark, Color primaryColor, Color secondaryColor, Color cardBgColor, Color borderColor, Color textPrimaryColor) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFFF8FBFF),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
            icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, size: 20),
            label: Text(
              isArabic ? 'السابق' : 'Previous',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${isArabic ? 'صفحة' : 'Page'} ${currentPage + 1} ${isArabic ? 'من' : 'of'} $totalPages',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
            icon: Icon(isArabic ? Icons.arrow_back : Icons.arrow_forward, size: 20),
            label: Text(
              isArabic ? 'التالي' : 'Next',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> renewSubscription(SubscriptionModel subscription, bool isArabic) async {
    try {
      setState(() => loading = true);

      await SubscriptionService.renew(subscription.id);

      currentPage = 0;
      await loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم تجديد الاشتراك بنجاح' : 'Subscription renewed successfully'),
            backgroundColor: AppColors.lightSuccess,
          ),
        );
      }

    }  catch (e) {
      print('Renew error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isArabic ? 'خطأ' : 'Error'}: $e'),
            backgroundColor: AppColors.lightDanger,
          ),
        );
      }
    }
    finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showEditDialog(SubscriptionModel subscription, bool isArabic, bool isDark, Color primaryColor) {
    DateTime startDate = DateTime.parse(subscription.startDate!);
    DateTime endDate = DateTime.parse(subscription.endDate!);
    final userId = UserSession.userId;
    int giftDays = 0;
    int giftGroups = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
              title: Text(
                isArabic ? 'إدارة الاشتراك' : 'Manage Subscription',
                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// ================== DATES ==================
                    ListTile(
                      leading: const Icon(Icons.login, color: Color(0xFF4CAF50)),
                      title: Text(
                        isArabic ? 'تاريخ البداية' : 'Start Date',
                        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      subtitle: Text(
                        dateFormat.format(startDate),
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                      title: Text(
                        isArabic ? 'تاريخ النهاية' : 'End Date',
                        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      subtitle: Text(
                        dateFormat.format(endDate),
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                    ),

                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

                    /// ================== GIFT DAYS ==================
                    ListTile(
                      leading: const Icon(Icons.card_giftcard, color: Colors.blue),
                      title: Text(
                        isArabic ? 'أيام هدية' : 'Gift Days',
                        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      subtitle: Text(
                        isArabic
                            ? 'تضاف إلى نهاية الاشتراك'
                            : 'Added to subscription end date',
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              giftDays = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ),

                    /// ================== GIFT GROUPS ==================
                    ListTile(
                      leading: const Icon(Icons.group_add, color: Colors.green),
                      title: Text(
                        isArabic ? 'مجموعات هدية' : 'Gift Groups',
                        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      subtitle: Text(
                        isArabic
                            ? 'تضاف كباقة إضافية'
                            : 'Extra groups as gift',
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              giftGroups = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isArabic ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    /// 🟢 1) تحديث التواريخ
                    if (giftDays > 0) {
                      endDate = endDate.add(Duration(days: giftDays));
                      await SubscriptionService.addGiftDays(
                        subscriptionId: subscription.id,
                        DaysCount: giftDays,
                        userId: userId!,
                      );
                    }

                    await SubscriptionService.updateSubscriptionDates(
                      subscription.id,
                      startDate,
                      endDate,
                    );

                    /// 🟢 2) إضافة مجموعات هدية
                    if (giftGroups > 0) {
                      await SubscriptionService.addGiftGroups(
                        subscriptionId: subscription.id,
                        groupsCount: giftGroups,
                        userId: userId!,
                      );
                    }

                    Navigator.pop(context);
                    loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isArabic ? 'حفظ' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}