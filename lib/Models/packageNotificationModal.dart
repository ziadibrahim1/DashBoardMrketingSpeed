// مودال الإشعار مع معاينة
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dashboard/pages/Package.dart';
import '../services/api_service.dart';

class NotificationModal extends StatefulWidget {
  final Package package;
  final void Function(String method, String title, String content, DateTime? scheduled) onSent;
  final bool isArabic;

  const NotificationModal({
    super.key,
    required this.package,
    required this.onSent,
    this.isArabic = true,
  });

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String sendMethod;
  DateTime? scheduledDate;

  @override
  void initState() {
    super.initState();
    sendMethod = widget.isArabic ? 'داخل التطبيق' : 'In-App';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: widget.isArabic ? const Locale('ar') : const Locale('en'),
    );
    if (picked != null) setState(() => scheduledDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewTitle = _titleController.text.trim().isEmpty
        ? (widget.isArabic ? 'عنوان تجريبي' : 'Sample Title')
        : _titleController.text.trim();

    final previewContent = _contentController.text.trim().isEmpty
        ? (widget.isArabic ? 'محتوى الإشعار سيظهر هنا.' : 'Notification content will appear here.')
        : _contentController.text.trim();

    final methods = widget.isArabic
        ? ['داخل التطبيق', 'رسائل الهاتف SMS', 'البريد الإلكتروني']
        : ['In-App', 'SMS', 'Email'];

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isArabic
                        ? 'إرسال إشعار لـ "${widget.package.name}"'
                        : 'Send Notification to "${widget.package.name}"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: widget.isArabic ? 'عنوان الإشعار *' : 'Notification Title *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: widget.isArabic ? 'محتوى الإشعار *' : 'Notification Content *'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sendMethod,
              decoration: InputDecoration(labelText: widget.isArabic ? 'طريقة الإرسال' : 'Send Method'),
              items: methods.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => sendMethod = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(widget.isArabic ? 'جدولة الإرسال:' : 'Schedule Send:'),
                const SizedBox(width: 8),
                Text(scheduledDate != null
                    ? DateFormat('yyyy/MM/dd').format(scheduledDate!)
                    : (widget.isArabic ? 'غير مجدول' : 'Not Scheduled')),
                IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                if (scheduledDate != null)
                  IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => scheduledDate = null)),
              ],
            ),
            const SizedBox(height: 16),
            // معاينة الترويسة
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'معاينة الإشعار' : 'Notification Preview',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text('${widget.isArabic ? 'العنوان' : 'Title'}: $previewTitle', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('${widget.isArabic ? 'المحتوى' : 'Content'}: $previewContent'),
                    const SizedBox(height: 6),
                    Text('${widget.isArabic ? 'الطريقة' : 'Method'}: $sendMethod'),
                    if (scheduledDate != null)
                      Text(
                        '${widget.isArabic ? 'مجدول لـ' : 'Scheduled for'}: ${DateFormat('yyyy/MM/dd').format(scheduledDate!)}',
                        style:   TextStyle(color:isDark?Color(0xFFD7EFDC): Colors.blue),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(widget.isArabic
                        ? 'يرجى ملء عنوان ومحتوى الإشعار'
                        : 'Please fill in the title and content of the notification')),
                  );
                  return;
                }

                try {
                  await ApiService.sendNotification(
                    packageId: widget.package.id,
                    method: sendMethod,
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    scheduledAt: scheduledDate,
                  );

                  widget.onSent(
                      sendMethod,
                      _titleController.text.trim(),
                      _contentController.text.trim(),
                      scheduledDate);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(widget.isArabic ? 'تم إرسال الإشعار بنجاح' : 'Notification sent successfully')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(widget.isArabic
                        ? 'فشل إرسال الإشعار'
                        : 'Failed to send notification')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:isDark?Colors.green: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(widget.isArabic ? 'إرسال الإشعار' : 'Send Notification',style:TextStyle(color:Colors.white)),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
