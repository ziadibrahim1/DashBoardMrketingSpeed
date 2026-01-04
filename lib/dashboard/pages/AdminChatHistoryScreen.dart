import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // درجات اللون الأزرق الاحترافية
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color accentBlue = const Color(0xFF2196F3);

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
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
  }

  List<AdminChatHistoryModel> _getFilteredConversations() {
    return allConversations.where((chat) {
      // فلتر البحث
      bool matchesSearch = searchQuery.isEmpty ||
          chat.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          chat.id.toString().contains(searchQuery);

      // فلتر الحالة (متصل/غير متصل)
      bool matchesStatus = filterStatus == "الكل" ||
          (filterStatus == "متصل" && chat.online);

      // فلتر التصنيف
      bool matchesTag = filterTag == "الكل" || chat.tag == filterTag;

      return matchesSearch && matchesStatus && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101214) : lightBlue.withOpacity(0.5),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildTopSearchAndFilters(isDark),
          _buildQuickFilterRow(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _buildChatList(isDark, isArabic),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        "سجل المحادثات",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : primaryBlue,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: accentBlue),
          onPressed: loadHistory,
          tooltip: "تحديث",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: "ابحث عن عميل بالاسم أو المعرف...",
            prefixIcon: Icon(Icons.search_rounded, color: accentBlue),
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

  Widget _buildQuickFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterChip("الكل", Icons.all_inclusive, isStatusFilter: true),
          _filterChip("محلولة", Icons.check_circle_outline, color: Colors.blue, isStatusFilter: false),
          _filterChip("بانتظار الرد", Icons.hourglass_empty_rounded, color: Colors.orange, isStatusFilter: false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon, {Color? color, required bool isStatusFilter}) {
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
        selectedColor: color ?? primaryBlue,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: (color ?? primaryBlue).withOpacity(0.2)),
      ),
    );
  }

  Widget _buildChatList(bool isDark, bool isArabic) {
    final filtered = _getFilteredConversations();

    if (filtered.isEmpty) return _buildEmptyState(isDark);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final chat = filtered[index];
        return _buildChatCard(chat, isDark, isArabic);
      },
    );
  }

  Widget _buildChatCard(AdminChatHistoryModel chat, bool isDark, bool isArabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withOpacity(0.05)),
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
              _buildUserAvatar(chat),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(chat.timestamp, isArabic),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey[300],
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
                        color: Colors.grey[600],
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
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AdminChatHistoryModel chat) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accentBlue, primaryBlue]),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: lightBlue,
              child: Text(
                chat.name.isNotEmpty ? chat.name[0] : '؟',
                style: TextStyle(
                  color: primaryBlue,
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
                border: Border.all(color: Colors.white, width: 2),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: primaryBlue.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty || filterStatus != "الكل" || filterTag != "الكل"
                ? "لا توجد نتائج"
                : "لا توجد محادثات",
            style: TextStyle(
              color: primaryBlue.withOpacity(0.4),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (searchQuery.isNotEmpty || filterStatus != "الكل" || filterTag != "الكل")
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    searchQuery = "";
                    filterStatus = "الكل";
                    filterTag = "الكل";
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text("مسح الفلاتر"),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return isArabic ? "الآن" : "now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} ${isArabic ? "دقيقة" : "min"}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${isArabic ? "ساعة" : "hr"}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} ${isArabic ? "يوم" : "day"}";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}