import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

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

  List<Map<String, dynamic>> allGroups = [
    {
      'country': 'السعودية',
      'category': 'عقارات',
      'name': 'جروب العقار السعودي',
      'link': '',
      'membersCount': '2',
      'members': [
        {'name': 'أحمد', 'phone': '0501234567'},
        {'name': 'سعيد', 'phone': '0557654321'},
      ],
      'isSendingLocked': false,
      'isVisible': false,
    },
    {
      'country': 'مصر',
      'category': 'توظيف',
      'name': 'جروب وظائف مصر',
      'link': '',
      'membersCount': '1',
      'members': [
        {'name': 'منى', 'phone': '01099887766'},
      ],
      'isSendingLocked': true,
      'isVisible': true,
    },
    {
      'country': 'السعودية',
      'category': 'سيارات',
      'name': 'جروب سيارات السعودية',
      'link': '',
      'membersCount': '0',
      'members': [],
      'isSendingLocked': false,
      'isVisible': false,
    },
    {
      'country': 'الإمارات',
      'category': 'عقارات',
      'name': 'جروب عقارات دبي',
      'link': '',
      'membersCount': '0',
      'members': [],
      'isSendingLocked': false,
      'isVisible': false,
    },
  ];

  bool showLockedOnly = false;

  int currentPage = 0;
  final int groupsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark? Color(0xFFD7EFDC) : const Color(0xFF65C4F8); // أزرق فاتح
    final titleColor = isDark ? Color(0xFFD7EFDC) : Colors.blueGrey.shade900;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;

    List<Map<String, dynamic>> filteredGroups = allGroups.where((group) {
      final nameMatch = group['name'].toString().toLowerCase().contains(groupSearchController.text.toLowerCase());
      final countryMatch = selectedCountries.isEmpty || selectedCountries.contains(group['country']);
      final categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(group['category']);
      final lockMatch = !showLockedOnly || (group['isSendingLocked'] == true);
      return nameMatch && countryMatch && categoryMatch && lockMatch;
    }).toList();

    final totalPages = (filteredGroups.length / groupsPerPage).ceil();
    final paginatedGroups = filteredGroups.skip(currentPage * groupsPerPage).take(groupsPerPage).toList();

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20), // ارتفاع الAppBar مع إضافة مساحة
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // الحواف الدائرية
            child: Container(
              color: isDark ? const Color(0xFF4D5D53) : primaryColor,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isArabic ? 'إدارة جروباتنا' : 'Our Groups Management',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFD7EFDC) : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: isArabic ? 'إعادة تعيين الفلاتر' : 'Reset Filters',
                      color: isDark ? const Color(0xFFD7EFDC) : Colors.white,
                      onPressed: () {
                        setState(() {
                          selectedCountries.clear();
                          selectedCategories.clear();
                          groupSearchController.clear();
                          categorySearchController.clear();
                          showLockedOnly = false;
                          currentPage = 0;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            isSmallScreen
                ? Column(
              children: [
                _buildCountriesCard(titleColor, cardColor, isArabic, primaryColor,isDark),
                const SizedBox(height: 12),
                _buildCategoriesCard(titleColor, cardColor, isArabic, primaryColor,isDark),
              ],
            )
                : Row(
              children: [
                Expanded(child: _buildCountriesCard(titleColor, cardColor, isArabic, primaryColor,isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoriesCard(titleColor, cardColor, isArabic, primaryColor,isDark)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  shadowColor: isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: isDark
                              ? const Color(0xFFD7EFDC)
                              : Colors.blue[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic
                              ? 'عرض المجموعات المقفلة فقط'
                              : 'Show Locked Groups Only',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue[900],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Switch(

                          value: showLockedOnly,
                          onChanged: (val) {
                            setState(() {
                              showLockedOnly = val;
                              currentPage = 0;
                            });
                          },
                          activeColor:isDark?Color(0xFFD7EFDC): Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildGroupsCard(paginatedGroups, titleColor, cardColor, primaryColor, isArabic,isDark),
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
                  Text('${currentPage + 1} / $totalPages', style: TextStyle(color: titleColor)),
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

  Widget _buildCountriesCard(Color titleColor, Color cardColor, bool isArabic, Color primaryColor,isDark) {
    return _buildSectionCard(
      title: '${isArabic ? 'الدول' : 'Countries'} (${allCountries.length})',
      titleColor: titleColor,
      cardColor: cardColor,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allCountries.map((country) {
            final selected = selectedCountries.contains(country);
            return FilterChip(
              label: Text(country, style:TextStyle(fontSize: 13,color:isDark?Color(
                  0xFFB2ECBC):Color(0xFF324E86))),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCountries.remove(country) : selectedCountries.add(country);
                  currentPage = 0;
                });
              },
              onDeleted: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isArabic ? 'تأكيد الحذف' : 'Delete Confirmation',style:TextStyle(color:isDark?Color(
                        0xFFB2ECBC):Color(0xFF324E86))),
                    content: Text(isArabic
                        ? 'هل أنت متأكد من حذف الدولة "$country"؟'
                        : 'Are you sure you want to delete country "$country"?',style:TextStyle(color:isDark?Color(
                        0xFFB2ECBC):Color(0xFF324E86))),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(isArabic ? 'إلغاء' : 'Cancel',style:TextStyle(color:isDark?Color(
                            0xFFB2ECBC):Color(0xFF324E86))),
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
                        child: Text(isArabic ? 'حذف' : 'Delete',style:TextStyle(color:isDark?Color(
                            0xFFB2ECBC):Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              selectedColor: primaryColor.withOpacity(0.2),
              backgroundColor: cardColor,
              checkmarkColor: primaryColor,
              labelStyle: TextStyle(color: selected ? Colors.grey.shade700 : Colors.grey.shade700),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildSoftButton(
          icon: Icons.add_location_alt_outlined,
          label: isArabic ? 'إضافة دولة' : 'Add Country',
          onTap: () => _showInputDialog(
            isArabic ? 'إضافة دولة' : 'Add Country',
            isArabic ? 'أدخل اسم الدولة' : 'Enter country name',
                (value) {
              if (value.isNotEmpty && !allCountries.contains(value)) {
                setState(() => allCountries.add(value));
              }
            },isDark,
          ),
          primaryColor: primaryColor,
          textColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildCategoriesCard(Color titleColor, Color cardColor, bool isArabic, Color primaryColor,isDark) {
    return _buildSectionCard(
      title: '${isArabic ? 'المجالات' : 'Categories'} (${allCategories.length})',
      titleColor: titleColor,
      cardColor: cardColor,
      children: [
        TextField(
          controller: categorySearchController,
          onChanged: (_) => setState(() {
            currentPage = 0;
          }),
          decoration: InputDecoration(
            hintText: isArabic ? 'بحث عن مجال' : 'Search category',
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
              .where((c) => c.toLowerCase().contains(categorySearchController.text.toLowerCase()))
              .map((category) {
            final selected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category, style:  TextStyle(fontSize: 13,color:isDark?Color(
                  0xFFB2ECBC):Color(0xFF324E86))),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCategories.remove(category) : selectedCategories.add(category);
                  currentPage = 0;
                });
              },
              onDeleted: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isArabic ? 'تأكيد الحذف' : 'Delete Confirmation'),
                    content: Text(isArabic
                        ? 'هل أنت متأكد من حذف المجال "$category"؟'
                        : 'Are you sure you want to delete category "$category"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(isArabic ? 'إلغاء' : 'Cancel'),
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
                        child: Text(isArabic ? 'حذف' : 'Delete'),
                      ),
                    ],
                  ),
                );
              },
              selectedColor: primaryColor.withOpacity(0.2),
              backgroundColor: cardColor,
              checkmarkColor: primaryColor,
              labelStyle: TextStyle(color: selected ? primaryColor : Colors.grey.shade700),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildSoftButton(
          icon: Icons.add,
          label: isArabic ? 'إضافة مجال' : 'Add Category',
          onTap: () => _showInputDialog(
            isArabic ? 'إضافة مجال' : 'Add Category',
            isArabic ? 'أدخل اسم المجال' : 'Enter category name',
                (value) {
              if (value.isNotEmpty && !allCategories.contains(value)) {
                setState(() => allCategories.add(value));
              }
            },isDark,
          ),
          primaryColor: primaryColor,
          textColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildGroupsCard(
      List<Map<String, dynamic>> groups,
      Color titleColor,
      Color cardColor,
      Color primaryColor,
      bool isArabic,
      bool isDark
      ) {
    return
      _buildSectionCard(
      title: '${isArabic ? 'الجروبات' : 'Groups'} (${allGroups.length})',
      titleColor: titleColor,
      cardColor: cardColor,
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
                  hintText: isArabic ? 'بحث عن جروب' : 'Search group',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: cardColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSoftButton(
              icon: Icons.group_add,
              label: isArabic ? 'إضافة جروب' : 'Add Group',
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
                      'members': [],
                      'isSendingLocked': false,
                      'isVisible': false,
                    });
                    currentPage = (allGroups.length / groupsPerPage).ceil() - 1;
                  });
                },
                isArabic: isArabic, isDark: isDark),
              primaryColor: primaryColor,
              textColor: primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                isArabic ? 'لا توجد جروبات مطابقة' : 'No matching groups',
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
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.group, color: primaryColor),
                  ),
                  title: Text(
                    group['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${isArabic ? 'الدولة' : 'Country'}: ${group['country']} - ${isArabic ? 'المجال' : 'Category'}: ${group['category']} - ${isArabic ? 'عدد الأعضاء' : 'Members'}: $membersCount',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر السماح بالظهور في التطبيق
                      IconButton(
                        icon: Icon(
                          group['isVisible'] == true ? Icons.visibility : Icons.visibility_off,
                          color: group['isVisible'] == true ? Colors.green : Colors.grey,
                        ),
                        tooltip: isArabic
                            ? (group['isVisible'] == true ? 'إخفاء من التطبيق' : 'السماح بالظهور في التطبيق')
                            : (group['isVisible'] == true ? 'Hide from app' : 'Allow visibility in app'),
                        onPressed: () {
                          setState(() {
                            group['isVisible'] = !(group['isVisible'] == true);
                          });
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.link, color: primaryColor),
                        tooltip: isArabic ? 'فتح الرابط' : 'Open Link',
                        onPressed: () {
                          final link = group['link'];
                          if (link != null && link.isNotEmpty) {
                            _launchUrl(link);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.grey),
                        tooltip: isArabic ? 'نسخ الرابط' : 'Copy Link',
                        onPressed: () {
                          final link = group['link'] ?? '';
                          if (link.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isArabic ? 'تم نسخ الرابط' : 'Link copied')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.group, color: primaryColor),
                        tooltip: isArabic ? 'عرض الأعضاء' : 'Show Members',
                        onPressed: () {
                          _showMembersDialog(group, isArabic);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        tooltip: isArabic ? 'تعديل الجروب' : 'Edit Group',
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
                            isArabic: isArabic,isDark:isDark
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: isArabic ? 'حذف الجروب' : 'Delete Group',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(isArabic ? 'تأكيد الحذف' : 'Delete Confirmation'),
                              content: Text(isArabic
                                  ? 'هل أنت متأكد من حذف الجروب "${group['name']}"؟'
                                  : 'Are you sure you want to delete group "${group['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    setState(() => allGroups.remove(group));
                                    Navigator.pop(context);
                                  },
                                  child: Text(isArabic ? 'حذف' : 'Delete'),
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

  void _showMembersDialog(Map<String, dynamic> group, bool isArabic) {
    final List members = group['members'] ?? [];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? 'أعضاء الجروب' : 'Group Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: members.isEmpty
              ? Text(isArabic ? 'لا يوجد أعضاء' : 'No members')
              : ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (_, index) {
              final member = members[index];
              final name = member['name'] ?? '';
              final phone = member['phone'] ?? '';
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Text(phone),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // هنا يمكنك إضافة منطق التصدير إلى Excel/PDF حسب الحاجة
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'تم تصدير الأعضاء (وهمياً)' : 'Members exported (dummy)')),
              );
            },
            child: Text(isArabic ? 'تصدير إلى Excel/PDF' : 'Export to Excel/PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color titleColor,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor, fontSize: 18)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSoftButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? primaryColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: (primaryColor ?? Colors.blue).withOpacity(0.1),
        highlightColor: (primaryColor ?? Colors.blue).withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (primaryColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: textColor ?? (primaryColor ?? Colors.blue)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: textColor ?? (primaryColor ?? Colors.blue))),
            ],
          ),
        ),
      ),
    );
  }

  void _showInputDialog(String title, String hint, void Function(String value) onSubmit,isDark) {
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
            child:  Text('إلغاء',style:TextStyle(color:isDark?Color(
          0xFFB2ECBC):Color(0xFF324E86))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child:   Text('حفظ',style:TextStyle(color:isDark?Color(
                0xFFB2ECBC):Color(0xFF324E86))),
            onPressed: () {
              Navigator.pop(context);
              onSubmit(controller.text.trim());
            },
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog({
    required BuildContext context,
    required List<String> allCountries,
    required List<String> allCategories,
    Map<String, dynamic>? existingGroup,
    required Function({
    required String name,
    required String link,
    required String country,
    required String category,
    }) onAddOrEdit,
    bool isArabic = true,
    required  bool isDark ,
  }) {
    final nameController = TextEditingController(text: existingGroup != null ? existingGroup['name'] : '');
    final linkController = TextEditingController(text: existingGroup != null ? existingGroup['link'] : '');
    String selectedCountry = existingGroup != null ? existingGroup['country'] : (allCountries.isNotEmpty ? allCountries.first : '');
    String selectedCategory = existingGroup != null ? existingGroup['category'] : (allCategories.isNotEmpty ? allCategories.first : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? (existingGroup != null ? 'تعديل الجروب' : 'إضافة جروب') : (existingGroup != null ? 'Edit Group' : 'Add Group'),style:TextStyle(color:isDark?Color(
            0xFFB2ECBC):Color(0xFF324E86))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: isArabic ? 'اسم الجروب' : 'Group Name'),
              ),
              TextField(
                controller: linkController,
                decoration: InputDecoration(labelText: isArabic ? 'رابط الجروب' : 'Group Link'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(labelText: isArabic ? 'الدولة' : 'Country'),
                items: allCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCountry = val);
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(labelText: isArabic ? 'المجال' : 'Category'),
                items: allCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedCategory = val);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel',style:TextStyle(color:isDark?Color(
                0xFFB2ECBC):Color(0xFF324E86))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'الرجاء إدخال اسم الجروب' : 'Please enter group name',style:TextStyle(color:isDark?Color(
                    0xFFB2ECBC):Color(0xFF324E86)))));
                return;
              }
              onAddOrEdit(
                name: nameController.text.trim(),
                link: linkController.text.trim(),
                country: selectedCountry,
                category: selectedCategory,
              );
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حفظ' : 'Save',style:TextStyle(color:isDark?Color(
                0xFFB2ECBC):Color(0xFF324E86))),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {

    debugPrint('فتح الرابط: $url');
  }
}

