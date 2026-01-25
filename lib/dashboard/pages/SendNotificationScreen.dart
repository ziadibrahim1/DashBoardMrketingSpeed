import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/app_config.dart';

// ألوان مخصصة للوضعين
class AppColors {
  // Colors for Light Mode
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightSideBar = Color(0xFFF8FAFC);
  static const Color lightBackground = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Colors for Dark Mode (Green Theme)
  static const Color darkPrimary = Color(0xFF2E7D32);
  static const Color darkSideBar = Color(0xFF1E1E2E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkTextPrimary = Color(0xFFE4E6EB);
  static const Color darkTextSecondary = Color(0xFFB0B3B8);
  static const Color darkBorder = Color(0xFF2D2D3E);
}

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailSubjectController = TextEditingController();

  List<Uint8List> _selectedImages = [];
  String _receiverType = "all";
  bool _schedule = false;
  DateTime? _scheduledTime;
  bool _sendInApp = true;
  bool _sendSms = false;
  bool _sendEmail = false;
  bool _sendEnglish = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailSubjectController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = isDark ? Colors.redAccent[400] : Colors.red;

    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("العنوان والنص مطلوبين"),
          backgroundColor: dangerColor,
        ),
      );
      return;
    }

    final destinations = <String>[];

    if (_sendInApp) destinations.add("in_app");
    if (_sendEmail) destinations.add("email");

    if (destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("اختر قناة إرسال واحدة على الأقل"),
          backgroundColor: dangerColor,
        ),
      );
      return;
    }

    final body = {
      "title": _titleController.text,
      "message": _messageController.text,
      "targetAudience": _receiverType,
      "destination": destinations,
      "scheduleAt": _schedule ? _scheduledTime?.toIso8601String() : null,
      "emailSubject": _emailSubjectController.text,
      "ar": _sendEnglish == true ? false : true,
    };

    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}notifications"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم إرسال الإشعار بنجاح ✅"),
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        );
        _resetFields();
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ أثناء الإرسال: $e"),
          backgroundColor: dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Choose colors based on theme
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final sideBarColor = isDark ? AppColors.darkSideBar : AppColors.lightSideBar;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // المحتوى الرئيسي
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(isArabic, textPrimaryColor, textSecondaryColor, primaryColor),
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العمود الأيسر: محتوى الرسالة
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(isArabic ? "محتوى الرسالة" : "Message Content", textPrimaryColor),
                              _buildInputField(
                                isArabic ? "العنوان" : "Title",
                                _titleController,
                                false,
                                sideBarColor,
                                textPrimaryColor,
                                textSecondaryColor,
                                borderColor,
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                isArabic ? "موضوع البريد (في حالة البريد الالكتروني)" : "Email Subject",
                                _emailSubjectController,
                                false,
                                sideBarColor,
                                textPrimaryColor,
                                textSecondaryColor,
                                borderColor,
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                isArabic ? "نص الإشعار" : "Message",
                                _messageController,
                                true,
                                sideBarColor,
                                textPrimaryColor,
                                textSecondaryColor,
                                borderColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(isArabic ? "الجمهور المستهدف" : "Target Audience", textPrimaryColor),
                              _buildAudienceDropdown(isArabic, sideBarColor, textPrimaryColor, primaryColor),
                              const SizedBox(height: 30),
                              _buildCardTitle(isArabic ? "قنوات الإرسال" : "Channels", textPrimaryColor),
                              _buildChannelSelection(primaryColor, textPrimaryColor),
                              const SizedBox(height: 30),
                              _buildCardTitle(isArabic ? "الجدولة" : "Scheduling", textPrimaryColor),
                              _buildScheduleCard(isArabic, borderColor, textPrimaryColor, primaryColor, backgroundColor),
                              const SizedBox(height: 40),
                              _buildSubmitButton(isArabic, primaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- مكونات الواجهة ---

  Widget _buildTopBar(bool isArabic, Color textPrimaryColor, Color textSecondaryColor, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "إرسال إشعار جديد" : "Send New Notification",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                  fontFamily: 'Arial'
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic ? "قم بإعداد وإرسال التنبيهات " : "Compose and dispatch alerts to your users",
              style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () => _resetFields(),
          icon: Icon(Icons.refresh, color: primaryColor),
          label: Text(
            isArabic ? "إعادة تعيين" : "Reset",
            style: TextStyle(color: primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            side: BorderSide(color: primaryColor),
          ),
        )
      ],
    );
  }

  Widget _buildInputField(
      String label,
      TextEditingController controller,
      bool isMultiline,
      Color sideBarColor,
      Color textPrimaryColor,
      Color textSecondaryColor,
      Color borderColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          style: TextStyle(color: textPrimaryColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: sideBarColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAudienceDropdown(bool isArabic, Color sideBarColor, Color textPrimaryColor, Color primaryColor) {
    final dropdownItems = [
      DropdownMenuItem(
        value: "all",
        child: Text(
          "جميع المستخدمين",
          style: TextStyle(color: textPrimaryColor),
        ),
      ),
      DropdownMenuItem(
        value: "subscribers",
        child: Text(
          "المستخدمين المشتركين فقط",
          style: TextStyle(color: textPrimaryColor),
        ),
      ),
      DropdownMenuItem(
        value: "users",
        child: Text(
          "المستخدمين المسجلين في وتساب",
          style: TextStyle(color: textPrimaryColor),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: sideBarColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sideBarColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _receiverType,
          isExpanded: true,
          dropdownColor: sideBarColor,
          style: TextStyle(color: textPrimaryColor),
          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
          items: dropdownItems,
          onChanged: (v) => setState(() => _receiverType = v!),
        ),
      ),
    );
  }

  Widget _buildChannelSelection(Color primaryColor, Color textPrimaryColor) {
    return Column(
      children: [
        _buildChannelTile(
          Icons.notifications_none,
          "داخل درج الاشعارات",
          _sendInApp,
              (v) => setState(() => _sendInApp = v),
          primaryColor,
          textPrimaryColor,
        ),
        _buildChannelTile(
          Icons.email_outlined,
          "عبر البريد الالكتروني",
          _sendEmail,
              (v) => setState(() => _sendEmail = v),
          primaryColor,
          textPrimaryColor,
        ),
        _buildChannelTile(
          Icons.language,
          "لغة إنجليزية",
          _sendEnglish,
              (v) => setState(() => _sendEnglish = v),
          primaryColor,
          textPrimaryColor,
        ),
      ],
    );
  }

  Widget _buildChannelTile(
      IconData icon,
      String title,
      bool value,
      Function(bool) onChanged,
      Color primaryColor,
      Color textPrimaryColor,
      ) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v!),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: textPrimaryColor,
        ),
      ),
      secondary: Icon(
        icon,
        size: 20,
        color: value ? primaryColor : textPrimaryColor.withOpacity(0.6),
      ),
      contentPadding: EdgeInsets.zero,
      activeColor: primaryColor,
      checkColor: Colors.white,
    );
  }

  Widget _buildScheduleCard(
      bool isArabic,
      Color borderColor,
      Color textPrimaryColor,
      Color primaryColor,
      Color backgroundColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? "جدولة لاحقاً" : "Schedule for later",
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch.adaptive(
                value: _schedule,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _schedule = v),
              ),
            ],
          ),
          if (_schedule) ...[
            const Divider(),
            TextButton.icon(
              onPressed: () async {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;

                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          surface: isDark ? AppColors.darkSideBar : Colors.white,
                          onSurface: textPrimaryColor,
                        ),
                        dialogBackgroundColor: isDark ? AppColors.darkSideBar : Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );

                if (date == null) return;

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          surface: isDark ? AppColors.darkSideBar : Colors.white,
                          onSurface: textPrimaryColor,
                        ),
                        dialogBackgroundColor: isDark ? AppColors.darkSideBar : Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );

                if (time == null) return;

                setState(() {
                  _scheduledTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
              icon: Icon(Icons.event, color: primaryColor),
              label: Text(
                _scheduledTime == null
                    ? isArabic ? "اختر التاريخ والوقت" : "Select Date & Time"
                    : DateFormat('yyyy-MM-dd HH:mm').format(_scheduledTime!),
                style: TextStyle(color: primaryColor),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isArabic, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _sendNotification,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(
          isArabic ? "إرسال الإشعار الآن" : "Dispatch Notification",
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16
          ),
        ),
      ),
    );
  }

  Widget _buildCardTitle(String title, Color textPrimaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor
        ),
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _titleController.clear();
      _messageController.clear();
      _emailSubjectController.clear();
      _selectedImages.clear();
      _receiverType = "all";
      _schedule = false;
      _scheduledTime = null;
      _sendInApp = true;
      _sendSms = false;
      _sendEmail = false;
      _sendEnglish = false;
    });
  }
}