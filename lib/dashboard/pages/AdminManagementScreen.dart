import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
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
  Future<void> fetchAdmins() async {
    final response = await http.get(Uri.parse("${AppConfig.apiBase}/api/dashboard-users"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      setState(() {
        admins = data.map((e) => {

          'id': e['id'],
          'email': e['email'],
          'firstName': e['first_name'],
          'middleName': e['middle_name'],
          'lastName': e['last_name'],
          'phone': e['phone'],
          'country': e['country'],
          'city': e['city'],
          'bank': e['bank'],
          'iban': e['iban'],
          'role': e['role'],
          'profileImagePath': e['image_path'],
          'permissions': jsonDecode(e['permissions_json'] ?? "{}"),
        }).toList();
      });
    }
  }
  Future<void> saveAdmin(Map<String, dynamic> admin, {int? id}) async {
    final url = id == null
        ? "${AppConfig.apiBase}/api/dashboard-users"
        : "${AppConfig.apiBase}/api/dashboard-users/$id";

    final request = http.MultipartRequest(
      id == null ? "POST" : "PUT",
      Uri.parse(url),
    );

    request.fields['Email'] = admin['Email']?.toString() ?? "";
    request.fields['FirstName'] = admin['FirstName']?.toString() ?? "";
    request.fields['MiddleName'] = admin['MiddleName']?.toString() ?? "";
    request.fields['LastName'] = admin['LastName']?.toString() ?? "";
    request.fields['Phone'] = admin['Phone']?.toString() ?? "";
    request.fields['Country'] = admin['Country']?.toString() ?? "";
    request.fields['City'] = admin['City']?.toString() ?? "";
    request.fields['Bank'] = admin['Bank']?.toString() ?? "";
    request.fields['Iban'] = admin['Iban']?.toString() ?? "";
    request.fields['Role'] = admin['Role']?.toString() ?? "";
    request.fields['Permissions'] = admin['Permissions'] ?? "{}";
    request.fields['ImagePath'] = admin['ImagePath']?.toString() ?? "";

    if (id == null) {
      request.fields['Password'] = admin['password'] ?? "123456";
    }




    final response = await request.send();

    final respString = await response.stream.bytesToString();
    print("Status: ${response.statusCode}");
    print("Response: $respString");

    if (response.statusCode == 200 || response.statusCode == 201) {
      await fetchAdmins();
    }
  }
  Future<bool> sendVerificationCode(String email) async {
    final url = Uri.parse("${AppConfig.apiBase}/api/admin/verify/send-code");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return res.statusCode == 200;
  }
  Future<bool> confirmVerificationCode(String email, String code) async {
    final url = Uri.parse("${AppConfig.apiBase}/api/admin/verify/confirm");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "code": code}),
    );

    if (res.statusCode == 200) return true;
    return false;
  }
  Future<bool?> _showDeleteConfirmation(Map<String, dynamic> admin, String langCode) {
    final isArabic = langCode == 'ar';
    final name = "${admin['firstName']} ${admin['middleName']} ${admin['lastName']}";

    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            isArabic ? "تأكيد الحذف" : "Delete Confirmation",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isArabic
                ? "هل أنت متأكد أنك تريد حذف المسؤول:\n$name ؟"
                : "Are you sure you want to delete admin:\n$name ?",
          ),
          actions: [
            TextButton(
              child: Text(isArabic ? "إلغاء" : "Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(isArabic ? "حذف" : "Delete"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteAdmin(int id) async {
    await http.delete(Uri.parse("${AppConfig.apiBase}/api/dashboard-users/$id"));
    fetchAdmins();
  }

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
  Future<bool?> showOtpDialog(String email) {
    final controllers = List.generate(6, (_) => TextEditingController());
    final focusNodes = List.generate(6, (_) => FocusNode());

    int remainingSeconds = 90;
    bool isResendEnabled = false;

    late StateSetter setStateDialog;

    // بدء التايمر
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        setStateDialog(() {});
      } else {
        isResendEnabled = true;
        timer.cancel();
        setStateDialog(() {});
      }
    });

    // يحصل على الكود
    String getCode() => controllers.map((c) => c.text).join();

    // تحقق تلقائي
    Future<void> autoVerify() async {
      final code = getCode();
      if (code.length == 6) {
        bool ok = await confirmVerificationCode(email, code);
        if (ok) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ رمز التحقق غير صحيح")),
          );
        }
      }
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          setStateDialog = setState;

          return AlertDialog(
            title: const Text("تأكيد البريد الإلكتروني"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("تم إرسال رمز التحقق إلى: $email"),
                const SizedBox(height: 15),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index + 1]);
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index - 1]);
                          }
                          autoVerify();
                        },
                      ),
                    );
                  }),
                )),

                const SizedBox(height: 20),

                // --- العد التنازلي ---
                Text(
                  isResendEnabled
                      ? "لم تستلم الرمز؟"
                      : "إعادة الإرسال بعد: $remainingSeconds ثانية",
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 8),

                // --- زر إعادة الإرسال ---
                TextButton(
                  onPressed: isResendEnabled
                      ? () async {
                    // إعادة إرسال الكود
                    bool sent = await sendVerificationCode(email);
                    if (sent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✔ تم إرسال رمز جديد"),
                        ),
                      );

                      // إعادة ضبط التايمر
                      remainingSeconds = 60;
                      isResendEnabled = false;

                      Timer.periodic(const Duration(seconds: 1),
                              (timer) {
                            if (remainingSeconds > 0) {
                              remainingSeconds--;
                              setState(() {});
                            } else {
                              isResendEnabled = true;
                              timer.cancel();
                              setState(() {});
                            }
                          });
                    }
                  }
                      : null,
                  child: Text(
                    "إعادة إرسال الرمز",
                    style: TextStyle(
                      color: isResendEnabled ? Colors.blue : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // ❌ حذف زر التأكيد – أصبح التحقق تلقائي
            actions: [
              TextButton(
                child: const Text("إلغاء"),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        },
      ),
    );
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
  final newPasswordController = TextEditingController();
  void _addOrEditAdmin({ Map<String, dynamic>? existingAdmin, int? index, required String langCode,})
  {
    final isAdding = existingAdmin == null;
    final canAdd = UserSession.checkPermission(context, "User Management", "Add");
    final canEdit = UserSession.checkPermission(context, "User Management", "Edit");
    final canModifyFields = isAdding ? canAdd : canEdit;
    final isAdminRole = UserSession.role == "Admin"?true : false;
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
    Map<String, List<String>> permissions = {};
    if (existingAdmin != null && existingAdmin['permissions'] != null) {
      existingAdmin['permissions'].forEach((key, value) {
        permissions[key] = List<String>.from(value);
      });
    }

    File? selectedImage = existingAdmin?['profileImagePath'] != null
        ? File(existingAdmin!['profileImagePath'])
        : null;

    bool hasUnsavedChanges = false;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentUser = UserSession.getUser();
    final currentUserId = currentUser?['id'];

    final passwordController = TextEditingController();
    final bool isEditingSelf =
        existingAdmin != null && existingAdmin['id'] == currentUserId;

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
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return AlertDialog(
                      backgroundColor: const Color(0xFF4D5D53),
                      title: Text(
                        t('confirm_exit_title', langCode),
                        style: TextStyle(
                            color: isDark
                                ? const Color(0xFFD7EFDC)
                                : const Color(0xFF65C4F8)),
                      ),
                      content: Text(
                        t('confirm_exit_content', langCode),
                        style: TextStyle(
                            color: isDark
                                ? const Color(0xFFD7EFDC)
                                : const Color(0xFF65C4F8)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            t('cancel', langCode),
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFD7EFDC)
                                  : const Color(0xFF65C4F8),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            t('save', langCode),
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFD7EFDC)
                                  : const Color(0xFF65C4F8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ) ??
                    false;
                return confirm;
              }
              return true;
            },
            child: Directionality(
              textDirection:
              langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                title: Text(
                  existingAdmin != null
                      ? t('edit_admin', langCode)
                      : t('add_admin', langCode),
                  style: TextStyle(
                    color:
                    isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                  ),
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildField(firstNameController,
                            t('first_name', langCode),
                            readOnly: !canModifyFields,
                            setModalState,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(middleNameController,
                            t('middle_name', langCode), setModalState,
                            readOnly: !canModifyFields,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(lastNameController,
                            t('last_name', langCode), setModalState,
                            readOnly: !canModifyFields,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(phoneController,
                            t('phone', langCode), setModalState,
                            readOnly: !canModifyFields,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(emailController,
                            t('email', langCode), setModalState,
                            readOnly: !canModifyFields,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),

                        /// 🟢 حقل كلمة المرور يظهر فقط إذا كنت تعدّل نفسك
                        if (isEditingSelf)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "كلمة المرور الجديدة",
                                labelStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFD7EFDC)
                                        : Colors.blue.shade900),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? const Color(0xFFD7EFDC)
                                          : Colors.blue.shade900),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? const Color(0xFFD7EFDC)
                                          : Colors.blue.shade900,
                                      width: 2),
                                ),
                              ),
                              onChanged: (_) => setModalState(() {
                                hasUnsavedChanges = true;
                              }),
                            ),
                          ),

                        buildField(countryController,
                            t('country', langCode), setModalState,
                            readOnly: !canModifyFields,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        /// 🟢 حقل كلمة المرور يظهر فقط عند إضافة مستخدم جديد
                        if (existingAdmin == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextField(
                              controller: newPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "كلمة المرور",
                                labelStyle: TextStyle(
                                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue.shade900,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (_) => setModalState(() {
                                hasUnsavedChanges = true;
                              }),
                            ),
                          ),

                        buildField(cityController, t('city', langCode),
                            readOnly: !canModifyFields,
                            setModalState,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(bankController, t('bank', langCode),
                            readOnly: !canModifyFields,
                            setModalState,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(ibanController, t('iban', langCode),
                            readOnly: !canModifyFields,
                            setModalState,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),
                        buildField(roleController, t('role', langCode),
                            readOnly: !canModifyFields,
                            setModalState,
                            labelColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            textColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            borderColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (result != null &&
                                result.files.single.path != null) {
                              setModalState(() {
                                selectedImage =
                                    File(result.files.single.path!);
                                hasUnsavedChanges = true;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: Text(t('upload_image', langCode)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                            foregroundColor: isDark
                                ? const Color(0xFF4D5D53)
                                : Colors.white,
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
                            color: isDark
                                ? const Color(0xFFD7EFDC)
                                : Colors.blue.shade900,
                          ),
                        ),

                        ...defaultPermissionsMap.entries.map((entry) {
                          return ExpansionTile(
                            title: Text(
                              langCode == 'ar'
                                  ? _translatePermissionKey(entry.key)
                                  : entry.key,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFD7EFDC)
                                    : Colors.blue.shade900,
                              ),
                            ),
                            children: entry.value.map((perm) {
                              final isChecked = permissions[entry.key]
                                  ?.contains(perm) ??
                                  false;
                              return CheckboxListTile(
                                title: Text(
                                  langCode == 'ar'
                                      ? _translatePermissionKey(perm)
                                      : perm,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFD7EFDC)
                                        : Colors.blue.shade900,
                                  ),
                                ),
                                value: isChecked,
                                  onChanged: (!canModifyFields || !isAdminRole)
                                      ? null
                                      : (val) {
                                    setModalState(() {
                                      permissions[entry.key] ??= [];
                                      if (val == true) {
                                        permissions[entry.key]!.add(perm);
                                      } else {
                                        permissions[entry.key]!.remove(perm);
                                      }
                                      hasUnsavedChanges = true;
                                    });
                                  }

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
                        color: isDark
                            ? const Color(0xFFD7EFDC)
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                  if (canModifyFields)
                    ElevatedButton(
                    onPressed: () async {
                      if (firstNameController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text(t('required_fields', langCode)),
                          ),
                        );
                        return;
                      }

                      final newAdmin = {
                        'Email': emailController.text.trim(),
                        'FirstName': firstNameController.text.trim(),
                        'MiddleName': middleNameController.text.trim(),
                        'LastName': lastNameController.text.trim(),
                        'Phone': phoneController.text.trim(),
                        'Country': countryController.text.trim(),
                        'City': cityController.text.trim(),
                        'Bank': bankController.text.trim(),
                        'Iban': ibanController.text.trim(),
                        'Role': roleController.text.trim(),
                        'Permissions': jsonEncode(permissions),
                        'ImagePath':
                        selectedImage != null ? selectedImage!.path : "",
                      };

                      /// 🟢 إضافة كلمة المرور فقط عند تعديل نفسك
                      if (isEditingSelf && passwordController.text.isNotEmpty) {
                        newAdmin['password'] = passwordController.text;
                      }
                      /// 🟢 إضافة كلمة المرور عند إنشاء مسؤول جديد فقط
                      if (existingAdmin == null) {
                        newAdmin['password'] = newPasswordController.text.trim().isEmpty
                            ? "123456"
                            : newPasswordController.text.trim();
                      }

                      print(newAdmin);

                      // 1) إرسال كود التحقق
                      bool sent = await sendVerificationCode(emailController.text.trim());
                      if (!sent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تعذر إرسال رمز التحقق")),
                        );
                        return;
                      }

                      bool? verified = await showOtpDialog(emailController.text.trim());
                      if (verified != true) return;

                      await saveAdmin(newAdmin, id: existingAdmin?['id']);


                      if (isEditingSelf) {
                        final refreshUrl =
                        Uri.parse("${AppConfig.apiBase}/api/dashboard-users/oneUser/${currentUserId}");

                        final refreshRes = await http.get(refreshUrl);

                        if (refreshRes.statusCode == 200) {
                          final freshData = jsonDecode(refreshRes.body);

                          final updatedSessionUser = {
                            'id': freshData['id'],
                            'email': freshData['email'],
                            'fullName': freshData['full_name'],
                            'role': freshData['role'],
                            'permissions': jsonDecode(freshData['permissions_json'] ?? "{}"),
                          };

                          UserSession.saveUser(updatedSessionUser);

                          print(
                            "🔄 Session Updated After Editing Self:\n$updatedSessionUser",
                          );
                        }
                      }

                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFD7EFDC)
                          : Colors.blue.shade900,
                      foregroundColor:
                      isDark ? const Color(0xFF4D5D53) : Colors.white,
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
        required Color borderColor, required bool readOnly,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        readOnly: readOnly,
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
  void initState() {
    super.initState();
    fetchAdmins();
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

        floatingActionButton:
         FloatingActionButton(
           onPressed: () {
             if (!UserSession.checkPermission(context, "User Management", "Add")) return;
             _addOrEditAdmin(langCode: langCode);
           },

           backgroundColor: isDark ? Colors.green : Colors.blue,
          child:   Icon(Icons.add,color:Colors.white),
          tooltip: t('add_admin', langCode),
        ) ,
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
                              onPressed: () {

                                _addOrEditAdmin(existingAdmin: admin, index: admins.indexOf(admin), langCode: langCode);
                              },

                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                if (!UserSession.checkPermission(context, "User Management", "Delete")) return;

                                final confirmed = await _showDeleteConfirmation(admin, langCode);

                                if (confirmed == true) {
                                  await deleteAdmin(admin['id']);
                                  fetchAdmins();
                                }
                              },


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
