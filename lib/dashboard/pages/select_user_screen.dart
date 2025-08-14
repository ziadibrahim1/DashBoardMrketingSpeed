import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import 'simulate_screen.dart';

class SelectUserScreen extends StatefulWidget {
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  List<Map<String, String>> users = [
    {
      'id': '1',
      'name_ar': 'أحمد',
      'name_en': 'Ahmed',
      'email': 'ahmed@example.com'
    },
    {
      'id': '2',
      'name_ar': 'سارة',
      'name_en': 'Sarah',
      'email': 'sarah@example.com'
    },
    {
      'id': '3',
      'name_ar': 'محمد',
      'name_en': 'Mohamed',
      'email': 'mohamed@example.com'
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredUsers = users.where((user) {
      final name = isArabic ? user['name_ar']! : user['name_en']!;
      return name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'اختيار المستخدم' : 'Select User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.teal[800] : Colors.teal,
      ),
      body: Column(
        children: [
          // مربع البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: isArabic ? 'بحث عن مستخدم...' : 'Search user...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          // قائمة المستخدمين
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (_, index) {
                final user = filteredUsers[index];
                final name = isArabic ? user['name_ar']! : user['name_en']!;
                final email = user['email']!;
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      isDark ? Colors.teal[700] : Colors.teal[300],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          isDark ? Colors.white : Colors.blueGrey[900]),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[700]),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SimulateScreen(userId: user['id']!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
