import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers/app_providers.dart';


class PlatformManagementPage extends StatefulWidget {
  const PlatformManagementPage({super.key});

  @override
  State<PlatformManagementPage> createState() => _PlatformManagementPageState();
}

class _PlatformManagementPageState extends State<PlatformManagementPage> {
  // المنصات مع الأسماء بالعربية والإنجليزية
  final List<PlatformModel> platforms = [
    PlatformModel('واتساب', 'WhatsApp', FontAwesomeIcons.whatsapp, Colors.green),
    PlatformModel('فيسبوك', 'Facebook', FontAwesomeIcons.facebook, Colors.indigo),
    PlatformModel('حراج', 'Haraj', Icons.store, Colors.brown),
    PlatformModel('تيك توك', 'TikTok', FontAwesomeIcons.tiktok, Colors.black),
    PlatformModel('إنستقرام', 'Instagram', FontAwesomeIcons.instagram, Colors.purple),
    PlatformModel('تيليجرام', 'Telegram', FontAwesomeIcons.telegram, Colors.blue),
    PlatformModel('البريد الإلكتروني', 'Email', FontAwesomeIcons.envelope, Colors.orange),
    PlatformModel('رسائل الهاتف', 'SMS', FontAwesomeIcons.sms, Colors.teal),
    PlatformModel('إكس (تويتر)', 'X (Twitter)', FontAwesomeIcons.xTwitter, Colors.black),
  ];

  // ترجمة النصوص الرئيسية
  final Map<String, Map<String, String>> translations = {
    'platform_management': {'ar': 'إدارة المنصات', 'en': 'Platform Management'},
    'edit_status': {'ar': 'تعديل الحالة', 'en': 'Edit Status'},
    'status': {'ar': 'الحالة', 'en': 'Status'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'active': {'ar': 'مفعلة', 'en': 'Active'},
    'closed_for_maintenance': {'ar': 'مغلقة للتطوير', 'en': 'Closed for maintenance'},
    'operating_hours': {'ar': 'تعمل خلال ساعات معينة', 'en': 'Operating in specific hours'},
    'auto_mode': {'ar': 'تشغيل تلقائي', 'en': 'Auto mode'},
    'unknown': {'ar': 'غير معروف', 'en': 'Unknown'},
    'optional_status_msg': {'ar': 'رسالة الحالة (اختيارية)', 'en': 'Status message (optional)'},
    'example_status_msg': {'ar': 'مثال: ستعمل خلال ساعات النهار فقط', 'en': 'Example: Will operate only during daytime'},
    'select_start_time': {'ar': 'حدد وقت البدء', 'en': 'Select start time'},
    'select_end_time': {'ar': 'حدد وقت الإيقاف', 'en': 'Select end time'},
    'from': {'ar': 'من:', 'en': 'From:'},
    'to': {'ar': 'إلى:', 'en': 'To:'},
    'incomplete_time': {'ar': '⏰ توقيت غير مكتمل', 'en': '⏰ Incomplete time'},
    'switch_language_tooltip_ar': {'ar': 'التبديل للإنجليزية', 'en': 'Switch to English'},
    'switch_language_tooltip_en': {'ar': 'Switch to Arabic', 'en': 'التبديل للعربية'},
  };

  String t(String key, String langCode) {
    return translations[key]?[langCode] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final isArabic = langCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4.2,
            children: platforms
                .map((platform) => _buildPlatformCard(context, platform, isDark, isArabic, langCode))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(BuildContext context, PlatformModel platform, bool isDark, bool isArabic, String langCode) {
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
                  backgroundColor:isDark ? Colors.grey[350] :  platform.color.withOpacity(0.2),
                  child: Icon(platform.icon, color: platform.color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic ? platform.nameAr : platform.nameEn,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    platform.statusText(langCode, t),
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
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showEditDialog(context, platform, langCode, t, isArabic),
                icon: Icon(Icons.edit, size: 16, color: isDark ? Colors.blue[200] : Colors.blue),
                label: Text(
                  t('edit_status', langCode),
                  style: TextStyle(color: isDark ? Colors.blue[200] : Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, PlatformModel platform, String langCode,
      String Function(String, String) t, bool isArabic) {
    String selectedStatus = platform.status;
    TextEditingController msgController = TextEditingController(text: platform.message);
    TimeOfDay? start = platform.startTime;
    TimeOfDay? end = platform.endTime;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              title: Text('${t('edit_status', langCode)} ${isArabic ? platform.nameAr : platform.nameEn}'),
              content: SingleChildScrollView(
                child: Column(
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
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(t(_statusKey(status), langCode)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedStatus = value);
                        }
                      },
                      decoration: InputDecoration(labelText: t('status', langCode)),
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
                                    ? '${t('from', langCode)} ${PlatformModel.formatTime(start!, langCode)}'
                                    : t('select_start_time', langCode),
                              ),
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
                                    ? '${t('to', langCode)} ${PlatformModel.formatTime(end!, langCode)}'
                                    : t('select_end_time', langCode),
                              ),
                              onPressed: () async {
                                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
                      decoration: InputDecoration(
                        labelText: t('optional_status_msg', langCode),
                        hintText: t('example_status_msg', langCode),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t('cancel', langCode)),
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
                  child: Text(t('save', langCode)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // تحويل الحالة إلى مفتاح لترجمتها
  String _statusKey(String status) {
    switch (status) {
      case 'مفعلة':
        return 'active';
      case 'مغلقة للتطوير':
        return 'closed_for_maintenance';
      case 'تعمل خلال ساعات معينة':
        return 'operating_hours';
      case 'تشغيل تلقائي':
        return 'auto_mode';
      default:
        return 'unknown';
    }
  }
}

class PlatformModel {
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;

  String status;
  String message;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  PlatformModel(
      this.nameAr,
      this.nameEn,
      this.icon,
      this.color, {
        this.status = 'مفعلة',
        this.message = '',
        this.startTime,
        this.endTime,
      });

  String statusText(String langCode, String Function(String, String) t) {
    if (status == 'تشغيل تلقائي') {
      if (startTime != null && endTime != null) {
        return '⏰ ${t('from', langCode)} ${formatTime(startTime!, langCode)} ${t('to', langCode)} ${formatTime(endTime!, langCode)}';
      }
      return t('incomplete_time', langCode);
    }

    switch (status) {
      case 'مفعلة':
        return '${t('active', langCode)}';
      case 'مغلقة للتطوير':
        return '${t('closed_for_maintenance', langCode)}';
      case 'تعمل خلال ساعات معينة':
        return '${t('operating_hours', langCode)}';
      default:
        return t('unknown', langCode);
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

  static String formatTime(TimeOfDay time, String langCode) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am
        ? (langCode == 'ar' ? 'صباحًا' : 'AM')
        : (langCode == 'ar' ? 'مساءً' : 'PM');
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
