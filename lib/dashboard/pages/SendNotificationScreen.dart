import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/app_config.dart';


class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  // الألوان الأساسية لـ Dashboard احترافية
  final Color sideBarColor = const Color(0xFFF8FAFC);
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color textColor = const Color(0xFF1E293B);
  final Color borderColor = const Color(0xFFE2E8F0);

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


  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("العنوان والنص مطلوبين")),
      );
      return;
    }

    final destinations = <String>[];
    if (_sendInApp) destinations.add("in_app");
    if (_sendEmail) destinations.add("email");

    if (destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اختر قناة إرسال واحدة على الأقل")),
      );
      return;
    }

    final body = {
      "title": _titleController.text,
      "message": _messageController.text,
      "targetAudience": _receiverType,
      "destination": destinations,
      "scheduleAt": _schedule ? _scheduledTime?.toIso8601String() : null,
      "emailSubject": _emailSubjectController.text
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
          const SnackBar(content: Text("تم إرسال الإشعار بنجاح ✅")),
        );
        _resetFields();
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ أثناء الإرسال: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
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
                    _buildTopBar(isArabic),
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
                              _buildCardTitle(isArabic ? "محتوى الرسالة" : "Message Content"),
                              _buildInputField(isArabic ? "العنوان" : "Title", _titleController, false),
                              const SizedBox(height: 20),
                              _buildInputField(isArabic ? "موضوع البريد (في حالة البريد الالكتروني)" : "Email Subject", _emailSubjectController, false),
                              const SizedBox(height: 20),
                              _buildInputField(isArabic ? "نص الإشعار" : "Message", _messageController, true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(isArabic ? "الجمهور المستهدف" : "Target Audience"),
                              _buildAudienceDropdown(isArabic),
                              const SizedBox(height: 30),
                              _buildCardTitle(isArabic ? "قنوات الإرسال" : "Channels"),
                              _buildChannelSelection(),
                              const SizedBox(height: 30),
                              _buildCardTitle(isArabic ? "الجدولة" : "Scheduling"),
                              _buildScheduleCard(isArabic),
                              const SizedBox(height: 40),
                              _buildSubmitButton(isArabic),
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

  Widget _buildTopBar(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? "إرسال إشعار جديد" : "Send New Notification",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor,fontFamily: 'Arial')),
            const SizedBox(height: 4),
            Text(isArabic ? "قم بإعداد وإرسال التنبيهات " : "Compose and dispatch alerts to your users",
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () => _resetFields(),
          icon: const Icon(Icons.refresh),
          label: Text(isArabic ? "إعادة تعيين" : "Reset"),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
        )
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isMultiline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: sideBarColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAudienceDropdown(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: sideBarColor, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _receiverType,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "all", child: Text("جميع المستخدمين")),
            DropdownMenuItem(value: "subscribers", child: Text("المستخدمين المشتركين فقط")),
            DropdownMenuItem(value: "users", child: Text("المستخدمين المسجلين في وتساب")),
          ],
          onChanged: (v) => setState(() => _receiverType = v!),
        ),
      ),
    );
  }

  Widget _buildChannelSelection() {
    return Column(
      children: [
        _buildChannelTile(Icons.notifications_none, "داخل درج الاشعارات", _sendInApp, (v) => setState(() => _sendInApp = v)),
        _buildChannelTile(Icons.email_outlined, "عبر البريد الالكتروني", _sendEmail, (v) => setState(() => _sendEmail = v)),
      ],
    );
  }

  Widget _buildChannelTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v!),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      secondary: Icon(icon, size: 20),
      contentPadding: EdgeInsets.zero,
      activeColor: primaryBlue,
    );
  }

  Widget _buildScheduleCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isArabic ? "جدولة لاحقاً" : "Schedule for later"),
              Switch.adaptive(value: _schedule, activeColor: primaryBlue, onChanged: (v) => setState(() => _schedule = v)),
            ],
          ),
          if (_schedule) ...[
            const Divider(),
            TextButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (date == null) return;

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
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
              // إضافة PickDate هنا
              icon: const Icon(Icons.event),
              label: Text(_scheduledTime == null ? "Select Date & Time" : DateFormat('yyyy-MM-dd HH:mm').format(_scheduledTime!)),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _sendNotification,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(isArabic ? "إرسال الإشعار الآن" : "Dispatch Notification",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  void _resetFields() {
    setState(() {
      _titleController.clear();
      _messageController.clear();
      _emailSubjectController.clear();
      _selectedImages.clear();
    });
  }

}