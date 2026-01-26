import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/UserModel.dart';

// ألوان مخصصة لواجهة لوحة التحكم
class AppColors {
  // Colors for Light Mode
  static const Color lightPrimary = Color(0xFF0F172A);
  static const Color lightAccent = Color(0xFF3B82F6);
  static const Color lightAccentLight = Color(0xFF60A5FA);
  static const Color lightSuccess = Color(0xFF22C55E);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightDanger = Color(0xFFEF4444);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextPrimary = Color(0xFF1E293B);

  // Colors for Dark Mode (Green Theme)
  static const Color darkPrimary = Color(0xFF020617);
  static const Color darkAccent = Color(0xFF4CAF50); // Green accent
  static const Color darkAccentLight = Color(0xFF66BB6A);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkDanger = Color(0xFFF44336);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E2E);
  static const Color darkBorder = Color(0xFF2D2D3E);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
  static const Color darkTextPrimary = Color(0xFFE4E6EB);
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
  late TextEditingController cityController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    final parts = widget.user.name.split(" ");
    firstNameController = TextEditingController(text: parts.isNotEmpty ? parts.first : "");
    lastNameController = TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(" ") : "");
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    statusController = TextEditingController(text: widget.user.status);
    cityController = TextEditingController(text: widget.user.city);
    countryController = TextEditingController(text: widget.user.country);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    statusController.dispose();
    cityController.dispose();
    countryController.dispose();
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

    // Choose colors based on theme
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final accentLightColor = isDark ? AppColors.darkAccentLight : AppColors.lightAccentLight;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBgColor = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          isRTL ? "إدارة العميل" : "Customer Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkPrimary : accentColor,
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
            _buildEnhancedProfileHeader(isDark, isRTL, cardBgColor, textPrimaryColor, textSecondaryColor, accentColor),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الإحصائيات السريعة
                  _buildEnhancedStatsGrid(isDark, isRTL, successColor, warningColor, dangerColor, textPrimaryColor, textSecondaryColor),
                  const SizedBox(height: 24),

                  // قسم البيانات الأساسية
                  _buildEnhancedSectionCard(
                    title: isRTL ? "البيانات الشخصية" : "Personal Information",
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    textPrimaryColor: textPrimaryColor,
                    children: [
                      _buildTwoColumnRow([
                        _buildEnhancedInputField(
                          isRTL ? "الاسم الأول" : "First Name",
                          firstNameController,
                          isDark,
                          enabled: isEditing,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          accentColor: accentColor,
                          textPrimaryColor: textPrimaryColor,
                          textSecondaryColor: textSecondaryColor,
                          icon: Icons.badge_outlined,
                        ),
                        _buildEnhancedInputField(
                          isRTL ? "الاسم الأخير" : "Last Name",
                          lastNameController,
                          isDark,
                          enabled: isEditing,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          accentColor: accentColor,
                          textPrimaryColor: textPrimaryColor,
                          textSecondaryColor: textSecondaryColor,
                          icon: Icons.badge_outlined,
                        ),
                      ]),
                      const SizedBox(height: 4),
                      _buildEnhancedInputField(
                        isRTL ? "البريد الإلكتروني" : "Email Address",
                        emailController,
                        isDark,
                        enabled: false,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        accentColor: accentColor,
                        textPrimaryColor: textPrimaryColor,
                        textSecondaryColor: textSecondaryColor,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 4),
                      _buildEnhancedInputField(
                        isRTL ? "رقم الهاتف" : "Phone Number",
                        phoneController,
                        isDark,
                        enabled: isEditing,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        accentColor: accentColor,
                        textPrimaryColor: textPrimaryColor,
                        textSecondaryColor: textSecondaryColor,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 4),
                      _buildTwoColumnRow([
                        _buildEnhancedInputField(
                          isRTL ? "المدينه" : "City",
                          cityController,
                          isDark,
                          enabled: isEditing,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          accentColor: accentColor,
                          textPrimaryColor: textPrimaryColor,
                          textSecondaryColor: textSecondaryColor,
                          icon: Icons.location_city_outlined,
                        ),
                        _buildEnhancedInputField(
                          isRTL ? "الدوله" : "Country",
                          countryController,
                          isDark,
                          enabled: isEditing,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          accentColor: accentColor,
                          textPrimaryColor: textPrimaryColor,
                          textSecondaryColor: textSecondaryColor,
                          icon: Icons.flag,
                        ),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // قسم الاشتراك والمالية
                  _buildEnhancedSectionCard(
                    title: isRTL ? "الاشتراكات" : "Subscriptions",
                    icon: Icons.credit_card_outlined,
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    textPrimaryColor: textPrimaryColor,
                    children: widget.user.subscriptions.isEmpty
                        ? [
                      Text(
                        isRTL ? "لا يوجد اشتراكات" : "No active subscriptions",
                        style: TextStyle(
                          color: textSecondaryColor,
                        ),
                      )
                    ]
                        : widget.user.subscriptions
                        .map((sub) => _buildSubscriptionCard(
                        sub,
                        isDark,
                        isRTL,
                        cardBgColor,
                        successColor,
                        warningColor,
                        dangerColor,
                        textPrimaryColor,
                        textSecondaryColor,
                        accentColor
                    ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // قسم تحليل النشاط
                  _buildEnhancedSectionCard(
                    title: isRTL ? "تحليل النشاط" : "Activity Analytics",
                    icon: Icons.analytics_outlined,
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                    textPrimaryColor: textPrimaryColor,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "الرسائل" : "Messages",
                              widget.user.totalMessages.toString(),
                              Icons.message_outlined,
                              accentColor,
                              isDark,
                              textSecondaryColor: textSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "المجموعات" : "Groups",
                              widget.user.groups.toString(),
                              Icons.groups_outlined,
                              successColor,
                              isDark,
                              textSecondaryColor: textSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              isRTL ? "التجديدات" : "Renewals",
                              widget.user.subscriptionsCount.toString(),
                              Icons.refresh_rounded,
                              warningColor,
                              isDark,
                              textSecondaryColor: textSecondaryColor,
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
  Widget _buildEnhancedProfileHeader(
      bool isDark,
      bool isRTL,
      Color cardBgColor,
      Color textPrimaryColor,
      Color textSecondaryColor,
      Color accentColor
      ) {
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildEnhancedAvatar(isDark, accentColor, cardBgColor, textSecondaryColor),
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
                    color: textPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildEnhancedStatusChip(widget.user.status, isRTL, successColor, dangerColor),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.email_outlined,
                      size: 13,
                      color: textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
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

  Widget _buildEnhancedAvatar(
      bool isDark,
      Color accentColor,
      Color cardBgColor,
      Color textSecondaryColor
      ) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: cardBgColor,
            backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
            child: pickedImage == null
                ? Icon(
              Icons.person,
              size: 32,
              color: textSecondaryColor,
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
                  color: accentColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSubscriptionCard(
      UserSubscription sub,
      bool isDark,
      bool isRTL,
      Color cardBgColor,
      Color successColor,
      Color warningColor,
      Color dangerColor,
      Color textPrimaryColor,
      Color textSecondaryColor,
      Color accentColor,
      ) {
    final isExpired = sub.daysLeft < 0;
    final isUrgent = sub.daysLeft >= 0 && sub.daysLeft <= 5;

    Color statusColor = isExpired
        ? dangerColor
        : isUrgent
        ? warningColor
        : successColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// اسم الباقة + الحالة
          Row(
            children: [
              Expanded(
                child: Text(
                  sub.planName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ),
              _buildSubscriptionStatusChip(sub.daysLeft, isRTL, dangerColor, warningColor, successColor),
            ],
          ),

          const SizedBox(height: 12),
          _buildEnhancedInfoRow(
            isRTL ? "السعر" : "Price",
            "${sub.price} \$",
            Icons.payments_outlined,
            isDark,
            accentColor: accentColor,
            successColor: successColor,
            textPrimaryColor: textPrimaryColor,
            textSecondaryColor: textSecondaryColor,
            valueColor: successColor,
          ),
          const SizedBox(height: 10),
          _buildEnhancedInfoRow(
            isRTL ? "من" : "From",
            sub.startDate,
            Icons.event_available_outlined,
            isDark,
            accentColor: accentColor,
            successColor: successColor,
            textPrimaryColor: textPrimaryColor,
            textSecondaryColor: textSecondaryColor,
          ),
          const SizedBox(height: 10),
          _buildEnhancedInfoRow(
            isRTL ? "إلى" : "To",
            sub.endDate,
            Icons.event_busy_outlined,
            isDark,
            accentColor: accentColor,
            successColor: successColor,
            textPrimaryColor: textPrimaryColor,
            textSecondaryColor: textSecondaryColor,
            valueColor: statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusChip(
      int daysLeft,
      bool isRTL,
      Color dangerColor,
      Color warningColor,
      Color successColor
      ) {
    if (daysLeft < 0) {
      return _statusChip(
        isRTL ? "منتهي" : "Expired",
        dangerColor,
      );
    } else if (daysLeft <= 5) {
      return _statusChip(
        isRTL ? "قارب على الانتهاء" : "Ending Soon",
        warningColor,
      );
    } else {
      return _statusChip(
        isRTL ? "نشط" : "Active",
        successColor,
      );
    }
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // شبكة الإحصائيات المحسّنة
  Widget _buildEnhancedStatsGrid(
      bool isDark,
      bool isRTL,
      Color successColor,
      Color warningColor,
      Color dangerColor,
      Color textPrimaryColor,
      Color textSecondaryColor
      ) {
    final daysLeft = widget.user.subscriptionDaysLeft ?? 0;
    final isUrgent = daysLeft < 5;
    final isWarning = daysLeft >= 5 && daysLeft <= 15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [dangerColor.withOpacity(0.1), dangerColor.withOpacity(0.05)]
              : isWarning
              ? [warningColor.withOpacity(0.1), warningColor.withOpacity(0.05)]
              : [successColor.withOpacity(0.1), successColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? dangerColor.withOpacity(0.3)
              : isWarning
              ? warningColor.withOpacity(0.3)
              : successColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? dangerColor
                  : isWarning
                  ? warningColor
                  : successColor,
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
                    color: textSecondaryColor,
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
                            ? dangerColor
                            : isWarning
                            ? warningColor
                            : successColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRTL ? "يوم" : "days",
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondaryColor,
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
                color: dangerColor,
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
    required Color cardBgColor,
    required Color borderColor,
    required Color accentColor,
    required Color textPrimaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: textPrimaryColor,
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
        Color? cardBgColor,
        Color? borderColor,
        Color? accentColor,
        Color? textPrimaryColor,
        Color? textSecondaryColor,
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
          color: textPrimaryColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: textSecondaryColor,
          ),
          prefixIcon: icon != null
              ? Icon(
            icon,
            size: 20,
            color: textSecondaryColor,
          )
              : null,
          filled: true,
          fillColor: cardBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor!, width: 2),
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
        Color? accentColor,
        Color? successColor,
        Color? textPrimaryColor,
        Color? textSecondaryColor,
        Color? valueColor,
        bool isBold = false,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (valueColor ?? accentColor!).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: valueColor ?? accentColor!,
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
                  color: textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? textPrimaryColor,
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
      bool isDark, {
        Color? textSecondaryColor,
      }) {
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
              color: textSecondaryColor,
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

  Widget _buildEnhancedStatusChip(
      String status,
      bool isRTL,
      Color successColor,
      Color dangerColor
      ) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isActive ? successColor : dangerColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? successColor : dangerColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? successColor : dangerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive
                ? (isRTL ? "نشط" : "Active")
                : (isRTL ? "موقوف" : "Suspended"),
            style: TextStyle(
              color: isActive ? successColor : dangerColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}