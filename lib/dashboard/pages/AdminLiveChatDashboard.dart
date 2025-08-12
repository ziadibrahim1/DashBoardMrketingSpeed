import 'package:flutter/material.dart';
import 'AdminLiveChatScreen.dart';

class AdminLiveChatDashboard extends StatefulWidget {
  const AdminLiveChatDashboard({super.key});

  @override
  State<AdminLiveChatDashboard> createState() => _AdminLiveChatDashboardState();
}

class _AdminLiveChatDashboardState extends State<AdminLiveChatDashboard> {
  final List<Map<String, String>> allConversations = [
    {"id": "1", "name": "أحمد", "avatar": "A"},
    {"id": "2", "name": "سارة", "avatar": "S"},
    {"id": "3", "name": "فهد", "avatar": "F"},
    {"id": "4", "name": "ريم", "avatar": "R"},
  ];

  final List<Map<String, String>> openedChats = [];
  final List<Map<String, String>> minimizedChats = [];
  String searchQuery = '';

  void openChat(String id, String name) {
    if (!openedChats.any((chat) => chat['id'] == id)) {
      setState(() {
        openedChats.add({"id": id, "name": name});
        minimizedChats.removeWhere((chat) => chat['id'] == id);
      });
    }
  }

  void closeChat(String id) {
    setState(() {
      openedChats.removeWhere((chat) => chat['id'] == id);
      minimizedChats.removeWhere((chat) => chat['id'] == id);
    });
  }

  void minimizeChat(String id) {
    final chat = openedChats.firstWhere((chat) => chat['id'] == id);
    setState(() {
      openedChats.removeWhere((c) => c['id'] == id);
      if (!minimizedChats.any((c) => c['id'] == id)) {
        minimizedChats.add(chat);
      }
    });
  }

  Widget _buildUserProfile(String id, String name, bool isArabic) {
    final userData = {
      "email": "$name@email.com",
      "phone": "0501234567",
      "subscription": isArabic ? "مميز" : "Premium",
      "expiry": "2025-12-31",
      "location": isArabic ? "الرياض، السعودية" : "Riyadh, Saudi Arabia",
      "joined": "2023-06-10"
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text(isArabic ? "الملف الشخصي" : "Profile",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
              title: Text(isArabic ? "الاسم" : "Name"), subtitle: Text(name)),
          ListTile(
              title: Text(isArabic ? "البريد الإلكتروني" : "Email"),
              subtitle: Text(userData['email']!)),
          ListTile(
              title: Text(isArabic ? "رقم الجوال" : "Phone"),
              subtitle: Text(userData['phone']!)),
          ListTile(
              title: Text(isArabic ? "المدينة" : "City"),
              subtitle: Text(userData['location']!)),
          const Divider(),
          Text(isArabic ? "الاشتراك" : "Subscription",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
              title: Text(isArabic ? "النوع" : "Type"),
              subtitle: Text(userData['subscription']!)),
          ListTile(
              title: Text(isArabic ? "تاريخ الانتهاء" : "Expiry Date"),
              subtitle: Text(userData['expiry']!)),
          ListTile(
              title: Text(isArabic ? "تاريخ الانضمام" : "Joined Date"),
              subtitle: Text(userData['joined']!)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final primaryColor = theme.colorScheme.primary;

    final filteredConversations = allConversations
        .where((conv) => conv['name']!.contains(searchQuery))
        .toList();

    return Scaffold(

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...minimizedChats.map((chat) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: FloatingActionButton.extended(
              heroTag: 'minimized_${chat['id']}',
              backgroundColor: theme.cardColor,
              label: Text(chat['name']!,
                  style: TextStyle(color: theme.textTheme.bodyLarge!.color)),
              icon: Icon(Icons.chat_bubble,color:isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
              onPressed: () => openChat(chat['id']!, chat['name']!),
            ),
          )),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF4F4F4),
              border: Border(
                right: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? "بحث عن مستخدم..."
                          : "Search for user...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (_, index) {
                      final conv = filteredConversations[index];
                      return InkWell(
                        onTap: () => openChat(conv['id']!, conv['name']!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.15),
                                child: Text(conv['avatar']!,
                                    style: TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(conv['name']!,
                                    style:   TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,color:isDark ? const Color(0xFFD7EFDC) :  Colors.blue[900])),
                              ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14,color:isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Conversation Area
          Expanded(
            child: openedChats.isEmpty
                ? Center(
              child: Text(
                isArabic
                    ? "اختر محادثة من القائمة الجانبية"
                    : "Select a conversation from the sidebar",
                style:
                TextStyle(fontSize: 18, color: theme.hintColor),
              ),
            )
                : Container(
              color: isDark
                  ? const Color(0xFF121212)
                  : const Color(0xFFF9FAFC),
              child: Row(
                children: openedChats.map((chat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        color: theme.cardColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: isArabic
                                            ? "تصغير"
                                            : "Minimize",
                                        child: IconButton(
                                          onPressed: () => minimizeChat(
                                              chat['id']!),
                                          icon: const Icon(Icons.minimize,
                                              color: Colors.orange),
                                        ),
                                      ),
                                      Tooltip(
                                        message: isArabic
                                            ? "إغلاق"
                                            : "Close",
                                        child: IconButton(
                                          onPressed: () =>
                                              closeChat(chat['id']!),
                                          icon: const Icon(Icons.close,
                                              color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Container(
                                  color: theme.colorScheme.surface,
                                  child: TabBar(
                                    tabs: [
                                      Tab(
                                          icon:  Icon(Icons
                                              .chat_bubble_outline,color:isDark ? const Color(0xFFD7EFDC) :  Colors.blue[900]),
                                          text: isArabic
                                              ? "المحادثة"
                                              : "Chat"),
                                      Tab(
                                          icon:   Icon(
                                              Icons.person_outline,color:isDark ? const Color(0xFFD7EFDC) :  Colors.blue[900]),
                                          text: isArabic
                                              ? "الملف الشخصي"
                                              : "Profile"),
                                    ],
                                    labelColor:
                                    isDark ? const Color(0xFFD7EFDC) :  Colors.blue[900],
                                    unselectedLabelColor:
                                    theme.hintColor,
                                    indicatorColor:
                                    isDark ? const Color(0xFFD7EFDC) :  Colors.blue[900],
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Stack(
                                        children: [
                                          AdminLiveChatScreen(
                                            conversationId:
                                            chat['id']!,
                                            userName: chat['name']!,
                                          ),
                                        ],
                                      ),
                                      _buildUserProfile(
                                          chat['id']!,
                                          chat['name']!,
                                          isArabic),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
