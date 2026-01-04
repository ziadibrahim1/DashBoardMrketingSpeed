import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:html' as html;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async'; // ✅ إضافة للـ Timer

import '../../core/ConversationModel.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';

class AdminLiveChatScreen extends StatefulWidget {
  final String conversationId;
  final String userName;

  const AdminLiveChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  State<AdminLiveChatScreen> createState() => _AdminLiveChatScreenState();
}

class _AdminLiveChatScreenState extends State<AdminLiveChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color primaryBlue = const Color(0xFF007BFF);
  final Color backgroundLight = const Color(0xFFF8FAFC);

  List<ChatMessage> messages = [];
  bool loading = true;
  bool userOnline = true;
  bool isTyping = false;

  HubConnection? _hubConnection;
  WebSocketChannel? _channel;
  bool _isConnected = true;

  Timer? _refreshTimer; //
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
    _connectSignalR();
    _startAutoRefresh(); // ✅ بدء التحديث التلقائي
  }

  // ✅ دالة لبدء التحديث التلقائي كل ثانيتين
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isRefreshing) {
        _refreshMessages();
      }
    });
  }

  // ✅ دالة التحديث الصامت (بدون إظهار loading)
  Future<void> _refreshMessages() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      final data = await ChatApi.getMessages(int.parse(widget.conversationId));

      if (mounted) {
        // التحقق من وجود رسائل جديدة فقط
        if (data.length > messages.length) {
          final shouldScroll = _isScrolledToBottom();

          setState(() {
            messages = data;
          });

          // التمرير التلقائي فقط إذا كان المستخدم في الأسفل
          if (shouldScroll) {
            _scrollToBottom();
          }
        } else if (data.length != messages.length) {
          // تحديث في حالة تغيير حالة الرسائل
          setState(() {
            messages = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing messages: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // ✅ التحقق من أن المستخدم في نهاية القائمة
  bool _isScrolledToBottom() {
    if (!_scrollController.hasClients) return true;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    return (maxScroll - currentScroll) < 100; // هامش 100 بكسل
  }

  void _connectSignalR() async {
    try {
      final serverUrl = "https://localhost:7222/chatHub";

      _hubConnection = HubConnectionBuilder()
          .withUrl(
        "$serverUrl?conversationId=${widget.conversationId}&role=support",
        HttpConnectionOptions(
          skipNegotiation: true,
          transport: HttpTransportType.webSockets,
        ),
      )
          .withAutomaticReconnect()
          .build();

      _hubConnection!.on("ReceiveMessage", _handleReceiveMessage);
      _hubConnection!.on("UserOnline", _handleUserOnline);

      await _hubConnection!.start();

      setState(() {
        _isConnected = true;
      });

      debugPrint("✅ SignalR Connected to conversation ${widget.conversationId}");

    } catch (e) {
      debugPrint("❌ SignalR Connection Error: $e");
      setState(() {
        _isConnected = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _connectSignalR();
      });
    }
  }

  dynamic _handleReceiveMessage(List<Object?>? args){
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      if (data['type'] == 'new_message') {
        final messageData = data['message'] as Map<String, dynamic>;
        final newMessage = ChatMessage.fromJson(messageData);

        if (newMessage.sender != 'support') {
          setState(() {
            messages.add(newMessage);
            isTyping = false;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error handling message: $e");
    }
  }

  dynamic _handleUserOnline(List<Object?>? args){
    if (args == null || args.isEmpty) return;
    final data = args[0] as Map<String, dynamic>;
    if (data['role'] == 'user') {
      setState(() {
        userOnline = true;
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // ✅ إيقاف التحديث التلقائي
    _channel?.sink.close();
    _hubConnection?.stop(); // ✅ إيقاف SignalR
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      final wsUrl = '${AppConfig.apiBase}/chatHub';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
      });

      _channel!.stream.listen(
            (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
          setState(() {
            _isConnected = true;
          });
          _reconnectWebSocket();
        },
        onDone: () {
          debugPrint('WebSocket Connection Closed');
          setState(() {
            _isConnected = true;
          });
          _reconnectWebSocket();
        },
      );

      _channel!.sink.add(jsonEncode({
        'type': 'connect',
        'conversationId': widget.conversationId,
        'role': 'support'
      }));

    } catch (e) {
      debugPrint('WebSocket Connection Failed: $e');
      setState(() {
        _isConnected = true;
      });
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _connectWebSocket();
      }
    });
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final Map<String, dynamic> messageData = jsonDecode(data);

      switch (messageData['type']) {
        case 'new_message':
          final newMessage = ChatMessage.fromJson(messageData['message']);
          setState(() {
            messages.add(newMessage);
          });
          _scrollToBottom();
          break;


        case 'user_online':
          setState(() {
            userOnline = true;
          });
          break;

        case 'user_offline':
          setState(() {
            userOnline = true;
          });
          break;

        case 'message_delivered':
          _updateMessageStatus(messageData['messageId'], 'delivered');
          break;

        case 'message_read':
          _updateMessageStatus(messageData['messageId'], 'read');
          break;
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  void _updateMessageStatus(String messageId, String status) {
    setState(() {
      final index = messages.indexWhere((m) => m.id.toString() == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: status);
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final data = await ChatApi.getMessages(int.parse(widget.conversationId));
      setState(() {
        messages = data;
        loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildMessage(ChatMessage msg, bool isArabic, bool isDark) {
    final isAdmin = msg.sender == "support";

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: isAdmin
              ? LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.8)])
              : null,
          color: isAdmin ? null : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAdmin ? 20 : 4),
            bottomRight: Radius.circular(isAdmin ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(msg, isAdmin, isDark),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.sentAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isAdmin ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatusIcon(msg.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(String? status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'sent':
        icon = Icons.check;
        color = Colors.white70;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case 'read':
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
      default:
        icon = Icons.check;
        color = Colors.white70;
    }

    return Icon(icon, size: 12, color: color);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return ' ${dateTime.day}/${dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month} ${dateTime.hour >= 12 ? 'PM' : 'AM'} $hour:$minute ';
  }

  Widget _buildMessageContent(ChatMessage msg, bool isAdmin, bool isDark) {

    return Text(
      msg.text ?? "",
      style: TextStyle(
        fontSize: 15,
        color: isAdmin ? Colors.white : (isDark ? Colors.white : Colors.black87),
        height: 1.4,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: primaryBlue.withOpacity(0.1),
                  child: Text(widget.userName[0], style: TextStyle(color: primaryBlue)),
                ),
                if (userOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: userOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userOnline
                          ? (isArabic ? "نشط" : "Online")
                          : (isArabic ? "غير متصل" : "Offline"),
                      style: TextStyle(
                        color: userOnline ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isConnected ? 'Live' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      color: _isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index], isArabic, isDark),
            ),
          ),
          _buildInputArea(isArabic, isDark),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isArabic, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: SafeArea(
        child: Row(
          children: [

            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  _sendTypingIndicator();
                },
                decoration: InputDecoration(
                  hintText: isArabic ? "اكتب هنا..." : "Type message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isConnected ? primaryBlue : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendTypingIndicator() {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'typing',
        'conversationId': widget.conversationId,
        'sender': 'support'
      }));
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || !_isConnected) return;


    final messageText = text.trim();
    _controller.clear();

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'message',
        'conversationId': widget.conversationId,
        'text': messageText,
        'sender': 'support',
        'timestamp': DateTime.now().toIso8601String(),

      }));
    }

    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        text: messageText,
        sender: 'support',
        sentAt: DateTime.now(),
        status: 'sending',
      ));
    });

    _scrollToBottom();

    try {
      await ChatApi.sendMessage(
        int.parse(widget.conversationId),
        messageText,
      );
    } catch (e) {
      debugPrint('Error sending message to API: $e');
    }
  }


}