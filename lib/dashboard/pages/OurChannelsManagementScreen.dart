import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للنسخ

class OurChannelsManagementScreen extends StatefulWidget {
  const OurChannelsManagementScreen({super.key});

  @override
  State<OurChannelsManagementScreen> createState() => _OurChannelsManagementScreenState();
}

class _OurChannelsManagementScreenState extends State<OurChannelsManagementScreen> {
  List<String> allCountries = [
    'السعودية', 'مصر', 'الإمارات', 'الكويت', 'قطر', 'البحرين', 'عمان', 'الأردن', 'المغرب', 'الجزائر',
  ];
  List<String> allCategories = [
    'تسويق إلكتروني', 'تطوير برمجيات', 'تعليم وتدريب', 'تصميم جرافيك', 'سفر وسياحة',
    'خدمات مالية', 'بيع وشراء', 'عقارات', 'سيارات', 'توظيف',
  ];

  Set<String> selectedCountries = {};
  Set<String> selectedCategories = {};

  final TextEditingController categorySearchController = TextEditingController();
  final TextEditingController channelSearchController = TextEditingController();

  List<Map<String, String>> allChannels = [
    {'country': 'السعودية', 'category': 'عقارات', 'name': 'قناة العقار السعودي', 'link': 'https://channel1.example'},
    {'country': 'مصر', 'category': 'توظيف', 'name': 'قناة وظائف مصر', 'link': 'https://channel2.example'},
    {'country': 'السعودية', 'category': 'سيارات', 'name': 'قناة سيارات السعودية', 'link': 'https://channel3.example'},
    {'country': 'الإمارات', 'category': 'عقارات', 'name': 'قناة عقارات دبي', 'link': 'https://channel4.example'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final filteredChannels = allChannels.where((channel) {
      final nameMatch = channel['name']!.contains(channelSearchController.text);
      final countryMatch = selectedCountries.isEmpty || selectedCountries.contains(channel['country']);
      final categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(channel['category']);
      return nameMatch && countryMatch && categoryMatch;
    }).toList();

    final isSmallScreen = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة قنواتنا'),
        backgroundColor: primary,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCountries.clear();
                        selectedCategories.clear();
                        channelSearchController.clear();
                        categorySearchController.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة تعيين الفلاتر'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                isSmallScreen
                    ? Column(
                  children: [
                    _buildCountriesCard(),
                    const SizedBox(height: 16),
                    _buildCategoriesCard(),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCountriesCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoriesCard()),
                  ],
                ),
                const SizedBox(height: 24),

                _buildChannelsCard(filteredChannels),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountriesCard() {
    return _buildSectionCard(
      title: 'الدول (${allCountries.length})',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCountries.map((country) {
            final selected = selectedCountries.contains(country);
            return InputChip(
              label: Text(country, style: const TextStyle(fontSize: 14)),
              selected: selected,
              selectedColor: Colors.blue.shade100,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedCountries.add(country);
                  } else {
                    selectedCountries.remove(country);
                  }
                });
              },
              deleteIcon: const Icon(Icons.close, size: 20),
              onDeleted: () => _confirmDelete(
                context: context,
                title: 'حذف الدولة',
                content: 'هل أنت متأكد من حذف الدولة "$country"؟',
                onConfirm: () {
                  setState(() {
                    allCountries.remove(country);
                    selectedCountries.remove(country);
                  });
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildSoftButton(
          icon: Icons.add_location_alt_outlined,
          label: 'إضافة دولة',
          onTap: () => _showInputDialog('إضافة دولة', 'أدخل اسم الدولة', (value) {
            if (value.isNotEmpty && !allCountries.contains(value)) {
              setState(() => allCountries.add(value));
            }
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesCard() {
    return _buildSectionCard(
      title: 'المجالات (${allCategories.length})',
      children: [
        TextField(
          controller: categorySearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'بحث عن مجال',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCategories
              .where((c) => c.contains(categorySearchController.text))
              .map((category) {
            final selected = selectedCategories.contains(category);
            return InputChip(
              label: Text(category, style: const TextStyle(fontSize: 14)),
              selected: selected,
              selectedColor: Colors.blue.shade100,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedCategories.add(category);
                  } else {
                    selectedCategories.remove(category);
                  }
                });
              },
              deleteIcon: const Icon(Icons.close, size: 20),
              onDeleted: () => _confirmDelete(
                context: context,
                title: 'حذف المجال',
                content: 'هل أنت متأكد من حذف المجال "$category"؟',
                onConfirm: () {
                  setState(() {
                    allCategories.remove(category);
                    selectedCategories.remove(category);
                  });
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildSoftButton(
          icon: Icons.add,
          label: 'إضافة مجال',
          onTap: () => _showInputDialog('إضافة مجال', 'أدخل اسم المجال', (value) {
            if (value.isNotEmpty && !allCategories.contains(value)) {
              setState(() => allCategories.add(value));
            }
          }),
        ),
      ],
    );
  }

  Widget _buildChannelsCard(List<Map<String, String>> filteredChannels) {
    return _buildSectionCard(
      title: 'القنوات (${filteredChannels.length})',
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: channelSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'بحث عن قناة',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            _buildSoftButton(
              icon: Icons.campaign,
              label: 'إضافة قناة',
              onTap: () => _showAddChannelDialog(
                context: context,
                allCountries: allCountries,
                allCategories: allCategories,
                onAddOrEdit: ({required name, required link, required country, required category}) {
                  setState(() {
                    allChannels.add({
                      'name': name,
                      'link': link,
                      'country': country,
                      'category': category,
                    });
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (filteredChannels.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'لا توجد قنوات مطابقة',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: filteredChannels.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final channel = filteredChannels[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: const Icon(Icons.campaign, color: Colors.blue),
                    radius: 26,
                  ),
                  title: Text(
                    channel['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'الدولة: ${channel['country']} - المجال: ${channel['category']}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ),
                  trailing: SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.link, color: Colors.blue),
                          tooltip: 'فتح الرابط',
                          onPressed: () {
                            final link = channel['link'];
                            if (link != null && link.isNotEmpty) {
                              _launchUrl(link);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.grey),
                          tooltip: 'نسخ الرابط',
                          onPressed: () {
                            final link = channel['link'] ?? '';
                            if (link.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: link));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ الرابط')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'تعديل القناة',
                          onPressed: () {
                            _showAddChannelDialog(
                              context: context,
                              allCountries: allCountries,
                              allCategories: allCategories,
                              existingChannel: channel,
                              onAddOrEdit: ({required name, required link, required country, required category}) {
                                setState(() {
                                  channel['name'] = name;
                                  channel['link'] = link;
                                  channel['country'] = country;
                                  channel['category'] = category;
                                });
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'حذف القناة',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text('هل أنت متأكد من حذف القناة "${channel['name']}"؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () {
                                      setState(() => allChannels.remove(channel));
                                      Navigator.pop(context);
                                    },
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).cardColor,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSoftButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showInputDialog(String title, String hint, void Function(String value) onSubmit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                onSubmit(text);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: onConfirm,
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddChannelDialog({
    required BuildContext context,
    required List<String> allCountries,
    required List<String> allCategories,
    required void Function({
    required String name,
    required String link,
    required String country,
    required String category,
    }) onAddOrEdit,
    Map<String, String>? existingChannel,
  }) {
    String? selectedCountry = existingChannel?['country'];
    String? selectedCategory = existingChannel?['category'];
    final nameController = TextEditingController(text: existingChannel?['name']);
    final linkController = TextEditingController(text: existingChannel?['link']);

    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).cardColor,
              titlePadding: const EdgeInsets.only(top: 20, right: 20, left: 20),
              contentPadding: const EdgeInsets.all(20),
              title: Row(
                children: [
                  Icon(
                    existingChannel == null ? Icons.campaign : Icons.edit,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      existingChannel == null ? 'إضافة قناة' : 'تعديل القناة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم القناة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        labelText: 'رابط القناة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'الدولة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: allCountries
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedCountry = val),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'المجال',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: allCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setStateDialog(() => selectedCategory = val),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final link = linkController.text.trim();
                    if (name.isEmpty || link.isEmpty || selectedCountry == null || selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
                      );
                      return;
                    }
                    onAddOrEdit(
                      name: name,
                      link: link,
                      country: selectedCountry!,
                      category: selectedCategory!,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(existingChannel == null ? 'إضافة' : 'حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    // To open the URL in a real app, use url_launcher package:
    // await launchUrl(Uri.parse(url));
    // Here just debug print as internet is disabled.
    debugPrint('فتح الرابط: $url');
  }

  @override
  void dispose() {
    categorySearchController.dispose();
    channelSearchController.dispose();
    super.dispose();
  }
}
