import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/ConversationModel.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import 'AdminLiveChatScreen.dart';

// ==================== Constants ====================
class ChatColors {
  static const primaryBlue = Color(0xFF007AFF);
  static const accentGreen = Color(0xFF34C759);
  static const softBlue = Color(0xFFE3F2FD);
  static const lightGray = Color(0xFFF8FAFC);
  static const redAccent = Colors.redAccent;
}

class ChatDimensions {
  static const sidebarWidth = 320.0;
  static const topBarHeight = 60.0;
  static const avatarSize = 52.0;
  static const minAvatarSize = 14.0;
  static const borderRadius = 18.0;
  static const cardPadding = 14.0;
}

// ==================== Main Dashboard ====================
class AdminLiveChatDashboard extends StatefulWidget {
  const AdminLiveChatDashboard({super.key});

  @override
  State<AdminLiveChatDashboard> createState() => _AdminLiveChatDashboardState();
}

class _AdminLiveChatDashboardState extends State<AdminLiveChatDashboard> {
  // State Management
  final _chatStateManager = ChatStateManager();
  bool _isLoading = true;
  String _searchQuery = '';

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startAutoRefresh();
  }

  Future<void> _initializeData() async {
    await _chatStateManager.fetchConversations();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && !_isRefreshing) {
        _refreshConversations();
      }
    });
  }

  Future<void> _refreshConversations() async {
    if (_isRefreshing || _isLoading) return;

    _isRefreshing = true;

    try {
      final updates = await _chatStateManager.fetchConversationsWithUpdates();

      if (mounted) {
        final newConvCount = updates['newConversations'] as int;

        // ✅ تحديث الـ UI
        setState(() {});

        // ✅ إشعار بالمحادثات الجديدة
        if (newConvCount > 0) {
          _showNewConversationsNotification(newConvCount);
        }
      }
    } catch (e) {
      debugPrint('Error refreshing conversations: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // ✅ إظهار إشعار بالمحادثات الجديدة
  void _showNewConversationsNotification(int count) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'لديك $count محادثة جديدة',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: ChatColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }


  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          _ChatSidebar(
            conversations: _chatStateManager.allConversations,
            activeChat: _chatStateManager.activeChat,
            isLoading: _isLoading,
            searchQuery: _searchQuery,
            isRefreshing: _isRefreshing,
            chatStateManager: _chatStateManager,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            onChatSelected: (conv) => setState(() => _chatStateManager.openChat(conv)),
            onConversationClosed: _handleConversationClose,
            onRefresh: _refreshConversations,
            isArabic: isArabic,
          ),
          Expanded(
            child: Column(
              children: [
                if (_chatStateManager.openedChats.isNotEmpty)
                  _ChatTopTabs(
                    openedChats: _chatStateManager.openedChats,
                    activeChat: _chatStateManager.activeChat,
                    onTabSelected: (chat) async {
                      setState(() => _chatStateManager.activeChat = chat);
                      await _chatStateManager.markConversationAsRead(chat.id);
                    },
                    onTabClosed: (chatId) => setState(() => _chatStateManager.closeChat(chatId)),
                  ),
                Expanded(
                  child: _ChatMainContent(
                    activeChat: _chatStateManager.activeChat,
                    isArabic: isArabic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _MinimizedChatsBar(
        minimizedChats: _chatStateManager.minimizedChats,
        onChatRestore: (chat) => setState(() => _chatStateManager.openChat(chat)),
      ),
    );
  }

  Future<void> _handleConversationClose(ConversationModel conv) async {
    final confirmed = await _showCloseConfirmationDialog(conv);
    if (!confirmed) return;

    try {
      await _chatStateManager.closeConversation(conv.id);
      if (mounted) {
        setState(() {});
        _showSnackBar('تم إنهاء المحادثة', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('فشل إنهاء المحادثة', isError: true);
      }
    }
  }

  Future<bool> _showCloseConfirmationDialog(ConversationModel conv) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إنهاء المحادثة'),
        content: Text('هل أنت متأكد من إنهاء المحادثة مع ${conv.userName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ChatColors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إنهاء'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ChatColors.redAccent : ChatColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ==================== Chat State Manager ====================
class ChatStateManager {
  List<ConversationModel> allConversations = [];
  final List<ConversationModel> openedChats = [];
  final List<ConversationModel> minimizedChats = [];
  ConversationModel? activeChat;

  // ✅ Map لتتبع عدد الرسائل غير المقروءة
  final Map<int, int> unreadCounts = {};
  Future<void> markConversationAsRead(int conversationId) async {
    try {
      await http.put(
        Uri.parse(
          '${AppConfig.baseUrl}admin/conversations/$conversationId/read',
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_TOKEN",
        },
      );

      // ✅ تحديث محلي
      unreadCounts.remove(conversationId);

      final index =
      allConversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        allConversations[index] =
            allConversations[index].copyWith(hasUnread: false);
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  void openChat(ConversationModel conv) {
    if (!openedChats.any((c) => c.id == conv.id)) {
      openedChats.add(conv);
    }
    activeChat = conv;
    minimizedChats.removeWhere((c) => c.id == conv.id);
    // ✅ مسح العداد عند فتح المحادثة
    unreadCounts.remove(conv.id);
  }

  void closeChat(int id) {
    openedChats.removeWhere((c) => c.id == id);
    minimizedChats.removeWhere((c) => c.id == id);
    if (activeChat?.id == id) {
      activeChat = openedChats.isNotEmpty ? openedChats.last : null;
    }
  }

  void minimizeChat(int id) {
    final chat = openedChats.firstWhere((c) => c.id == id);
    openedChats.removeWhere((c) => c.id == id);
    if (!minimizedChats.any((c) => c.id == id)) {
      minimizedChats.add(chat);
    }
    if (activeChat?.id == id) {
      activeChat = openedChats.isNotEmpty ? openedChats.last : null;
    }
  }

  // ✅ دالة محدثة للتحقق من الرسائل الجديدة

  Future<Map<String, dynamic>> fetchConversationsWithUpdates() async {
    try {
      final agentId = UserSession.userId;
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}admin/conversations/$agentId/active'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final newConversations =
        data.map((e) => ConversationModel.fromJson(e)).toList();

        int newConvCount = 0;

        for (var conv in newConversations) {
          // محادثة جديدة
          if (!allConversations.any((c) => c.id == conv.id)) {
            newConvCount++;
          }

          // تحديث العداد من السيرفر
          if (conv.unreadCount! > 0) {
            unreadCounts[conv.id] = conv.unreadCount!;
          } else {
            unreadCounts.remove(conv.id);
          }
        }

        allConversations = newConversations;

        return {
          'newConversations': newConvCount,
          'newMessages': newConversations
              .where((c) => c.unreadCount! > 0)
              .toList(),
        };
      }
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    }

    return {'newConversations': 0, 'newMessages': []};
  }

  Future<void> fetchConversations() async {
    await fetchConversationsWithUpdates();
  }

  Future<void> closeConversation(int conversationId) async {
    await http.put(
      Uri.parse('${AppConfig.baseUrl}admin/conversations/$conversationId/close'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode("closed"),
    );

    allConversations.removeWhere((c) => c.id == conversationId);
    unreadCounts.remove(conversationId);
    if (activeChat?.id == conversationId) {
      activeChat = null;
    }
  }
}

// ==================== Sidebar Component ====================
class _ChatSidebar extends StatelessWidget {
  final List<ConversationModel> conversations;
  final ConversationModel? activeChat;
  final bool isLoading;
  final bool isRefreshing;
  final String searchQuery;
  final ChatStateManager? chatStateManager;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ConversationModel> onChatSelected;
  final ValueChanged<ConversationModel> onConversationClosed;
  final VoidCallback onRefresh;
  final bool isArabic;

  const _ChatSidebar({
    required this.conversations,
    required this.activeChat,
    required this.isLoading,
    required this.isRefreshing,
    required this.searchQuery,
    this.chatStateManager,
    required this.onSearchChanged,
    required this.onChatSelected,
    required this.onConversationClosed,
    required this.onRefresh,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = conversations
        .where((c) => c.userName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Container(
      width: ChatDimensions.sidebarWidth,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(
            isArabic: isArabic,
            searchQuery: searchQuery,
            isRefreshing: isRefreshing,
            onSearchChanged: onSearchChanged,
            onRefresh: onRefresh,
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ConversationsList(
              conversations: filtered,
              activeChat: activeChat,
              chatStateManager: chatStateManager,
              onChatSelected: onChatSelected,
              onConversationClosed: onConversationClosed,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Sidebar Header ====================
class _SidebarHeader extends StatelessWidget {
  final bool isArabic;
  final String searchQuery;
  final bool isRefreshing;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;

  const _SidebarHeader({
    required this.isArabic,
    required this.searchQuery,
    required this.isRefreshing,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ChatColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: ChatColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? "المحادثات المباشرة" : "Live Support",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: isRefreshing
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ChatColors.primaryBlue,
                    ),
                  ),
                )
                    : const Icon(
                  Icons.refresh_rounded,
                  color: ChatColors.primaryBlue,
                ),
                onPressed: isRefreshing ? null : onRefresh,
                tooltip: isArabic ? 'تحديث' : 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: isArabic ? "بحث عن مستخدم..." : "Search users...",
              hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Conversations List ====================
class _ConversationsList extends StatelessWidget {
  final List<ConversationModel> conversations;
  final ConversationModel? activeChat;
  final ChatStateManager? chatStateManager;
  final ValueChanged<ConversationModel> onChatSelected;
  final ValueChanged<ConversationModel> onConversationClosed;

  const _ConversationsList({
    required this.conversations,
    required this.activeChat,
    this.chatStateManager,
    required this.onChatSelected,
    required this.onConversationClosed,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد محادثات',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ConversationTile(
        conversation: conversations[i],
        isActive: activeChat?.id == conversations[i].id,
        chatStateManager: chatStateManager,
        onTap: () => onChatSelected(conversations[i]),
        onClose: () => onConversationClosed(conversations[i]),
      ),
    );
  }
}

// ==================== Conversation Tile ====================
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final ChatStateManager? chatStateManager;

  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onClose,
    this.chatStateManager,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = chatStateManager?.unreadCounts[conversation.id] ?? 0;
    final bool hasUnread = unreadCount > 0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.98 + (0.02 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2), // تقليل المارجن لتوفير مساحة
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [
            BoxShadow(
              color: ChatColors.primaryBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Material(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () async {
              onTap();
              if (chatStateManager != null) {
                await chatStateManager!.markConversationAsRead(conversation.id);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? ChatColors.primaryBlue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // القسم 1: الصورة والبادج
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _AnimatedAvatar(
                        userName: conversation.userName,
                        isActive: isActive,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: _UnreadBadge(count: unreadCount),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // القسم 2: المعلومات النصية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // الاسم
                            Expanded( // أهم تعديل: Expanded هنا يمنع تجاوز النص
                              child: Text(
                                conversation.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // التاريخ
                            if (conversation.lastMessageAt != null)
                              Text(
                                formatChatDate(conversation.lastMessageAt, true),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: hasUnread ? ChatColors.primaryBlue : Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        _ConversationSubtext(
                          hasUnread: hasUnread, isActive: isActive,
                          lastMessage: conversation.lastMessage,
                        ),
                      ],
                    ),
                  ),

                  // القسم 3: زر الإغلاق (يظهر فقط عند التفاعل أو النشاط)
                  if (conversation.status == 'active' || isActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _CloseButton(onPressed: onClose),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

// ==================== Animated Avatar ====================
class _AnimatedAvatar extends StatelessWidget {
  final String userName;
  final bool isActive;

  const _AnimatedAvatar({
    required this.userName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isActive) _PulseEffect(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          width: ChatDimensions.avatarSize,
          height: ChatDimensions.avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
              colors: [ChatColors.primaryBlue, ChatColors.primaryBlue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade100],
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? ChatColors.primaryBlue.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: isActive ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _OnlineIndicator(),
        ),
      ],
    );
  }
}

// ==================== Helper Widgets ====================
class _PulseEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (0.15 * value),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ChatColors.primaryBlue.withOpacity(0.3 * (1 - value)),
                  ChatColors.primaryBlue.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
class _OnlineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.85, end: 1.15),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: ChatDimensions.minAvatarSize,
            height: ChatDimensions.minAvatarSize,
            decoration: BoxDecoration(
              color: ChatColors.accentGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: ChatColors.accentGreen.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
String formatChatDate(DateTime? date, bool isArabic) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return isArabic ? 'الآن' : 'Now';
  } else if (difference.inHours < 1) {
    return isArabic
        ? 'منذ ${difference.inMinutes} د'
        : '${difference.inMinutes}m ago';
  } else if (difference.inDays == 0) {
    return DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(date);
  } else if (difference.inDays == 1) {
    return isArabic ? 'أمس' : 'Yesterday';
  } else {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'إنهاء المحادثة',
      icon: const Icon(
        Icons.lock_outline_rounded,
        color: ChatColors.redAccent,
        size: 20,
      ),
      splashRadius: 22,
      onPressed: onPressed,
    );
  }
}


// ==================== Top Tabs ====================
class _ChatTopTabs extends StatelessWidget {
  final List<ConversationModel> openedChats;
  final ConversationModel? activeChat;
  final ValueChanged<ConversationModel> onTabSelected;
  final ValueChanged<int> onTabClosed;

  const _ChatTopTabs({
    required this.openedChats,
    required this.activeChat,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: ChatDimensions.topBarHeight,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: openedChats.length,
        itemBuilder: (context, index) {
          final chat = openedChats[index];
          final isActive = activeChat?.id == chat.id;

          return _ChatTab(
            chat: chat,
            isActive: isActive,
            onTap: () => onTabSelected(chat),
            onClose: () => onTabClosed(chat.id),
          );
        },
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  final ConversationModel chat;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _ChatTab({
    required this.chat,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 180 : 140,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
          colors: [
            ChatColors.primaryBlue,
            ChatColors.primaryBlue.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isActive ? null : theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: ChatColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  chat.userName,
                  style: TextStyle(
                    color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: isActive ? Colors.white : theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MainContent ====================
class _ChatMainContent extends StatelessWidget {
  final ConversationModel? activeChat;
  final bool isArabic;

  const _ChatMainContent({
    required this.activeChat,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    if (activeChat == null) {
      return _EmptyState(isArabic: isArabic);
    }

    return _ActiveChatView(
      conversation: activeChat!,
      isArabic: isArabic,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isArabic;

  const _EmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.scaffoldBackgroundColor,
            ChatColors.softBlue.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ChatColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 60,
                color: ChatColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? "أهلاً بك في مركز المساعدة" : "Welcome to Support Center",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "اختر محادثة من القائمة لبدء الدعم"
                  : "Select a conversation to start support",
              style: TextStyle(
                color: theme.hintColor.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChatView extends StatelessWidget {
  final ConversationModel conversation;
  final bool isArabic;

  const _ActiveChatView({
    required this.conversation,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.brightness == Brightness.light
          ? ChatColors.lightGray
          : theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: AdminLiveChatScreen(
                key: ValueKey(conversation.id),
                conversationId: conversation.id.toString(),
                userName: conversation.userName,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ChatColors.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: _UserProfilePanel(
                conversation: conversation,
                isArabic: isArabic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== User Profile Panel ====================
class _UserProfilePanel extends StatelessWidget {
  final ConversationModel conversation;
  final bool isArabic;

  const _UserProfilePanel({
    required this.conversation,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.brightness == Brightness.light
          ? Colors.grey[50]
          : theme.cardColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        children: [
          _ProfileHeader(
            userName: conversation.userName,
            isArabic: isArabic,
          ),
          const SizedBox(height: 32),
          _ProfileSection(
            title: isArabic ? "معلومات التواصل" : "Contact Information",
            child: _ContactInfoCard(
              conversation: conversation,
              isArabic: isArabic,
            ),
          ),
          const SizedBox(height: 24),
          _SubscriptionCard(
            subscription: conversation.subscription,
            isArabic: isArabic,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final bool isArabic;

  const _ProfileHeader({
    required this.userName,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ChatColors.primaryBlue.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: ChatColors.primaryBlue,
            child: Text(
              userName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: ChatColors.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isArabic ? "نشط الآن" : "Active Now",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final ConversationModel conversation;
  final bool isArabic;

  const _ContactInfoCard({
    required this.conversation,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_rounded,
            label: isArabic ? "البريد" : "Email",
            value: conversation.email,
          ),
          const Divider(height: 24, thickness: 0.5),
          _InfoRow(
            icon: Icons.phone_iphone_rounded,
            label: isArabic ? "الجوال" : "Phone",
            value: conversation.phone,
          ),
          const Divider(height: 24, thickness: 0.5),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: isArabic ? "الموقع" : "Location",
            value: "${conversation.country}, ${conversation.city}",
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChatColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: ChatColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final dynamic subscription;
  final bool isArabic;

  const _SubscriptionCard({
    required this.subscription,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChatColors.primaryBlue,
            ChatColors.primaryBlue.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ChatColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "الاشتراك" : "Plan",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscription != null
                      ? subscription.planName
                      : (isArabic ? "بدون اشتراك" : "No Subscription"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subscription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? "متبقي ${subscription.daysLeft} يوم"
                        : "${subscription.daysLeft} days left",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Minimized Chats Bar ====================
class _MinimizedChatsBar extends StatelessWidget {
  final List<ConversationModel> minimizedChats;
  final ValueChanged<ConversationModel> onChatRestore;

  const _MinimizedChatsBar({
    required this.minimizedChats,
    required this.onChatRestore,
  });

  @override
  Widget build(BuildContext context) {
    if (minimizedChats.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: minimizedChats.map((chat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FloatingActionButton.extended(
              heroTag: chat.id,
              backgroundColor: ChatColors.primaryBlue,
              onPressed: () => onChatRestore(chat),
              label: Text(
                chat.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class _ConversationSubtext extends StatelessWidget {
  final bool isActive;
  final bool hasUnread;
  final String? lastMessage;


  const _ConversationSubtext({
    required this.isActive,
    required this.hasUnread,
    this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // اختيارياً: يمكنك إضافة أيقونة الحالة (تم الإرسال/تمت القراءة)
        Icon(
          Icons.done_all,
          size: 14,
          color: hasUnread ? ChatColors.primaryBlue : Colors.grey[400],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            lastMessage!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              // جعل النص أغمق إذا كانت الرسالة غير مقروءة
              color: hasUnread ? Colors.black87 : Colors.grey[600],
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.5),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
