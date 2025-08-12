import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';


class TelegramChannelsScreen extends StatefulWidget {
  const TelegramChannelsScreen({Key? key}) : super(key: key);

  @override
  State<TelegramChannelsScreen> createState() => _TelegramChannelsScreenState();
}

class _TelegramChannelsScreenState extends State<TelegramChannelsScreen> {
  List<String> allCountries = [
    'السعودية',
    'مصر',
    'الإمارات',
    'الكويت',
    'قطر',
    'البحرين',
    'عمان',
    'الأردن',
    'المغرب',
    'الجزائر',
  ];

  List<String> allCategories = [
    'تسويق إلكتروني',
    'تطوير برمجيات',
    'تعليم وتدريب',
    'تصميم جرافيك',
    'سفر وسياحة',
    'خدمات مالية',
    'بيع وشراء',
    'عقارات',
    'سيارات',
    'توظيف',
  ];

  Set<String> selectedCountries = {};
  Set<String> selectedCategories = {};

  final TextEditingController categorySearchController = TextEditingController();
  final TextEditingController channelSearchController = TextEditingController();

  List<Map<String, dynamic>> allChannels = [
    {
      'country': 'السعودية',
      'category': 'عقارات',
      'name': 'قناة العقار السعودي',
      'link': 'https://t.me/realestate_sa',
      'membersCount': 1500,
      'members': [
        {'name': 'محمد', 'phone': '0501234567'},
        {'name': 'علي', 'phone': '0559876543'},
      ],
      'allowPosting': true,
      'visibleInApp': true,
    },
    {
      'country': 'مصر',
      'category': 'توظيف',
      'name': 'قناة وظائف مصر',
      'link': 'https://t.me/jobs_egypt',
      'membersCount': 3400,
      'members': [
        {'name': 'أحمد', 'phone': '01123456789'},
        {'name': 'سارة', 'phone': '01098765432'},
      ],
      'allowPosting': false,
      'visibleInApp': false,
    },
    {
      'country': 'الإمارات',
      'category': 'عقارات',
      'name': 'قناة عقارات دبي',
      'link': 'https://t.me/dubai_realestate',
      'membersCount': 2200,
      'members': [],
      'allowPosting': true,
      'visibleInApp': true,
    },
  ];

  int currentPage = 0;
  final int channelsPerPage = 20;

  bool showLockedOnly = false;

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? const Color(0xFF4D5D53) : const Color(0xFF65C4F8);
    final textColor = isDark ? const Color(0xFFD7EFDC) : Colors.blue[800]!;

    // تصفية القنوات حسب الفلاتر
    final filteredChannels = allChannels.where((channel) {
      final nameMatch = (channel['name'] as String).toLowerCase().contains(channelSearchController.text.toLowerCase());
      final countryMatch = selectedCountries.isEmpty || selectedCountries.contains(channel['country']);
      final categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(channel['category']);
      final lockedMatch = !showLockedOnly || (channel['allowPosting'] == false);
      return nameMatch && countryMatch && categoryMatch && lockedMatch;
    }).toList();

    final totalPages = (filteredChannels.length / channelsPerPage).ceil();
    final paginatedChannels = filteredChannels.skip(currentPage * channelsPerPage).take(channelsPerPage).toList();

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar:PreferredSize(
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
                        isArabic ? 'إدارة قنواتنا' : 'Our Channels Management',
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
                          channelSearchController.clear();
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'عرض القنوات المقفلة فقط' : 'Show Locked Channels Only',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: showLockedOnly,
                      onChanged: (val) {
                        setState(() {
                          showLockedOnly = val;
                          currentPage = 0;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            isSmallScreen
                ? Column(
              children: [
                _buildCountriesCard(isArabic, textColor),
                const SizedBox(height: 12),
                _buildCategoriesCard(isArabic, textColor),
              ],
            )
                : Row(
              children: [
                Expanded(child: _buildCountriesCard(isArabic, textColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoriesCard(isArabic, textColor)),
              ],
            ),
            const SizedBox(height: 16),
            _buildChannelsCard(paginatedChannels, isArabic, isDark, primaryColor, textColor),
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
                  Text('${currentPage + 1} / $totalPages', style: TextStyle(color: textColor)),
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

  Widget _buildCountriesCard(bool isArabic, Color textColor) {
    return _buildSectionCard(
      title: '${isArabic ? 'الدول' : 'Countries'} (${allCountries.length})',
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allCountries.map((country) {
            final selected = selectedCountries.contains(country);
            return FilterChip(
              label: Text(country, style: TextStyle(fontSize: 13, color: textColor)),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCountries.remove(country) : selectedCountries.add(country);
                });
              },
              onDeleted: () {
                _confirmDeleteItem(
                  itemName: country,
                  itemType: isArabic ? 'الدولة' : 'Country',
                  onConfirm: () {
                    setState(() {
                      allCountries = allCountries.where((c) => c != country).toList();
                      selectedCountries.remove(country);
                      allChannels.removeWhere((ch) => ch['country'] == country);
                      currentPage = 0;
                    });
                  },
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesCard(bool isArabic, Color textColor) {
    final filteredCategories = allCategories
        .where((cat) => cat.toLowerCase().contains(categorySearchController.text.toLowerCase()))
        .toList();

    return _buildSectionCard(
      title: '${isArabic ? 'التصنيفات' : 'Categories'} (${allCategories.length})',
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: filteredCategories.map((category) {
            final selected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category, style: TextStyle(fontSize: 13, color: textColor)),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected ? selectedCategories.remove(category) : selectedCategories.add(category);
                });
              },
              onDeleted: () {
                _confirmDeleteItem(
                  itemName: category,
                  itemType: isArabic ? 'التصنيف' : 'Category',
                  onConfirm: () {
                    setState(() {
                      allCategories = allCategories.where((c) => c != category).toList();
                      selectedCategories.remove(category);
                      allChannels.removeWhere((ch) => ch['category'] == category);
                      currentPage = 0;
                    });
                  },
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChannelsCard(
      List<Map<String, dynamic>> channels,
      bool isArabic,
      bool isDark,
      Color primaryColor,
      Color textColor,
      ) {
    return _buildSectionCard(
      title: '${isArabic ? 'القنوات' : 'Channels'} (${allChannels.length})',
      children: [
        TextField(
          controller: channelSearchController,
          onChanged: (_) => setState(() {
            currentPage = 0;
          }),
          decoration: InputDecoration(
            hintText: isArabic ? 'بحث عن قناة' : 'Search channel',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (channels.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                isArabic ? 'لا توجد قنوات مطابقة' : 'No matching channels',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: channels.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final group = channels[index];
              final membersCount = group['membersCount'] ?? '0';
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color:isDark?Colors.grey[800]: Colors.white,
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
                        tooltip: isArabic ? 'تعديل القناة' : 'Edit Channel',
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
                        tooltip: isArabic ? 'حذف القناة' : 'Delete Channel',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(isArabic ? 'تأكيد الحذف' : 'Delete Confirmation'),
                              content: Text(isArabic
                                  ? 'هل أنت متأكد من حذف القناة "${group['name']}"؟'
                                  : 'Are you sure you want to delete Channel "${group['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    setState(() => allChannels.remove(group));
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

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
  void _launchUrl(String url) {

    debugPrint('فتح الرابط: $url');
  }
  void _confirmDeleteItem({required String itemName, required String itemType, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف $itemType "$itemName"؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showMembersDialog(Map<String, dynamic> channel, bool isArabic) {
    final members = channel['members'] as List<dynamic>? ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${isArabic ? 'أعضاء القناة' : 'Channel Members'}: ${channel['name']}'),
        content: members.isEmpty
            ? Text(isArabic ? 'لا يوجد أعضاء' : 'No members')
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (_, index) {
              final member = members[index];
              return ListTile(
                title: Text(member['name'] ?? ''),
                subtitle: Text(member['phone'] ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text(isArabic ? 'إغلاق' : 'Close'),
            onPressed: () => Navigator.pop(ctx),
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
        title: Text(isArabic ? (existingGroup != null ? 'تعديل القناة' : 'إضافة قناة') : (existingGroup != null ? 'Edit Channel' : 'Add Channel'),style:TextStyle(color:isDark?Color(
            0xFFB2ECBC):Color(0xFF324E86))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: isArabic ? 'اسم القناة' : 'Channel Name'),
              ),
              TextField(
                controller: linkController,
                decoration: InputDecoration(labelText: isArabic ? 'رابط القناة' : 'Channel Link'),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'الرجاء إدخال اسم القناة' : 'Please enter Channel name',style:TextStyle(color:isDark?Color(
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
}
