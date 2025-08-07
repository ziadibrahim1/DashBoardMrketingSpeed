import 'package:flutter/material.dart';

class AdminChatHistoryScreen extends StatefulWidget {
  const AdminChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminChatHistoryScreen> createState() => _AdminChatHistoryScreenState();
}

class _AdminChatHistoryScreenState extends State<AdminChatHistoryScreen> {
  String searchQuery = "";
  String sortOption = "الأحدث";
  String filterStatus = "الكل"; // متصل، غير متصل، الكل
  String filterTag = "الكل";    // الكل، محلولة، بانتظار الرد

  List<Map<String, dynamic>> allConversations = [
    {
      "id": "c1",
      "name": "محمد علي",
      "lastMessage": "هل يمكنني استرجاع المنتج؟",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "online": true,
      "tag": "بانتظار الرد",
    },
    {
      "id": "c2",
      "name": "سارة محمد",
      "lastMessage": "شكرًا لكم.",
      "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
      "online": false,
      "tag": "محلولة",
    },
    {
      "id": "c3",
      "name": "أحمد خالد",
      "lastMessage": "تم إرسال الصورة",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "online": true,
      "tag": "بانتظار الرد",
    },
  ];

  List<String> tags = ["محلولة", "بانتظار الرد"];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = allConversations.where((c) {
      final matchesSearch = c["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesFilterStatus = filterStatus == "الكل" ||
          (filterStatus == "متصل" && c["online"]) ||
          (filterStatus == "غير متصل" && !c["online"]);

      final matchesFilterTag = filterTag == "الكل" || c["tag"] == filterTag;

      return matchesSearch && matchesFilterStatus && matchesFilterTag;
    }).toList()
      ..sort((a, b) => sortOption == "الأحدث"
          ? b["timestamp"].compareTo(a["timestamp"])
          : a["timestamp"].compareTo(b["timestamp"]));

    return Scaffold(
      appBar: AppBar(
        title:  Text("سجل المحادثات",style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
        actions: [
          // فلتر حالة الاتصال
          PopupMenuButton<String>(
            tooltip: "فلتر حالة الاتصال",
            onSelected: (val) => setState(() => filterStatus = val),
            itemBuilder: (_) => const [
              PopupMenuItem(value: "الكل", child: Text("الكل")),
              PopupMenuItem(value: "متصل", child: Text("متصل فقط")),
              PopupMenuItem(value: "غير متصل", child: Text("غير متصل فقط")),
            ],
            icon: const Icon(Icons.filter_alt),
          ),

          // فلتر حالة المحادثة (Tag)
          PopupMenuButton<String>(
            tooltip: "فلتر حالة المحادثة",
            onSelected: (val) => setState(() => filterTag = val),
            itemBuilder: (_) => [
              const PopupMenuItem(value: "الكل", child: Text("الكل")),
              ...tags.map((tag) => PopupMenuItem(value: tag, child: Text(tag)))
            ],
            icon: const Icon(Icons.label),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث باسم العميل...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),

          if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "لا توجد محادثات مطابقة للبحث",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final chat = filtered[index];
                  final online = chat["online"] as bool;
                  final tag = chat["tag"] as String;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[200],
                              radius: 24,
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: online ? Colors.green : Colors.grey,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    chat["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: tag == "محلولة"
                                              ? Colors.green.withOpacity(0.15)
                                              : Colors.orange.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: tag == "محلولة"
                                                    ? Colors.green.shade800
                                                    : Colors.orange.shade800,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () => _showChatDetails(chat),
                                              child: const Icon(Icons.edit,
                                                  size: 16, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat["lastMessage"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(chat["timestamp"]),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteChat(chat["id"]),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _deleteChat(String id) {
    setState(() {
      allConversations.removeWhere((c) => c["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حذف المحادثة")),
    );
  }

  void _showChatDetails(Map<String, dynamic> chat) {
    String selectedTag = chat["tag"];

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              const Text("ضبط حالة المحادثة"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("اختر الحالة:"),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return DropdownButtonFormField<String>(
                    value: selectedTag,
                    items: tags.map((tag) {
                      return DropdownMenuItem(
                        value: tag,
                        child: Row(
                          children: [
                            Icon(
                              tag == "محلولة" ? Icons.check_circle : Icons.hourglass_top,
                              color: tag == "محلولة" ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(tag),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() {
                          selectedTag = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("حفظ"),
              onPressed: () {
                setState(() {
                  chat["tag"] = selectedTag;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم تحديث حالة المحادثة")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} دقيقة";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ساعة";
    } else {
      return "${difference.inDays} يوم";
    }
  }
}
