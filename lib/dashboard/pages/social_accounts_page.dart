import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class SocialAccountsPage extends StatefulWidget {
  const SocialAccountsPage({super.key});

  @override
  State<SocialAccountsPage> createState() => _SocialAccountsPageState();
}

class _SocialAccountsPageState extends State<SocialAccountsPage> {
  late List<_SocialItem> _items;

  final Map<int, bool> _editMode = {};
  final Map<int, TextEditingController> _controllers = {};
  final TextEditingController _policyController = TextEditingController();
  bool _isEditingPolicy = false;

  @override
  void initState() {
    super.initState();

    // لا تهيئ هنا، سيتم تهيئتهم في build حسب اللغة
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _policyController.dispose();
    super.dispose();
  }

  void _initItems(bool isArabic) {
    // إعادة تهيئة العناصر بناءً على اللغة
    _items = [
      _SocialItem(isArabic ? 'واتساب' : 'WhatsApp', FontAwesomeIcons.whatsapp, 'https://wa.me/...', Colors.green),
      _SocialItem(isArabic ? 'تيليجرام' : 'Telegram', FontAwesomeIcons.telegram, 'https://t.me/...', Colors.blue),
      _SocialItem(isArabic ? 'فيسبوك' : 'Facebook', FontAwesomeIcons.facebook, 'https://facebook.com/...', Colors.indigo),
      _SocialItem(isArabic ? 'إنستقرام' : 'Instagram', FontAwesomeIcons.instagram, 'https://instagram.com/...', Colors.purple),
      _SocialItem(isArabic ? 'تويتر (X)' : 'Twitter (X)', FontAwesomeIcons.xTwitter, 'https://x.com/...', Colors.black),
      _SocialItem(isArabic ? 'تيك توك' : 'TikTok', FontAwesomeIcons.tiktok, 'https://tiktok.com/@...', Colors.black),
      _SocialItem(isArabic ? 'سناب شات' : 'Snapchat', FontAwesomeIcons.snapchatGhost, 'https://snapchat.com/add/...', Colors.yellow[700]!),
      _SocialItem(isArabic ? 'الهاتف' : 'Phone', FontAwesomeIcons.phone, '+966 5XXXXXXXX', Colors.teal),
      _SocialItem(isArabic ? 'البريد الإلكتروني' : 'Email', FontAwesomeIcons.envelope, 'example@email.com', Colors.orange),
      _SocialItem(isArabic ? 'الموقع الإلكتروني' : 'Website', FontAwesomeIcons.link, 'https://...', Colors.teal),
      _SocialItem(isArabic ? 'اليوتيوب' : 'YouTube', FontAwesomeIcons.youtube, 'https://...', Colors.red),
    ];

    // تهيئة الكنترولرات وحالة التحرير اذا لم تكن مهيأة مسبقا
    for (int i = 0; i < _items.length; i++) {
      if (!_controllers.containsKey(i)) {
        _controllers[i] = TextEditingController(text: _items[i].hint);
      }
      if (!_editMode.containsKey(i)) {
        _editMode[i] = false;
      }
    }

    if (_policyController.text.isEmpty) {
      _policyController.text = isArabic
          ? "هنا يمكنك كتابة سياسة الخصوصية أو شروط الاستخدام الخاصة بالتطبيق..."
          : "Here you can write your app's privacy policy or terms of use...";
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // تهيئة العناصر بناء على اللغة
    _initItems(isArabic);

    final titleColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[900];


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان روابط التواصل
          Text(
            isArabic ? 'روابط حسابات التواصل' : 'Social Media Links',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 24),

          // كروت الحسابات
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(_items.length, (index) {
              return SizedBox(
                width: 420,
                child: _buildSocialCard(context, index, titleColor!, isArabic, isDark),
              );
            }),
          ),

          const SizedBox(height: 40),

          // سياسة التطبيق
          Text(
            isArabic ? 'سياسة التطبيق' : 'App Policy',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
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
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
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
                      icon: Icon(_isEditingPolicy ? Icons.save : Icons.edit, color: titleColor),
                      label: Text(
                        _isEditingPolicy ? (isArabic ? 'حفظ' : 'Save') : (isArabic ? 'تعديل' : 'Edit'),
                        style: TextStyle(color: titleColor),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditingPolicy = !_isEditingPolicy;
                        });
                        if (!_isEditingPolicy) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isArabic ? '✅ تم حفظ سياسة التطبيق' : '✅ App policy saved')),
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

  Widget _buildSocialCard(BuildContext context, int index, Color titleColor, bool isArabic, bool isDark) {
    final theme = Theme.of(context);
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
                  backgroundColor: Colors.grey[100],
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: isArabic ? 'تعديل' : 'Edit',
                  onPressed: () {
                    setState(() {
                      _editMode[index] = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: isArabic ? 'مسح' : 'Delete',
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
              style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
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
                      SnackBar(content: Text(isArabic ? '✅ تم حفظ ${item.label}' : '✅ ${item.label} saved')),
                    );
                  },
                  icon:  Icon(Icons.save, size: 16,color:titleColor),
                  label: Text(isArabic ? 'حفظ' : 'Save',style:TextStyle(color:titleColor)),
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
