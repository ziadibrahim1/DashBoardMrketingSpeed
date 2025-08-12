import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final emailSubjectController = TextEditingController();

  List<Uint8List> selectedImages = [];

  String receiverType = "all";
  bool schedule = false;
  DateTime? scheduledTime;

  bool sendInApp = true;
  bool sendSms = false;
  bool sendEmail = false;

  String receiverSearch = "";

  Timer? countdownTimer;
  Duration remaining = Duration.zero;

  final List<Map<String, dynamic>> receiverOptionsAR = [
    {"key": "all", "label": "الكل", "count": 500},
    {"key": "subscribed", "label": "المشتركين", "count": 320},
    {"key": "not_subscribed", "label": "غير المشتركين", "count": 180},
    {"key": "users", "label": "المستخدمين", "count": 400},
    {"key": "non_users", "label": "غير المستخدمين", "count": 100},
  ];
  final List<Map<String, dynamic>> receiverOptionsEN = [
    {"key": "all", "label": "all", "count": 500},
    {"key": "subscribed", "label": "subscribed", "count": 320},
    {"key": "not_subscribed", "label": "not subscribed", "count": 180},
    {"key": "users", "label": "users", "count": 400},
    {"key": "non_users", "label": "non users", "count": 100},
  ];
  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    emailSubjectController.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        selectedImages = result.files
            .where((f) => f.bytes != null)
            .map((f) => f.bytes!)
            .toList();
      });
    }
  }

  Future<void> pickScheduleDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: scheduledTime ?? DateTime.now(),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: scheduledTime != null
          ? TimeOfDay(hour: scheduledTime!.hour, minute: scheduledTime!.minute)
          : const TimeOfDay(hour: 10, minute: 0),
    );

    if (time == null) return;

    setState(() {
      scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _startCountdown();
    });
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    if (scheduledTime == null) {
      remaining = Duration.zero;
      return;
    }
    remaining = scheduledTime!.difference(DateTime.now());
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = scheduledTime!.difference(DateTime.now());
      if (diff.isNegative) {
        countdownTimer?.cancel();
        setState(() {
          remaining = Duration.zero;
        });
      } else {
        setState(() {
          remaining = diff;
        });
      }
    });
  }

  bool get canSend {
    return sendInApp || sendSms || sendEmail;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  void openConfirmDialog() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? 'تأكيد إرسال الإشعار' : 'Confirm Notification'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewRow(
                  isArabic ? 'العنوان:' : 'Title:', titleController.text),
              const SizedBox(height: 8),
              _buildPreviewRow(
                  isArabic ? 'الموضوع (للبريد):' : 'Email Subject:', emailSubjectController.text),
              const SizedBox(height: 8),
              _buildPreviewRow(
                  isArabic ? 'النص:' : 'Message:', messageController.text),
              const SizedBox(height: 12),
              Text(isArabic ? 'طرق الإرسال:' : 'Send Methods:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                [
                  if (sendInApp) isArabic ? "داخل التطبيق" : "In-App",
                  if (sendSms) isArabic ? "رسالة SMS" : "SMS",
                  if (sendEmail) isArabic ? "بريد إلكتروني" : "Email",
                ].join(", "),
              ),
              const SizedBox(height: 12),
              if (schedule && scheduledTime != null)
                Text(
                  isArabic
                      ? "سيتم الإرسال بتاريخ: ${DateFormat('yyyy/MM/dd - HH:mm').format(scheduledTime!)}"
                      : "Scheduled for: ${DateFormat('yyyy/MM/dd - HH:mm').format(scheduledTime!)}",
                ),
              const SizedBox(height: 12),
              if (selectedImages.isNotEmpty)
                Text(
                  isArabic ? "الصور المرفقة: ${selectedImages.length}" : "Attached images: ${selectedImages.length}",
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(isArabic ? 'تأكيد الإرسال' : 'Confirm Send'),
            onPressed: () {
              Navigator.pop(context);
              _performSend();
            },
          ),
        ],
      ),
    );
  }

  void _performSend() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      showError(isArabic ? "يرجى إدخال العنوان والنص" : "Please enter title and message");
      return;
    }

    if (!canSend) {
      showError(isArabic ? "يرجى اختيار طريقة إرسال واحدة على الأقل" : "Select at least one send method");
      return;
    }

    // منطق الإرسال (مكان ربط API)
    showSuccess(isArabic ? "تم إرسال الإشعار بنجاح" : "Notification sent successfully");

    setState(() {
      titleController.clear();
      messageController.clear();
      emailSubjectController.clear();
      receiverType = "all";
      schedule = false;
      scheduledTime = null;
      selectedImages.clear();
      sendInApp = true;
      sendSms = false;
      sendEmail = false;
      remaining = Duration.zero;
    });
  }

  Widget _buildPreviewRow(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        children: [
          TextSpan(
            text: ' $value',
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredReceivers =isArabic? receiverOptionsAR:receiverOptionsEN
        .where((r) => r["label"]
        .toString()
        .toLowerCase()
        .contains(receiverSearch.toLowerCase()))
        .toList();

    return Scaffold(

      body:
      Card(
        color: isDark ?null:Colors.grey[100],
        child:
        Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: isDark ? Color(0xFF2C352F) : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "معلومات الإشعار" : "Notification Info",
                            style:TextStyle(fontWeight: FontWeight.bold,fontSize:25,
                                color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                          ),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "عنوان الإشعار" : "Notification Title",
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12), // تقدر تغير الرقم عشان تحدد مدى انحناء الحواف
                                  borderSide: BorderSide(
                                    width: 3, // سمك الخط 3
                                    color: Colors.grey, // تقدر تغير اللون حسب رغبتك
                                  ),
                                ),
                                hintText: isArabic ? "مثال: تحديث جديد" : "e.g. New Update",
                              ),
                            )
                              ,
                         isDark:isDark),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "موضوع البريد (اختياري)" : "Email Subject (Optional)",
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12), // تقدر تغير الرقم عشان تحدد مدى انحناء الحواف
                                  borderSide: BorderSide(
                                    width: 3, // سمك الخط 3
                                    color: Colors.grey, // تقدر تغير اللون حسب رغبتك
                                  ),
                                ),
                                hintText: isArabic ? "موضوع البريد الإلكتروني" : "Email subject",
                              ),
                            ),
                              isDark:isDark),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "نص الإشعار" : "Notification Body",
                            child: TextField(
                              controller: titleController,
                              maxLines:5,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12), // تقدر تغير الرقم عشان تحدد مدى انحناء الحواف
                                  borderSide: BorderSide(
                                    width: 3, // سمك الخط 3
                                    color: Colors.grey, // تقدر تغير اللون حسب رغبتك
                                  ),
                                ),
                                hintText: isArabic ? "تفاصيل الإشعار" : "Notification content",
                              ),
                            ),
                              isDark:isDark),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    color: isDark ? Color(0xFF2C352F) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "الفئة المستهدفة" : "Target Audience",style:TextStyle(fontWeight: FontWeight.bold,fontSize:25,
                          color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (v) => setState(() => receiverSearch = v),
                            controller: titleController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), // تقدر تغير الرقم عشان تحدد مدى انحناء الحواف
                                borderSide: BorderSide(
                                  width: 3, // سمك الخط 3
                                  color: Colors.grey, // تقدر تغير اللون حسب رغبتك
                                ),
                              ),
                              hintText: isArabic ? "ابحث هنا..." : "Search here...",
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: filteredReceivers.map((opt) {
                                  final selected = receiverType == opt['key'];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: ChoiceChip(
                                      backgroundColor: isDark ? Colors.green[900] : Colors.blue[900],
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(opt['label'],
                                        style: const TextStyle(
                                          color: Colors.white)),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.green[900] : Colors.blue[900],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              opt['count'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      selected: selected,
                                      onSelected: (_) {
                                        setState(() {
                                          receiverType = opt['key'];
                                        });
                                      },
                                      selectedColor:  isDark ? const Color(
                                          0xFF87D5A8) : Colors.blue[300],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    color: isDark ? Color(0xFF2C352F) : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "الجدولة" : "Scheduling",
                          style:TextStyle(fontWeight: FontWeight.bold,fontSize:25,
                      color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: schedule,
                                onChanged: (val) => setState(() {
                                  schedule = val!;
                                  if (!schedule) {
                                    scheduledTime = null;
                                    remaining = Duration.zero;
                                    countdownTimer?.cancel();
                                  } else {
                                    pickScheduleDateTime();
                                  }
                                }),
                              ),
                              Text(isArabic ? "جدولة الإشعار" : "Schedule Notification",style:TextStyle(fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                              const SizedBox(width: 16),
                              if (schedule && scheduledTime != null)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  label: Text(isArabic ? "تغيير الوقت" : "Change Time",style:TextStyle(fontWeight: FontWeight.bold ,
                                      color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                                  onPressed: pickScheduleDateTime,
                                ),
                              const SizedBox(width: 12),
                              if (schedule && scheduledTime != null)
                                Text(
                                  "${isArabic ? 'الوقت المتبقي' : 'Time left'}: ${_formatDuration(remaining)}",
          style:TextStyle(fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: isDark ? Color(0xFF2C352F) : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "طرق الإرسال" : "Send Methods",
                           style:TextStyle(fontWeight: FontWeight.bold,fontSize:25,
                      color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 20,
                            children: [
                              FilterChip(
                                selectedColor:isDark?Colors.green[800]: Colors.blue[100],
                                label: Text(isArabic ? "داخل التطبيق" : "In-App",style:TextStyle(fontWeight: FontWeight.bold ,
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                                selected: sendInApp,
                                onSelected: (val) => setState(() => sendInApp = val),
                              ),
                              FilterChip(
                                selectedColor:isDark?Colors.green[800]: Colors.blue[100],
                                label: Text(isArabic ? "رسالة SMS" : "SMS",style:TextStyle(fontWeight: FontWeight.bold ,
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                                selected: sendSms,
                                onSelected: (val) => setState(() => sendSms = val),
                              ),
                              FilterChip(
                                selectedColor:isDark?Colors.green[800]: Colors.blue[100],
                                label: Text(isArabic ? "بريد إلكتروني" : "Email",style:TextStyle(fontWeight: FontWeight.bold ,
                                    color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                                selected: sendEmail,
                                onSelected: (val) => setState(() => sendEmail = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: isDark ? Color(0xFF2C352F) : Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "إرفاق صور (اختياري)" : "Attach Images (Optional)",
                            style:TextStyle(fontWeight: FontWeight.bold,fontSize:25,
                                color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon:  Icon(Icons.image,color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),
                                label: Text(isArabic ? "اختيار صور" : "Select Images",
                                  style:TextStyle(fontWeight: FontWeight.bold ,
                                      color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900]),),
                                onPressed: pickImage,
                              ),
                              const SizedBox(width: 16),
                              if (selectedImages.isNotEmpty)
                                Expanded(
                                  child: SizedBox(
                                    height: 80,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: selectedImages.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Image.memory(selectedImages[index], width: 80, height: 80),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.send,
                          color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                        ),
                        label: Text(
                          isArabic ? "إرسال الإشعار" : "Send Notification",
                          style: TextStyle(
                            color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900],
                          ),
                        ),
                        onPressed: canSend ? openConfirmDialog : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          backgroundColor: isDark ? Colors.green[900] :   Colors.blue[100],
                          foregroundColor: isDark ? Colors.green[100] : Colors.blue[900],
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  Widget _buildLabeledInput({required String label, required Widget child,required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style:TextStyle(fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFD7EFDC) : Colors.blue[900])),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
