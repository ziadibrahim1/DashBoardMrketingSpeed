import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/UserModel.dart';

// ------------------------------------
// 🎨 ثوابت الألوان والجمالية
// ------------------------------------
const Color primaryColorLight = Color(0xFF2196F3); // أزرق حيوي للوضع الفاتح
const Color primaryColorDark = Color(0xFF4CAF50); // أخضر حيوي للوضع الداكن
const Color cardColorLight = Color(0xFFFFFFFF);
const Color cardColorDark = Color(0xFF2C3E50);

class UserDetailsPage extends StatefulWidget {
  final UserModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool isEditing = false;
  File? pickedImage;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController statusController; // جديد لإظهار الحالة

  late bool isRTL;

  @override
  void initState() {
    super.initState();

    // تقسيم الاسم الكامل
    final parts = widget.user.name.split(" ");
    firstNameController =
        TextEditingController(text: parts.isNotEmpty ? parts.first : "");
    lastNameController =
        TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(" ") : "");

    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: "N/A"); // افتراضي
    statusController = TextEditingController(text: widget.user.status);

  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    statusController.dispose();
    super.dispose();
  }

  // 📸 وظيفة تحميل صورة
  // ------------------------------------
  Future<void> _pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  // ------------------------------------
  // 💾 وظيفة الحفظ
  // ------------------------------------
  void _saveChanges() {
    setState(() => isEditing = false);
    // 💡 يمكن هنا استخدام API Call:
    // final updatedUser = UserModel(
    //   id: widget.user.id,
    //   name: "${firstNameController.text} ${lastNameController.text}",
    //   email: emailController.text,
    //   status: statusController.text, // أو حسب التحديث

    // );
    // callApiUpdateUser(updatedUser);
  }

  // ------------------------------------
  // 🖼️ عناصر البناء المحسنة
  // ------------------------------------


  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    required bool isDark,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        enabled: isEditing && enabled,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: activeColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1),
          ),
          filled: true,
          fillColor: isDark ? cardColorDark.withOpacity(0.8) : Colors.grey.shade50,
        ),
      ),
    );
  }

  // 2. بطاقة إحصائية مُحسنة
  Widget _buildStatisticCard({
    required String label,
    required dynamic value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardColorDark : cardColorLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 3. شارة الحالة المُحسنة (للحقل غير القابل للتعديل)
  Widget _statusBadge(String status, bool isRTL) {
    final isActive = status == 'active';
    final color = isActive ? primaryColorDark : Colors.red.shade700;
    final bgColor = isActive ? primaryColorDark.withOpacity(0.15) : Colors.red.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive
            ? (isRTL ? '✅ فعال' : '✅ Active')
            : (isRTL ? '❌ غير فعال' : '❌ Inactive'),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    isRTL = locale.languageCode == 'ar';
    final activeColor = isDark ? primaryColorDark : primaryColorLight;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E272C) : Colors.grey.shade100,
        appBar: AppBar(
          title: Text(
            isRTL ? "👤 تفاصيل المستخدم" : "👤 User Details",
            style: TextStyle(
                color: isDark ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: activeColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
              onPressed: isEditing ? _saveChanges : () => setState(() => isEditing = true),
              tooltip: isEditing ? (isRTL ? "حفظ التغييرات" : "Save Changes") : (isRTL ? "تعديل" : "Edit"),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -----------------------------
              // صورة المستخدم المحسّنة
              // -----------------------------
              _buildAvatarSection(isDark, activeColor),

              const SizedBox(height: 30),

              _buildSectionTitle(isRTL ? "البيانات الأساسية" : "Basic Info", activeColor, isDark),

              // حقول الإدخال المحسنة
              _buildField(
                label: isRTL ? "الاسم الأول" : "First Name",
                controller: firstNameController,
                isDark: isDark,
                activeColor: activeColor,
              ),
              _buildField(
                label: isRTL ? "الاسم الأخير" : "Last Name",
                controller: lastNameController,
                isDark: isDark,
                activeColor: activeColor,
              ),
              _buildField(
                label: isRTL ? "البريد الإلكتروني" : "Email",
                controller: emailController,
                isDark: isDark,
                activeColor: activeColor,
                enabled: false, // لا يُفضل تعديل البريد
              ),
              _buildField(
                label: isRTL ? "رقم الهاتف" : "Phone Number",
                controller: phoneController,
                isDark: isDark,
                activeColor: activeColor,
              ),

              // حقل الحالة (غير قابل للتعديل)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: isRTL ? "الحالة" : "Status",
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? cardColorDark.withOpacity(0.8) : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  child: _statusBadge(widget.user.status, isRTL),
                ),
              ),

              const SizedBox(height: 30),
              _buildSectionTitle(isRTL ? "تفاصيل الاشتراك" : "Subscription Details", activeColor, isDark),

              _buildField(
                label: isRTL ? "الخطة" : "Plan",
                controller: TextEditingController(text: widget.user.planName ?? "N/A"),
                isDark: isDark,
                activeColor: activeColor,
                enabled: false,
              ),
              _buildField(
                label: isRTL ? "السعر" : "Price",
                controller: TextEditingController(text: widget.user.price?.toString() ?? "N/A"),
                isDark: isDark,
                activeColor: activeColor,
                enabled: false,
              ),
              _buildField(
                label: isRTL ? "تاريخ البداية" : "Start Date",
                controller: TextEditingController(text: widget.user.startDate ?? "N/A"),
                isDark: isDark,
                activeColor: activeColor,
                enabled: false,
              ),
              _buildField(
                label: isRTL ? "تاريخ النهاية" : "End Date",
                controller: TextEditingController(text: widget.user.endDate ?? "N/A"),
                isDark: isDark,
                activeColor: activeColor,
                enabled: false,
              ),


              const SizedBox(height: 30),

              _buildSectionTitle(isRTL ? "إحصائيات الاشتراك" : "Subscription Statistics", activeColor, isDark),

              // -----------------------------
              // الإحصائيات في شبكة أنيقة (Grid)
              // -----------------------------
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildStatisticCard(
                    label: isRTL ? "الأيام المتبقية" : "Days Left",
                    value: widget.user.subscriptionDaysLeft,
                    icon: Icons.calendar_month_rounded,
                    color: widget.user.subscriptionDaysLeft > 0 ? activeColor : Colors.red,
                    isDark: isDark,
                  ),
                  _buildStatisticCard(
                    label: isRTL ? "مرات الاشتراك" : "Subscription Count",
                    value: widget.user.subscriptionsCount,
                    icon: Icons.repeat_one_on_rounded,
                    color: Colors.orange.shade700,
                    isDark: isDark,
                  ),
                  _buildStatisticCard(
                    label: isRTL ? "عدد الرسائل" : "Total Messages",
                    value: widget.user.totalMessages,
                    icon: Icons.message_rounded,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  _buildStatisticCard(
                    label: isRTL ? "عدد الجروبات" : "Total Groups",
                    value: widget.user.groups,
                    icon: Icons.group_work_rounded,
                    color: Colors.teal,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // عنصر الصورة الشخصية
  Widget _buildAvatarSection(bool isDark, Color activeColor) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: activeColor.withOpacity(0.2),
            backgroundImage: pickedImage != null
                ? FileImage(pickedImage!)
                : null,
            child: pickedImage == null
                ? Icon(Icons.person_rounded,
                size: 80,
                color: activeColor)
                : null,
          ),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                    border: Border.all(
                      color: isDark ? cardColorDark : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 20, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // عنوان القسم
  Widget _buildSectionTitle(String title, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            color: color,
            margin: isRTL
                ? const EdgeInsets.only(left: 8)
                : const EdgeInsets.only(right: 8),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }
}