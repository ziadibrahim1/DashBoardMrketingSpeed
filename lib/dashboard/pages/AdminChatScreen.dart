import 'package:flutter/material.dart';
import 'AdminLiveChatScreen.dart';

class AdminChatScreen extends StatelessWidget {
  const AdminChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatSessions = [
      {"id": "conv-001", "user": "محمد", "lastMessage": "شكراً على الرد"},
      {"id": "conv-002", "user": "أحمد", "lastMessage": "عندي مشكلة في الاشتراك"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("الدردشة المباشرة مع العملاء"),
      ),
      body: ListView.builder(
        itemCount: chatSessions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final session = chatSessions[index];
          return Card(
            child: ListTile(
              title: Text("العميل: ${session['user']}"),
              subtitle: Text(session['lastMessage']!),
              trailing: const Icon(Icons.chat),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminLiveChatScreen(
                      conversationId: session['id']!,
                      userName: session['user']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
