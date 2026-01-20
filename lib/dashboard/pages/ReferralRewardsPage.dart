import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/app_config.dart';
import '../../core/FeatureGrant.dart';
import '../../providers/app_providers.dart';

class ReferralRewardsPage extends StatefulWidget {
  const ReferralRewardsPage({super.key});

  @override
  State<ReferralRewardsPage> createState() => _ReferralRewardsPageState();
}

class _ReferralRewardsPageState extends State<ReferralRewardsPage>
    with SingleTickerProviderStateMixin {
  List<FeatureGrant> referralLogs = [];
  List<FeatureGrant> filteredLogs = [];
  bool isLoading = false;
  String searchQuery = '';
  String statusFilter = 'all';
  int currentPage = 1;
  int totalPages = 1;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // Premium Blue Gradient Palette
  final Color primaryBlue = const Color(0xFF1E40AF);
  final Color secondaryBlue = const Color(0xFF3B82F6);
  final Color accentBlue = const Color(0xFF60A5FA);
  final Color lightBlue = const Color(0xFFDEEBFF);
  final Color ultraLightBlue = const Color(0xFFF0F7FF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _searchController.addListener(_onSearchChanged);
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      _filterLogs();
    });
  }

  void _filterLogs() {
    if (searchQuery.isEmpty) {
      filteredLogs = referralLogs;
    } else {
      final query = searchQuery.toLowerCase();
      filteredLogs = referralLogs.where((log) {
        return log.referrer.toLowerCase().contains(query) ||
            log.email.toLowerCase().contains(query) ||
            log.feature.toLowerCase().contains(query) ||
            log.addedBy.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    _animationController.forward(from: 0);

    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}admin/feature-grants'
            '?status=$statusFilter'
            '&page=$currentPage',
      );

      final response = await http.get(uri);
      final body = jsonDecode(response.body);

      referralLogs =
          (body['data'] as List).map((e) => FeatureGrant.fromJson(e)).toList();
      totalPages = body['meta']?['last_page'] ?? 1;

      _filterLogs();
    } catch (e) {
      debugPrint("Error loading data: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(isArabic, isDark),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildEnhancedStatsGrid(isArabic, isDark),
                  _buildAdvancedSearchBar(isArabic, isDark),
                  _buildPremiumRewardsList(isArabic, isDark),
                  _buildModernPagination(isArabic, isDark),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Floating App Bar
  Widget _buildModernAppBar(bool isArabic, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FB5F5),
            Color(0xFF1B367A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'مركز المكافآت' : 'Rewards Center',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic ? 'إدارة الإحالات والمكافآت' : 'Manage Referrals & Rewards',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: loadData,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Stats Grid with Glassmorphism
  Widget _buildEnhancedStatsGrid(bool isArabic, bool isDark) {
    final totalGrants = filteredLogs.length;
    final uniqueReferrers = filteredLogs.map((e) => e.referrer).toSet().length;
    final totalPoints = filteredLogs.fold<int>(0, (s, e) => s + e.granted);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 5,
          children: [
            _buildGlassStatCard(
              label: isArabic ? 'إجمالي العمليات' : 'Total Grants',
              value: totalGrants.toString(),
              icon: Icons.assignment_turned_in_rounded,
              gradient: [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
              isDark: isDark,
            ),
            _buildGlassStatCard(
              label: isArabic ? 'المستخدمين النشطين' : 'Active Users',
              value: uniqueReferrers.toString(),
              icon: Icons.groups_rounded,
              gradient: [const Color(0xFF235C88), const Color(0xFF79ADFB)],
              isDark: isDark,
            ),
            _buildGlassStatCard(
              label: isArabic ? 'مجموع النقاط' : 'Total Points',
              value: totalPoints.toString(),
              icon: Icons.diamond_rounded,
              gradient: [const Color(0xFF2790DB), const Color(0xEF87BDE4)],
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Advanced Search Bar with Gradient Border
  Widget _buildAdvancedSearchBar(bool isArabic, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : primaryBlue.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: isArabic ? 'ابحث عن مستخدم أو بريد إلكتروني...' : 'Search user or email...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue.withOpacity(0.15), accentBlue.withOpacity(0.15)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${filteredLogs.length}',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  // Premium Rewards List with Enhanced Cards
  Widget _buildPremiumRewardsList(bool isArabic, bool isDark) {
    if (isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue.withOpacity(0.1), accentBlue.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'جاري التحميل...' : 'Loading...',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (referralLogs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: primaryBlue.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'لا توجد بيانات' : 'No Data Available',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'لا توجد مكافآت حاليًا' : 'No rewards available yet',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredLogs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: primaryBlue.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'لا توجد نتائج' : 'No Results Found',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'جرب البحث بكلمات مختلفة' : 'Try searching with different keywords',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final safeLogs = filteredLogs.where((e) => e != null).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final log = safeLogs[index];
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index / safeLogs.length) * 0.3,
                    ((index + 1) / safeLogs.length) * 0.3 + 0.7,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index / safeLogs.length) * 0.3,
                      ((index + 1) / safeLogs.length) * 0.3 + 0.7,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: _buildEnhancedRewardCard(log, isArabic, isDark),
              ),
            );
          },
          childCount: safeLogs.length,
        ),
      ),
    );
  }

  // Enhanced Reward Card with Modern Design
  Widget _buildEnhancedRewardCard(FeatureGrant log, bool isArabic, bool isDark) {
    final referrer = log.referrer.isNotEmpty ? log.referrer : '-';
    final email = log.email.isNotEmpty ? log.email : '-';
    final feature = log.feature.isNotEmpty ? log.feature : '-';
    final addedBy = log.addedBy.isNotEmpty ? log.addedBy : '-';
    final reason = log.reason.isNotEmpty ? log.reason : '-';
    final granted = log.granted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : primaryBlue.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : primaryBlue.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, secondaryBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referrer,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.email_rounded,
                                size: 14,
                                color: isDark ? Colors.white54 : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, secondaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_circle_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$granted',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : primaryBlue.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryBlue.withOpacity(0.15),
                                  accentBlue.withOpacity(0.15)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  size: 14,
                                  color: primaryBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  feature,
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 16,
                            color: isDark ? Colors.white38 : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            addedBy,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (reason != '-') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern Pagination with Gradient
  Widget _buildModernPagination(bool isArabic, bool isDark) {
    if (totalPages <= 1) return const SliverToBoxAdapter(child: SizedBox(height: 20));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : primaryBlue.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradientPaginationButton(
                icon: Icons.chevron_left_rounded,
                enabled: currentPage > 1,
                onTap: () {
                  currentPage--;
                  loadData();
                },
                isDark: isDark,
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currentPage',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '/',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '$totalPages',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _buildGradientPaginationButton(
                icon: Icons.chevron_right_rounded,
                enabled: currentPage < totalPages,
                onTap: () {
                  currentPage++;
                  loadData();
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
              colors: [primaryBlue.withOpacity(0.15), accentBlue.withOpacity(0.15)],
            )
                : null,
            color: enabled
                ? null
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
            border: enabled
                ? Border.all(
              color: primaryBlue.withOpacity(0.3),
              width: 1.5,
            )
                : null,
          ),
          child: Icon(
            icon,
            color: enabled ? primaryBlue : Colors.grey[400],
            size: 22,
          ),
        ),
      ),
    );
  }
}