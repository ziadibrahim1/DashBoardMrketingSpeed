import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool isEditing = false;
  File? pickedImage;

  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController typeController;
  late TextEditingController orgNameController;
  late TextEditingController orgDescController;
  late TextEditingController phoneController;
  late TextEditingController countryController;
  late TextEditingController cityController;

  late bool isRTL;

  @override
  void initState() {
    super.initState();
    final fullName = widget.user['name'] ?? '';
    final names = fullName.trim().split(' ');
    firstNameController = TextEditingController(text: names.isNotEmpty ? names[0] : '');
    middleNameController = TextEditingController(text: names.length > 2 ? names.sublist(1, names.length - 1).join(' ') : (names.length == 2 ? '' : ''));
    lastNameController = TextEditingController(text: names.length > 1 ? names.last : '');
    emailController = TextEditingController(text: widget.user['email'] ?? '');
    passwordController = TextEditingController(text: '••••••••');
    typeController = TextEditingController(text: widget.user['type'] ?? '');
    orgNameController = TextEditingController(text: widget.user['organizationName'] ?? '');
    orgDescController = TextEditingController(text: widget.user['organizationDescription'] ?? '');
    phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    countryController = TextEditingController(text: widget.user['country'] ?? '');
    cityController = TextEditingController(text: widget.user['city'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    isRTL = ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);

    final primaryColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);
    final labelStyle = TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87, fontSize: 15);
    final hintStyle = TextStyle(color: isDark ? Colors.white30 : Colors.black26);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          title: Text(
            isRTL ? 'تفاصيل المستخدم' : 'User Details',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: primaryColor,
          actions: [
            if (!isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: isRTL ? 'تعديل' : 'Edit',
                onPressed: () => setState(() => isEditing = true),
              ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: isRTL ? 'حفظ' : 'Save',
                onPressed: () {
                  setState(() => isEditing = false);
                  // TODO: تنفيذ الحفظ
                },
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.blue[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // صورة المستخدم مع ظل و تراكب الأيقونة
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 62,
                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                          backgroundImage: pickedImage != null
                              ? FileImage(pickedImage!)
                              : (widget.user['photoUrl'] != null
                              ? NetworkImage(widget.user['photoUrl']) as ImageProvider
                              : null),
                          child: (pickedImage == null && widget.user['photoUrl'] == null)
                              ? Icon(Icons.person, size: 62, color: isDark ? Colors.grey[400] : Colors.grey[600])
                              : null,
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: isRTL ? null : 8,
                          left: isRTL ? 8 : null,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryColor,
                              child: Icon(Icons.edit, size: 22, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    buildSectionTitle(
                      context,
                      isRTL ? 'البيانات الأساسية' : 'Basic Information',isDark
                    ),
                  ],
                ),

                buildDoubleField(
                  isRTL ? 'الاسم الأول' : 'First Name',
                  firstNameController,
                  isRTL ? 'الاسم الثاني' : 'Middle Name',
                  middleNameController,
                  labelStyle,
                ),
                buildDoubleField(
                  isRTL ? 'الاسم الأخير' : 'Last Name',
                  lastNameController,
                  isRTL ? 'البريد الإلكتروني' : 'Email',
                  emailController,
                  labelStyle,
                ),
                buildSingleField(
                  isRTL ? 'كلمة المرور' : 'Password',
                  passwordController,
                  labelStyle,
                  obscureText: true,
                  hintText: isEditing ? null : (isRTL ? '********' : '********'),
                ),

                const SizedBox(height: 36),

                buildSectionTitle(context, isRTL ? 'البيانات التكميلية' : 'Additional Information', isDark),
                buildDoubleField(
                  isRTL ? 'نوع المؤسسة' : 'Organization Type',
                  typeController,
                  isRTL ? 'اسم المؤسسة' : 'Organization Name',
                  orgNameController,
                  labelStyle,
                ),
                buildSingleField(
                  isRTL ? 'وصف المؤسسة' : 'Organization Description',
                  orgDescController,
                  labelStyle,
                  maxLines: 3,
                ),
                const SizedBox(height: 15),

                buildDoubleField(
                  isRTL ? 'رقم الجوال' : 'Phone Number',
                  phoneController,
                  isRTL ? 'الدولة' : 'Country',
                  countryController,
                  labelStyle,
                ),
                buildSingleField(
                  isRTL ? 'المدينة' : 'City',
                  cityController,
                  labelStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.greenAccent[100] : Colors.blue[900],

          ),
        ),
      ),
    );
  }

  Widget buildDoubleField(String label1, TextEditingController controller1, String label2, TextEditingController controller2, TextStyle labelStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(child: buildSingleField(label1, controller1, labelStyle)),
          const SizedBox(width: 18),
          Expanded(child: buildSingleField(label2, controller2, labelStyle)),
        ],
      ),
    );
  }

  Widget buildSingleField(String label, TextEditingController controller, TextStyle labelStyle,
      {bool obscureText = false, int maxLines = 1, String? hintText}) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      obscureText: obscureText,
      maxLines: maxLines,
      style: TextStyle(color: isEditing ? null : Colors.grey.shade600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: labelStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }
}
