import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart'; // تأكد من مسار الاستيراد الصحيح للـ LocaleProvider

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
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ترجمات حسب اللغة
    final translations = {
      "chatHistoryTitle": isArabic ? "سجل المحادثات" : "Chat History",
      "filterConnectionStatus": isArabic ? "فلتر حالة الاتصال" : "Filter Connection Status",
      "all": isArabic ? "الكل" : "All",
      "onlineOnly": isArabic ? "متصل فقط" : "Online Only",
      "offlineOnly": isArabic ? "غير متصل فقط" : "Offline Only",
      "filterChatStatus": isArabic ? "فلتر حالة المحادثة" : "Filter Chat Status",
      "searchClientName": isArabic ? "ابحث باسم العميل..." : "Search by client name...",
      "noChatsFound": isArabic ? "لا توجد محادثات مطابقة للبحث" : "No chats match your search",
      "waitingReply": isArabic ? "بانتظار الرد" : "Waiting Reply",
      "solved": isArabic ? "محلولة" : "Solved",
      "editChatStatus": isArabic ? "ضبط حالة المحادثة" : "Adjust Chat Status",
      "selectStatus": isArabic ? "اختر الحالة:" : "Select status:",
      "cancel": isArabic ? "إلغاء" : "Cancel",
      "save": isArabic ? "حفظ" : "Save",
      "chatDeleted": isArabic ? "تم حذف المحادثة" : "Chat deleted",
      "chatStatusUpdated": isArabic ? "تم تحديث حالة المحادثة" : "Chat status updated",
      "latest": isArabic ? "الأحدث" : "Latest",
      "oldest": isArabic ? "الأقدم" : "Oldest",
      "minutesAgo": isArabic ? "دقيقة" : "min",
      "hoursAgo": isArabic ? "ساعة" : "hr",
      "daysAgo": isArabic ? "يوم" : "day",
    };

    // نعدل القيم بالإنجليزية حسب isArabic
    final filterStatusOptions = [
      translations["all"]!,
      translations["onlineOnly"]!,
      translations["offlineOnly"]!,
    ];
    final filterTagOptions = [
      translations["all"]!,
      translations["solved"]!,
      translations["waitingReply"]!,
    ];
    final sortOptions = [
      translations["latest"]!,
      translations["oldest"]!,
    ];

    // هنا نحول القيم الحالية في filterStatus وfilterTag للإنجليزية أو العربية بناءً على isArabic
    // لكن بما أن البيانات مخزنة بالعربية، نحتاج عمل خريطة عكسية للفلتر ليطابق الترجمة

    String mapFilterStatusToInternal(String val) {
      if (val == translations["all"]) return "الكل";
      if (val == translations["onlineOnly"]) return "متصل";
      if (val == translations["offlineOnly"]) return "غير متصل";
      return val;
    }

    String mapFilterTagToInternal(String val) {
      if (val == translations["all"]) return "الكل";
      if (val == translations["solved"]) return "محلولة";
      if (val == translations["waitingReply"]) return "بانتظار الرد";
      return val;
    }

    String mapSortOptionToInternal(String val) {
      if (val == translations["latest"]) return "الأحدث";
      if (val == translations["oldest"]) return "الأقدم";
      return val;
    }

    final filtered = allConversations.where((c) {
      final matchesSearch = c["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final internalFilterStatus = mapFilterStatusToInternal(filterStatus);
      final internalFilterTag = mapFilterTagToInternal(filterTag);

      final matchesFilterStatus = internalFilterStatus == "الكل" ||
          (internalFilterStatus == "متصل" && c["online"]) ||
          (internalFilterStatus == "غير متصل" && !c["online"]);

      final matchesFilterTag = internalFilterTag == "الكل" || c["tag"] == internalFilterTag;

      return matchesSearch && matchesFilterStatus && matchesFilterTag;
    }).toList()
      ..sort((a, b) {
        final internalSortOption = mapSortOptionToInternal(sortOption);
        return internalSortOption == "الأحدث"
            ? b["timestamp"].compareTo(a["timestamp"])
            : a["timestamp"].compareTo(b["timestamp"]);
      });

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            translations["chatHistoryTitle"]!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: translations["filterConnectionStatus"],
              onSelected: (val) => setState(() => filterStatus = val),
              itemBuilder: (_) => filterStatusOptions
                  .map((val) => PopupMenuItem(value: val, child: Text(val)))
                  .toList(),
              icon:   Icon(Icons.filter_alt,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
            ),
            PopupMenuButton<String>(
              tooltip: translations["filterChatStatus"],
              onSelected: (val) => setState(() => filterTag = val),
              itemBuilder: (_) => filterTagOptions
                  .map((val) => PopupMenuItem(value: val, child: Text(val)))
                  .toList(),
              icon:   Icon(Icons.label,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: translations["searchClientName"],
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
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64,
                          color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                      const SizedBox(height: 16),
                      Text(
                        translations["noChatsFound"]!,
                        style:   TextStyle(fontSize: 16,
                            color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
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

                    String displayTag = tag == "محلولة"
                        ? translations["solved"]!
                        : translations["waitingReply"]!;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
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
                                child:   Icon(Icons.person,
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
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
                                                displayTag,
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
                                                child:   Icon(Icons.edit,
                                                    size: 16,
                                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
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
                                _formatTime(chat["timestamp"], isArabic),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteChat(chat["id"], translations["chatDeleted"]!),
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
      ),
    );
  }

  void _deleteChat(String id, String msg) {
    setState(() {
      allConversations.removeWhere((c) => c["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showChatDetails(Map<String, dynamic> chat) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final translations = {
      "editChatStatus": isArabic ? "ضبط حالة المحادثة" : "Adjust Chat Status",
      "selectStatus": isArabic ? "اختر الحالة:" : "Select status:",
      "cancel": isArabic ? "إلغاء" : "Cancel",
      "save": isArabic ? "حفظ" : "Save",
      "chatStatusUpdated": isArabic ? "تم تحديث حالة المحادثة" : "Chat status updated",
      "solved": isArabic ? "محلولة" : "Solved",
      "waitingReply": isArabic ? "بانتظار الرد" : "Waiting Reply",
    };

    String selectedTag = chat["tag"];

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                  Icon(Icons.info_outline,
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                const SizedBox(width: 8),
                Text(translations["editChatStatus"]!),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translations["selectStatus"]!),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return DropdownButtonFormField<String>(
                      value: selectedTag,
                      items: tags.map((tag) {
                        // tag بالعربية، نستخدم نفس القيمة كـ value لكن نعرض النص بناءً على اللغة
                        final displayTag = isArabic ? tag : (tag == "محلولة" ? "Solved" : "Waiting Reply");
                        final icon = tag == "محلولة" ? Icons.check_circle : Icons.hourglass_top;
                        final iconColor = tag == "محلولة" ? Colors.green : Colors.orange;

                        return DropdownMenuItem(
                          value: tag,
                          child: Row(
                            children: [
                              Icon(icon, color: iconColor),
                              const SizedBox(width: 8),
                              Text(displayTag),
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
                child: Text(translations["cancel"]!,style:TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
              ),
              ElevatedButton.icon(
                icon:   Icon(Icons.save,
                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                label: Text(translations["save"]!,style:TextStyle(
        color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
                onPressed: () {
                  setState(() {
                    chat["tag"] = selectedTag;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(translations["chatStatusUpdated"]!)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} ${isArabic ? "دقيقة" : "min"}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${isArabic ? "ساعة" : "hr"}";
    } else {
      return "${difference.inDays} ${isArabic ? "يوم" : "day"}";
    }
  }
}
