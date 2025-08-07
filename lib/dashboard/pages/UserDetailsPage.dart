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
    final labelStyle = TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text('تفاصيل المستخدم',style:TextStyle(color:Colors.white)),
        backgroundColor:isDark? Color(0xFF339E1D):Color(0xFF25B4FF),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل',
              onPressed: () {
                setState(() => isEditing = true);
              },
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'حفظ',
              onPressed: () {
                setState(() => isEditing = false);
                // TODO: تنفيذ الحفظ
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ الصورة الشخصية
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: pickedImage != null
                        ? FileImage(pickedImage!)
                        : (widget.user['photoUrl'] != null
                        ? NetworkImage(widget.user['photoUrl']) as ImageProvider
                        : null),
                    child: (pickedImage == null && widget.user['photoUrl'] == null)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            buildSectionTitle(context, 'البيانات الأساسية'),
            buildDoubleField('الاسم الأول', firstNameController, 'الاسم الثاني', middleNameController, labelStyle),
            buildDoubleField('الاسم الأخير', lastNameController, 'البريد الإلكتروني', emailController, labelStyle),
            buildSingleField('كلمة المرور', passwordController, labelStyle, obscureText: true),

            const SizedBox(height: 24),
            buildSectionTitle(context, 'البيانات التكميلية'),
            buildDoubleField('نوع المؤسسة', typeController, 'اسم المؤسسة', orgNameController, labelStyle),
            buildSingleField('وصف المؤسسة', orgDescController, labelStyle, maxLines: 2),
            buildDoubleField('رقم الجوال', phoneController, 'الدولة', countryController, labelStyle),
            buildSingleField('المدينة', cityController, labelStyle),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildDoubleField(String label1, TextEditingController controller1, String label2, TextEditingController controller2, TextStyle labelStyle) {
    return Row(
      children: [
        Expanded(child: buildSingleField(label1, controller1, labelStyle)),
        const SizedBox(width: 16),
        Expanded(child: buildSingleField(label2, controller2, labelStyle)),
      ],
    );
  }

  Widget buildSingleField(String label, TextEditingController controller, TextStyle labelStyle, {bool obscureText = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
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
