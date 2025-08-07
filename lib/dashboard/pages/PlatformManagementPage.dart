import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlatformManagementPage extends StatefulWidget {
  const PlatformManagementPage({super.key});

  @override
  State<PlatformManagementPage> createState() => _PlatformManagementPageState();
}

class _PlatformManagementPageState extends State<PlatformManagementPage> {
  final List<PlatformModel> platforms = [
    PlatformModel('واتساب', FontAwesomeIcons.whatsapp, Colors.green),
    PlatformModel('فيسبوك', FontAwesomeIcons.facebook, Colors.indigo),
    PlatformModel('حراج', Icons.store, Colors.brown),
    PlatformModel('تيك توك', FontAwesomeIcons.tiktok, Colors.black),
    PlatformModel('إنستقرام', FontAwesomeIcons.instagram, Colors.purple),
    PlatformModel('تيليجرام', FontAwesomeIcons.telegram, Colors.blue),
    PlatformModel('البريد الإلكتروني', FontAwesomeIcons.envelope, Colors.orange),
    PlatformModel('رسائل الهاتف', FontAwesomeIcons.sms, Colors.teal),
    PlatformModel('إكس (تويتر)', FontAwesomeIcons.xTwitter, Colors.black),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title:   Text('إدارة المنصات', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 4.2,
          children: platforms.map((platform) => _buildPlatformCard(context, platform)).toList(),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(BuildContext context, PlatformModel platform) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: platform.color.withOpacity(0.1),
                  child: Icon(platform.icon, color: platform.color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    platform.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    platform.statusText(),
                    style: TextStyle(
                      fontSize: 13,
                      color: platform.statusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (platform.message.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                platform.message,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showEditDialog(context, platform),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('تعديل الحالة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, PlatformModel platform) {
    String selectedStatus = platform.status;
    TextEditingController msgController = TextEditingController(text: platform.message);
    TimeOfDay? start = platform.startTime;
    TimeOfDay? end = platform.endTime;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('تعديل حالة ${platform.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: [
                    'مفعلة',
                    'مغلقة للتطوير',
                    'تعمل خلال ساعات معينة',
                    'تشغيل تلقائي',
                  ]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                  decoration: const InputDecoration(labelText: 'الحالة'),
                ),
                const SizedBox(height: 12),
                if (selectedStatus == 'تشغيل تلقائي') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            start != null
                                ? 'من: ${PlatformModel.formatTime(start!)}'
                                : 'حدد وقت البدء',
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (picked != null) {
                              setDialogState(() => start = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time_filled),
                          label: Text(
                            end != null
                                ? 'إلى: ${PlatformModel.formatTime(end!)}'
                                : 'حدد وقت الإيقاف',
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (picked != null) {
                              setDialogState(() => end = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: msgController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'رسالة الحالة (اختيارية)',
                    hintText: 'مثال: ستعمل خلال ساعات النهار فقط',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    platform.status = selectedStatus;
                    platform.message = msgController.text;
                    if (selectedStatus == 'تشغيل تلقائي') {
                      platform.startTime = start;
                      platform.endTime = end;
                    } else {
                      platform.startTime = null;
                      platform.endTime = null;
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

}

class PlatformModel {
  final String name;
  final IconData icon;
  final Color color;
  String status;
  String message;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  PlatformModel(this.name, this.icon, this.color,
      {this.status = 'مفعلة', this.message = '', this.startTime, this.endTime});

  String statusText() {
    if (status == 'تشغيل تلقائي') {
      if (startTime != null && endTime != null) {
        return '⏰ من ${formatTime(startTime!)} إلى ${formatTime(endTime!)}';
      }
      return '⏰ توقيت غير مكتمل';
    }

    switch (status) {
      case 'مفعلة':
        return '✅ المنصة مفعلة';
      case 'مغلقة للتطوير':
        return '🔧 مغلقة للتطوير';
      case 'تعمل خلال ساعات معينة':
        return '⏰ تعمل في أوقات محددة';
      default:
        return 'غير معروف';
    }
  }

  Color statusColor() {
    switch (status) {
      case 'مفعلة':
        return Colors.green;
      case 'مغلقة للتطوير':
        return Colors.orange;
      case 'تعمل خلال ساعات معينة':
      case 'تشغيل تلقائي':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
