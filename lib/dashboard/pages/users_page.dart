import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/UserModel.dart';
import '../../core/app_config.dart';
import 'UserDetailsPage.dart';

class AppColors {
  // Colors for Light Mode
  static const lightPrimary = Color(0xFF399EF3); // Indigo Modern
  static const lightSuccess = Color(0xFF10B981);
  static const lightDanger = Color(0xFFEF4444);
  static const lightCardBg = Colors.white;
  static const lightScaffoldBg = Color(0xFFF8FAFC);
  static const lightTextPrimary = Color(0xFF1E293B);
  static const lightTextSecondary = Color(0xFF64748B);

  // Colors for Dark Mode (Green Theme)
  static const darkPrimary = Color(0xFF4CAF50); // Green
  static const darkSuccess = Color(0xFF66BB6A);
  static const darkDanger = Color(0xFFF44336);
  static const darkCardBg = Color(0xFF1E1E2E);
  static const darkScaffoldBg = Color(0xFF121212);
  static const darkTextPrimary = Color(0xFFE4E6EB);
  static const darkTextSecondary = Color(0xFFB0B3B8);
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with SingleTickerProviderStateMixin {
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _statusFilter = 'all';
  int _currentPage = 0;
  final int _itemsPerPage = 12;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse("${AppConfig.apiBase}/api/users/all"));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() => _allUsers = data.map((u) => UserModel.fromJson(u)).toList());
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Choose colors based on theme
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final cardBgColor = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final scaffoldBgColor = isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final filtered = _allUsers.where((u) {
      // 1️⃣ البحث: الاسم أو الايميل
      final matchSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2️⃣ حالة المستخدم: active, inactive أو all
      final matchStatus = _statusFilter == 'all' || u.status == _statusFilter;

      final matchMessages = u.totalMessages > 10;
      final matchSubscription = u.subscriptionDaysLeft > 0;

      return matchSearch && matchStatus;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernHeader(isAr, isDark, primaryColor),
          _buildFilterPanel(isAr, isDark, cardBgColor, primaryColor, textPrimaryColor),
          _isLoading
              ? SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          )
              : _buildContentGrid(
              filtered,
              isAr,
              isDark,
              cardBgColor,
              primaryColor,
              successColor,
              dangerColor,
              textPrimaryColor,
              textSecondaryColor
          ),
        ],
      ),
      // ✅ الزر العائم هنا
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _fetchData,
        backgroundColor: primaryColor,
        elevation: 8,
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.refresh_rounded, color: Colors.white),
        label: Text(
          isAr ? "تحديث" : "Refresh",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- 1. رأس الصفحة الانسيابي ---
  Widget _buildModernHeader(bool isAr, bool isDark, Color primaryColor) {
    final gradientColors = isDark
        ? [Color(0xFF2E7D32), Color(0xFF1B5E20)] // Green gradient for dark mode
        : [Color(0xFF4FB5F5), Color(0xFF1B367A)]; // Original gradient for light mode

    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Icon(
                  isDark ? Icons.people_alt_rounded : Icons.auto_awesome_motion_rounded,
                  color: Colors.white,
                  size: 30
              ),
              const SizedBox(width: 15),
              Text(
                isAr ? "المستخدمين" : "Users Center",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              _buildStatChip("${_allUsers.length}", isAr ? "إجمالي" : "Total"),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. لوحة التحكم والفلاتر  ---
  Widget _buildFilterPanel(bool isAr, bool isDark, Color cardBgColor, Color primaryColor, Color textPrimaryColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.03), blurRadius: 10)],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: isAr ? "ابحث عن مستخدم..." : "Search user...",
                    hintStyle: TextStyle(color: textPrimaryColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ✅ هنا ضيف DropdownButton
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox(),
                dropdownColor: cardBgColor,
                style: TextStyle(color: textPrimaryColor),
                items: [
                  DropdownMenuItem(
                      value: 'all',
                      child: Text(isAr ? 'الكل' : 'All', style: TextStyle(color: textPrimaryColor))
                  ),
                  DropdownMenuItem(
                      value: 'active',
                      child: Text(isAr ? 'نشط' : 'Active', style: TextStyle(color: textPrimaryColor))
                  ),
                  DropdownMenuItem(
                      value: 'inactive',
                      child: Text(isAr ? 'غير نشط' : 'Inactive', style: TextStyle(color: textPrimaryColor))
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _statusFilter = v);
                },
              ),
            ),

            const SizedBox(width: 12),
            _buildFilterAction(Icons.filter_list_rounded, isDark, cardBgColor, primaryColor),
          ],
        ),
      ),
    );
  }

  // --- 3. عرض المحتوى (Grid/List) المتجاوب ---
  Widget _buildContentGrid(
      List<UserModel> users,
      bool isAr,
      bool isDark,
      Color cardBgColor,
      Color primaryColor,
      Color successColor,
      Color dangerColor,
      Color textPrimaryColor,
      Color textSecondaryColor
      ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 450,
          mainAxisExtent: 220,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _UserCard(
              user: users[index],
              isAr: isAr,
              isDark: isDark,
              cardBgColor: cardBgColor,
              primaryColor: primaryColor,
              successColor: successColor,
              dangerColor: dangerColor,
              textPrimaryColor: textPrimaryColor,
              textSecondaryColor: textSecondaryColor,
              onRefresh: _fetchData
          ),
          childCount: users.length,
        ),
      ),
    );
  }

  // ويدجت فرعية
  Widget _buildStatChip(String val, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
      ],
    );
  }

  Widget _buildFilterAction(IconData icon, bool isDark, Color cardBgColor, Color primaryColor) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: primaryColor),
      ),
    );
  }
}

// --- 4. بطاقة المستخدم الاحترافية (The User Card) ---
class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isAr, isDark;
  final Color cardBgColor, primaryColor, successColor, dangerColor, textPrimaryColor, textSecondaryColor;
  final VoidCallback onRefresh;

  const _UserCard({
    required this.user,
    required this.isAr,
    required this.isDark,
    required this.cardBgColor,
    required this.primaryColor,
    required this.successColor,
    required this.dangerColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                    user.name[0],
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        user.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textPrimaryColor
                        ),
                        maxLines: 1
                    ),
                    Text(
                        user.email,
                        style: TextStyle(color: textSecondaryColor, fontSize: 12),
                        maxLines: 1
                    ),
                  ],
                ),
              ),
              _StatusIndicator(isActive: user.status == 'active', successColor: successColor, dangerColor: dangerColor),
            ],
          ),
          Divider(height: 24, color: textSecondaryColor.withOpacity(0.2)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                    Icons.message_rounded,
                    "${user.totalMessages}",
                    isAr ? "رسالة" : "Msgs",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.calendar_today_rounded,
                    "${user.subscriptionDaysLeft}d",
                    isAr ? "متبقي" : "Left",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.group_rounded,
                    "${user.groups}",
                    isAr ? "مجموعة" : "Groups",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.block_rounded,
                    "${user.blockedGroups}",
                    isAr ? "محظورة" : "Blocked Groups",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.exit_to_app_rounded,
                    "${user.leftGroups}",
                    isAr ? "تم مغادرته" : "Left Groups",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.report_rounded,
                    "${user.suggestionsCount}",
                    isAr ? "اقتراح" : "Suggestions",
                    textPrimaryColor,
                    textSecondaryColor
                ),
                _buildMiniStat(
                    Icons.reply_rounded,
                    "${user.suggestionRepliesCount}",
                    isAr ? "رد" : "Replies",
                    textPrimaryColor,
                    textSecondaryColor
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserDetailsPage(user: user))
                  ),
                  icon: Icon(Icons.visibility_outlined, size: 16, color: primaryColor),
                  label: Text(
                    isAr ? "التفاصيل" : "Details",
                    style: TextStyle(color: primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ActionIcon(
                icon: user.status == 'active' ? Icons.block_rounded : Icons.check_circle_outline,
                color: user.status == 'active' ? dangerColor : successColor,
                onTap: () async {
                  final res = await http.put(Uri.parse("${AppConfig.apiBase}/api/users/toggle-status/${user.id}"));
                  if (res.statusCode == 200) onRefresh();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String val, String label, Color textPrimaryColor, Color textSecondaryColor) {
    return Column(
      children: [
        Icon(icon, size: 16, color: textSecondaryColor),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimaryColor)),
        Text(label, style: TextStyle(color: textSecondaryColor, fontSize: 10)),
      ],
    );
  }
}

// ويدجت الأيقونات التفاعلية
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isActive;
  final Color successColor;
  final Color dangerColor;
  const _StatusIndicator({
    required this.isActive,
    required this.successColor,
    required this.dangerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? successColor : dangerColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: (isActive ? successColor : dangerColor).withOpacity(0.4),
              blurRadius: 6
          ),
        ],
      ),
    );
  }
}