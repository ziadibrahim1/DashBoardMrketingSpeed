import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/UserModel.dart';

// ألوان مخصصة لواجهة لوحة التحكم
class AppColors {
  static const Color primary = Color(0xFF0F172A);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textPrimary = Color(0xFF1E293B);
}

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
  late TextEditingController statusController;

  @override
  void initState() {
    super.initState();
    final parts = widget.user.name.split(" ");
    firstNameController = TextEditingController(text: parts.isNotEmpty ? parts.first : "");
    lastNameController = TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(" ") : "");
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  void _saveChanges() {
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : AppColors.surface,
      appBar: AppBar(
        title: Text(
          isRTL ? "إدارة العميل" : "Customer Management",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF399EF3),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الهيدر التعريفي المحسّن
            _buildEnhancedProfileHeader(isDark, isRTL),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الإحصائيات السريعة
                  _buildEnhancedStatsGrid(isDark, isRTL),
                  const SizedBox(height: 24),

                  // قسم البيانات الأساسية
                  _buildEnhancedSectionCard(
                    title: isRTL ? "البيانات الشخصية" : "Personal Information",
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    children: [
                      _buildTwoColumnRow([
                        _buildEnhancedInputField(
                          isRTL ? "الاسم الأول" : "First Name",
                          firstNameController,
                          isDark,
                          icon: Icons.badge_outlined,
                        ),
                        _buildEnhancedInputField(
                          isRTL ? "الاسم الأخير" : "Last Name",
                          lastNameController,
                          isDark,
                          icon: Icons.badge_outlined,
                        ),
                      ]),
                      const SizedBox(height: 4),
                      _buildEnhancedInputField(
                        isRTL ? "البريد الإلكتروني" : "Email Address",
                        emailController,
                        isDark,
                        enabled: false,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 4),
                      _buildEnhancedInputField(
                        isRTL ? "رقم الهاتف" : "Phone Number",
                        phoneController,
                        isDark,
                        icon: Icons.phone_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // قسم الاشتراك والمالية
                  _buildEnhancedSectionCard(
                    title: isRTL ? "حالة الاشتراك والمالية" : "Subscription & Billing",
                    icon: Icons.credit_card_outlined,
                    isDark: isDark,
                    children: [
                      _buildEnhancedInfoRow(
                        isRTL ? "الخطة الحالية" : "Current Plan",
                        widget.user.planName ?? (isRTL ? "غير متاح" : "N/A"),
                        Icons.workspace_premium_outlined,
                        isDark,
                        valueColor: AppColors.accent,
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      _buildDivider(isDark),
                      const SizedBox(height: 16),
                      _buildEnhancedInfoRow(
                        isRTL ? "قيمة الاشتراك" : "Subscription Price",
                        "${widget.user.price ?? '--'} \$",
                        Icons.payments_outlined,
                        isDark,
                        valueColor: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedInfoRow(
                        isRTL ? "تاريخ التفعيل" : "Activation Date",
                        widget.user.startDate ?? "--",
                        Icons.event_available_outlined,
                        isDark,
                      ),

                      const SizedBox(height: 16),
                      _buildEnhancedInfoRow(
                        isRTL ? "تاريخ الانتهاء" : "Expiry Date",
                        widget.user.endDate ?? "--",
                        Icons.event_busy_outlined,
                        isDark,
                        valueColor: AppColors.danger,
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  // قسم تحليل النشاط
                  _buildEnhancedSectionCard(
                    title: isRTL ? "تحليل النشاط" : "Activity Analytics",
                    icon: Icons.analytics_outlined,
                    isDark: isDark,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "الرسائل" : "Messages",
                              widget.user.totalMessages.toString(),
                              Icons.message_outlined,
                              AppColors.accent,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "المجموعات" : "Groups",
                              widget.user.groups.toString(),
                              Icons.groups_outlined,
                              AppColors.success,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "التجديدات" : "Renewals",
                              widget.user.subscriptionsCount.toString(),
                              Icons.refresh_rounded,
                              AppColors.warning,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // هيدر الملف الشخصي المبسّط
  Widget _buildEnhancedProfileHeader(bool isDark, bool isRTL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildEnhancedAvatar(isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildEnhancedStatusChip(widget.user.status, isRTL),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.email_outlined,
                      size: 13,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAvatar(bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : AppColors.accent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : AppColors.surface,
            backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
            child: pickedImage == null
                ? Icon(
              Icons.person,
              size: 32,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            )
                : null,
          ),
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
                  color: AppColors.accent,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  // شبكة الإحصائيات المحسّنة
  Widget _buildEnhancedStatsGrid(bool isDark, bool isRTL) {
    final daysLeft = widget.user.subscriptionDaysLeft ?? 0;
    final isUrgent = daysLeft < 5;
    final isWarning = daysLeft >= 5 && daysLeft <= 15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [AppColors.danger.withOpacity(0.1), AppColors.danger.withOpacity(0.05)]
              : isWarning
              ? [AppColors.warning.withOpacity(0.1), AppColors.warning.withOpacity(0.05)]
              : [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.danger.withOpacity(0.3)
              : isWarning
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.danger
                  : isWarning
                  ? AppColors.warning
                  : AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.schedule_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? "الأيام المتبقية" : "Days Remaining",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      daysLeft.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? AppColors.danger
                            : isWarning
                            ? AppColors.warning
                            : AppColors.success,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRTL ? "يوم" : "days",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isRTL ? "عاجل" : "URGENT",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEnhancedInputField(
      String label,
      TextEditingController controller,
      bool isDark, {
        bool enabled = true,
        IconData? icon,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: controller,
        enabled: isEditing && enabled,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
          prefixIcon: icon != null
              ? Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          )
              : null,
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoRow(
      String label,
      String value,
      IconData icon,
      bool isDark, {
        Color? valueColor,
        bool isBold = false,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (valueColor ?? AppColors.accent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: valueColor ?? AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
      String title,
      String value,
      IconData icon,
      Color color,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow(List<Widget> children) {
    return Row(
      children: children
          .map((e) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: e,
        ),
      ))
          .toList(),
    );
  }

  Widget _buildEnhancedStatusChip(String status, bool isRTL) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.danger).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? AppColors.success : AppColors.danger).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive
                ? (isRTL ? "نشط" : "Active")
                : (isRTL ? "موقوف" : "Suspended"),
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.danger,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}