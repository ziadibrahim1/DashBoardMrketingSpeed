import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String title;
  final bool isGroup;
  final bool multiMode;
  final List<String> targets;
  final bool toGroupMembers;

  ChatRoomScreen({
    required this.userId,
    required this.title,
    required this.isGroup,
    this.multiMode = false,
    this.targets = const [],
    this.toGroupMembers = false,
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

    // في المستقبل: ربط الرسالة بـ API
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
    if (widget.toGroupMembers) return "عضو في الجروب";
    return widget.isGroup ? "جروب" : "دردشة";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (widget.multiMode)
              Text(
                '${widget.targets.length} ${_getTargetType()}',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              )
            else
              Text(
                widget.isGroup ? 'جروب' : 'دردشة',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.multiMode)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey.shade200,
              width: double.infinity,
              child: Text(
                'الأهداف:\n${widget.targets.join(", ")}',
                style: TextStyle(fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                final isMine = msg.startsWith("أنا:");
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Theme.of(context).primaryColorLight
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg, textDirection: TextDirection.rtl),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
