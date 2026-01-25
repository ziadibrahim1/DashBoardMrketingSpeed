import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/Suggestion.dart';
import '../../Models/suggestions_service.dart';
import '../../providers/app_providers.dart';

enum SuggestionFilter {
  all,
  newest,
  replied,
  notReplied,
  starred,
}

class SuggestionsManagementPage extends StatefulWidget {
  const SuggestionsManagementPage({super.key});
  @override
  State<SuggestionsManagementPage> createState() =>
      _SuggestionsManagementPageState();
}

class _SuggestionsManagementPageState extends State<SuggestionsManagementPage> {
  static const int pageSize = 20;
  List<Suggestion> suggestions = [];
  bool isLoading = true;
  String? loadError;
  int currentPage = 1;
  SuggestionFilter selectedFilter = SuggestionFilter.all;
  String usernameSearch = '';
  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final data = await SuggestionsService.fetchSuggestions(
          localeProvider.locale.languageCode == 'ar');

      setState(() {
        suggestions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadError = e.toString();
        isLoading = false;
      });
      debugPrint('Failed to load suggestions: $e');
    }
  }

  void _replyToSuggestion(Suggestion suggestion, bool isArabic, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        String replyText = suggestion.adminReply ?? '';
        final textController = TextEditingController(text: replyText);

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.reply_rounded,
                    color: isDark ? const Color(0xFF81C784) : Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isArabic ? 'رد إداري' : 'Admin Reply',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFA5D6A7) : Colors.blue.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(minHeight: 150),
              child: TextField(
                maxLines: 5,
                controller: textController,
                onChanged: (value) => replyText = value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: isArabic ? 'اكتب الرد هنا...' : 'Write reply here...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : Colors.blue.shade50.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF388E3C) : Colors.blue.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF388E3C) : Colors.blue.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF81C784) : Colors.blue.shade600,
                      width: 2,
                    ),
                  ),
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  isArabic ? 'إلغاء' : 'Cancel',
                  style: const TextStyle(fontSize: 15),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF388E3C) : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isArabic ? 'إرسال' : 'Send',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final trimmedReply = replyText.trim();
                  if (trimmedReply.isEmpty) return;

                  try {
                    await SuggestionsService.replyToSuggestion(
                      suggestion.id,
                      trimmedReply,
                    );

                    setState(() {
                      suggestion.adminReply = trimmedReply;
                      suggestion.isNew = false; // 🔥 خلاص بقى قديم
                    });

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic ? 'فشل إرسال الرد' : 'Failed to send reply',
                        ),
                      ),
                    );
                  }
                },

              ),
            ],
          ),
        );
      },
    );
  }

  List<Suggestion> getFilteredSuggestions() {
    List<Suggestion> filtered = [...suggestions];

    // 🔍 فلترة حسب اسم المستخدم
    if (usernameSearch.isNotEmpty) {
      filtered = filtered.where((s) =>
          s.username.toLowerCase().contains(usernameSearch.toLowerCase())
      ).toList();
    }

    switch (selectedFilter) {
      case SuggestionFilter.all:
        break;
      case SuggestionFilter.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SuggestionFilter.replied:
        filtered = filtered.where((s) => s.adminReply != null).toList();
        break;
      case SuggestionFilter.notReplied:
        filtered = filtered.where((s) => s.adminReply == null).toList();
        break;
      case SuggestionFilter.starred:
        filtered = filtered.where((s) => s.isStarred).toList();
        break;
    }

    return filtered;
  }

  List<Suggestion> getPagedSuggestions(List<Suggestion> filtered) {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > filtered.length
        ? filtered.length
        : (start + pageSize);
    return filtered.sublist(start, end);
  }

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(bool isDark) {
    if (isDark) {
      // ألوان خضراء للوضع الداكن
      return {
        'primary': const Color(0xFF388E3C),     // أخضر داكن
        'secondary': const Color(0xFF4CAF50),    // أخضر متوسط
        'light': const Color(0xFF81C784),        // أخضر فاتح
        'background': const Color(0xFF1E2720),   // خلفية خضراء داكنة
        'card': const Color(0xFF263238),         // كارت أخضر داكن
      };
    } else {
      // ألوان زرقاء للوضع الفاتح
      return {
        'primary': Colors.blue.shade700,
        'secondary': Colors.blue.shade600,
        'light': Colors.blue.shade400,
        'background': const Color(0xFFF5F7FA),
        'card': Colors.white,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _getColors(isDark);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? const Color(0xFF4CAF50) : Colors.blue.shade600,
          ),
        ),
      );
    }

    if (loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              loadError!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredSuggestions = getFilteredSuggestions();
    final titles = _getLocalizedTitles(isArabic);
    final pagedSuggestions = getPagedSuggestions(filteredSuggestions);
    final totalPages = (filteredSuggestions.length / pageSize).ceil();
    final newCount = suggestions.where((s) => s.isNew).length;
    final totalCount = suggestions.length;

    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1419) : colors['background']!,
        body: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [
                            Color(0xFF1B5E20),
                            Color(0xFF2E7D32),
                          ]
                              : const [Color(0xFF4FB5F5), Color(0xFF1B367A)],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// ===== Title Row =====
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.dashboard_customize_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    titles['pageTitle']!,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            /// ===== Stats Cards =====
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.inventory_2_rounded,
                                    label: titles['totalSuggestions']!,
                                    count: totalCount,
                                    color: Colors.white,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.fiber_new_rounded,
                                    label: titles['newSuggestions']!,
                                    count: newCount,
                                    color: Colors.white,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filter Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colors['card']! : colors['card']!,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: isDark ? colors['light']! : colors['primary']!,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArabic ? 'تصفية حسب:' : 'Filter by:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? colors['light']! : colors['primary']!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colors['primary']!.withOpacity(0.2)
                                : colors['primary']!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? colors['primary']!
                                  : colors['primary']!.withOpacity(0.5),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SuggestionFilter>(
                              value: selectedFilter,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark ? colors['light']! : colors['primary']!,
                              ),
                              dropdownColor: isDark ? colors['card']! : colors['card']!,
                              items: [
                                _buildFilterItem(SuggestionFilter.all, titles['allSuggestions']!, Icons.all_inclusive_rounded, isDark, colors),
                                _buildFilterItem(SuggestionFilter.newest, titles['newestFirst']!, Icons.new_releases_rounded, isDark, colors),
                                _buildFilterItem(SuggestionFilter.replied, titles['replied']!, Icons.check_circle_rounded, isDark, colors),
                                _buildFilterItem(SuggestionFilter.notReplied, titles['notReplied']!, Icons.schedule_rounded, isDark, colors),
                                _buildFilterItem(SuggestionFilter.starred, titles['starred']!, Icons.star_rounded, isDark, colors),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedFilter = val;
                                    currentPage = 1;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              usernameSearch = value;
                              currentPage = 1; // ⬅️ يرجع لأول صفحة
                            });
                          },
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? 'بحث باسم المستخدم...'
                                : 'Search by username...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark ? colors['light']! : colors['primary']!,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? colors['primary']!.withOpacity(0.2)
                                : colors['primary']!.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? colors['primary']! : colors['primary']!.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? colors['primary']! : colors['primary']!.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? colors['light']! : colors['primary']!,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            // Suggestions List
            pagedSuggestions.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 80,
                      color: isDark ? colors['primary']! : colors['primary']!.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titles['noSuggestions']!,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final suggestion = pagedSuggestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSuggestionCard(
                        suggestion,
                        isArabic,
                        isDark,
                        textDirection,
                        titles,
                        colors,
                      ),
                    );
                  },
                  childCount: pagedSuggestions.length,
                ),
              ),
            ),

            // Pagination
            if (totalPages > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: _buildPagination(totalPages, isDark, colors),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<SuggestionFilter> _buildFilterItem(
      SuggestionFilter value, String label, IconData icon, bool isDark, Map<String, Color> colors) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? colors['light']! : colors['primary']!,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? colors['light']! : colors['primary']!,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
      Suggestion suggestion,
      bool isArabic,
      bool isDark,
      TextDirection textDirection,
      Map<String, String> titles,
      Map<String, Color> colors,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors['card']! : colors['card']!,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? colors['primary']!.withOpacity(0.3) : colors['primary']!.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : colors['primary']!.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  colors['primary']!.withOpacity(0.3),
                  colors['secondary']!.withOpacity(0.2),
                ]
                    : [
                  colors['primary']!.withOpacity(0.1),
                  colors['primary']!.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              textDirection: textDirection,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? colors['primary']! : colors['primary']!,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Text(
                        suggestion.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark ? colors['light']! : colors['primary']!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(suggestion.createdAt, isArabic),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? colors['light']!.withOpacity(0.8) : colors['primary']!.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (suggestion.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_new_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          titles['newTag']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors['primary']!.withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    tooltip: suggestion.isStarred ? titles['unmark']! : titles['mark']!,
                    icon: Icon(
                      suggestion.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: suggestion.isStarred
                          ? Colors.amber.shade600
                          : (isDark ? colors['light']!.withOpacity(0.6) : colors['primary']!.withOpacity(0.4)),
                      size: 26,
                    ),
                    onPressed: () async {
                      try {
                        await SuggestionsService.toggleStar(suggestion.id, !suggestion.isStarred);
                        setState(() {
                          suggestion.isStarred = !suggestion.isStarred;
                        });
                      } catch (e) {
                        debugPrint('Failed to toggle star: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to mark/unmark suggestion')),
                        );
                      }
                    },
                  ),

                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors['primary']!.withOpacity(0.1)
                        : colors['primary']!.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? colors['primary']!.withOpacity(0.3) : colors['primary']!.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    isArabic ? suggestion.contentAr : suggestion.contentEn,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark ? colors['light']! : colors['primary']!,
                    ),
                    textDirection: textDirection,
                  ),
                ),

                if (suggestion.adminReply != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                          colors['primary']!.withOpacity(0.3),
                          colors['secondary']!.withOpacity(0.2),
                        ]
                            : [
                          colors['primary']!.withOpacity(0.1),
                          colors['primary']!.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? colors['primary']!.withOpacity(0.5) : colors['primary']!.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      textDirection: textDirection,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? colors['primary']! : colors['primary']!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Text(
                                isArabic ? 'رد الإدارة:' : 'Admin Reply:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? colors['light']! : colors['primary']!,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                suggestion.adminReply!,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: isDark ? colors['light']! : colors['primary']!,
                                ),
                                textDirection: textDirection,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Align(
                  alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _replyToSuggestion(suggestion, isArabic, isDark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? colors['primary']! : colors['primary']!,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.reply_rounded, size: 20),
                    label: Text(
                      titles['adminReply']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPagination(int totalPages, bool isDark, Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors['card']! : colors['card']!,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(totalPages, (index) {
          final pageNum = index + 1;
          final isSelected = pageNum == currentPage;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  currentPage = pageNum;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [colors['primary']!, colors['secondary']!]
                        : [colors['primary']!, colors['secondary']!],
                  )
                      : null,
                  color: isSelected
                      ? null
                      : isDark
                      ? colors['primary']!.withOpacity(0.2)
                      : colors['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? colors['light']! : colors['primary']!)
                        : (isDark ? colors['primary']! : colors['primary']!.withOpacity(0.3)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: colors['primary']!.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? colors['light']! : colors['primary']!),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date, bool isArabic) {
    final months = isArabic
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    if (isArabic) {
      return '$day $month $year';
    } else {
      return '$month $day, $year';
    }
  }

  Map<String, String> _getLocalizedTitles(bool isArabic) {
    return {
      'pageTitle': isArabic ? 'إدارة اقتراحات المستخدمين' : 'User Suggestions Management',
      'totalSuggestions': isArabic ? 'إجمالي الاقتراحات' : 'Total Suggestions',
      'newSuggestions': isArabic ? 'الاقتراحات الجديدة' : 'New Suggestions',
      'allSuggestions': isArabic ? 'كل الاقتراحات' : 'All Suggestions',
      'newestFirst': isArabic ? 'الأحدث أولاً' : 'Newest First',
      'replied': isArabic ? 'تم الرد عليها' : 'Replied',
      'notReplied': isArabic ? 'لم يتم الرد عليها' : 'Not Replied',
      'starred': isArabic ? 'المميزة ★' : 'Starred ★',
      'noSuggestions': isArabic ? 'لا توجد اقتراحات' : 'No Suggestions',
      'adminReply': isArabic ? 'رد إداري' : 'Admin Reply',
      'cancel': isArabic ? 'إلغاء' : 'Cancel',
      'send': isArabic ? 'إرسال' : 'Send',
      'replyHint': isArabic ? 'اكتب الرد هنا...' : 'Write reply here...',
      'mark': isArabic ? 'تمييز الاقتراح' : 'Mark Suggestion',
      'unmark': isArabic ? 'إلغاء التمييز' : 'Unmark Suggestion',
      'newTag': isArabic ? 'جديد' : 'New',
      'page': isArabic ? 'صفحة' : 'Page',
      'of': isArabic ? 'من' : 'of',
    };
  }
}