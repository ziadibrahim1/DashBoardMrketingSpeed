import 'package:flutter/material.dart';

import 'simulate_telegram_screen.dart';

class SelectTelegramUserScreen extends StatefulWidget {
  @override
  _SelectTelegramUserScreenState createState() => _SelectTelegramUserScreenState();
}

class _SelectTelegramUserScreenState extends State<SelectTelegramUserScreen> {
  final List<Map<String, String>> users = [
    {'id': 'u1', 'name': 'أحمد'},
    {'id': 'u2', 'name': 'سارة'},
    {'id': 'u3', 'name': 'محمود'},
    {'id': 'u4', 'name': 'منى'},
  ];

  String searchQuery = '';

  List<Map<String, String>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users.where((user) => user['name']!.contains(searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختيار مستخدم (تليجرام)', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن المستخدم...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (_, index) {
                final user = filteredUsers[index];
                return ListTile(
                  title: Text(user['name']!),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SimulateTelegramScreen(userId: user['id']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
