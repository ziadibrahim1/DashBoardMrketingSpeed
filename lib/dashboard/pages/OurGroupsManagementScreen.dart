import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/api_service.dart';
import '../../providers/app_providers.dart';

class OurGroupsManagementScreen extends StatefulWidget {
  const OurGroupsManagementScreen({super.key});

  @override
  State<OurGroupsManagementScreen> createState() => _OurGroupsManagementScreenState();
}

class _OurGroupsManagementScreenState extends State<OurGroupsManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allCountries = [];
  List<Map<String, dynamic>> allCategories = [];
  Set<int> selectedCountryIds = {};
  Set<int> selectedCategoryIds = {};
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allGroups = [];
  bool showLockedOnly = false;
  bool showFiltersPanel = false;
  int currentPage = 0;
  final int groupsPerPage = 20;
  bool _isLoading = true;
  String viewMode = 'grid';

  // ألوان محسّنة
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF64B5F6);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF2742B0);
  static const Color backgroundColor = Color(0xFFF5F9FF);
  static const Color cardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1E2732);
  static const Color darkBackground = Color(0xFF0D1117);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final countries = await ApiService.getCountries();
      final categories = await ApiService.getCategories();
      final groups = await ApiService.getGroups();

      setState(() {
        allCountries = List<Map<String, dynamic>>.from(countries);
        allCategories = List<Map<String, dynamic>>.from(categories);
        allGroups = groups.map<Map<String, dynamic>>((g) => {
          'id': g['id'] ?? 0,
          'name': g['groupName'] ?? '',
          'link': g['inviteLink'] ?? '',
          'countryId': g['countryId'] ?? 0,
          'countryName': g['countryName'] ?? '',
          'categoryId': g['categoryId'] ?? 0,
          'categoryName': g['categoryName'] ?? '',
          'isVisible': g['isHidden'] != true,
          'isSendingLocked': g['sendingStatus'] == 'closed',
          'membersCount': '0',
          'members': [],
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ في تحميل البيانات')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredGroups {
    return allGroups.where((group) {
      final nameMatch = (group['name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      final countryId = group['countryId'];
      final categoryId = group['categoryId'];

      final countryMatch = selectedCountryIds.isEmpty ||
          (countryId != null && countryId != 0 && selectedCountryIds.contains(countryId));
      final categoryMatch = selectedCategoryIds.isEmpty ||
          (categoryId != null && categoryId != 0 && selectedCategoryIds.contains(categoryId));
      final lockMatch = !showLockedOnly || group['isSendingLocked'] == true;

      return nameMatch && countryMatch && categoryMatch && lockMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? darkBackground : backgroundColor;
    final cardBg = isDark ? darkCardColor : cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? _buildLoadingState(isArabic, textColor)
          : CustomScrollView(
        slivers: [
          _buildAppBar(isArabic, isDark),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchAndActions(isArabic, isDark, cardBg, textColor),
                if (showFiltersPanel)
                  _buildFiltersPanel(isArabic, isDark, cardBg, textColor),
                _buildStatsBar(isArabic, isDark, cardBg, textColor),
              ],
            ),
          ),
          _buildGroupsContent(isArabic, isDark, cardBg, textColor),
        ],
      ),
      floatingActionButton: _buildFloatingActions(isArabic, isDark),
    );
  }

  Widget _buildLoadingState(bool isArabic, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'جاري التحميل...' : 'Loading...',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isArabic, bool isDark) {
    return SliverAppBar(
      expandedHeight: 50,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isArabic ? 'إدارة الجروبات' : 'Groups Management',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, darkBlue, accentPurple],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          tooltip: isArabic ? 'إعادة تحميل' : 'Reload',
          onPressed: _loadData,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 22),
          onSelected: (value) {
            if (value == 'clear') {
              setState(() {
                selectedCountryIds.clear();
                selectedCategoryIds.clear();
                searchController.clear();
                showLockedOnly = false;
                currentPage = 0;
              });
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.clear_all_rounded, color: primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(isArabic ? 'مسح جميع الفلاتر' : 'Clear All Filters'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  void _showAddCategoryDialog(
      String title,
      bool isDark,
      bool isArabic,
      ) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameArController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم المجال (عربي)' : 'Category Name (Arabic)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم المجال (إنجليزي)' : 'Category Name (English)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(isArabic ? 'حفظ' : 'Save'),
              onPressed: () async {
                if (nameArController.text.trim().isEmpty) {
                  _showErrorSnackBar(
                    isArabic
                        ? 'يرجى إدخال اسم المجال بالعربي'
                        : 'Arabic name is required',
                  );
                  return;
                }

                try {
                  await ApiService.saveCategory({
                    'nameAr': nameArController.text.trim(),
                    'nameEn': nameEnController.text.trim(),
                  });

                  Navigator.pop(context);
                  await _loadData();

                  if (mounted) {
                    _showSuccessSnackBar(
                      isArabic
                          ? 'تم إضافة المجال بنجاح'
                          : 'Category added successfully',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar(
                      isArabic
                          ? 'فشل في إضافة المجال'
                          : 'Failed to add category',
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndActions(bool isArabic, bool isDark, Color cardBg, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() => currentPage = 0),
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: isArabic ? 'ابحث...' : 'Search...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: primaryBlue, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade600, size: 18),
                  onPressed: () => setState(() {
                    searchController.clear();
                    currentPage = 0;
                  }),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionChip(
                  icon: Icons.filter_list_rounded,
                  label: isArabic ? 'فلاتر' : 'Filters',
                  isActive: showFiltersPanel,
                  count: selectedCountryIds.length + selectedCategoryIds.length,
                  onTap: () => setState(() => showFiltersPanel = !showFiltersPanel),
                  gradient: const LinearGradient(colors: [primaryBlue, darkBlue]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionChip(
                  icon: Icons.lock_rounded,
                  label: isArabic ? 'مقفلة' : 'Locked',
                  isActive: showLockedOnly,
                  onTap: () => setState(() {
                    showLockedOnly = !showLockedOnly;
                    currentPage = 0;
                  }),
                  gradient: const LinearGradient(colors: [accentOrange, Colors.deepOrange]),
                ),
              ),
              const SizedBox(width: 8),
              _buildViewModeButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isActive,
    int count = 0,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Material(
      color: isActive ? Colors.transparent : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: isActive ? gradient : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.3) : primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isActive ? Colors.white : primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButton(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeIcon(Icons.grid_view_rounded, 'grid'),
          _buildViewModeIcon(Icons.view_list_rounded, 'list'),
        ],
      ),
    );
  }

  Widget _buildViewModeIcon(IconData icon, String mode) {
    final isActive = viewMode == mode;
    return Material(
      color: isActive ? primaryBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => setState(() => viewMode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade600,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(bool isArabic, bool isDark, Color cardBg, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primaryBlue, lightBlue]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'الدول' : 'Countries',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              if (selectedCountryIds.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => selectedCountryIds.clear()),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: Text(isArabic ? 'مسح' : 'Clear', style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.add_rounded, color: primaryBlue, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () => _showAddCountryDialog(
                  isArabic ? 'إضافة دولة جديدة' : 'Add New Country',
                  isDark,
                  isArabic,
                ),
              ),

            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allCountries.map((country) {
              final int? id = country['id'];
              if (id == null) return const SizedBox.shrink();
              final bool selected = selectedCountryIds.contains(id);
              return _buildFilterChip(
                label: country['name'] ?? '',
                isSelected: selected,
                onTap: () => setState(() {
                  selected ? selectedCountryIds.remove(id) : selectedCountryIds.add(id);
                  currentPage = 0;
                }),
                isDark: isDark,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [accentOrange, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.category_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'المجالات' : 'Categories',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              if (selectedCategoryIds.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => selectedCategoryIds.clear()),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: Text(isArabic ? 'مسح' : 'Clear', style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.add_rounded, color: accentOrange, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () => _showAddCategoryDialog(
                  isArabic ? 'إضافة مجال جديد' : 'Add New Category',
                  isDark,
                  isArabic,
                ),
              ),

            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allCategories.map((category) {
              final int? id = category['id'];
              if (id == null) return const SizedBox.shrink();
              final bool selected = selectedCategoryIds.contains(id);
              return _buildFilterChip(
                label: category['name'] ?? '',
                isSelected: selected,
                onTap: () => setState(() {
                  selected ? selectedCategoryIds.remove(id) : selectedCategoryIds.add(id);
                  currentPage = 0;
                }),
                isDark: isDark,
                color: accentOrange,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color color = primaryBlue,
  }) {
    return Material(
      color: isSelected ? color : (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(bool isArabic, bool isDark, Color cardBg, Color textColor) {
    final total = allGroups.length;
    final filtered = filteredGroups.length;
    final visible = filteredGroups.where((g) => g['isVisible'] == true).length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.08), accentPurple.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.groups_rounded,
              label: isArabic ? 'الإجمالي' : 'Total',
              value: '$total',
              color: primaryBlue,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              icon: Icons.filter_list_rounded,
              label: isArabic ? 'النتائج' : 'Results',
              value: '$filtered',
              color: accentOrange,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              icon: Icons.visibility_rounded,
              label: isArabic ? 'ظاهرة' : 'Visible',
              value: '$visible',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsContent(bool isArabic, bool isDark, Color cardBg, Color textColor) {
    final paginatedGroups = filteredGroups
        .skip(currentPage * groupsPerPage)
        .take(groupsPerPage)
        .toList();

    if (filteredGroups.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue.withOpacity(0.1), lightBlue.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'لا توجد جروبات مطابقة' : 'No matching groups',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isArabic ? 'جرب تغيير الفلاتر أو البحث' : 'Try changing filters or search',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (viewMode == 'grid') {
      return SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index == paginatedGroups.length) {
                return _buildPagination(isArabic, isDark);
              }
              return _buildGroupGridCard(
                paginatedGroups[index],
                isArabic,
                isDark,
                cardBg,
                textColor,
              );
            },
            childCount: paginatedGroups.length + 1,
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == paginatedGroups.length) {
              return _buildPagination(isArabic, isDark);
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                index == 0 ? 12 : 5,
                12,
                index == paginatedGroups.length - 1 ? 12 : 5,
              ),
              child: _buildGroupListCard(
                paginatedGroups[index],
                isArabic,
                isDark,
                cardBg,
                textColor,
              ),
            );
          },
          childCount: paginatedGroups.length + 1,
        ),
      );
    }
  }

  Widget _buildGroupGridCard(
      Map<String, dynamic> group,
      bool isArabic,
      bool isDark,
      Color cardBg,
      Color textColor,
      ) {
    final isLocked = group['isSendingLocked'] == true;
    final isVisible = group['isVisible'] == true;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? accentOrange.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showGroupDetails(group, isArabic, isDark),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLocked
                              ? [accentOrange, Colors.deepOrange]
                              : [primaryBlue, lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : Icons.group_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVisible ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            size: 10,
                            color: isVisible ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group['name'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (group['countryName']?.toString().isNotEmpty == true)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 11, color: primaryBlue),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                group['countryName'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (group['categoryName']?.toString().isNotEmpty == true)
                        Row(
                          children: [
                            Icon(Icons.category, size: 11, color: accentOrange),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                group['categoryName'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniButton(
                        icon: Icons.link_rounded,
                        label: isArabic ? 'رابط' : 'Link',
                        onTap: () => _openGroupLink(group['link'] ?? ''),
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildMiniButton(
                        icon: Icons.edit_rounded,
                        label: isArabic ? 'تعديل' : 'Edit',
                        onTap: () => _editGroup(group, isArabic, isDark),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupListCard(
      Map<String, dynamic> group,
      bool isArabic,
      bool isDark,
      Color cardBg,
      Color textColor,
      ) {
    final isLocked = group['isSendingLocked'] == true;
    final isVisible = group['isVisible'] == true;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? accentOrange.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showGroupDetails(group, isArabic, isDark),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLocked
                          ? [accentOrange, Colors.deepOrange]
                          : [primaryBlue, lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : Icons.group_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (group['countryName']?.toString().isNotEmpty == true) ...[
                            Icon(Icons.location_on, size: 12, color: primaryBlue),
                            const SizedBox(width: 3),
                            Text(
                              group['countryName'] ?? '',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (group['categoryName']?.toString().isNotEmpty == true) ...[
                            Icon(Icons.category, size: 12, color: accentOrange),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                group['categoryName'] ?? '',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVisible ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    size: 14,
                    color: isVisible ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.link_rounded, size: 20),
                  color: primaryBlue,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () => _openGroupLink(group['link'] ?? ''),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: Colors.green,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: () => _editGroup(group, isArabic, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(bool isArabic, bool isDark) {
    final totalPages = (filteredGroups.length / groupsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              isArabic ? Icons.chevron_right : Icons.chevron_left,
              color: currentPage > 0 ? primaryBlue : Colors.grey.shade400,
            ),
            onPressed: currentPage > 0
                ? () => setState(() => currentPage--)
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryBlue, lightBlue]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${currentPage + 1} / $totalPages',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isArabic ? Icons.chevron_left : Icons.chevron_right,
              color: currentPage < totalPages - 1 ? primaryBlue : Colors.grey.shade400,
            ),
            onPressed: currentPage < totalPages - 1
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(bool isArabic, bool isDark) {
    return FloatingActionButton(
      onPressed: () => _addNewGroup(isArabic, isDark),
      backgroundColor: primaryBlue,
      child: const Icon(Icons.add_rounded, color: Colors.white),
    );
  }

  void _openGroupLink(String link) async {
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرابط غير متاح')),
      );
      return;
    }
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showGroupDetails(Map<String, dynamic> group, bool isArabic, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGroupDetailsSheet(group, isArabic, isDark),
    );
  }

  Widget _buildGroupDetailsSheet(Map<String, dynamic> group, bool isArabic, bool isDark) {
    final cardBg = isDark ? darkCardColor : cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isLocked = group['isSendingLocked'] == true;
    final isVisible = group['isVisible'] == true;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLocked ? [accentOrange, Colors.deepOrange] : [primaryBlue, lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : Icons.group_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isArabic ? 'تفاصيل الجروب' : 'Group Details',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDetailRow(
                  Icons.public_rounded,
                  isArabic ? 'الدولة' : 'Country',
                  group['countryName'] ?? (isArabic ? 'غير محدد' : 'Not specified'),
                  primaryBlue,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.category_rounded,
                  isArabic ? 'المجال' : 'Category',
                  group['categoryName'] ?? (isArabic ? 'غير محدد' : 'Not specified'),
                  accentOrange,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.link_rounded,
                  isArabic ? 'رابط الانضمام' : 'Join Link',
                  group['link'] ?? (isArabic ? 'لا يوجد رابط' : 'No link'),
                  Colors.blue,
                  isCopyable: true,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'الإعدادات' : 'Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  icon: Icons.visibility_rounded,
                  title: isArabic ? 'إظهار الجروب' : 'Show Group',
                  value: isVisible,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    await _toggleVisibility(group);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  icon: Icons.lock_rounded,
                  title: isArabic ? 'قفل الإرسال' : 'Lock Sending',
                  value: isLocked,
                  activeColor: accentOrange,
                  onChanged: (value) async {
                    await _toggleLock(group);
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editGroup(group, isArabic, isDark);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: Text(isArabic ? 'تعديل' : 'Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteGroup(group, isArabic);
                    },
                    icon: const Icon(Icons.delete_rounded, size: 18),
                    label: Text(isArabic ? 'حذف' : 'Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color, {bool isCopyable = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCopyable && value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: color,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value.startsWith('http') ? 'تم نسخ الرابط' : 'تم النسخ'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color activeColor,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? activeColor : Colors.grey),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _toggleVisibility(Map<String, dynamic> group) async {
    try {
      final newVisibility = !(group['isVisible'] == true);
      await ApiService.updateGroup(group['id'], {
        'isHidden': !newVisibility,
      });
      setState(() {
        group['isVisible'] = newVisibility;
      });
      _showSuccessSnackBar('تم تحديث حالة الظهور');
    } catch (e) {
      _showErrorSnackBar('فشل في تحديث حالة الظهور');
    }
  }

  Future<void> _toggleLock(Map<String, dynamic> group) async {
    try {
      final newLockStatus = !(group['isSendingLocked'] == true);
      await ApiService.updateGroup(group['id'], {
        'sendingStatus': newLockStatus ? 'closed' : 'open',
      });
      setState(() {
        group['isSendingLocked'] = newLockStatus;
      });
      _showSuccessSnackBar('تم تحديث حالة الإرسال');
    } catch (e) {
      _showErrorSnackBar('فشل في تحديث حالة الإرسال');
    }
  }

  void _editGroup(Map<String, dynamic> group, bool isArabic, bool isDark) {
    final nameController = TextEditingController(text: group['name']);
    final linkController = TextEditingController(text: group['link']);
    int? selectedCountryId = group['countryId'];
    int? selectedCategoryId = group['categoryId'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [Colors.white, const Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'تعديل الجروب' : 'Edit Group',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic ? 'قم بتحديث معلومات المجموعة' : 'Update group information',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: nameController,
                          label: isArabic ? 'اسم الجروب' : 'Group Name',
                          icon: Icons.group_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: linkController,
                          label: isArabic ? 'رابط الانضمام' : 'Join Link',
                          icon: Icons.link_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown<int>(
                          value: selectedCountryId != 0 ? selectedCountryId : null,
                          label: isArabic ? 'الدولة' : 'Country',
                          icon: Icons.public_rounded,
                          items: allCountries,
                          isDark: isDark,
                          onChanged: (value) => setDialogState(() => selectedCountryId = value),
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown<int>(
                          value: selectedCategoryId != 0 ? selectedCategoryId : null,
                          label: isArabic ? 'المجال' : 'Category',
                          icon: Icons.category_rounded,
                          items: allCategories,
                          isDark: isDark,
                          onChanged: (value) => setDialogState(() => selectedCategoryId = value),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'إلغاء' : 'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              _showErrorSnackBar(isArabic ? 'الرجاء إدخال اسم الجروب' : 'Please enter group name');
                              return;
                            }
                            try {
                              await ApiService.updateGroup(group['id'], {
                                'groupName': nameController.text,
                                'inviteLink': linkController.text,
                                'countryId': selectedCountryId,
                                'categoryId': selectedCategoryId,
                              });
                              await _loadData();
                              Navigator.pop(context);
                              _showSuccessSnackBar(isArabic ? 'تم تحديث الجروب بنجاح' : 'Group updated successfully');
                            } catch (e) {
                              _showErrorSnackBar(isArabic ? 'فشل في تحديث الجروب' : 'Failed to update group');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? 'حفظ التعديلات' : 'Save Changes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  void _addNewGroup(bool isArabic, bool isDark) {
    final nameController = TextEditingController();
    final linkController = TextEditingController();
    int? selectedCountryId;
    int? selectedCategoryId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [Colors.white, const Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'إضافة جروب جديد' : 'Add New Group',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArabic ? 'أنشئ مجموعة جديدة' : 'Create a new group',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: nameController,
                          label: isArabic ? 'اسم الجروب' : 'Group Name',
                          icon: Icons.group_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: linkController,
                          label: isArabic ? 'رابط الانضمام' : 'Join Link',
                          icon: Icons.link_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown<int>(
                          value: selectedCountryId,
                          label: isArabic ? 'الدولة' : 'Country',
                          icon: Icons.public_rounded,
                          items: allCountries,
                          isDark: isDark,
                          onChanged: (value) => setDialogState(() => selectedCountryId = value),
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown<int>(
                          value: selectedCategoryId,
                          label: isArabic ? 'المجال' : 'Category',
                          icon: Icons.category_rounded,
                          items: allCategories,
                          isDark: isDark,
                          onChanged: (value) => setDialogState(() => selectedCategoryId = value),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'إلغاء' : 'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              _showErrorSnackBar(isArabic ? 'الرجاء إدخال اسم الجروب' : 'Please enter group name');
                              return;
                            }
                            try {
                              await ApiService.saveGroup({
                                'groupName': nameController.text,
                                'inviteLink': linkController.text,
                                'countryId': selectedCountryId,
                                'categoryId': selectedCategoryId,
                              });
                              await _loadData();
                              Navigator.pop(context);
                              _showSuccessSnackBar(isArabic ? 'تم إضافة الجروب بنجاح' : 'Group added successfully');
                            } catch (e) {
                              _showErrorSnackBar(isArabic ? 'فشل في إضافة الجروب' : 'Failed to add group');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? 'إضافة الجروب' : 'Add Group',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // Helper widget for modern text field
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
        ),
      ),
    );
  }

  // Helper widget for modern dropdown
  Widget _buildModernDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required bool isDark,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item['id'] as T,
            child: Text(item['name'] ?? ''),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
  void _deleteGroup(Map<String, dynamic> group, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف "${group['name']}"؟'
              : 'Are you sure you want to delete "${group['name']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deleteGroup(group['id']);
                await _loadData();
                Navigator.pop(context);
                _showSuccessSnackBar(isArabic ? 'تم حذف الجروب بنجاح' : 'Group deleted successfully');
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackBar(isArabic ? 'فشل في حذف الجروب' : 'Failed to delete group');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }


  void _showAddCountryDialog(
      String title,
      bool isDark,
      bool isArabic,
      ) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    final isoCodeController = TextEditingController();
    final phoneCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameArController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الدولة (عربي)' : 'Country Name (Arabic)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameEnController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الدولة (إنجليزي)' : 'Country Name (English)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: isoCodeController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'كود الدولة (اول حرفين كبار بالانجليزية)' : 'ISO Code',
                    hintText: 'SA',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCodeController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'كود الهاتف' : 'Phone Code',
                    hintText: '+966....',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(isArabic ? 'حفظ' : 'Save'),
              onPressed: () async {
                if (nameArController.text.isEmpty ||
                    isoCodeController.text.isEmpty) {
                  _showErrorSnackBar(
                    isArabic
                        ? 'يرجى إدخال اسم الدولة وكود ISO'
                        : 'Name and ISO Code are required',
                  );
                  return;
                }

                try {
                  await ApiService.saveCountry({
                    'nameAr': nameArController.text.trim(),
                    'nameEn': nameEnController.text.trim(),
                    'isoCode': isoCodeController.text.trim(),
                    'phoneCode': phoneCodeController.text.trim(),
                  });

                  Navigator.pop(context);
                  await _loadData();

                  if (mounted) {
                    _showSuccessSnackBar(
                      isArabic
                          ? 'تم إضافة الدولة بنجاح'
                          : 'Country added successfully',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar(
                      isArabic
                          ? 'فشل في إضافة الدولة'
                          : 'Failed to add country',
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}