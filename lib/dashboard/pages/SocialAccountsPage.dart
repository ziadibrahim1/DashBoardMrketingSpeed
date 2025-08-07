import 'package:flutter/material.dart';

class SocialAccountsPage extends StatefulWidget {
  const SocialAccountsPage({super.key});

  @override
  State<SocialAccountsPage> createState() => _SocialAccountsPageState();
}

class _SocialAccountsPageState extends State<SocialAccountsPage> {
  final List<Map<String, String>> _socialAccounts = [
    {'platform': 'WhatsApp', 'url': 'https://wa.me/966555555555'},
    {'platform': 'Instagram', 'url': 'https://instagram.com/example'},
  ];

  final _platforms = ['WhatsApp', 'Telegram', 'Instagram', 'Facebook', 'Twitter/X', 'TikTok', 'YouTube'];
  String? _selectedPlatform;
  final TextEditingController _urlController = TextEditingController();
  int? _editingIndex;

  void _showSocialDialog({Map<String, String>? existingAccount, int? index}) {
    _selectedPlatform = existingAccount?['platform'];
    _urlController.text = existingAccount?['url'] ?? '';
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_editingIndex == null ? 'إضافة حساب' : 'تعديل الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPlatform,
              decoration: const InputDecoration(labelText: 'المنصة'),
              items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _selectedPlatform = val),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'رابط الحساب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedPlatform != null && _urlController.text.isNotEmpty) {
                final account = {
                  'platform': _selectedPlatform!,
                  'url': _urlController.text.trim(),
                };

                setState(() {
                  if (_editingIndex != null) {
                    _socialAccounts[_editingIndex!] = account;
                  } else {
                    _socialAccounts.add(account);
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(int index) {
    setState(() => _socialAccounts.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة حسابات التواصل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSocialDialog(),
            tooltip: 'إضافة حساب جديد',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('المنصة')),
              DataColumn(label: Text('الرابط')),
              DataColumn(label: Text('إجراءات')),
            ],
            rows: List.generate(_socialAccounts.length, (index) {
              final account = _socialAccounts[index];
              return DataRow(cells: [
                DataCell(Text(account['platform']!)),
                DataCell(SelectableText(account['url']!)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'تعديل',
                      onPressed: () => _showSocialDialog(
                        existingAccount: account,
                        index: index,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'حذف',
                      onPressed: () => _deleteAccount(index),
                    ),
                  ],
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
