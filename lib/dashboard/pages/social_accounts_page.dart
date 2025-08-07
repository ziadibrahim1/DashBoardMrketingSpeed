import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialAccountsPage extends StatefulWidget {
  const SocialAccountsPage({super.key});

  @override
  State<SocialAccountsPage> createState() => _SocialAccountsPageState();
}

class _SocialAccountsPageState extends State<SocialAccountsPage> {
  final List<_SocialItem> _items = [
    _SocialItem('واتساب', FontAwesomeIcons.whatsapp, 'https://wa.me/...', Colors.green),
    _SocialItem('تيليجرام', FontAwesomeIcons.telegram, 'https://t.me/...', Colors.blue),
    _SocialItem('فيسبوك', FontAwesomeIcons.facebook, 'https://facebook.com/...', Colors.indigo),
    _SocialItem('إنستقرام', FontAwesomeIcons.instagram, 'https://instagram.com/...', Colors.purple),
    _SocialItem('تويتر (X)', FontAwesomeIcons.xTwitter, 'https://x.com/...', Colors.black),
    _SocialItem('تيك توك', FontAwesomeIcons.tiktok, 'https://tiktok.com/@...', Colors.black),
    _SocialItem('سناب شات', FontAwesomeIcons.snapchatGhost, 'https://snapchat.com/add/...', Colors.yellow[700]!),
    _SocialItem('الهاتف', FontAwesomeIcons.phone, '+966 5XXXXXXXX', Colors.teal),
    _SocialItem('البريد الإلكتروني', FontAwesomeIcons.envelope, 'example@email.com', Colors.orange),
    _SocialItem('الموقع الإلكتروني', FontAwesomeIcons.link, 'https://...', Colors.teal),
    _SocialItem('اليوتيوب', FontAwesomeIcons.youtube, 'https://...', Colors.red),
  ];

  final Map<int, bool> _editMode = {};
  final Map<int, TextEditingController> _controllers = {};
  final TextEditingController _policyController = TextEditingController();

  bool _isEditingPolicy = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _items.length; i++) {
      _editMode[i] = false;
      _controllers[i] = TextEditingController(text: _items[i].hint);
    }

    _policyController.text = "هنا يمكنك كتابة سياسة الخصوصية أو شروط الاستخدام الخاصة بالتطبيق...";
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _policyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'روابط حسابات التواصل',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
          ),
          const SizedBox(height: 24),

          // ✅ كروت الحسابات
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(_items.length, (index) {
              return SizedBox(
                width: 420,
                child: _buildSocialCard(context, index),
              );
            }),
          ),

          const SizedBox(height: 40),

          // ✅ سياسة التطبيق
          Text(
            'سياسة التطبيق',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 3,
            color: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _policyController,
                    readOnly: !_isEditingPolicy,
                    maxLines: 8,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: Icon(_isEditingPolicy ? Icons.save : Icons.edit),
                      label: Text(_isEditingPolicy ? 'حفظ' : 'تعديل'),
                      onPressed: () {
                        setState(() {
                          _isEditingPolicy = !_isEditingPolicy;
                        });
                        if (!_isEditingPolicy) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ تم حفظ سياسة التطبيق')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = _items[index];
    final isEditing = _editMode[index]!;
    final controller = _controllers[index]!;
    final fieldColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Card(
      elevation: 5,
      shadowColor: item.iconColor.withOpacity(0.2),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: item.iconColor.withOpacity(0.1),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'تعديل',
                  onPressed: () {
                    setState(() {
                      _editMode[index] = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'مسح',
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      _editMode[index] = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              readOnly: !isEditing,
              decoration: InputDecoration(
                hintText: item.hint,
                filled: true,
                fillColor: fieldColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: theme.textTheme.bodySmall,
            ),
            if (isEditing)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _editMode[index] = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ تم حفظ ${item.label}')),
                    );
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('حفظ'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SocialItem {
  final String label;
  final IconData icon;
  final String hint;
  final Color iconColor;

  _SocialItem(this.label, this.icon, this.hint, this.iconColor);
}
