import 'package:flutter/material.dart';
import '../../core/ConversationModel.dart';
import 'ChatReviewDialog.dart';

class AdminChatHistoryScreen extends StatefulWidget {
  const AdminChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminChatHistoryScreen> createState() => _AdminChatHistoryScreenState();
}

class _AdminChatHistoryScreenState extends State<AdminChatHistoryScreen> {
  String searchQuery = "";
  String filterStatus = "الكل";
  String filterTag = "الكل";
  bool isLoading = true;
  List<AdminChatHistoryModel> allConversations = [];

  // درجات اللون الأزرق الاحترافية للوضع الفاتح
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color accentBlue = const Color(0xFF2196F3);

  // درجات اللون الأخضر للوضع الداكن
  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color lightGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    setState(() => isLoading = true);
    try {
      final data = await AdminChatHistoryApi.fetchHistory();
      setState(() {
        allConversations = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('loadError', isArabic: _isArabic) + ': $e')),
        );
      }
    }
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  String _t(String key, {bool? isArabic}) {
    final ar = isArabic ?? _isArabic;
    final translations = {
      'title': ar ? 'سجل المحادثات' : 'Chat History',
      'refresh': ar ? 'تحديث' : 'Refresh',
      'searchHint': ar ? 'ابحث عن عميل بالاسم أو المعرف...' : 'Search by name or ID...',
      'all': ar ? 'الكل' : 'All',
      'solved': ar ? 'محلولة' : 'Solved',
      'pending': ar ? 'بانتظار الرد' : 'Pending',
      'online': ar ? 'متصل' : 'Online',
      'offline': ar ? 'غير متصل' : 'Offline',
      'noResults': ar ? 'لا توجد نتائج' : 'No results',
      'noChats': ar ? 'لا توجد محادثات' : 'No chats',
      'clearFilters': ar ? 'مسح الفلاتر' : 'Clear Filters',
      'now': ar ? 'الآن' : 'now',
      'min': ar ? 'دقيقة' : 'min',
      'hr': ar ? 'ساعة' : 'hr',
      'day': ar ? 'يوم' : 'day',
      'loadError': ar ? 'خطأ في تحميل البيانات' : 'Error loading data',
    };
    return translations[key] ?? key;
  }

  List<AdminChatHistoryModel> _getFilteredConversations() {
    return allConversations.where((chat) {
      bool matchesSearch = searchQuery.isEmpty ||
          chat.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          chat.id.toString().contains(searchQuery);

      bool matchesStatus = filterStatus == "الكل" || filterStatus == "All" ||
          (filterStatus == "متصل" && chat.online) ||
          (filterStatus == "Online" && chat.online);

      bool matchesTag = filterTag == "الكل" || filterTag == "All" ||
          chat.tag == filterTag ||
          (_isArabic && filterTag == "محلولة" && chat.tag == "محلولة") ||
          (!_isArabic && filterTag == "Solved" && chat.tag == "محلولة") ||
          (_isArabic && filterTag == "بانتظار الرد" && chat.tag == "بانتظار الرد") ||
          (!_isArabic && filterTag == "Pending" && chat.tag == "بانتظار الرد");

      return matchesSearch && matchesStatus && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF101214)
          : lightBlue.withOpacity(0.5),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildTopSearchAndFilters(isDark),
          _buildQuickFilterRow(isDark),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _buildChatList(isDark),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final primaryColor = isDark ? accentGreen : primaryBlue;
    final accentColor = isDark ? accentGreen : accentBlue;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        _t('title'),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : primaryColor,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: accentColor),
          onPressed: loadHistory,
          tooltip: _t('refresh'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopSearchAndFilters(bool isDark) {
    final accentColor = isDark ? accentGreen : accentBlue;
    final primaryColor = isDark ? primaryGreen : primaryBlue;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: _t('searchHint'),
            prefixIcon: Icon(Icons.search_rounded, color: accentColor),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => setState(() => searchQuery = ""),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilterRow(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip(_t('all'), Icons.all_inclusive, isStatusFilter: true, isDark: isDark),
          _filterChip(_t('solved'), Icons.check_circle_outline, color: Colors.blue, isStatusFilter: false, isDark: isDark),
          _filterChip(_t('pending'), Icons.hourglass_empty_rounded, color: Colors.orange, isStatusFilter: false, isDark: isDark),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon, {Color? color, required bool isStatusFilter, required bool isDark}) {
    final primaryColor = isDark ? primaryGreen : primaryBlue;
    bool isSelected = isStatusFilter
        ? (filterStatus == label)
        : (filterTag == label);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? Colors.grey)),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (val) {
          setState(() {
            if (isStatusFilter) {
              filterStatus = label;
            } else {
              filterTag = label;
            }
          });
        },
        selectedColor: color ?? primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: (color ?? primaryColor).withOpacity(0.2)),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    final filtered = _getFilteredConversations();

    if (filtered.isEmpty) return _buildEmptyState(isDark);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final chat = filtered[index];
        return _buildChatCard(chat, isDark);
      },
    );
  }

  Widget _buildChatCard(AdminChatHistoryModel chat, bool isDark) {
    final primaryColor = isDark ? primaryGreen : primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ChatReviewDialog(
              chatId: chat.id.toString(),
              userName: chat.name,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildUserAvatar(chat, isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            chat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(chat.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.blueGrey[300],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusBadges(chat),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AdminChatHistoryModel chat, bool isDark) {
    final accentColor = isDark ? accentGreen : accentBlue;
    final primaryColor = isDark ? primaryGreen : primaryBlue;
    final lightColor = isDark ? lightGreen : lightBlue;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accentColor, primaryColor]),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: lightColor.withOpacity(isDark ? 0.3 : 1.0),
              child: Text(
                chat.name.isNotEmpty ? chat.name[0] : '؟',
                style: TextStyle(
                  color: isDark ? accentGreen : primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (chat.online)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.grey[850]! : Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadges(AdminChatHistoryModel chat) {
    bool isSolved = chat.tag == "محلولة";
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSolved
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            chat.tag,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSolved ? Colors.green[700] : Colors.orange[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final primaryColor = isDark ? accentGreen : primaryBlue;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: primaryColor.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty || filterStatus != _t('all') || filterTag != _t('all')
                ? _t('noResults')
                : _t('noChats'),
            style: TextStyle(
              color: primaryColor.withOpacity(0.4),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (searchQuery.isNotEmpty || filterStatus != _t('all') || filterTag != _t('all'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                    filterStatus = _t('all');
                    filterTag = _t('all');
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: Text(_t('clearFilters')),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return _t('now');
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} ${_t('min')}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${_t('hr')}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} ${_t('day')}";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}