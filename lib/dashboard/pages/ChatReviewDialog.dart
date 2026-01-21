import 'package:flutter/material.dart';
import 'dart:ui';
import '../../Models/VideoDto.dart';
import '../../core/ConversationModel.dart';
import '../../providers/app_providers.dart';
import 'package:provider/provider.dart';

class ChatReviewDialog extends StatefulWidget {
  final String chatId;
  final String userName;

  const ChatReviewDialog({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  State<ChatReviewDialog> createState() => _ChatReviewDialogState();
}

class _ChatReviewDialogState extends State<ChatReviewDialog> {
  bool isLoading = true;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(seconds: 1));
    final data = await ChatApi.getMessages(int.parse(widget.chatId));
    setState(() {
      messages = data; // استبدلها بـ data
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : Colors.blue;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isRTL = localeProvider.locale.languageCode == 'ar';
        final loc = AppLocalizations(localeProvider.locale.languageCode);

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(theme, primaryColor, isRTL),
                  Expanded(
                    child: isLoading
                        ? _buildShimmerLoading(primaryColor)
                        : _buildMessagesList(theme, primaryColor, isRTL),
                  ),
                  _buildFooter(theme, primaryColor, isRTL),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, Color primaryColor, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isRTL ? "مراجعة سجل المحادثة" : "Chat History Review",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ThemeData theme, Color primaryColor, bool isRTL) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                Icons.speaker_notes_off_outlined,
                size: 64,
                color: theme.disabledColor
            ),
            const SizedBox(height: 16),
            Text(
              isRTL ? "لا توجد رسائل سابقة" : "No previous messages",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.sender == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: isUser
                ? (isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end)
                : (isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start),
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser
                      ? primaryColor
                      : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: isRTL
                      ? BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 4 : 20),
                    bottomRight: Radius.circular(isUser ? 20 : 4),
                  )
                      : BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                ),
                child: Text(
                  msg.text ?? "",
                  style: TextStyle(
                    color: isUser ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.sentAt),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(Color primaryColor) {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, Color primaryColor, bool isRTL) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: primaryColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)
            )
          ]
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: theme.brightness == Brightness.dark
                ? Colors.green[100]
                : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.check_circle_outline,
            color: primaryColor,
          ),
          label: Text(
            isRTL ? "تمت المراجعة" : "Review Completed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}