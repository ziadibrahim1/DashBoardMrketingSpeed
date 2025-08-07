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

  Widget _buildUserProfile(String id, String name) {
    final userData = {
      "email": "$name@email.com",
      "phone": "0501234567",
      "subscription": "Premium",
      "expiry": "2025-12-31",
      "location": "الرياض، السعودية",
      "joined": "2023-06-10"
    };

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          Text("الملف الشخصي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(title: Text("الاسم"), subtitle: Text(name)),
          ListTile(title: Text("البريد الإلكتروني"), subtitle: Text(userData['email']!)),
          ListTile(title: Text("رقم الجوال"), subtitle: Text(userData['phone']!)),
          ListTile(title: Text("المدينة"), subtitle: Text(userData['location']!)),
          const Divider(),
          Text("الاشتراك", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(title: Text("النوع"), subtitle: Text(userData['subscription']!)),
          ListTile(title: Text("تاريخ الانتهاء"), subtitle: Text(userData['expiry']!)),
          ListTile(title: Text("تاريخ الانضمام"), subtitle: Text(userData['joined']!)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final filteredConversations = allConversations
        .where((conv) => conv['name']!.contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title:Text("لوحة المحادثات",  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
        elevation: 0.5,
      ),
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
              icon: Icon(Icons.chat_bubble, color: primaryColor),
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
                      hintText: "بحث عن مستخدم...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.15),
                                child: Text(conv['avatar']!,
                                    style: TextStyle(color: primaryColor)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(conv['name']!,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
                "اختر محادثة من القائمة الجانبية",
                style: TextStyle(fontSize: 18, color: theme.hintColor),
              ),
            )
                : Container(
              color: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFC),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: "تصغير",
                                        child: IconButton(
                                          onPressed: () => minimizeChat(chat['id']!),
                                          icon: const Icon(Icons.minimize,
                                              color: Colors.orange),
                                        ),
                                      ),
                                      Tooltip(
                                        message: "إغلاق",
                                        child: IconButton(
                                          onPressed: () => closeChat(chat['id']!),
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
                                    tabs: const [
                                      Tab(
                                          icon: Icon(Icons.chat_bubble_outline),
                                          text: "المحادثة"),
                                      Tab(
                                          icon: Icon(Icons.person_outline),
                                          text: "الملف الشخصي"),
                                    ],
                                    labelColor: theme.colorScheme.primary,
                                    unselectedLabelColor: theme.hintColor,
                                    indicatorColor: theme.colorScheme.primary,
                                  ),
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Stack(
                                        children: [
                                          AdminLiveChatScreen(
                                            conversationId: chat['id']!,
                                            userName: chat['name']!,
                                          ),
                                          Positioned(
                                            left: 16,
                                            bottom: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),

                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildUserProfile(chat['id']!, chat['name']!),
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
