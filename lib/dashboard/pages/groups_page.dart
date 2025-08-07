import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  final List<Map<String, dynamic>> groups = const [
    {
      'name': 'مجموعة واتساب - تسويق السعودية',
      'platform': 'WhatsApp',
      'members': 134,
      'created': '2025-07-15',
      'link': 'https://chat.whatsapp.com/abc123',
    },
    {
      'name': 'قناة تليجرام - خصومات الصيف',
      'platform': 'Telegram',
      'members': 412,
      'created': '2025-07-10',
      'link': 'https://t.me/joinchat/xyz456',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green[700] : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📂 إدارة المجموعات',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('اسم المجموعة')),
                DataColumn(label: Text('المنصة')),
                DataColumn(label: Text('عدد الأعضاء')),
                DataColumn(label: Text('تاريخ الإضافة')),
                DataColumn(label: Text('خيارات')),
              ],
              rows: groups.map((group) {
                return DataRow(cells: [
                  DataCell(Text(group['name'])),
                  DataCell(Text(group['platform'])),
                  DataCell(Text(group['members'].toString())),
                  DataCell(Text(group['created'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.link),
                        tooltip: 'فتح المجموعة',
                        onPressed: () {
                          // في التطبيق الحقيقي يتم فتح الرابط باستخدام url_launcher
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'تعديل',
                        onPressed: () {
                          // يمكن لاحقًا فتح نافذة تعديل
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف',
                        onPressed: () {
                          // تأكيد الحذف لاحقًا
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
