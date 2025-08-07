import 'package:flutter/material.dart';
import 'UserDetailsPage.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String selectedStatusFilter = 'all';
  String selectedSubscriptionFilter = 'all';
  String searchQuery = '';
  int currentPage = 0;
  final int usersPerPage = 20;

  final List<Map<String, dynamic>> allUsers = [
    {
      'name': 'أحمد خالد',
      'email': 'ahmed@example.com',
      'status': 'active',
      'messages': 124,
      'groups': 5,
      'subscriptionDaysLeft': 30,
      'joinedSince': 90,
      'subscriptionCount': 2,
      'flexPoints': 12,
    },
    {
      'name': 'Sara Mohamed',
      'email': 'sara@example.com',
      'status': 'inactive',
      'messages': 87,
      'groups': 2,
      'subscriptionDaysLeft': 0,
      'joinedSince': 380,
      'subscriptionCount': 1,
      'flexPoints': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    List<Map<String, dynamic>> filteredUsers = allUsers.where((user) {
      final matchesStatus = selectedStatusFilter == 'all' || user['status'] == selectedStatusFilter;
      final matchesSubscription = selectedSubscriptionFilter == 'all' ||
          (selectedSubscriptionFilter == 'activeOnly' && user['subscriptionDaysLeft'] > 0) ||
          (selectedSubscriptionFilter == 'expiredOnly' && user['subscriptionDaysLeft'] == 0);
      final matchesSearch = user['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesSubscription && matchesSearch;
    }).toList();

    final totalPages = (filteredUsers.length / usersPerPage).ceil();
    final paginatedUsers = filteredUsers.skip(currentPage * usersPerPage).take(usersPerPage).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 28, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                'إدارة المستخدمين',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildFilterDropdown(
                title: 'الحالة',
                value: selectedStatusFilter,
                items: {
                  'all': 'الكل',
                  'active': 'فعال',
                  'inactive': 'غير فعال',
                },
                onChanged: (val) {
                  setState(() {
                    selectedStatusFilter = val;
                    currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: 20),
              buildFilterDropdown(
                title: 'الاشتراك',
                value: selectedSubscriptionFilter,
                items: {
                  'all': 'الكل',
                  'activeOnly': 'مشترك حاليًا',
                  'expiredOnly': 'الاشتراك منتهي',
                },
                onChanged: (val) {
                  setState(() {
                    selectedSubscriptionFilter = val;
                    currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '🔍 ابحث بالاسم',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                      currentPage = 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) => isDark ? Colors.grey[900] : Colors.grey[200]),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) => isDark ? Colors.grey[850] : Colors.white),
                  columns: const [
                    DataColumn(label: Text('الاسم')),
                    DataColumn(label: Text('البريد الإلكتروني')),
                    DataColumn(label: Text('الحالة')),
                    DataColumn(label: Text('عدد الرسائل')),
                    DataColumn(label: Text('الجروبات')),
                    DataColumn(label: Text('الأيام المتبقية')),
                    DataColumn(label: Text('مرات الاشتراك')),
                    DataColumn(label: Text('فليكسات')),
                    DataColumn(label: Text('خيارات')),
                  ],
                  rows: paginatedUsers.map((user) {
                    final isActive = user['status'] == 'active';
                    return DataRow(cells: [
                      DataCell(Text(user['name'])),
                      DataCell(Text(user['email'])),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'فعال' : 'غير فعال',
                          style: TextStyle(
                            color: isActive ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataCell(Text('${user['messages']}')),
                      DataCell(Text('${user['groups']}')),
                      DataCell(Text('${user['subscriptionDaysLeft']} يوم')),
                      DataCell(Text('${user['subscriptionCount']} مرة')),
                      DataCell(Text('${user['flexPoints']}')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
                            tooltip: 'إهداء فليكسات',
                            onPressed: () {
                              showFlexGiftDialog(context, user);
                            },
                          ),
                          IconButton(
                            icon: Icon(isActive ? Icons.block : Icons.check_circle_outline,
                                color: isActive ? Colors.orange : Colors.green),
                            tooltip: isActive ? 'تعطيل' : 'تفعيل',
                            onPressed: () {
                              setState(() {
                                user['status'] = isActive ? 'inactive' : 'active';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'حذف',
                            onPressed: () {
                              setState(() {
                                allUsers.remove(user);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: primaryColor),
                            tooltip: 'تفاصيل',
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserDetailsPage(user: user),
                              ));
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
              ),
              Text('${currentPage + 1} / $totalPages'),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFilterDropdown({
    required String title,
    required String value,
    required Map<String, String> items,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  void showFlexGiftDialog(BuildContext context, Map<String, dynamic> user) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إهداء فليكسات لـ ${user['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'عدد الفليكسات (1 - 100)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('إهداء'),
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount >= 1 && amount <= 100) {
                setState(() {
                  user['flexPoints'] = (user['flexPoints'] ?? 0) + amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ تم إهداء $amount فليكس لـ ${user['name']}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ الرجاء إدخال رقم بين 1 و 100')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
