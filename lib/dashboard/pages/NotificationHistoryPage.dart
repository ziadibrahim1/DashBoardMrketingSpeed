import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/NotificationItem.dart';
import '../../core/app_config.dart';
import '../../providers/app_providers.dart';

class NotificationHistoryPage extends StatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  State<NotificationHistoryPage> createState() => _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends State<NotificationHistoryPage> {
  List<NotificationItem> notifications = [];
  bool loading = true;
  String searchQuery = '';
  String filterChannel = 'all';

  // الترجمات
  Map<String, Map<String, String>> translations = {
    'ar': {
      'title': 'سجل الإشعارات',
      'subtitle': 'إدارة ومتابعة جميع الإشعارات المرسلة',
      'totalNotifications': 'إجمالي الإشعارات',
      'inAppNotifications': 'إشعارات في التطبيق',
      'packageNotifications': 'إشعارات في الباقات',
      'emailNotifications': 'إشعارات البريد',
      'searchPlaceholder': 'البحث في الإشعارات...',
      'all': 'الكل',
      'inApp': 'في التطبيق',
      'refresh': 'تحديث',
      'noNotifications': 'لا توجد إشعارات بعد',
      'noResults': 'لم يتم العثور على نتائج',
      'notificationsWillAppear': 'سيظهر سجل الإشعارات هنا',
      'tryDifferentKeywords': 'جرب البحث بكلمات مختلفة',
      'resend': 'إعادة إرسال',
      'notificationDetails': 'تفاصيل الإشعار',
      'titleLabel': 'العنوان',
      'messageLabel': 'الرسالة',
      'channelLabel': 'القناة',
      'dateLabel': 'التاريخ',
      'resendNotification': 'إعادة إرسال الإشعار',
      'errorLoading': 'حدث خطأ في تحميل البيانات',
      'resendSuccess': 'تم إعادة إرسال الإشعار بنجاح',
      'resendFailed': 'فشلت عملية إعادة الإرسال',
    },
    'en': {
      'title': 'Notification History',
      'subtitle': 'Manage and track all sent notifications',
      'totalNotifications': 'Total Notifications',
      'inAppNotifications': 'In-App Notifications',
      'packageNotifications': 'Package Notifications',
      'emailNotifications': 'Email Notifications',
      'searchPlaceholder': 'Search notifications...',
      'all': 'All',
      'inApp': 'In-App',
      'refresh': 'Refresh',
      'noNotifications': 'No notifications yet',
      'noResults': 'No results found',
      'notificationsWillAppear': 'Notification history will appear here',
      'tryDifferentKeywords': 'Try searching with different keywords',
      'resend': 'Resend',
      'notificationDetails': 'Notification Details',
      'titleLabel': 'Title',
      'messageLabel': 'Message',
      'channelLabel': 'Channel',
      'dateLabel': 'Date',
      'resendNotification': 'Resend Notification',
      'errorLoading': 'Error loading data',
      'resendSuccess': 'Notification resent successfully',
      'resendFailed': 'Failed to resend notification',
    },
  };

  String t(String key, String locale) {
    return translations[locale]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse("${AppConfig.baseUrl}notifications/history"),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          notifications = data
              .map((json) => NotificationItem.fromJson(json))
              .toList()
              .reversed
              .toList();
          loading = false;
        });
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        final locale = context.read<LocaleProvider>().locale.languageCode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('errorLoading', locale)),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resendNotification(NotificationItem notification) async {
    final locale = context.read<LocaleProvider>().locale.languageCode;
    final body = {
      "title": notification.title,
      "message": notification.message,
      "targetAudience": notification.targetAudience,
      "destination": [notification.destination],
      "scheduleAt": notification.scheduleAt,
      "emailSubject": ""
    };
    try {
      final res = await http.post(
        Uri.parse("${AppConfig.baseUrl}notifications/repeat/${notification.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(t('resendSuccess', locale)),
                ],
              ),
              backgroundColor: const Color(0xFF259C40),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('resendFailed', locale)),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<NotificationItem> get filteredNotifications {
    return notifications.where((n) {
      final matchesSearch = n.title.contains(searchQuery) ||
          n.message.contains(searchQuery);
      final matchesFilter = filterChannel == 'all' ||
          n.destination.toLowerCase() == filterChannel.toLowerCase() ||
          (filterChannel == 'in_app' && n.destination.toLowerCase() == 'in_app');
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final isDark = themeMode == ThemeMode.dark;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final isRTL = locale == 'ar';

    // ألوان الوضع الفاتح
    final lightBg = const Color(0xFFF8FAFC);
    final lightCardBg = Colors.white;
    final lightBorder = const Color(0xFFE2E8F0);
    final lightPrimary = const Color(0xFF1B367A);

    // ألوان الوضع الداكن (أخضر)
    final darkBg = const Color(0xFF1D201D);
    final darkCardBg = const Color(0xFF19231B);
    final darkBorder = const Color(0xFF233526);
    final darkPrimary = const Color(0xFF139838);

    final bg = isDark ? darkBg : lightBg;
    final cardBg = isDark ? darkCardBg : lightCardBg;
    final border = isDark ? darkBorder : lightBorder;
    final primary = isDark ? darkPrimary : lightPrimary;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textTertiary = isDark ? Colors.grey[500] : Colors.grey[500];

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeaderCard(isDark, cardBg, border, primary, textPrimary, locale),
                  const SizedBox(height: 24),
                  _buildStatsSection(isDark, cardBg, border, textPrimary, textSecondary, locale),
                  const SizedBox(height: 24),
                  _buildFilterSection(isDark, cardBg, border, primary, textPrimary, textSecondary, textTertiary, locale),
                  const SizedBox(height: 24),
                  _buildNotificationsList(isDark, cardBg, border, primary, textPrimary, textSecondary, textTertiary, locale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark, Color cardBg, Color border, Color primary, Color textPrimary, String locale) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF268C3F), const Color(0xFF216532)]
              : [const Color(0xFF1B367A), const Color(0xFF0B3DB6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF268C3F) : const Color(0xff2581eb)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('title', locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('subtitle', locale),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, Color cardBg, Color border, Color textPrimary, Color? textSecondary, String locale) {
    final fcmCount = notifications.where((n) => n.destination.toLowerCase() == 'in_app').length;
    final pkgCount = notifications.where((n) => n.targetAudience.toLowerCase() == 'package').length;
    final emailCount = notifications.where((n) => n.destination.toLowerCase() == 'email').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            t('totalNotifications', locale),
            notifications.length.toString(),
            Icons.campaign_rounded,
            isDark ? const Color(0xFF10B981) : const Color(0xFF2563EB),
            isDark ? const Color(0xFF064E3B) : const Color(0xFFEFF6FF),
            cardBg,
            border,
            textPrimary,
            textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            t('inAppNotifications', locale),
            fcmCount.toString(),
            Icons.phone_android_rounded,
            const Color(0xFF08932D),
            isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
            cardBg,
            border,
            textPrimary,
            textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            t('packageNotifications', locale),
            pkgCount.toString(),
            Icons.wallet,
            const Color(0xFF56C0DC),
            isDark ? const Color(0xFF164E63) : const Color(0xFFECFDF5),
            cardBg,
            border,
            textPrimary,
            textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            t('emailNotifications', locale),
            emailCount.toString(),
            Icons.email_rounded,
            const Color(0xFFF59E0B),
            isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
            cardBg,
            border,
            textPrimary,
            textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor, Color cardBg, Color border, Color textPrimary, Color? textSecondary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDark, Color cardBg, Color border, Color primary, Color textPrimary, Color? textSecondary, Color? textTertiary, String locale) {
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: t('searchPlaceholder', locale),
                hintStyle: TextStyle(color: textTertiary),
                prefixIcon: Icon(Icons.search, color: textTertiary),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filterChannel,
                icon: Icon(Icons.keyboard_arrow_down, color: textPrimary),
                dropdownColor: cardBg,
                style: TextStyle(color: textPrimary),
                items: [
                  DropdownMenuItem(value: 'all', child: Text(t('all', locale))),
                  DropdownMenuItem(value: 'in_app', child: Text(t('inApp', locale))),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                ],
                onChanged: (value) => setState(() => filterChannel = value!),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _fetchNotifications,
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
            ),
            tooltip: t('refresh', locale),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark, Color cardBg, Color border, Color primary, Color textPrimary, Color? textSecondary, Color? textTertiary, String locale) {
    if (loading) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5, color: primary),
        ),
      );
    }

    final filtered = filteredNotifications;

    if (filtered.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                searchQuery.isEmpty ? t('noNotifications', locale) : t('noResults', locale),
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchQuery.isEmpty ? t('notificationsWillAppear', locale) : t('tryDifferentKeywords', locale),
                style: TextStyle(color: textTertiary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? const Color(0xFF334155) : Colors.grey[100],
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) => _buildNotificationCard(filtered[index], isDark, primary, textPrimary, textSecondary, textTertiary, locale),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, bool isDark, Color primary, Color textPrimary, Color? textSecondary, Color? textTertiary, String locale) {
    final isEmail = notification.destination.toLowerCase() == 'email';
    final channelColor = isEmail ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final channelBg = isEmail
        ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5));
    final channelIcon = isEmail ? Icons.email_rounded : Icons.phone_android_rounded;

    return InkWell(
      onTap: () => _showNotificationDetails(notification, isDark, primary, textPrimary, textSecondary, locale),
      hoverColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: channelBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(channelIcon, color: channelColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: channelBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: channelColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(channelIcon, size: 14, color: channelColor),
                            const SizedBox(width: 6),
                            Text(
                              notification.destination.toUpperCase(),
                              style: TextStyle(
                                color: channelColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _resendNotification(notification),
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: Text(t('resend', locale)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        return "${parts[0]} • ${parts[1]}";
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  void _showNotificationDetails(NotificationItem notification, bool isDark, Color primary, Color textPrimary, Color? textSecondary, String locale) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF0F172A) : Colors.grey[100];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    t('notificationDetails', locale),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: inputBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow(t('titleLabel', locale), notification.title, textSecondary, textPrimary),
              const SizedBox(height: 16),
              _detailRow(t('messageLabel', locale), notification.message, textSecondary, textPrimary),
              const SizedBox(height: 16),
              _detailRow(t('channelLabel', locale), notification.destination.toUpperCase(), textSecondary, textPrimary),
              const SizedBox(height: 16),
              _detailRow(t('dateLabel', locale), notification.createdAt, textSecondary, textPrimary),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _resendNotification(notification);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(t('resendNotification', locale)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color? textSecondary, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}