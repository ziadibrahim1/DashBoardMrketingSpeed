import 'package:flutter/material.dart';

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
    if (start > filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        isFrom ? fromDate = picked : toDate = picked;
        currentPage = 0;
      });
    }
  }

  void resetFilters() {
    setState(() {
      selectedUser = selectedPlatform = selectedStatus = selectedType = null;
      fromDate = toDate = null;
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

  @override
  Widget build(BuildContext context) {
    final groupedCounts = getUserPlatformMessageCounts(allMessages);

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📨 سجل الرسائل',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFiltersCard(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Text(
                  'عدد النتائج: ${filteredMessages.length} من أصل ${allMessages.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildDataTable(constraints),
                const SizedBox(height: 24),
                _buildPaginationControls(),
                const SizedBox(height: 32),
                Text(
                  '📊 إحصائيات الرسائل حسب المستخدم والمنصة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatisticsCards(groupedCounts),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFiltersCard() {
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
            _buildDropdown('المستخدم', selectedUser, _getUniqueValues('user'), (val) {
              setState(() {
                selectedUser = val;
                currentPage = 0;
              });
            }),
            _buildDropdown('المنصة', selectedPlatform, _getUniqueValues('platform'), (val) {
              setState(() {
                selectedPlatform = val;
                currentPage = 0;
              });
            }),
            _buildDropdown('الحالة', selectedStatus, ['تم', 'فشل'], (val) {
              setState(() {
                selectedStatus = val;
                currentPage = 0;
              });
            }),
            _buildDropdown('النوع', selectedType, _getUniqueValues('type'), (val) {
              setState(() {
                selectedType = val;
                currentPage = 0;
              });
            }),
            _buildDateButton('من', fromDate, () => pickDate(context, true)),
            _buildDateButton('إلى', toDate, () => pickDate(context, false)),
            ElevatedButton(
              onPressed: resetFilters,
              child: const Text('إعادة تعيين'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(
          hintText: '🔍 بحث باسم المستخدم',
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

  Widget _buildDataTable(BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.maxWidth,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          dataRowHeight: 56,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('المستخدم')),
            DataColumn(label: Text('المنصة')),
            DataColumn(label: Text('المرسل إليه')),
            DataColumn(label: Text('النوع')),
            DataColumn(label: Text('المحتوى')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('إجراءات')),
          ],
          rows: paginatedMessages.map((msg) {
            final isSuccess = msg['status'] == 'تم';
            return DataRow(cells: [
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
                  message: 'إعادة الإرسال',
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سيتم تنفيذ إعادة الإرسال لاحقًا')),
                      );
                    },
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = ((filteredMessages.length - 1) ~/ rowsPerPage) + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: currentPage == 0 ? null : previousPage,
          child: const Text('السابق'),
        ),
        const SizedBox(width: 20),
        Text('صفحة ${currentPage + 1} من $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: (currentPage + 1) * rowsPerPage >= filteredMessages.length ? null : nextPage,
          child: const Text('التالي'),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(Map<String, Map<String, int>> groupedCounts) {
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
                ...platforms.entries.map((e) => Text('🔸 ${e.key}: ${e.value} رسالة')),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(
      String label, String? value, List<String> items, void Function(String?) onChanged) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return SizedBox(
      width: 140,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(date != null ? '$label: ${date.toLocal().toString().split(' ')[0]}' : label),
      ),
    );
  }

  List<String> _getUniqueValues(String key) {
    final values = allMessages.map((e) => e[key].toString()).toSet().toList();
    values.sort();
    return values;
  }
}
