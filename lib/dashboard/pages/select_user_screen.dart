// ✅ شاشة اختيار المستخدم (SelectUserScreen)
import 'package:flutter/material.dart';

import 'simulate_screen.dart';

class SelectUserScreen extends StatefulWidget {
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  List<Map<String, String>> users = [
    {'id': '1', 'name': 'أحمد'},
    {'id': '2', 'name': 'سارة'},
    {'id': '3', 'name': 'محمد'},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users
        .where((user) => user['name']!.contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار المستخدم', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن مستخدم...',
                border: OutlineInputBorder(),
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
                        builder: (_) => SimulateScreen(),
                        settings: RouteSettings(arguments: user['id']),
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
