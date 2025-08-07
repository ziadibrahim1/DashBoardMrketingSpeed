import 'package:flutter/material.dart';

class ReferralRewardsPage extends StatefulWidget {
  const ReferralRewardsPage({super.key});

  @override
  State<ReferralRewardsPage> createState() => _ReferralRewardsPageState();
}

class _ReferralRewardsPageState extends State<ReferralRewardsPage> {
  final List<Map<String, dynamic>> referralLogs = List.generate(
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

  String searchQuery = '';
  String selectedStatus = 'الكل';
  int currentPage = 1;
  int rowsPerPage = 20;

  List<String> statuses = ['الكل', 'تمت', 'معلقة'];

  @override
  Widget build(BuildContext context) {
    final filteredLogs = referralLogs.where((log) {
      final matchesSearch = searchQuery.isEmpty ||
          log['referrer'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          log['code'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == 'الكل' || log['status'] == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    final pagedLogs = filteredLogs.skip((currentPage - 1) * rowsPerPage).take(rowsPerPage).toList();
    final totalPages = (filteredLogs.length / rowsPerPage).ceil();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'إدارة نظام المكافآت',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard("عدد الدعوات", referralLogs.length),
                _buildStatCard("مستخدمين قاموا بدعوة", referralLogs.map((e) => e['referrer']).toSet().length),
                _buildStatCard("مستخدمين جدد", referralLogs.map((e) => e['friend']).toSet().length),
                _buildStatCard("إجمالي المكافآت", '${referralLogs.length * 10} نقطة'),
              ],
            ),
            const SizedBox(height: 30),
            _buildFilters(),
            const SizedBox(height: 20),
            _buildTable(pagedLogs),
            const SizedBox(height: 16),
            _buildPaginationControls(totalPages),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث باسم المستخدم أو رمز الدعوة',
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

  Widget _buildTable(List<Map<String, dynamic>> logs) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('المستخدم الداعي')),
          DataColumn(label: Text('رمز الدعوة')),
          DataColumn(label: Text('المستخدم الجديد')),
          DataColumn(label: Text('تاريخ الاستخدام')),
          DataColumn(label: Text('المكافأة')),
          DataColumn(label: Text('الحالة')),
        ],
        rows: logs.map((log) {
          return DataRow(cells: [
            DataCell(Text(log['referrer'])),
            DataCell(Text(log['code'])),
            DataCell(Text(log['friend'])),
            DataCell(Text(log['date'].toString().split(' ')[0])),
            DataCell(Text(log['reward'])),
            DataCell(Text(
              log['status'],
              style: TextStyle(
                color: log['status'] == 'تمت' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () => setState(() => currentPage--)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('صفحة $currentPage من $totalPages'),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => setState(() => currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
