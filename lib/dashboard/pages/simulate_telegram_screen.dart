import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class SimulateScreentele extends StatefulWidget {
  final String userId;

  const SimulateScreentele({Key? key, required this.userId}) : super(key: key);

  @override
  _SimulateScreenStatetele createState() => _SimulateScreenStatetele();
}

class _SimulateScreenStatetele extends State<SimulateScreentele>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> groups = [
    {'name': 'قناة تسويق 1', 'members': 123},
    {'name': 'قناة تيليجرام 2', 'members': 80},
    {'name': 'قناة دعم فني', 'members': 45},
  ];

  final List<String> chats = ['عميل 1', 'عميل 2', 'عميل VIP', 'عميل جديد'];

  List<String> selectedGroups = [];
  List<String> selectedChats = [];

  bool selectAllGroups = false;
  bool selectAllChats = false;

  // متغيرات لعرض ChatRoom داخل نفس الصفحة
  bool _showChatRoom = false;
  String _chatRoomTitle = '';
  List<String> _chatRoomTargets = [];
  bool _chatRoomIsGroup = false;
  bool _chatRoomToGroupMembers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _openChatRoomInline({
    required String title,
    required List<String> targets,
    required bool isGroup,
    bool toGroupMembers = false,
    required bool type,
  }) {
    setState(() {
      _showChatRoom = true;
      _chatRoomTitle = title;
      _chatRoomTargets = targets;
      _chatRoomIsGroup = isGroup;
      _chatRoomToGroupMembers = toGroupMembers;
    });
  }

  void _closeChatRoom() {
    setState(() {
      _showChatRoom = false;
      _chatRoomTargets = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final primaryColor = isDark ? const Color(0xFF4D5D53) : const Color(0xFF65C4F8);
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon:  Icon(Icons.arrow_back,color: isDark ? Colors.green[200] : Colors.blue[900],
                ),
                onPressed: _closeChatRoom,
              ),
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: isDark ? const Color(0xFF5EAF6D) : Colors.blue[800],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[800],
                  ),
                  unselectedLabelColor: isDark ? const Color(0xFF86D091) : Colors.blue[300],
                  tabs: [
                    Tab(text: isArabic ? 'القنوات (${groups.length})' : 'Channels (${groups.length})'),
                    Tab(text: isArabic ? 'الدردشات (${chats.length})' : 'Chats (${chats.length})'),
                  ],
                ),
              ),
            ],
          ),

        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : const Color(0xFFAFDBF5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _showChatRoom
            ? ChatRoomScreen(
          userId: widget.userId,
          title: _chatRoomTitle,
          isGroup: _chatRoomIsGroup,
          multiMode: true,
          targets: _chatRoomTargets,
          toGroupMembers: _chatRoomToGroupMembers,type:false
        )
            : TabBarView(
          controller: _tabController,
          children: [
            _buildGroupTab(
                isArabic, cardColor, textColor, subtitleColor, primaryColor, isDark),
            _buildChatTab(
                isArabic, cardColor, textColor, primaryColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTab(bool isArabic, Color? cardColor, Color textColor,
      Color? subtitleColor, Color? primaryColor, bool isDark) {
    return Column(
      children: [
        _buildGroupActions(isArabic, primaryColor, isDark),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  activeColor: isDark ? Colors.green : Colors.blue,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(name,
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isArabic
                        ? 'عدد الأعضاء: $members'
                        : 'Members: $members',
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

  Widget _buildChatTab(bool isArabic, Color? cardColor, Color textColor,
      Color? primaryColor, bool isDark) {
    return Column(
      children: [
        _buildChatActions(isArabic, primaryColor, isDark),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: CheckboxListTile(
                  activeColor: isDark ? Colors.green : Colors.blue,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(chat,
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w600)),
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

  Widget _buildGroupActions(bool isArabic, Color? primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(selectAllGroups ? Icons.clear_all : Icons.select_all,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.white),
            label: Text(
                selectAllGroups
                    ? (isArabic ? 'إلغاء تحديد الكل' : 'Unselect All')
                    : (isArabic ? 'تحديد كل القنوات' : 'Select All Channels'),
                style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.green.shade800 : Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                if (selectAllGroups) {
                  selectedGroups.clear();
                } else {
                  selectedGroups =
                      groups.map((g) => g['name'].toString()).toList();
                }
                selectAllGroups = !selectAllGroups;
              });
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.send,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.white),
            label: Text(isArabic
                ? 'إرسال إلى القنوات المحددة'
                : 'Send to Selected Channels',
                style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.green.shade800 : Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoomInline(
                title: isArabic
                    ? 'إرسال إلى ${selectedGroups.length} قناة'
                    : 'Send to ${selectedGroups.length} Channels',
                targets: selectedGroups,
                isGroup: true
                  ,type:false
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.people,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.white),
            label: Text(isArabic
                ? 'إرسال لأعضاء القنوات المحددة'
                : 'Send to Channels Members',
                style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.green.shade800 : Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoomInline(
                title: isArabic
                    ? 'أعضاء القنوات المحددة (${selectedGroups.length})'
                    : 'Members of Selected Channels (${selectedGroups.length})',
                targets: selectedGroups,
                isGroup: true,
                toGroupMembers: true,type:false
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatActions(bool isArabic, Color? primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(selectAllChats ? Icons.clear_all : Icons.select_all,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.white),
            label: Text(
                selectAllChats
                    ? (isArabic ? 'إلغاء تحديد الكل' : 'Unselect All')
                    : (isArabic ? 'تحديد كل الدردشات' : 'Select All Chats'),
                style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.green.shade800 : Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
            icon: Icon(Icons.send,
                color: isDark ? const Color(0xFFD7EFDC) : Colors.white),
            label: Text(isArabic
                ? 'إرسال إلى الدردشات المحددة'
                : 'Send to Selected Chats',
                style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isDark ? Colors.green.shade800 : Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: selectedChats.isEmpty
                ? null
                : () {
              _openChatRoomInline(
                title: isArabic
                    ? 'إرسال إلى ${selectedChats.length} دردشة'
                    : 'Send to ${selectedChats.length} Chats',
                targets: selectedChats,
                isGroup: false,
                  type:false
              );
            },
          ),
        ],
      ),
    );
  }
}
