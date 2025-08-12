import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String title;
  final bool isGroup;
  final bool multiMode;
  final List<String> targets;
  final bool toGroupMembers;
  final bool type;


  ChatRoomScreen({
    required this.userId,
    required this.title,
    required this.isGroup,
    this.multiMode = false,
    this.targets = const [],
    this.toGroupMembers = false,
    required this.type,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (widget.multiMode) {
        for (final target in widget.targets) {
          messages.add("📤 إلى ${_getTargetType()}: [$target] - $text");
        }
      } else {
        messages.add("أنا: $text");
      }
      _controller.clear();
    });

    // ربط API لاحقًا
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final fileName = picked.name;
      setState(() {
        if (widget.multiMode) {
          for (final target in widget.targets) {
            messages.add("🖼 صورة مرفقة إلى ${_getTargetType()} [$target]: $fileName");
          }
        } else {
          messages.add("🖼 صورة مرفقة: $fileName");
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final fileName = result.files.first.name;
      setState(() {
        if (widget.multiMode) {
          for (final target in widget.targets) {
            messages.add("📎 ملف مرفق إلى ${_getTargetType()} [$target]: $fileName");
          }
        } else {
          messages.add("📎 ملف مرفق: $fileName");
        }
      });
    }
  }

  String _getTargetType() {
    if (widget.toGroupMembers) return "عضو في ";
    return widget.isGroup ? widget.type?"جروب":"قناة" : "دردشة";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final sentMessageColor =  isDark ? Colors.green.shade500 : Colors.blue.shade500;
    final receivedMessageColor = isDark ? Colors.grey[800] : Colors.white;
    final inputFillColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: Column(
        children: [
          if (widget.multiMode)
            Row(
              children:[
    Expanded(
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '${isArabic ? 'الأهداف:' : 'Targets:'}\n${widget.targets.join(", ")}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ),

    ),
            ],
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                final isMine = msg.startsWith("أنا:");
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMine ? sentMessageColor : receivedMessageColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMine ? 16 : 4),
                        bottomRight: Radius.circular(isMine ? 4 : 16),
                      ),
                      boxShadow: [
                        if (!isMine)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(1, 2),
                          )
                      ],
                    ),
                    child: Text(
                      msg,
                      style: TextStyle(
                        color: isMine ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 15,
                        height: 1.3,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: inputFillColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: isDark ? Colors.green.shade800 : Colors.blue.shade800),
                  onPressed: _pickFile,
                  tooltip: isArabic ? 'إرفاق ملف' : 'Attach File',
                ),
                IconButton(
                  icon: Icon(Icons.image, color: isDark ? Colors.green.shade800 : Colors.blue.shade800),
                  onPressed: _pickImage,
                  tooltip: isArabic ? 'إرفاق صورة' : 'Attach Image',
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: isArabic ? 'اكتب رسالة...' : 'Type a message...',
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor:isDark ? Colors.green.shade800 : Colors.blue.shade800,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                    tooltip: isArabic ? 'إرسال' : 'Send',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
