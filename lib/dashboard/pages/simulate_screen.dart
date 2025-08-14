import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class SimulateScreen extends StatefulWidget {
  final String userId;

  const SimulateScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SimulateScreenState createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> groups = [
    {'name': 'جروب تسويق 1', 'members': 123},
    {'name': 'قناة تيليجرام 2', 'members': 80},
    {'name': 'جروب دعم فني', 'members': 45},
  ];

  final List<String> chats = ['عميل 1', 'عميل 2', 'عميل VIP', 'عميل جديد'];

  List<String> selectedGroups = [];
  List<String> selectedChats = [];

  bool selectAllGroups = false;
  bool selectAllChats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final primaryColor = isDark ? Colors.teal[300] : Colors.teal;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          isArabic ? 'محاكاة المستخدم' : 'User Simulation',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: [
            Tab(text: isArabic ? 'الجروبات (${groups.length})' : 'Groups (${groups.length})'),
            Tab(text: isArabic ? 'الدردشات (${chats.length})' : 'Chats (${chats.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupTab(isArabic, cardColor, textColor, subtitleColor, primaryColor),
          _buildChatTab(isArabic, cardColor, textColor, primaryColor),
        ],
      ),
    );
  }

  Widget _buildGroupTab(bool isArabic, Color? cardColor, Color textColor, Color? subtitleColor, Color? primaryColor) {
    return Column(
      children: [
        _buildGroupActions(isArabic, primaryColor),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: groups.length,
            itemBuilder: (_, index) {
              final group = groups[index];
              final name = group['name'] ?? (isArabic ? 'بدون اسم' : 'No Name');
              final members = group['members']?.toString() ?? '0';

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  activeColor: primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isArabic ? 'عدد الأعضاء: $members' : 'Members: $members',
                    style: TextStyle(color: subtitleColor),
                  ),
                  value: selectedGroups.contains(name),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedGroups.add(name);
                      } else {
                        selectedGroups.remove(name);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab(bool isArabic, Color? cardColor, Color textColor, Color? primaryColor) {
    return Column(
      children: [
        _buildChatActions(isArabic, primaryColor),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: chats.length,
            itemBuilder: (_, index) {
              final chat = chats[index];

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  activeColor: primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(chat, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  value: selectedChats.contains(chat),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedChats.add(chat);
                      } else {
                        selectedChats.remove(chat);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupActions(bool isArabic, Color? primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(selectAllGroups ? Icons.clear_all : Icons.select_all),
            label: Text(selectAllGroups
                ? (isArabic ? 'إلغاء تحديد الكل' : 'Unselect All')
                : (isArabic ? 'تحديد كل الجروبات' : 'Select All Groups')),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                if (selectAllGroups) {
                  selectedGroups.clear();
                } else {
                  selectedGroups = groups.map((g) => g['name'].toString()).toList();
                }
                selectAllGroups = !selectAllGroups;
              });
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: Text(isArabic ? 'إرسال إلى الجروبات المحددة' : 'Send to Selected Groups'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: isArabic
                    ? 'إرسال إلى ${selectedGroups.length} جروب'
                    : 'Send to ${selectedGroups.length} Groups',
                targets: selectedGroups,
                isGroup: true,
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: Text(isArabic ? 'إرسال لأعضاء الجروبات المحددة' : 'Send to Group Members'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: isArabic
                    ? 'أعضاء الجروبات المحددة (${selectedGroups.length})'
                    : 'Members of Selected Groups (${selectedGroups.length})',
                targets: selectedGroups,
                isGroup: true,
                toGroupMembers: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatActions(bool isArabic, Color? primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(selectAllChats ? Icons.clear_all : Icons.select_all),
            label: Text(selectAllChats
                ? (isArabic ? 'إلغاء تحديد الكل' : 'Unselect All')
                : (isArabic ? 'تحديد كل الدردشات' : 'Select All Chats')),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                if (selectAllChats) {
                  selectedChats.clear();
                } else {
                  selectedChats = List.from(chats);
                }
                selectAllChats = !selectAllChats;
              });
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: Text(isArabic ? 'إرسال إلى الدردشات المحددة' : 'Send to Selected Chats'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedChats.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: isArabic
                    ? 'إرسال إلى ${selectedChats.length} دردشة'
                    : 'Send to ${selectedChats.length} Chats',
                targets: selectedChats,
                isGroup: false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _openChatRoom({
    required String title,
    required List<String> targets,
    required bool isGroup,
    bool toGroupMembers = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          userId: widget.userId,
          title: title,
          isGroup: isGroup,
          multiMode: true,
          targets: targets,
          toGroupMembers: toGroupMembers,
        ),
      ),
    );
  }
}
