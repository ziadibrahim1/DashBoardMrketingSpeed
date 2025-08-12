import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';


class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<Map<String, dynamic>> admins = [];
  String searchQuery = '';
  String selectedRoleFilter = 'all';

  Map<String, List<String>> defaultPermissionsMap = {
    'User Management': ['View', 'Add', 'Edit', 'Delete'],
    'Payment Management': ['View', 'Edit'],
    'Technical Support': ['View', 'Reply'],
    'Statistics': ['View'],
  };

  // ترجمة النصوص
  final Map<String, Map<String, String>> translations = {
    'admin_management': {'ar': 'إدارة المسؤولين', 'en': 'Admin Management'},
    'search_hint': {'ar': 'ابحث بالاسم...', 'en': 'Search by name...'},
    'all': {'ar': 'الكل', 'en': 'All'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'add_admin': {'ar': 'إضافة مسؤول', 'en': 'Add Admin'},
    'edit_admin': {'ar': 'تعديل مسؤول', 'en': 'Edit Admin'},
    'confirm_exit_title': {'ar': 'تأكيد الخروج', 'en': 'Confirm Exit'},
    'confirm_exit_content': {
      'ar': 'يوجد تغييرات غير محفوظة، هل تريد المتابعة؟',
      'en': 'There are unsaved changes, do you want to continue?'
    },
    'required_fields': {'ar': 'يرجى تعبئة الحقول المطلوبة', 'en': 'Please fill required fields'},
    'upload_image': {'ar': 'تحميل صورة', 'en': 'Upload Image'},
    'permissions': {'ar': 'الصلاحيات', 'en': 'Permissions'},
    'first_name': {'ar': 'الاسم الأول', 'en': 'First Name'},
    'middle_name': {'ar': 'الاسم الثاني', 'en': 'Middle Name'},
    'last_name': {'ar': 'الاسم الأخير', 'en': 'Last Name'},
    'phone': {'ar': 'رقم الهاتف', 'en': 'Phone Number'},
    'email': {'ar': 'البريد الإلكتروني', 'en': 'Email'},
    'country': {'ar': 'الدولة', 'en': 'Country'},
    'city': {'ar': 'المدينة', 'en': 'City'},
    'bank': {'ar': 'البنك', 'en': 'Bank'},
    'iban': {'ar': 'رقم الحساب البنكي', 'en': 'IBAN'},
    'role': {'ar': 'الدور', 'en': 'Role'},
    'no_admins': {'ar': 'لا يوجد مسؤولين.', 'en': 'No admins found.'},
    'delete_admin_msg': {'ar': 'تم حذف المسؤول.', 'en': 'Admin deleted.'},
    'undo': {'ar': 'تراجع', 'en': 'Undo'},
    'role_filter_label': {'ar': 'تصفية الدور', 'en': 'Filter Role'},
  };

  String t(String key, String langCode) {
    return translations[key]?[langCode] ?? key;
  }

  List<Map<String, dynamic>> get filteredAdmins {
    return admins.where((admin) {
      final name = '${admin['firstName']} ${admin['middleName']} ${admin['lastName']}';
      final matchesSearch = name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole = selectedRoleFilter == 'all' || admin['role'] == selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _confirmDelete(int index, String langCode) {
    final removedAdmin = admins.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('delete_admin_msg', langCode)),
        action: SnackBarAction(
          label: t('undo', langCode),
          onPressed: () {
            setState(() => admins.insert(index, removedAdmin));
          },
        ),
      ),
    );
  }

  void _addOrEditAdmin({
    Map<String, dynamic>? existingAdmin,
    int? index,
    required String langCode,
  }) {
    final firstNameController = TextEditingController(text: existingAdmin?['firstName']);
    final middleNameController = TextEditingController(text: existingAdmin?['middleName']);
    final lastNameController = TextEditingController(text: existingAdmin?['lastName']);
    final phoneController = TextEditingController(text: existingAdmin?['phone']);
    final countryController = TextEditingController(text: existingAdmin?['country']);
    final cityController = TextEditingController(text: existingAdmin?['city']);
    final emailController = TextEditingController(text: existingAdmin?['email']);
    final bankController = TextEditingController(text: existingAdmin?['bank']);
    final ibanController = TextEditingController(text: existingAdmin?['iban']);
    final roleController = TextEditingController(text: existingAdmin?['role'] ?? 'Supervisor');
    Map<String, List<String>> permissions = Map<String, List<String>>.from(
        existingAdmin?['permissions'] ?? {});
    File? selectedImage = existingAdmin?['profileImagePath'] != null
        ? File(existingAdmin!['profileImagePath'])
        : null;

    bool hasUnsavedChanges = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => WillPopScope(
            onWillPop: () async {
              if (hasUnsavedChanges) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return AlertDialog(
                      backgroundColor: const Color(0xFF4D5D53),
                      title: Text(
                        t('confirm_exit_title', langCode),
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                        ),
                      ),
                      content: Text(
                        t('confirm_exit_content', langCode),
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            t('cancel', langCode),
                            style: TextStyle(
                              color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            t('save', langCode),
                            style: TextStyle(
                              color: isDark ? const Color(0xFFD7EFDC) : const Color(0xFF65C4F8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ) ?? false;
                return confirm;
              }
              return true;
            },
            child: Directionality(
              textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                backgroundColor:  isDark ?Colors.grey[850]: Colors.white,
                title: Text(
                  existingAdmin != null ? t('edit_admin', langCode) : t('add_admin', langCode),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFD7EFDC) :   Colors.blue[900],
                  ),
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildField(firstNameController, t('first_name', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(middleNameController, t('middle_name', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(lastNameController, t('last_name', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(phoneController, t('phone', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(emailController, t('email', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(countryController, t('country', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(cityController, t('city', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(bankController, t('bank', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(ibanController, t('iban', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        buildField(roleController, t('role', langCode), setModalState,
                          labelColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          textColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          borderColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (result != null && result.files.single.path != null) {
                              setModalState(() {
                                selectedImage = File(result.files.single.path!);
                                hasUnsavedChanges = true;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: Text(t('upload_image', langCode)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                            foregroundColor: isDark ? const Color(0xFF4D5D53) : Colors.white,
                          ),
                        ),
                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Image.file(selectedImage!, height: 100),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          t('permissions', langCode),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                          ),
                        ),
                        ...defaultPermissionsMap.entries.map((entry) {
                          return ExpansionTile(
                            title: Text(
                              langCode == 'ar' ? _translatePermissionKey(entry.key) : entry.key,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                              ),
                            ),
                            children: entry.value.map((perm) {
                              final isChecked = permissions[entry.key]?.contains(perm) ?? false;
                              return CheckboxListTile(
                                title: Text(
                                  langCode == 'ar' ? _translatePermissionKey(perm) : perm,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFD7EFDC) :Colors.blue.shade900,
                                  ),
                                ),
                                value: isChecked,
                                onChanged: (val) {
                                  setModalState(() {
                                    permissions[entry.key] ??= [];
                                    if (val == true) {
                                      permissions[entry.key]!.add(perm);
                                    } else {
                                      permissions[entry.key]!.remove(perm);
                                    }
                                    hasUnsavedChanges = true;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      t('cancel', langCode),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (firstNameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t('required_fields', langCode))),
                        );
                        return;
                      }

                      final newAdmin = {
                        'firstName': firstNameController.text.trim(),
                        'middleName': middleNameController.text.trim(),
                        'lastName': lastNameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'country': countryController.text.trim(),
                        'city': cityController.text.trim(),
                        'email': emailController.text.trim(),
                        'bank': bankController.text.trim(),
                        'iban': ibanController.text.trim(),
                        'role': roleController.text.trim(),
                        'profileImagePath': selectedImage?.path,
                        'permissions': permissions,
                      };

                      setState(() {
                        if (index != null) {
                          admins[index] = newAdmin;
                        } else {
                          admins.add(newAdmin);
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                      foregroundColor: isDark ? const Color(0xFF4D5D53) : Colors.white,
                    ),
                    child: Text(t('save', langCode)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }

  // ترجمات بسيطة للمفاتيح
  String _translatePermissionKey(String key) {
    const Map<String, String> map = {
      'User Management': 'إدارة المستخدمين',
      'Payment Management': 'إدارة الدفع',
      'Technical Support': 'الدعم الفني',
      'Statistics': 'الإحصائيات',
      'View': 'عرض',
      'Add': 'إضافة',
      'Edit': 'تعديل',
      'Delete': 'حذف',
      'Reply': 'رد',
    };
    return map[key] ?? key;
  }

  Widget buildField(
      TextEditingController controller,
      String label,
      void Function(void Function()) setModalState, {
        required Color labelColor,
        required Color textColor,
        required Color borderColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
        ),
        onChanged: (_) => setModalState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final isArabic = langCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            t('admin_management', langCode),
            style: TextStyle(color: isDark ? Colors.white : Colors.white,fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.blue[100],
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.blueGrey[900]),

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditAdmin(langCode: langCode),
          backgroundColor: isDark ? Colors.green : Colors.blue,
          child:   Icon(Icons.add,color:Colors.white),
          tooltip: t('add_admin', langCode),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: t('search_hint', langCode),
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedRoleFilter,
                    items: [
                      'all',
                      ...admins.map((e) => e['role'].toString()).toSet(),
                    ]
                        .map(
                          (role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role == 'all' ? t('all', langCode) : role),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedRoleFilter = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredAdmins.isEmpty
                    ? Center(child: Text(t('no_admins', langCode)))
                    : ListView.builder(
                  itemCount: filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = filteredAdmins[index];
                    final fullName =
                        '${admin['firstName']} ${admin['middleName']} ${admin['lastName']}';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      color: isDark ? Colors.grey[850] : Colors.white,
                      child: ListTile(
                        leading: admin['profileImagePath'] != null
                            ? CircleAvatar(
                          backgroundImage:
                          FileImage(File(admin['profileImagePath'])),
                        )
                            : CircleAvatar(
                          backgroundColor: isDark ? Colors.grey : Colors.blueGrey[100],
                          child: Icon(Icons.person,
                              color: isDark ? Colors.white : Colors.blueGrey[800]),
                        ),
                        title: Text(fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            )),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📧 ${admin['email']}',
                                style: TextStyle(color: isDark ? Colors.white70 : null)),
                            Text('📱 ${admin['phone']}',
                                style: TextStyle(color: isDark ? Colors.white70 : null)),
                            Text('🏦 ${admin['bank']} - ${admin['iban']}',
                                style: TextStyle(color: isDark ? Colors.white70 : null)),
                            Text('🎯 ${t('role', langCode)}: ${admin['role']}',
                                style: TextStyle(color: isDark ? Colors.white70 : null)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: isDark ? Colors.teal[300] : Colors.blue),
                              onPressed: () => _addOrEditAdmin(
                                existingAdmin: admin,
                                index: admins.indexOf(admin),
                                langCode: langCode,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(admins.indexOf(admin), langCode),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
