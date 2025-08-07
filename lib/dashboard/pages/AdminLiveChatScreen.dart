import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;

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
  final List<Map<String, dynamic>> messages = [];

  bool userOnline = true;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "from": "admin",
        "type": "text",
        "content": text.trim(),
      });
    });

    _controller.clear();
  }

  Future<void> _sendImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      setState(() {
        messages.add({
          "from": "admin",
          "type": "image",
          "content": url,
        });
      });
    }
  }

  Future<void> _sendFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      setState(() {
        messages.add({
          "from": "admin",
          "type": "file",
          "content": fileName,
          "url": url,
        });
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isAdmin = msg["from"] == "admin";
    final type = msg["type"];
    final content = msg["content"];
    final theme = Theme.of(context);
    final bubbleColor = isAdmin ? theme.colorScheme.primary.withOpacity(0.15) : theme.cardColor;

    Widget child;

    switch (type) {
      case "image":
        child = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(content, height: 150, width: 220, fit: BoxFit.cover),
        );
        break;
      case "file":
        child = InkWell(
          onTap: () {
            if (msg["url"] != null) {
              html.window.open(msg["url"], '_blank');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  content,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        );
        break;
      default:
        child = Text(content, style: const TextStyle(fontSize: 15));
    }

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 0),
            bottomRight: Radius.circular(isAdmin ? 0 : 16),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = userOnline ? Colors.green : Colors.grey;
    final statusText = userOnline ? "متصل الآن" : "غير متصل";

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: statusColor),
                      const SizedBox(width: 6),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: "إرسال صورة",
            onPressed: _sendImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            tooltip: "إرسال ملف",
            onPressed: _sendFile,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text("ابدأ المحادثة مع ${widget.userName}", style: TextStyle(color: theme.hintColor)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (_, index) {
                final reversedIndex = messages.length - 1 - index;
                return _buildMessage(messages[reversedIndex]);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالة...",
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
