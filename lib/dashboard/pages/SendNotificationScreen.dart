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

  final List<Map<String, dynamic>> receiverOptions = [
    {"key": "all", "label": "الكل", "count": 500},
    {"key": "subscribed", "label": "المشتركين", "count": 320},
    {"key": "not_subscribed", "label": "غير المشتركين", "count": 180},
    {"key": "users", "label": "المستخدمين", "count": 400},
    {"key": "non_users", "label": "غير المستخدمين", "count": 100},
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

    final filteredReceivers = receiverOptions
        .where((r) => r["label"]
        .toString()
        .toLowerCase()
        .contains(receiverSearch.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? "إرسال إشعار للمستخدمين" : "Send Notification",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "معلومات الإشعار" : "Notification Info",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "عنوان الإشعار" : "Notification Title",
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: isArabic ? "مثال: تحديث جديد" : "e.g. New Update",
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "موضوع البريد (اختياري)" : "Email Subject (Optional)",
                            child: TextField(
                              controller: emailSubjectController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: isArabic ? "موضوع البريد الإلكتروني" : "Email subject",
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabeledInput(
                            label: isArabic ? "نص الإشعار" : "Notification Body",
                            child: TextField(
                              controller: messageController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: isArabic ? "تفاصيل الإشعار" : "Notification content",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "الفئة المستهدفة" : "Target Audience",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (v) => setState(() => receiverSearch = v),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
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
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(opt['label']),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              opt['count'].toString(),
                                              style: const TextStyle(
                                                color: Colors.blue,
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
                                      selectedColor: Colors.blue.shade300,
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
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "الجدولة" : "Scheduling",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                              Text(isArabic ? "جدولة الإشعار" : "Schedule Notification"),
                              const SizedBox(width: 16),
                              if (schedule && scheduledTime != null)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  label: Text(isArabic ? "تغيير الوقت" : "Change Time"),
                                  onPressed: pickScheduleDateTime,
                                ),
                              const SizedBox(width: 12),
                              if (schedule && scheduledTime != null)
                                Text(
                                  "${isArabic ? 'الوقت المتبقي' : 'Time left'}: ${_formatDuration(remaining)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "طرق الإرسال" : "Send Methods",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 20,
                            children: [
                              FilterChip(
                                label: Text(isArabic ? "داخل التطبيق" : "In-App"),
                                selected: sendInApp,
                                onSelected: (val) => setState(() => sendInApp = val),
                              ),
                              FilterChip(
                                label: Text(isArabic ? "رسالة SMS" : "SMS"),
                                selected: sendSms,
                                onSelected: (val) => setState(() => sendSms = val),
                              ),
                              FilterChip(
                                label: Text(isArabic ? "بريد إلكتروني" : "Email"),
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
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "إرفاق صور (اختياري)" : "Attach Images (Optional)",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.image),
                                label: Text(isArabic ? "اختيار صور" : "Select Images"),
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
                        icon: const Icon(Icons.send),
                        label: Text(isArabic ? "إرسال الإشعار" : "Send Notification"),
                        onPressed: canSend ? openConfirmDialog : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
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
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  Widget _buildLabeledInput({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
