// 2. simulate_screen.dart (شاشة الجروبات والدردشات)
import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class SimulateScreen extends StatefulWidget {
  @override
  _SimulateScreenState createState() => _SimulateScreenState();
}

class _SimulateScreenState extends State<SimulateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String userId;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محاكاة المستخدم'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'الجروبات (${groups.length})'),
            Tab(text: 'الدردشات (${chats.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupTab(),
          _buildChatTab(),
        ],
      ),
    );
  }

  Widget _buildGroupTab() {
    return Column(
      children: [
        _buildGroupActions(),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (_, index) {
              final group = groups[index];
              final name = group['name'] ?? 'بدون اسم';
              final members = group['members']?.toString() ?? '0';

              return CheckboxListTile(
                title: Text('$name'),
                subtitle: Text('عدد الأعضاء: $members'),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        _buildChatActions(),
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, index) {
              final chat = chats[index];
              return CheckboxListTile(
                title: Text(chat),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupActions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        children: [
          ElevatedButton(
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
            child: Text(selectAllGroups ? 'إلغاء تحديد الكل' : 'تحديد كل الجروبات'),
          ),
          ElevatedButton(
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: 'إرسال إلى ${selectedGroups.length} جروب',
                targets: selectedGroups,
                isGroup: true,
              );
            },
            child: Text('إرسال إلى الجروبات المحددة'),
          ),
          ElevatedButton(
            onPressed: selectedGroups.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: 'أعضاء الجروبات المحددة (${selectedGroups.length})',
                targets: selectedGroups,
                isGroup: true,
                toGroupMembers: true,
              );
            },
            child: Text('إرسال لأعضاء الجروبات المحددة'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatActions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        children: [
          ElevatedButton(
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
            child: Text(selectAllChats ? 'إلغاء تحديد الكل' : 'تحديد كل الدردشات'),
          ),
          ElevatedButton(
            onPressed: selectedChats.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: 'إرسال إلى ${selectedChats.length} دردشة',
                targets: selectedChats,
                isGroup: false,
              );
            },
            child: Text('إرسال إلى الدردشات المحددة'),
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
          userId: userId,
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