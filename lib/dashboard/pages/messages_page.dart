import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<Map<String, dynamic>> allMessages = [
    {
      'user': 'أحمد خالد',
      'platform': 'WhatsApp',
      'destination': 'مجموعة تسويق 1',
      'type': 'مجموعة',
      'content': 'عرض خاص لمدة يومين!',
      'status': 'تم',
      'date': DateTime.parse('2025-07-29 14:32'),
    },
    {
      'user': 'Sara Mohamed',
      'platform': 'Telegram',
      'destination': 'عضو: @mohamed',
      'type': 'عضو',
      'content': 'مرحبا بك 👋',
      'status': 'فشل',
      'date': DateTime.parse('2025-07-28 20:14'),
    },
    {
      'user': 'أحمد خالد',
      'platform': 'Telegram',
      'destination': 'عضو: @ali',
      'type': 'عضو',
      'content': 'اشترك الآن',
      'status': 'تم',
      'date': DateTime.parse('2025-07-27 12:00'),
    },
    {
      'user': 'Sara Mohamed',
      'platform': 'Telegram',
      'destination': 'قناة تسويق',
      'type': 'قناة',
      'content': 'جديد اليوم',
      'status': 'تم',
      'date': DateTime.parse('2025-07-26 10:00'),
    },
  ];

  String? selectedUser;
  String? selectedPlatform;
  String? selectedStatus;
  String? selectedType;
  DateTime? fromDate;
  DateTime? toDate;
  String searchKeyword = '';

  static const int rowsPerPage = 20;
  int currentPage = 0;

  List<Map<String, dynamic>> get filteredMessages {
    return allMessages.where((msg) {
      if (selectedUser != null && msg['user'] != selectedUser) return false;
      if (selectedPlatform != null && msg['platform'] != selectedPlatform) return false;
      if (selectedStatus != null && msg['status'] != selectedStatus) return false;
      if (selectedType != null && msg['type'] != selectedType) return false;
      if (fromDate != null && msg['date'].isBefore(fromDate!)) return false;
      if (toDate != null && msg['date'].isAfter(toDate!)) return false;
      if (searchKeyword.isNotEmpty &&
          !msg['user'].toString().toLowerCase().contains(searchKeyword.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get paginatedMessages {
    final start = currentPage * rowsPerPage;
    final end = start + rowsPerPage;
    final filtered = filteredMessages;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  Future<void> pickDate(BuildContext context, bool isFrom, bool isArabic) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      locale: isArabic ? const Locale('ar') : const Locale('en'),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          // إذا حددت تاريخ 'من' أكبر من 'إلى' نعيد تعيين 'إلى'
          if (toDate != null && toDate!.isBefore(fromDate!)) {
            toDate = null;
          }
        } else {
          toDate = picked;
          // إذا حددت تاريخ 'إلى' أصغر من 'من' نعيد تعيين 'من'
          if (fromDate != null && fromDate!.isAfter(toDate!)) {
            fromDate = null;
          }
        }
        currentPage = 0;
      });
    }
  }

  void resetFilters() {
    setState(() {
      selectedUser = null;
      selectedPlatform = null;
      selectedStatus = null;
      selectedType = null;
      fromDate = null;
      toDate = null;
      searchKeyword = '';
      currentPage = 0;
    });
  }

  void nextPage() {
    if ((currentPage + 1) * rowsPerPage < filteredMessages.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  Map<String, Map<String, int>> getUserPlatformMessageCounts(List<Map<String, dynamic>> messages) {
    final Map<String, Map<String, int>> counts = {};
    for (var msg in messages) {
      final String user = msg['user'];
      final String platform = msg['platform'];
      counts[user] ??= {};
      counts[user]![platform] = (counts[user]![platform] ?? 0) + 1;
    }
    return counts;
  }

  String messageCountLabel(int count, bool isArabic) {
    if (isArabic) {
      return count > 1 ? 'رسائل' : 'رسالة';
    } else {
      return count > 1 ? 'messages' : 'message';
    }
  }

  List<String> getStatusItems(bool isArabic) {
    return isArabic ? ['تم', 'فشل'] : ['Success', 'Failed'];
  }

  List<String> getUniqueValues(String key) {
    final values = allMessages.map((e) => e[key].toString()).toSet().toList();
    values.sort();
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedCounts = getUserPlatformMessageCounts(allMessages);

    // ترجمات النصوص
    final translations = {
      'title': isArabic ? '📨 سجل الرسائل' : '📨 Messages Log',
      'userLabel': isArabic ? 'المستخدم' : 'User',
      'platformLabel': isArabic ? 'المنصة' : 'Platform',
      'statusLabel': isArabic ? 'الحالة' : 'Status',
      'typeLabel': isArabic ? 'النوع' : 'Type',
      'destinationLabel': isArabic ? 'المرسل إليه' : 'Destination',
      'contentLabel': isArabic ? 'المحتوى' : 'Content',
      'dateLabel': isArabic ? 'التاريخ' : 'Date',
      'actionsLabel': isArabic ? 'إجراءات' : 'Actions',
      'resetFiltersLabel': isArabic ? 'إعادة تعيين' : 'Reset',
      'searchHint': isArabic ? '🔍 بحث باسم المستخدم' : '🔍 Search by User Name',
      'resultsCountLabel': isArabic
          ? 'عدد النتائج: ${filteredMessages.length} من أصل ${allMessages.length}'
          : 'Results: ${filteredMessages.length} of ${allMessages.length}',
      'previousLabel': isArabic ? 'السابق' : 'Previous',
      'nextLabel': isArabic ? 'التالي' : 'Next',
      'pageLabel': isArabic ? 'صفحة' : 'Page',
      'ofLabel': isArabic ? 'من' : 'of',
      'resendTooltip': isArabic ? 'إعادة الإرسال' : 'Resend',
      'resendSnackBar': isArabic ? 'سيتم تنفيذ إعادة الإرسال لاحقًا' : 'Resend will be implemented later',
      'fromLabel': isArabic ? 'من' : 'From',
      'toLabel': isArabic ? 'إلى' : 'To',
      'messageStatsTitle': isArabic ? '📊 إحصائيات الرسائل حسب المستخدم والمنصة' : '📊 Message Statistics by User and Platform',
    };

    return Scaffold(
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations['title']!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFD7EFDC) :Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children:[Expanded(child:_buildFiltersCard(isArabic, translations,isDark),),]),
                    const SizedBox(height: 24),
                    Row(children:[Expanded(child: _buildSearchBar(translations),),]),
                    const SizedBox(height: 16),
                    Text(
                      translations['resultsCountLabel']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    _buildDataTable(constraints, isArabic, translations,isDark),
                    const SizedBox(height: 24),
                    _buildPaginationControls(isArabic, translations),
                    const SizedBox(height: 32),
                    Text(
                      translations['messageStatsTitle']!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsCards(groupedCounts, isArabic),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFiltersCard(bool isArabic, Map<String, String> translations,isDark) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildDropdown(
              translations['userLabel']!,
              selectedUser,
              getUniqueValues('user'),
                  (val) {
                setState(() {
                  selectedUser = val;
                  currentPage = 0;
                });
              },
            ),
            _buildDropdown(
              translations['platformLabel']!,
              selectedPlatform,
              getUniqueValues('platform'),
                  (val) {
                setState(() {
                  selectedPlatform = val;
                  currentPage = 0;
                });
              },
            ),
            _buildDropdown(
              translations['statusLabel']!,
              selectedStatus,
              getStatusItems(isArabic),
                  (val) {
                setState(() {
                  selectedStatus = val;
                  currentPage = 0;
                });
              },
            ),
            _buildDropdown(
              translations['typeLabel']!,
              selectedType,
              getUniqueValues('type'),
                  (val) {
                setState(() {
                  selectedType = val;
                  currentPage = 0;
                });
              },
            ),
            _buildDateButton(translations['fromLabel']!, fromDate, () => pickDate(context, true, isArabic),isDark),
            _buildDateButton(translations['toLabel']!, toDate, () => pickDate(context, false, isArabic),isDark),
            ElevatedButton(
              onPressed: resetFilters,
              child: Text(translations['resetFiltersLabel']!,style:TextStyle(color:isDark ? Color(0xFFD7EFDC) :Color(
                  0xFF314250))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(Map<String, String> translations) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(
          hintText: translations['searchHint'],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (val) {
          setState(() {
            searchKeyword = val;
            currentPage = 0;
          });
        },
      ),
    );
  }

  Widget _buildDataTable(BoxConstraints constraints, bool isArabic, Map<String, String> translations,isDark) {
    return
      SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(isDark ? const Color(
              0xFF3F423F) :Colors.grey.shade100),
          dataRowHeight: 56,
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text(translations['userLabel']!)),
            DataColumn(label: Text(translations['platformLabel']!)),
            DataColumn(label: Text(translations['destinationLabel']!)),
            DataColumn(label: Text(translations['typeLabel']!)),
            DataColumn(label: Text(translations['contentLabel']!)),
            DataColumn(label: Text(translations['statusLabel']!)),
            DataColumn(label: Text(translations['dateLabel']!)),
            DataColumn(label: Text(translations['actionsLabel']!)),
          ],
          rows: paginatedMessages.map((msg) {
            final isSuccess = (msg['status'] == 'تم' || msg['status'] == 'Success');
            return DataRow(
              cells: [
                DataCell(Text(msg['user'])),
                DataCell(Text(msg['platform'])),
                DataCell(Text(msg['destination'])),
                DataCell(Text(msg['type'])),
                DataCell(Text(msg['content'], overflow: TextOverflow.ellipsis)),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    msg['status'],
                    style: TextStyle(
                      color: isSuccess ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
                DataCell(Text(msg['date'].toString().substring(0, 16))),
                DataCell(
                  Tooltip(
                    message: translations['resendTooltip'],
                    child: IconButton(
                      icon:   Icon(Icons.refresh, color: isDark ?   Color(0xFFD7EFDC) :Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(translations['resendSnackBar']!)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(bool isArabic, Map<String, String> translations) {
    final totalPages = ((filteredMessages.length - 1) ~/ rowsPerPage) + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: currentPage == 0 ? null : previousPage,
          child: Text(translations['previousLabel']!),
        ),
        const SizedBox(width: 20),
        Text(
          '${translations['pageLabel']} ${currentPage + 1} ${translations['ofLabel']} $totalPages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: (currentPage + 1) * rowsPerPage >= filteredMessages.length ? null : nextPage,
          child: Text(translations['nextLabel']!),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(Map<String, Map<String, int>> groupedCounts, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedCounts.entries.map((entry) {
        final user = entry.key;
        final platforms = entry.value;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👤 $user', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...platforms.entries.map((e) =>
                    Text('🔸 ${e.key}: ${e.value} ${messageCountLabel(e.value, isArabic)}')),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, void Function(String?) onChanged) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap,isDark) {
    return SizedBox(
      width: 140,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(date != null ? '$label: ${date.toLocal().toString().split(' ')[0]}' : label,style:TextStyle(color:isDark ? Color(0xFFD7EFDC) :Color(
            0xFF314250))),
      ),
    );
  }
}
