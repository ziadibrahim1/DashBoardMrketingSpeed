import 'package:flutter/material.dart';

class SuggestionsManagementPage extends StatefulWidget {
  const SuggestionsManagementPage({super.key});

  @override
  State<SuggestionsManagementPage> createState() =>
      _SuggestionsManagementPageState();
}

enum SuggestionFilter {
  all,
  newest,
  replied,
  notReplied,
  starred,
}

class _SuggestionsManagementPageState extends State<SuggestionsManagementPage> {
  static const int pageSize = 20;

  List<Suggestion> suggestions = List.generate(
    75,
        (index) => Suggestion(
      id: index + 1,
      username: "مستخدم ${index + 1}",
      content: "هذا هو الاقتراح رقم ${index + 1}.",
      isNew: index % 5 == 0, // كل خامس اقتراح جديد
      dateAdded: DateTime.now().subtract(Duration(days: index)),
      adminReply: index % 7 == 0 ? "رد إداري على الاقتراح رقم ${index + 1}" : null,
      isStarred: index % 10 == 0,
    ),
  );

  int currentPage = 1;
  SuggestionFilter selectedFilter = SuggestionFilter.all;

  void _replyToSuggestion(Suggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) {
        String replyText = suggestion.adminReply ?? '';
        return AlertDialog(
          title: const Text('رد إداري'),
          content: TextField(
            maxLines: 4,
            controller: TextEditingController(text: replyText),
            onChanged: (value) => replyText = value,
            decoration: const InputDecoration(
              hintText: 'اكتب الرد هنا...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('إرسال'),
              onPressed: () {
                setState(() {
                  suggestion.adminReply = replyText.trim().isEmpty ? null : replyText.trim();
                  suggestion.isNew = false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<Suggestion> get filteredSuggestions {
    List<Suggestion> filtered = [...suggestions];

    switch (selectedFilter) {
      case SuggestionFilter.all:
        break;
      case SuggestionFilter.newest:
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SuggestionFilter.replied:
        filtered = filtered.where((s) => s.adminReply != null).toList();
        break;
      case SuggestionFilter.notReplied:
        filtered = filtered.where((s) => s.adminReply == null).toList();
        break;
      case SuggestionFilter.starred:
        filtered = filtered.where((s) => s.isStarred).toList();
        break;
    }

    return filtered;
  }

  List<Suggestion> get pagedSuggestions {
    final filtered = filteredSuggestions;
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > filtered.length ? filtered.length : (start + pageSize);
    return filtered.sublist(start, end);
  }

  int get totalPages => (filteredSuggestions.length / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final newCount = suggestions.where((s) => s.isNew).length;
    final totalCount = suggestions.length;

    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(


      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'إدارة اقتراحات المستخدمين',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // العدادات الكلية والجديدة مع فلتر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // العدادات
                Row(
                  children: [
                    _buildCountCard(
                        label: "إجمالي الاقتراحات",
                        count: totalCount,
                        color: Colors.blue),
                    const SizedBox(width: 24),
                    _buildCountCard(
                        label: "الاقتراحات الجديدة",
                        count: newCount,
                        color: Colors.red),
                  ],
                ),

                // فلتر الاقتراحات
                DropdownButton<SuggestionFilter>(
                  value: selectedFilter,
                  items: const [
                    DropdownMenuItem(
                        value: SuggestionFilter.all,
                        child: Text("كل الاقتراحات")),
                    DropdownMenuItem(
                        value: SuggestionFilter.newest,
                        child: Text("الأحدث أولاً")),
                    DropdownMenuItem(
                        value: SuggestionFilter.replied,
                        child: Text("تم الرد عليها")),
                    DropdownMenuItem(
                        value: SuggestionFilter.notReplied,
                        child: Text("لم يتم الرد عليها")),
                    DropdownMenuItem(
                        value: SuggestionFilter.starred,
                        child: Text("المميزة ★")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedFilter = val;
                        currentPage = 1;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // قائمة الاقتراحات مع التمرير والصفحات
            Expanded(
              child: pagedSuggestions.isEmpty
                  ? Center(
                child: Text(
                  "لا توجد اقتراحات",
                  style: TextStyle(
                      fontSize: 18, color: Colors.grey.shade600),
                ),
              )
                  : ListView.separated(
                itemCount: pagedSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final suggestion = pagedSuggestions[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            // زر التمييز بنجمة
                            IconButton(
                              tooltip: suggestion.isStarred
                                  ? "إلغاء التمييز"
                                  : "تمييز الاقتراح",
                              icon: Icon(
                                suggestion.isStarred
                                    ? Icons.star
                                    : Icons.star_border,
                                color: suggestion.isStarred
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  suggestion.isStarred = !suggestion.isStarred;
                                });
                              },
                            ),

                            // علامة جديد إذا الاقتراح جديد
                            if (suggestion.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "جديد",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          suggestion.content,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        if (suggestion.adminReply != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.reply, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    suggestion.adminReply!,
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => _replyToSuggestion(suggestion),
                            icon: const Icon(Icons.reply),
                            label: const Text('رد إداري'),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Pagination controls
            if (totalPages > 1)
              Center(
                child: Wrap(
                  spacing: 8,
                  children: List.generate(totalPages, (index) {
                    final pageNum = index + 1;
                    final isSelected = pageNum == currentPage;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isSelected ? primaryColor : Colors.grey.shade300,
                        foregroundColor:
                        isSelected ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage = pageNum;
                        });
                      },
                      child: Text(pageNum.toString()),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(
      {required String label, required int count, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class Suggestion {
  final int id;
  final String username;
  final String content;
  bool isNew;
  String? adminReply;
  bool isStarred;
  final DateTime dateAdded;

  Suggestion({
    required this.id,
    required this.username,
    required this.content,
    this.isNew = true,
    this.adminReply,
    this.isStarred = false,
    required this.dateAdded,
  });
}
