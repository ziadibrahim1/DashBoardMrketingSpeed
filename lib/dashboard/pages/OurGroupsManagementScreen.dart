import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OurGroupsManagementScreen extends StatefulWidget {
  const OurGroupsManagementScreen({super.key});

  @override
  State<OurGroupsManagementScreen> createState() => _OurGroupsManagementScreenState();
}

class _OurGroupsManagementScreenState extends State<OurGroupsManagementScreen> {
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
  final TextEditingController groupSearchController = TextEditingController();

  List<Map<String, String>> allGroups = [
    {'country': 'السعودية', 'category': 'عقارات', 'name': 'جروب العقار السعودي', 'link': '', 'membersCount': '15'},
    {'country': 'مصر', 'category': 'توظيف', 'name': 'جروب وظائف مصر', 'link': '', 'membersCount': '40'},
    {'country': 'السعودية', 'category': 'سيارات', 'name': 'جروب سيارات السعودية', 'link': '', 'membersCount': '27'},
    {'country': 'الإمارات', 'category': 'عقارات', 'name': 'جروب عقارات دبي', 'link': '', 'membersCount': '33'},
  ];

  int currentPage = 0;
  final int groupsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final filteredGroups = allGroups.where((group) {
      final nameMatch = group['name']!.contains(groupSearchController.text);
      final countryMatch = selectedCountries.isEmpty || selectedCountries.contains(group['country']);
      final categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(group['category']);
      return nameMatch && countryMatch && categoryMatch;
    }).toList();

    final totalPages = (filteredGroups.length / groupsPerPage).ceil();
    final paginatedGroups = filteredGroups.skip(currentPage * groupsPerPage).take(groupsPerPage).toList();

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title:   Text('إدارة جروباتنا', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedCountries.clear();
                    selectedCategories.clear();
                    groupSearchController.clear();
                    categorySearchController.clear();
                    currentPage = 0;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة تعيين الفلاتر'),
              ),
            ),
            const SizedBox(height: 8),
            isSmallScreen
                ? Column(
              children: [
                _buildCountriesCard(),
                const SizedBox(height: 12),
                _buildCategoriesCard(),
              ],
            )
                : Row(
              children: [
                Expanded(child: _buildCountriesCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoriesCard()),
              ],
            ),
            const SizedBox(height: 16),
            _buildGroupsCard(paginatedGroups),
            const SizedBox(height: 8),
            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: currentPage > 0
                        ? () => setState(() {
                      currentPage--;
                    })
                        : null,
                  ),
                  Text('${currentPage + 1} / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: currentPage < totalPages - 1
                        ? () => setState(() {
                      currentPage++;
                    })
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildCountriesCard() {
    return _buildSectionCard(
      title: 'الدول (${allCountries.length})',
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allCountries.map((country) {
            final selected = selectedCountries.contains(country);
            return FilterChip(
              label: Text(country, style: const TextStyle(fontSize: 13)),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCountries.remove(country) : selectedCountries.add(country);
                });
              },
              onDeleted: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: Text('هل أنت متأكد من حذف الدولة "$country"؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            allCountries.remove(country);
                            selectedCountries.remove(country);
                            allGroups.removeWhere((g) => g['country'] == country);
                            currentPage = 0;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allCategories
              .where((c) => c.contains(categorySearchController.text))
              .map((category) {
            final selected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category, style: const TextStyle(fontSize: 13)),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCategories.remove(category) : selectedCategories.add(category);
                });
              },
              onDeleted: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: Text('هل أنت متأكد من حذف المجال "$category"؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            allCategories.remove(category);
                            selectedCategories.remove(category);
                            allGroups.removeWhere((g) => g['category'] == category);
                            currentPage = 0;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
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

  Widget _buildGroupsCard(List<Map<String, String>> groups) {
    return _buildSectionCard(
      title: 'الجروبات (${allGroups.length})',
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: groupSearchController,
                onChanged: (_) => setState(() {
                  currentPage = 0;
                }),
                decoration: InputDecoration(
                  hintText: 'بحث عن جروب',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSoftButton(
              icon: Icons.group_add,
              label: 'إضافة جروب',
              onTap: () => _showAddGroupDialog(
                context: context,
                allCountries: allCountries,
                allCategories: allCategories,
                onAddOrEdit: ({required name, required link, required country, required category}) {
                  setState(() {
                    allGroups.add({
                      'name': name,
                      'link': link,
                      'country': country,
                      'category': category,
                      'membersCount': '0',
                    });
                    currentPage = (allGroups.length / groupsPerPage).ceil() - 1;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                'لا توجد جروبات مطابقة',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: groups.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final group = groups[index];
              final membersCount = group['membersCount'] ?? '0';
              final channel = groups[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.group, color: Colors.blue),
                  ),
                  title: Text(
                    group['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'الدولة: ${group['country']} - المجال: ${group['category']} - عدد الأعضاء: $membersCount',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        tooltip: 'تعديل الجروب',
                        onPressed: () {
                          _showAddGroupDialog(
                            context: context,
                            allCountries: allCountries,
                            allCategories: allCategories,
                            existingGroup: group,
                            onAddOrEdit: ({required name, required link, required country, required category}) {
                              setState(() {
                                group['name'] = name;
                                group['link'] = link;
                                group['country'] = country;
                                group['category'] = category;
                              });
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف الجروب',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('تأكيد الحذف'),
                              content: Text('هل أنت متأكد من حذف الجروب "${group['name']}"؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    setState(() => allGroups.remove(group));
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
              );
            },
          ),
      ],
    );
  }
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(8),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () {
              Navigator.pop(context);
              onSubmit(controller.text.trim());
            },
          ),
        ],
      ),
    );
  }
}

void _showAddGroupDialog({
  required BuildContext context,
  required List<String> allCountries,
  required List<String> allCategories,
  required void Function({
  required String name,
  required String link,
  required String country,
  required String category,
  }) onAddOrEdit,
  Map<String, String>? existingGroup,
}) {
  String? selectedCountry = existingGroup?['country'];
  String? selectedCategory = existingGroup?['category'];
  final nameController = TextEditingController(text: existingGroup?['name']);
  final linkController = TextEditingController(text: existingGroup?['link']);

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
                  existingGroup == null ? Icons.group_add : Icons.edit,
                  color: primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    existingGroup == null ? 'إضافة جروب جديد' : 'تعديل الجروب',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdown(
                    context: context,
                    label: 'اختر الدولة',
                    value: selectedCountry,
                    items: allCountries,
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedCountry = val;
                        selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context: context,
                    label: 'اختر المجال',
                    value: selectedCategory,
                    items: selectedCountry == null ? [] : allCategories,
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context: context,
                    label: 'اسم الجروب',
                    controller: nameController,
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context: context,
                    label: 'رابط الجروب',
                    controller: linkController,
                    icon: Icons.link,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedCountry != null &&
                      selectedCategory != null &&
                      nameController.text.trim().isNotEmpty) {
                    onAddOrEdit(
                      name: nameController.text.trim(),
                      link: linkController.text.trim(),
                      country: selectedCountry!,
                      category: selectedCategory!,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildDropdown({
  required BuildContext context,
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        hint: Text('اختر $label'),
      ),
    ),
  );
}

Widget _buildTextField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  IconData? icon,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
Future<void> _launchUrl(String url) async {
  // To open the URL in a real app, use url_launcher package:
  // await launchUrl(Uri.parse(url));
  // Here just debug print as internet is disabled.
  debugPrint('فتح الرابط: $url');
}
