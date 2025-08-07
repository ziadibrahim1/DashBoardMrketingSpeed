import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class SimulateTelegramScreen extends StatefulWidget {
  final String userId;

  const SimulateTelegramScreen({required this.userId});

  @override
  _SimulateTelegramScreenState createState() => _SimulateTelegramScreenState();
}

class _SimulateTelegramScreenState extends State<SimulateTelegramScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> channels = [
    {'name': 'قناة تسويق رقمي', 'members': 154},
    {'name': 'قناة أخبار التطبيق', 'members': 87},
    {'name': 'قناة دعم العملاء', 'members': 43},
  ];

  final List<String> chats = ['عميل TG 1', 'عميل TG 2', 'VIP TG', 'TG جديد'];

  List<String> selectedChannels = [];
  List<String> selectedChats = [];

  bool selectAllChannels = false;
  bool selectAllChats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محاكاة تليجرام'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'القنوات (${channels.length})'),
            Tab(text: 'الدردشات (${chats.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChannelTab(),
          _buildChatTab(),
        ],
      ),
    );
  }

  Widget _buildChannelTab() {
    return Column(
      children: [
        _buildChannelActions(),
        Expanded(
          child: ListView.builder(
            itemCount: channels.length,
            itemBuilder: (_, index) {
              final channel = channels[index];
              final name = channel['name'] ?? 'بدون اسم';
              final members = channel['members']?.toString() ?? '0';

              return CheckboxListTile(
                title: Text(name),
                subtitle: Text('عدد الأعضاء: $members'),
                value: selectedChannels.contains(name),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedChannels.add(name);
                    } else {
                      selectedChannels.remove(name);
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

  Widget _buildChannelActions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (selectAllChannels) {
                  selectedChannels.clear();
                } else {
                  selectedChannels = channels.map((c) => c['name'].toString()).toList();
                }
                selectAllChannels = !selectAllChannels;
              });
            },
            child: Text(selectAllChannels ? 'إلغاء تحديد الكل' : 'تحديد كل القنوات'),
          ),
          ElevatedButton(
            onPressed: selectedChannels.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: 'إرسال إلى ${selectedChannels.length} قناة',
                targets: selectedChannels,
                isGroup: true,
              );
            },
            child: Text('إرسال إلى القنوات المحددة'),
          ),
          ElevatedButton(
            onPressed: selectedChannels.isEmpty
                ? null
                : () {
              _openChatRoom(
                title: 'أعضاء القنوات المحددة (${selectedChannels.length})',
                targets: selectedChannels,
                isGroup: true,
                toGroupMembers: true,
              );
            },
            child: Text('إرسال لأعضاء القنوات المحددة'),
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
