import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/UserModel.dart';
import '../../core/app_config.dart';
import 'UserDetailsPage.dart';

// --- الهوية البصرية الجديدة (Premium Theme) ---
class ThemeLib {
  static const primary = Color(0xFF399EF3); // Indigo Modern
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const cardBgLight = Colors.white;
  static const cardBgDark = Color(0xFF1E1E2E);
  static const scaffoldBg = Color(0xFFF8FAFC);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
      backgroundColor: isDark ? const Color(0xFF121212) : ThemeLib.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernHeader(isAr, isDark),
          _buildFilterPanel(isAr, isDark),
          _isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : _buildContentGrid(filtered, isAr, isDark),
        ],
      ),
      // ✅ الزر العائم هنا
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _fetchData,
        backgroundColor: ThemeLib.primary,
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
  Widget _buildModernHeader(bool isAr, bool isDark) {
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
            gradient: LinearGradient(colors: [ThemeLib.primary, ThemeLib.primary.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: ThemeLib.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_motion_rounded, color: Colors.white, size: 30),
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
  Widget _buildFilterPanel(bool isAr, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? ThemeLib.cardBgDark : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: isAr ? "ابحث عن مستخدم..." : "Search user...",
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
                color: isDark ? ThemeLib.cardBgDark : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'active', child: Text('نشط')),
                  DropdownMenuItem(value: 'inactive', child: Text('غير نشط')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _statusFilter = v);
                },
              ),
            ),

            const SizedBox(width: 12),
            _buildFilterAction(Icons.filter_list_rounded, isDark),
          ],
        ),
      ),
    );
  }

  // --- 3. عرض المحتوى (Grid/List) المتجاوب ---
  Widget _buildContentGrid(List<UserModel> users, bool isAr, bool isDark) {
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
              (context, index) => _UserCard(user: users[index], isAr: isAr, isDark: isDark, onRefresh: _fetchData),
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

  Widget _buildFilterAction(IconData icon, bool isDark, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? ThemeLib.cardBgDark : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: ThemeLib.primary),
      ),
    );
  }
}

// --- 4. بطاقة المستخدم الاحترافية (The User Card) ---
class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isAr, isDark;
  final VoidCallback onRefresh;

  const _UserCard({required this.user, required this.isAr, required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThemeLib.cardBgDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ThemeLib.primary.withOpacity(0.1),
                child: Text(user.name[0], style: const TextStyle(color: ThemeLib.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                    Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                  ],
                ),
              ),
              _StatusIndicator(isActive: user.status == 'active'),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(Icons.message_rounded, "${user.totalMessages}", isAr ? "رسالة" : "Msgs"),
                _buildMiniStat(Icons.calendar_today_rounded, "${user.subscriptionDaysLeft}d", isAr ? "متبقي" : "Left"),
                _buildMiniStat(Icons.group_rounded, "${user.groups}", isAr ? "مجموعة" : "Groups"),
                _buildMiniStat(Icons.block_rounded, "${user.blockedGroups}", isAr ? "محظورة" : "Blocked Groups"),
                _buildMiniStat(Icons.exit_to_app_rounded, "${user.leftGroups}", isAr ? "تم مغادرته" : "Left Groups"),
                _buildMiniStat(Icons.report_rounded, "${user.suggestionsCount}", isAr ? "اقتراح" : "Suggestions"),
                _buildMiniStat(Icons.reply_rounded, "${user.suggestionRepliesCount}", isAr ? "رد" : "Replies"),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailsPage(user: user))),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(isAr ? "التفاصيل" : "Details"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeLib.primary.withOpacity(0.1),
                    foregroundColor: ThemeLib.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ActionIcon(
                icon: user.status == 'active' ? Icons.block_rounded : Icons.check_circle_outline,
                color: user.status == 'active' ? ThemeLib.danger : ThemeLib.success,
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

  Widget _buildMiniStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isActive;
  const _StatusIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: isActive ? ThemeLib.success : ThemeLib.danger,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: (isActive ? ThemeLib.success : ThemeLib.danger).withOpacity(0.4), blurRadius: 6)],
      ),
    );
  }
}