import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import 'simulate_screen.dart';
import 'simulate_telegram_screen.dart';

class SelectUserScreentele extends StatefulWidget {
  @override
  _SelectUserScreenStatetele createState() => _SelectUserScreenStatetele();
}

class _SelectUserScreenStatetele extends State<SelectUserScreentele> {
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
  String? selectedUserId;

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: isDark ? const Color(0xFF4D5D53) : const Color(0xFF65C4F8),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      if (selectedUserId != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              selectedUserId = null; // العودة لقائمة المستخدمين
                            });
                          },
                        )
                      else
                        const SizedBox(width: 48), // موازنة للمساحة مع زر الرجوع
                      Expanded(
                        child: Center(
                          child: Text(
                            isArabic ? 'اختيار المستخدم' : 'Select User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFB2ECBC)
                                  :  Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (selectedUserId == null) ...[
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
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        isDark ? const Color(0xFFB2ECBC) : const Color(0xFF324E86),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blueGrey[900]),
                      ),
                      subtitle: Text(
                        email,
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700]),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? const Color(0xFFB2ECBC) : const Color(0xFF324E86),
                        size: 18,
                      ),
                      onTap: () {
                        setState(() {
                          selectedUserId = user['id']!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // شاشة المحاكاة
            Expanded(child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300], // خلفية خفيفة للتاب بار
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SimulateScreentele(userId: selectedUserId!)),
            ),
          ],
        ],
      ),
    );
  }
}
