import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';

enum SuggestionFilter {
  all,
  newest,
  replied,
  notReplied,
  starred,
}

class SuggestionsManagementPage extends StatefulWidget {
  const SuggestionsManagementPage({super.key});
  @override
  State<SuggestionsManagementPage> createState() =>
      _SuggestionsManagementPageState();
}

class _SuggestionsManagementPageState extends State<SuggestionsManagementPage> {
  static const int pageSize = 20;
  late List<Suggestion> suggestions;

  int currentPage = 1;
  SuggestionFilter selectedFilter = SuggestionFilter.all;

  @override
  void initState() {
    super.initState();
    suggestions = List.generate(
      75,
          (index) => Suggestion(
        id: index + 1,
        username: "مستخدم ${index + 1}",
        content: "هذا هو الاقتراح رقم ${index + 1}.",
        isNew: index % 5 == 0,
        dateAdded: DateTime.now().subtract(Duration(days: index)),
        adminReply:
        index % 7 == 0 ? "رد إداري على الاقتراح رقم ${index + 1}" : null,
        isStarred: index % 10 == 0,
      ),
    );
  }

  void _replyToSuggestion(Suggestion suggestion, bool isArabic,bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        String replyText = suggestion.adminReply ?? '';
        return AlertDialog(
          title: Text(isArabic ? 'رد إداري' : 'Admin Reply',style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
          content: TextField(
            maxLines: 4,
            controller: TextEditingController(text: replyText),
            onChanged: (value) => replyText = value,
            decoration: InputDecoration(
              hintText: isArabic ? 'اكتب الرد هنا...' : 'Write reply here...',
              border: const OutlineInputBorder(),
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          actions: [
            TextButton(
              child: Text(isArabic ? 'إلغاء' : 'Cancel',style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(isArabic ? 'إرسال' : 'Send',style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
              onPressed: () {
                setState(() {
                  suggestion.adminReply =
                  replyText.trim().isEmpty ? null : replyText.trim();
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

  List<Suggestion> getFilteredSuggestions() {
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

  List<Suggestion> getPagedSuggestions(List<Suggestion> filtered) {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > filtered.length
        ? filtered.length
        : (start + pageSize);
    return filtered.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // نصوص حسب اللغة
    final titles = {
      'pageTitle': isArabic ? 'إدارة اقتراحات المستخدمين' : 'User Suggestions Management',
      'totalSuggestions': isArabic ? 'إجمالي الاقتراحات' : 'Total Suggestions',
      'newSuggestions': isArabic ? 'الاقتراحات الجديدة' : 'New Suggestions',
      'allSuggestions': isArabic ? 'كل الاقتراحات' : 'All Suggestions',
      'newestFirst': isArabic ? 'الأحدث أولاً' : 'Newest First',
      'replied': isArabic ? 'تم الرد عليها' : 'Replied',
      'notReplied': isArabic ? 'لم يتم الرد عليها' : 'Not Replied',
      'starred': isArabic ? 'المميزة ★' : 'Starred ★',
      'noSuggestions': isArabic ? 'لا توجد اقتراحات' : 'No Suggestions',
      'adminReply': isArabic ? 'رد إداري' : 'Admin Reply',
      'cancel': isArabic ? 'إلغاء' : 'Cancel',
      'send': isArabic ? 'إرسال' : 'Send',
      'replyHint': isArabic ? 'اكتب الرد هنا...' : 'Write reply here...',
      'mark': isArabic ? 'تمييز الاقتراح' : 'Mark Suggestion',
      'unmark': isArabic ? 'إلغاء التمييز' : 'Unmark Suggestion',
      'newTag': isArabic ? 'جديد' : 'New',
      'page': isArabic ? 'صفحة' : 'Page',
      'of': isArabic ? 'من' : 'of',
    };

    final filteredSuggestions = getFilteredSuggestions();
    final pagedSuggestions = getPagedSuggestions(filteredSuggestions);
    final totalPages = (filteredSuggestions.length / pageSize).ceil();
    final newCount = suggestions.where((s) => s.isNew).length;
    final totalCount = suggestions.length;

    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;

    // لضبط اتجاه النص والتخطيط
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final alignmentStart = isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final alignmentEnd = isArabic ? Alignment.centerRight : Alignment.centerLeft;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titles['pageTitle']!,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: textDirection,
                children: [
                  // العدادات
                  Row(
                    textDirection: textDirection,
                    children: [
                      _buildCountCard(
                          label: titles['totalSuggestions']!,
                          count: totalCount,
                          color: isDark?Colors.green:Colors.blue),
                      const SizedBox(width: 24),
                      _buildCountCard(
                          label: titles['newSuggestions']!,
                          count: newCount,
                          color: isDark?Colors.green:Colors.blue),
                    ],
                  ),
                  // فلتر الاقتراحات
                  DropdownButton<SuggestionFilter>(
                    value: selectedFilter,
                    items: [
                      DropdownMenuItem(
                          value: SuggestionFilter.all,
                          child: Text(titles['allSuggestions']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]))),
                      DropdownMenuItem(
                          value: SuggestionFilter.newest,
                          child: Text(titles['newestFirst']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]))),
                      DropdownMenuItem(
                          value: SuggestionFilter.replied,
                          child: Text(titles['replied']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]))),
                      DropdownMenuItem(
                          value: SuggestionFilter.notReplied,
                          child: Text(titles['notReplied']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]))),
                      DropdownMenuItem(
                          value: SuggestionFilter.starred,
                          child: Text(titles['starred']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]))),
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
              Expanded(
                child: pagedSuggestions.isEmpty
                    ? Center(
                  child: Text(
                    titles['noSuggestions']!,
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey.shade600),
                  ),
                )
                    : ListView.separated(
                  itemCount: pagedSuggestions.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final suggestion = pagedSuggestions[index];
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark?Colors.green.withOpacity(.1):Colors.white,
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
                        crossAxisAlignment: alignmentStart,
                        children: [
                          Row(
                            textDirection: textDirection,
                            children: [
                               Icon(Icons.person,color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  suggestion.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                       color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: suggestion.isStarred
                                    ? titles['unmark']!
                                    : titles['mark']!,
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
                                    suggestion.isStarred =
                                    !suggestion.isStarred;
                                  });
                                },
                              ),
                              if (suggestion.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    titles['newTag']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                      Row(
                        textDirection:isArabic? TextDirection.rtl:TextDirection.ltr,
                        children: [Text(
                            suggestion.content,
                            style: TextStyle(
                                fontSize: 15,color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                            textDirection: textDirection,
                          ),]),
                          const SizedBox(height: 12),
                          if (suggestion.adminReply != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: isDark ?   Colors.green.withOpacity(.3) : Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                textDirection: textDirection,
                                children: [
                                  Icon(Icons.reply,
                                      color: isDark
                                          ? Colors.greenAccent
                                          : Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      suggestion.adminReply!,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                                      ),
                                      textDirection: textDirection,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            alignment: alignmentEnd,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _replyToSuggestion(suggestion, isArabic,isDark),
                              icon:  Icon(Icons.reply,color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                              label: Text(titles['adminReply']!,style:TextStyle(color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                            ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
                          isSelected ? isDark ? Colors.green[900] : Colors.blue[900] : Colors.grey.shade300,
                          foregroundColor:
                          isSelected ? Colors.white :  isDark ?  Colors.green[900] : Colors.blue[300],
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
