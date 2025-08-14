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
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

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
                Icon(Icons.people_alt_rounded, size: 28, color:isDark? Colors.green:Colors.blue),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'إدارة المستخدمين' : 'Users Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFD7EFDC) :Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildFilterDropdown(
                title: isArabic ? 'الحالة' : 'Status',
                value: selectedStatusFilter,
                items: {
                  'all': isArabic ? 'الكل' : 'All',
                  'active': isArabic ? 'فعال' : 'Active',
                  'inactive': isArabic ? 'غير فعال' : 'Inactive',
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
                title: isArabic ? 'الاشتراك' : 'Subscription',
                value: selectedSubscriptionFilter,
                items: {
                  'all': isArabic ? 'الكل' : 'All',
                  'activeOnly': isArabic ? 'مشترك حاليًا' : 'Active Only',
                  'expiredOnly': isArabic ? 'الاشتراك منتهي' : 'Expired Only',
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
                  decoration: InputDecoration(
                    labelText: isArabic ? '🔍 ابحث بالاسم' : '🔍 Search by name',
                    border: const OutlineInputBorder(),
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
                  columns: [
                    DataColumn(label: Text(isArabic ? 'الاسم' : 'Name')),
                    DataColumn(label: Text(isArabic ? 'البريد الإلكتروني' : 'Email')),
                    DataColumn(label: Text(isArabic ? 'الحالة' : 'Status')),
                    DataColumn(label: Text(isArabic ? 'عدد الرسائل' : 'Messages')),
                    DataColumn(label: Text(isArabic ? 'الجروبات' : 'Groups')),
                    DataColumn(label: Text(isArabic ? 'الأيام المتبقية' : 'Days Left')),
                    DataColumn(label: Text(isArabic ? 'مرات الاشتراك' : 'Subscription Count')),
                    DataColumn(label: Text(isArabic ? 'فليكسات' : 'Flex Points')),
                    DataColumn(label: Text(isArabic ? 'خيارات' : 'Options')),
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
                          isActive ? (isArabic ? 'فعال' : 'Active') : (isArabic ? 'غير فعال' : 'Inactive'),
                          style: TextStyle(
                            color: isActive ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataCell(Text('${user['messages']}')),
                      DataCell(Text('${user['groups']}')),
                      DataCell(Text('${user['subscriptionDaysLeft']} ${isArabic ? 'يوم' : 'days'}')),
                      DataCell(Text('${user['subscriptionCount']} ${isArabic ? 'مرة' : 'times'}')),
                      DataCell(Text('${user['flexPoints']}')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon:   Icon(Icons.card_giftcard, color:isDark? Colors.green:Colors.blue),
                            tooltip: isArabic ? 'إهداء فليكسات' : 'Gift Flex Points',
                            onPressed: () {
                              showFlexGiftDialog(context, user, isArabic);
                            },
                          ),
                          IconButton(
                            icon: Icon(isActive ? Icons.block : Icons.check_circle_outline,
                                color: isActive ? Colors.orange : Colors.green),
                            tooltip: isActive ? (isArabic ? 'تعطيل' : 'Disable') : (isArabic ? 'تفعيل' : 'Enable'),
                            onPressed: () {
                              setState(() {
                                user['status'] = isActive ? 'inactive' : 'active';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: isArabic ? 'حذف' : 'Delete',
                            onPressed: () {
                              setState(() {
                                allUsers.remove(user);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color:isDark? Colors.green:Colors.blue),
                            tooltip: isArabic ? 'تفاصيل' : 'Details',
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
                tooltip: isArabic ? 'السابق' : 'Previous',
              ),
              Text('${currentPage + 1} / $totalPages'),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
                tooltip: isArabic ? 'التالي' : 'Next',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showFlexGiftDialog(BuildContext context, Map<String, dynamic> user, bool isArabic) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? 'إهداء فليكسات لـ ${user['name']}' : 'Gift Flex Points to ${user['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: isArabic ? 'عدد الفليكسات (1 - 100)' : 'Number of Flex Points (1 - 100)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(isArabic ? 'إهداء' : 'Gift'),
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount >= 1 && amount <= 100) {
                setState(() {
                  user['flexPoints'] = (user['flexPoints'] ?? 0) + amount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ ${isArabic ? "تم إهداء" : "Gifted"} $amount ${isArabic ? "فليكس" : "flex points"} ${isArabic ? "لـ" : "to"} ${user['name']}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isArabic ? '⚠️ الرجاء إدخال رقم بين 1 و 100' : '⚠️ Please enter a number between 1 and 100')),
                );
              }
            },
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


}
