import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<Map<String, dynamic>> admins = [];
  String searchQuery = '';
  String selectedRoleFilter = 'الكل';
  Map<String, List<String>> defaultPermissionsMap = {
    'إدارة المستخدمين': ['عرض', 'إضافة', 'تعديل', 'حذف'],
    'إدارة الدفع': ['عرض', 'تعديل'],
    'الدعم الفني': ['عرض', 'رد'],
    'الإحصائيات': ['عرض'],
  };

  List<Map<String, dynamic>> get filteredAdmins {
    return admins.where((admin) {
      final name = '${admin['firstName']} ${admin['middleName']} ${admin['lastName']}';
      final matchesSearch = name.contains(searchQuery);
      final matchesRole = selectedRoleFilter == 'الكل' || admin['role'] == selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _confirmDelete(int index) {
    final removedAdmin = admins.removeAt(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حذف المسؤول.'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() => admins.insert(index, removedAdmin));
          },
        ),
      ),
    );
  }

  void _addOrEditAdmin({Map<String, dynamic>? existingAdmin, int? index}) {
    final firstNameController = TextEditingController(text: existingAdmin?['firstName']);
    final middleNameController = TextEditingController(text: existingAdmin?['middleName']);
    final lastNameController = TextEditingController(text: existingAdmin?['lastName']);
    final phoneController = TextEditingController(text: existingAdmin?['phone']);
    final countryController = TextEditingController(text: existingAdmin?['country']);
    final cityController = TextEditingController(text: existingAdmin?['city']);
    final emailController = TextEditingController(text: existingAdmin?['email']);
    final bankController = TextEditingController(text: existingAdmin?['bank']);
    final ibanController = TextEditingController(text: existingAdmin?['iban']);
    final roleController = TextEditingController(text: existingAdmin?['role'] ?? 'مشرف');
    Map<String, List<String>> permissions = Map<String, List<String>>.from(
        existingAdmin?['permissions'] ?? {});
    File? selectedImage = existingAdmin?['profileImagePath'] != null
        ? File(existingAdmin!['profileImagePath'])
        : null;

    bool hasUnsavedChanges = false;

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
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الخروج'),
                    content: const Text('يوجد تغييرات غير محفوظة، هل تريد المتابعة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('نعم'),
                      ),
                    ],
                  ),
                ) ??
                    false;
                return confirm;
              }
              return true;
            },
            child: AlertDialog(
              title: Text(existingAdmin != null ? 'تعديل مسؤول' : 'إضافة مسؤول'),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildField(firstNameController, 'الاسم الأول', setModalState),
                      buildField(middleNameController, 'الاسم الثاني', setModalState),
                      buildField(lastNameController, 'الاسم الأخير', setModalState),
                      buildField(phoneController, 'رقم الهاتف', setModalState),
                      buildField(emailController, 'البريد الإلكتروني', setModalState),
                      buildField(countryController, 'الدولة', setModalState),
                      buildField(cityController, 'المدينة', setModalState),
                      buildField(bankController, 'البنك', setModalState),
                      buildField(ibanController, 'رقم الحساب البنكي', setModalState),
                      buildField(roleController, 'الدور', setModalState),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result =
                          await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null && result.files.single.path != null) {
                            setModalState(() {
                              selectedImage = File(result.files.single.path!);
                              hasUnsavedChanges = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('تحميل صورة'),
                      ),
                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.file(selectedImage!, height: 100),
                        ),
                      const SizedBox(height: 16),
                      const Text('الصلاحيات', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...defaultPermissionsMap.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(entry.key),
                          children: entry.value.map((perm) {
                            return CheckboxListTile(
                              title: Text(perm),
                              value: permissions[entry.key]?.contains(perm) ?? false,
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
                    onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    if (firstNameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى تعبئة الحقول المطلوبة')),
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
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildField(TextEditingController controller, String label, void Function(void Function()) setModalState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setModalState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المسؤولين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAdmin(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'ابحث بالاسم...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedRoleFilter,
                  items: ['الكل', ...admins.map((e) => e['role'].toString()).toSet()]
                      .map((role) => DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedRoleFilter = val!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredAdmins.isEmpty
                  ? const Center(child: Text('لا يوجد مسؤولين.'))
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
                    child: ListTile(
                      leading: admin['profileImagePath'] != null
                          ? CircleAvatar(backgroundImage: FileImage(File(admin['profileImagePath'])))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📧 ${admin['email']}'),
                          Text('📱 ${admin['phone']}'),
                          Text('🏦 ${admin['bank']} - ${admin['iban']}'),
                          Text('🎯 الدور: ${admin['role']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _addOrEditAdmin(
                              existingAdmin: admin,
                              index: admins.indexOf(admin),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(admins.indexOf(admin)),
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
    );
  }
}
