import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class ReferralRewardsPage extends StatefulWidget {
  const ReferralRewardsPage({super.key});

  @override
  State<ReferralRewardsPage> createState() => _ReferralRewardsPageState();
}

class _ReferralRewardsPageState extends State<ReferralRewardsPage> {
  late List<Map<String, dynamic>> referralLogs;

  String searchQuery = '';
  String? selectedStatus;
  int currentPage = 1;
  final int rowsPerPage = 20;

  late List<String> statuses;

  @override
  void initState() {
    super.initState();

    referralLogs = List.generate(
      50,
          (index) => {
        'referrer': 'User ${index + 1}',
        'code': 'REF${1000 + index}',
        'friend': 'Friend ${index + 1}',
        'date': DateTime.now().subtract(Duration(days: index)),
        'reward': '10 نقاط',
        'status': index % 3 == 0 ? 'معلقة' : 'تمت',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تعيين قائمة الحالات والاختيار حسب اللغة
    statuses = isArabic ? ['الكل', 'تمت', 'معلقة'] : ['All', 'Completed', 'Pending'];
    selectedStatus ??= statuses.first;
    // فلترة السجلات
    final filteredLogs = referralLogs.where((log) {
      final matchesSearch = searchQuery.isEmpty ||
          log['referrer'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          log['code'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == statuses[0] || log['status'] == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    // الصفحات
    final pagedLogs = filteredLogs.skip((currentPage - 1) * rowsPerPage).take(rowsPerPage).toList();
    final totalPages = (filteredLogs.length / rowsPerPage).ceil();

    // ألوان العناوين
    final titleColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              isArabic ? 'إدارة نظام المكافآت' : 'Referral Rewards Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(isArabic ? "عدد الدعوات" : "Total Referrals", referralLogs.length, theme,isDark),
                _buildStatCard(
                    isArabic ? "مستخدمين قاموا بدعوة" : "Users Who Referred",
                    referralLogs.map((e) => e['referrer']).toSet().length,
                    theme,isDark),
                _buildStatCard(
                    isArabic ? "مستخدمين جدد" : "New Users",
                    referralLogs.map((e) => e['friend']).toSet().length,
                    theme,isDark),
                _buildStatCard(
                    isArabic ? "إجمالي المكافآت" : "Total Rewards",
                    '${referralLogs.length * 10} ${isArabic ? "نقطة" : "Points"}',
                    theme,isDark),
              ],
            ),
            const SizedBox(height: 30),
            _buildFilters(isArabic, theme),
            const SizedBox(height: 20),
            _buildTable(pagedLogs, isArabic, theme),
            const SizedBox(height: 16),
            _buildPaginationControls(totalPages, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, ThemeData theme,isDark) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:isDark ? const Color(0xFF4D5D53):Color(0xFFD9F2FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style:   TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isArabic, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: isArabic ? 'ابحث باسم المستخدم أو رمز الدعوة' : 'Search by user or referral code',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                  currentPage = 1;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> logs, bool isArabic, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(theme.brightness == Brightness.dark
              ? const Color(0xFF4D5D53):Color(0xFFD9F2FF)),
        columns: [
          DataColumn(label: Text(isArabic ? 'المستخدم الداعي' : 'Referrer')),
          DataColumn(label: Text(isArabic ? 'رمز الدعوة' : 'Referral Code')),
          DataColumn(label: Text(isArabic ? 'المستخدم الجديد' : 'New User')),
          DataColumn(label: Text(isArabic ? 'تاريخ الاستخدام' : 'Date')),
          DataColumn(label: Text(isArabic ? 'المكافأة' : 'Reward')),
          DataColumn(label: Text(isArabic ? 'الحالة' : 'Status')),
        ],
        rows: logs.map((log) {
          final isCompleted = (isArabic && log['status'] == 'تمت') || (!isArabic && log['status'] == 'Completed');
          final isPending = (isArabic && log['status'] == 'معلقة') || (!isArabic && log['status'] == 'Pending');
          return DataRow(cells: [
            DataCell(Text(log['referrer'])),
            DataCell(Text(log['code'])),
            DataCell(Text(log['friend'])),
            DataCell(Text(log['date'].toString().split(' ')[0])),
            DataCell(Text(log['reward'])),
            DataCell(Text(
              log['status'],
              style: TextStyle(
                color: isCompleted ? Colors.green : (isPending ? Colors.orange : theme.colorScheme.primary),
                fontWeight: FontWeight.bold,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: isArabic ? 'الصفحة السابقة' : 'Previous Page',
        ),
        Text(isArabic ? 'صفحة $currentPage من $totalPages' : 'Page $currentPage of $totalPages'),
        IconButton(
          onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: isArabic ? 'الصفحة التالية' : 'Next Page',
        ),
      ],
    );
  }
}
