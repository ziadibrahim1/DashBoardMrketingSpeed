import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import '../../providers/app_providers.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> admins = [];
  String searchQuery = '';
  String selectedRoleFilter = 'all';
  String selectedStatusFilter = 'all';
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  Set<int> selectedAdmins = {};
  bool isMultiSelectMode = false;

  // ✅ الألوان للوضع الفاتح (نفس الألوان الحالية)
  static const Color primaryBlueLight = Color(0xFF1B367A);
  static const Color lightBlueLight = Color(0xFF4FB5F5);
  static const Color darkBlueLight = Color(0xFF0D47A1);
  static const Color accentBlueLight = Color(0xFF64B5F6);
  static const Color bgLightMode = Color(0xFFF5F9FF);

  // ✅ الألوان للوضع الداكن (أخضر)
  static const Color primaryGreenDark = Color(0xFF10B981);
  static const Color lightGreenDark = Color(0xFF216532);
  static const Color darkGreenDark = Color(0xFF059669);
  static const Color accentGreenDark = Color(0xFF6EE7B7);
  static const Color bgDarkMode = Color(0xFF1F2937);

  // ألوان مشتركة
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A237E);
  static const Color inactiveRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);

  final List<Map<String, String>> availablePages = [
    {'key': 'DashboardStatsSection', 'ar': 'قسم إحصائيات لوحة التحكم', 'en': 'Dashboard Stats Section'},
    {'key': 'UsersPage', 'ar': 'صفحة المستخدمين', 'en': 'Users Page'},
    {'key': 'AdminUsersScreen', 'ar': 'شاشة مستخدمي الإدارة', 'en': 'Admin Users Screen'},
    {'key': 'SubscriptionsPage', 'ar': 'صفحة الاشتراكات', 'en': 'Subscriptions Page'},
    {'key': 'PlatformManagementPage', 'ar': 'صفحة إدارة المنصة', 'en': 'Platform Management Page'},
    {'key': 'AdminManagementScreen', 'ar': 'شاشة إدارة المسؤولين', 'en': 'Admin Management Screen'},
    {'key': 'PackagesPage', 'ar': 'صفحة الباقات', 'en': 'Packages Page'},
    {'key': 'SocialAccountsPage', 'ar': 'صفحة الحسابات الاجتماعية', 'en': 'Social Accounts Page'},
    {'key': 'ReferralRewardsPage', 'ar': 'صفحة مكافآت الإحالة', 'en': 'Referral Rewards Page'},
    {'key': 'SuggestionsManagementPage', 'ar': 'صفحة إدارة الاقتراحات', 'en': 'Suggestions Management Page'},
    {'key': 'SupervisorsMarketersPage', 'ar': 'صفحة المشرفين والمسوقين', 'en': 'Supervisors & Marketers Page'},
    {'key': 'WithdrawalsScreen', 'ar': 'شاشة السحوبات', 'en': 'Withdrawals Screen'},
    {'key': 'ApiDashboardScreen', 'ar': 'شاشة لوحة تحكم API', 'en': 'API Dashboard Screen'},
    {'key': 'PaymentManagementSection', 'ar': 'قسم إدارة الدفع', 'en': 'Payment Management Section'},
    {'key': 'VideoManagerScreen', 'ar': 'شاشة إدارة الفيديوهات', 'en': 'Video Manager Screen'},
    {'key': 'StatsPage', 'ar': 'صفحة الإحصائيات', 'en': 'Stats Page'},
    {'key': 'StatsPageTelegram', 'ar': 'صفحة إحصائيات تيليجرام', 'en': 'Telegram Stats Page'},
    {'key': 'AdminLiveChatDashboard', 'ar': 'لوحة الدردشة المباشرة', 'en': 'Admin Live Chat Dashboard'},
    {'key': 'AdminChatHistoryScreen', 'ar': 'شاشة سجل المحادثات', 'en': 'Admin Chat History Screen'},
    {'key': 'SendNotificationPage', 'ar': 'صفحة إرسال الإشعارات', 'en': 'Send Notification Page'},
    {'key': 'NotificationHistoryPage', 'ar': 'صفحة سجل الإشعارات', 'en': 'Notification History Page'},
    {'key': 'ReportsScreen', 'ar': 'صفحة التقارير', 'en': 'Reports Screen  '},
  ];

  // ✅ دوال للحصول على الألوان حسب الثيم
  Color _getPrimaryColor(bool isDark) => isDark ? primaryGreenDark : primaryBlueLight;
  Color _getLightColor(bool isDark) => isDark ? lightGreenDark : lightBlueLight;
  Color _getDarkColor(bool isDark) => isDark ? darkGreenDark : darkBlueLight;
  Color _getAccentColor(bool isDark) => isDark ? accentGreenDark : accentBlueLight;
  Color _getBgColor(bool isDark) => isDark ? bgDarkMode : bgLightMode;
  Color _getCardColor(bool isDark) => isDark ? Colors.grey[850]! : cardLight;
  Color _getTextColor(bool isDark) => isDark ? Colors.white : textDark;

  Future<void> fetchAdmins() async {
    final response = await http.get(Uri.parse("${AppConfig.apiBase}/api/dashboard-users"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        admins = data.map((e) => {
          'id': e['id'],
          'email': e['email'] ?? '',
          'firstName': e['first_name'] ?? '',
          'middleName': e['middle_name'] ?? '',
          'lastName': e['last_name'] ?? '',
          'phone': e['phone'] ?? '',
          'country': e['country'] ?? '',
          'city': e['city'] ?? '',
          'bank': e['bank'] ?? '',
          'iban': e['iban'] ?? '',
          'role': e['role'] ?? 'user',
          'isActive': e['is_active'] ?? true,
          'profileImagePath': e['image_path'],
          'DashboardStatsSection': e['dashboardStatsSection'] ?? 0,
          'UsersPage': e['usersPage'] ?? 0,
          'AdminUsersScreen': e['adminUsersScreen'] ?? 0,
          'SubscriptionsPage': e['subscriptionsPage'] ?? 0,
          'PlatformManagementPage': e['platformManagementPage'] ?? 0,
          'AdminManagementScreen': e['adminManagementScreen'] ?? 0,
          'PackagesPage': e['packagesPage'] ?? 0,
          'SocialAccountsPage': e['socialAccountsPage'] ?? 0,
          'ReferralRewardsPage': e['referralRewardsPage'] ?? 0,
          'SuggestionsManagementPage': e['suggestionsManagementPage'] ?? 0,
          'SupervisorsMarketersPage': e['supervisorsMarketersPage'] ?? 0,
          'WithdrawalsScreen': e['withdrawalsScreen'] ?? 0,
          'ApiDashboardScreen': e['ApiDashboardScreen'] ?? 0,
          'PaymentManagementSection': e['paymentManagementSection'] ?? 0,
          'VideoManagerScreen': e['videoManagerScreen'] ?? 0,
          'StatsPage': e['statsPage'] ?? 0,
          'StatsPageTelegram': e['statsPageTelegram'] ?? 0,
          'AdminLiveChatDashboard': e['adminLiveChatDashboard'] ?? 0,
          'AdminChatHistoryScreen': e['adminChatHistoryScreen'] ?? 0,
          'SendNotificationPage': e['sendNotificationPage'] ?? 0,
          'NotificationHistoryPage': e['notificationHistoryPage'] ?? 0,
          'ReportsScreen': e['reportsScreen'] ?? 0,
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> get inactiveUsers {
    return filteredAdmins.where((admin) => admin['isActive'] == false).toList();
  }

  List<Map<String, dynamic>> get activeUsers {
    return filteredAdmins.where((admin) => admin['isActive'] == true).toList();
  }

  Future<void> bulkPermanentDeleteInactive(String langCode) async {
    if (inactiveUsers.isEmpty) {
      _showSnackBar(t('no_inactive_users',langCode), inactiveRed);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: inactiveRed, size: 28),
            const SizedBox(width: 12),
            Text(t('bulk_permanent_delete_title', langCode)),
          ],
        ),
        content: Text(
          t('bulk_permanent_delete_message', langCode).replaceFirst(
              '{}',
              inactiveUsers.length.toString()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', langCode)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: inactiveRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('delete_permanent', langCode)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.post(
          Uri.parse("${AppConfig.apiBase}/api/dashboard-users/bulk-permanent-delete"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(inactiveUsers.map((admin) => admin['id']).toList()),
        );

        if (response.statusCode == 200) {
          await fetchAdmins();
          _showSnackBar(
            t('bulk_permanent_delete_success', langCode).replaceFirst(
                '{}',
                inactiveUsers.length.toString()
            ),
            successGreen,
          );
        } else {
          _showSnackBar(t('bulk_permanent_delete_failed', langCode), inactiveRed);
        }
      } catch (e) {
        _showSnackBar(t('bulk_permanent_delete_error', langCode), inactiveRed);
      }
    }
  }

  Future<void> bulkReactivateInactive(String langCode) async {
    if (inactiveUsers.isEmpty) {
      _showSnackBar(t('no_inactive_users', langCode), inactiveRed);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: successGreen, size: 28),
            const SizedBox(width: 12),
            Text(t('bulk_reactivate_title', langCode)),
          ],
        ),
        content: Text(
          t('bulk_reactivate_message', langCode).replaceFirst(
              '{}',
              inactiveUsers.length.toString()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', langCode)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('activate', langCode)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final responses = await Future.wait(
            inactiveUsers.map((admin) =>
                http.put(Uri.parse("${AppConfig.apiBase}/api/dashboard-users/${admin['id']}/activate"))
            )
        );

        final successCount = responses.where((r) => r.statusCode == 200).length;

        await fetchAdmins();
        _showSnackBar(
          t('bulk_reactivate_success', langCode).replaceFirst('{}', successCount.toString()),
          successGreen,
        );
      } catch (e) {
        _showSnackBar(t('bulk_reactivate_error', langCode), inactiveRed);
      }
    }
  }

  Future<void> bulkDeactivateSelected(String langCode) async {
    if (selectedAdmins.isEmpty) {
      _showSnackBar(t('no_users_selected', langCode), inactiveRed);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text(t('bulk_deactivate_title', langCode)),
          ],
        ),
        content: Text(
          t('bulk_deactivate_message', langCode).replaceFirst(
              '{}',
              selectedAdmins.length.toString()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', langCode)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('deactivate', langCode)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.post(
          Uri.parse("${AppConfig.apiBase}/api/dashboard-users/bulk-deactivate"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(selectedAdmins.toList()),
        );

        if (response.statusCode == 200) {
          await fetchAdmins();
          _showSnackBar(
            t('bulk_deactivate_success', langCode).replaceFirst(
                '{}',
                selectedAdmins.length.toString()
            ),
            successGreen,
          );
          setState(() {
            isMultiSelectMode = false;
            selectedAdmins.clear();
          });
        } else {
          _showSnackBar(t('bulk_deactivate_failed', langCode), inactiveRed);
        }
      } catch (e) {
        _showSnackBar(t('bulk_deactivate_error', langCode), inactiveRed);
      }
    }
  }

  Future<void> bulkPermanentDeleteSelected(String langCode) async {
    if (selectedAdmins.isEmpty) {
      _showSnackBar(t('no_users_selected', langCode), inactiveRed);
      return;
    }

    final inactiveSelectedAdmins = selectedAdmins.where((id) {
      final admin = filteredAdmins.firstWhere((a) => a['id'] == id, orElse: () => {});
      return admin['isActive'] == false;
    }).toSet();

    if (inactiveSelectedAdmins.isEmpty) {
      _showSnackBar(t('no_inactive_selected', langCode), inactiveRed);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: inactiveRed, size: 28),
            const SizedBox(width: 12),
            Text(t('bulk_permanent_delete_selected_title', langCode)),
          ],
        ),
        content: Text(
          t('bulk_permanent_delete_selected_message', langCode).replaceFirst(
              '{}',
              inactiveSelectedAdmins.length.toString()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', langCode)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: inactiveRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('delete_permanent', langCode)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.post(
          Uri.parse("${AppConfig.apiBase}/api/dashboard-users/bulk-permanent-delete"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(inactiveSelectedAdmins.toList()),
        );

        if (response.statusCode == 200) {
          await fetchAdmins();
          _showSnackBar(
            t('bulk_permanent_delete_selected_success', langCode).replaceFirst(
                '{}',
                inactiveSelectedAdmins.length.toString()
            ),
            successGreen,
          );
          setState(() {
            isMultiSelectMode = false;
            selectedAdmins.clear();
          });
        } else {
          _showSnackBar(t('bulk_permanent_delete_selected_failed', langCode), inactiveRed);
        }
      } catch (e) {
        _showSnackBar(t('bulk_permanent_delete_selected_error', langCode), inactiveRed);
      }
    }
  }

  Future<void> bulkReactivateSelected(String langCode) async {
    if (selectedAdmins.isEmpty) {
      _showSnackBar(t('no_users_selected', langCode), inactiveRed);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: successGreen, size: 28),
            const SizedBox(width: 12),
            Text(t('bulk_reactivate_selected_title', langCode)),
          ],
        ),
        content: Text(
          t('bulk_reactivate_selected_message', langCode).replaceFirst(
              '{}',
              selectedAdmins.length.toString()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', langCode)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: successGreen),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('activate', langCode)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final responses = await Future.wait(
            selectedAdmins.map((id) =>
                http.put(Uri.parse("${AppConfig.apiBase}/api/dashboard-users/$id/activate"))
            )
        );

        final successCount = responses.where((r) => r.statusCode == 200).length;

        await fetchAdmins();
        _showSnackBar(
          t('bulk_reactivate_selected_success', langCode).replaceFirst('{}', successCount.toString()),
          successGreen,
        );
        setState(() {
          isMultiSelectMode = false;
          selectedAdmins.clear();
        });
      } catch (e) {
        _showSnackBar(t('bulk_reactivate_selected_error', langCode), inactiveRed);
      }
    }
  }

  void toggleMultiSelectMode() {
    setState(() {
      isMultiSelectMode = !isMultiSelectMode;
      if (!isMultiSelectMode) {
        selectedAdmins.clear();
      }
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (selectedAdmins.length == filteredAdmins.length) {
        selectedAdmins.clear();
      } else {
        selectedAdmins = filteredAdmins.map((admin) => admin['id'] as int).toSet();
      }
    });
  }

  Future<void> saveAdmin(Map<String, dynamic> admin, {int? id}) async {
    final url = id == null
        ? "${AppConfig.apiBase}/api/dashboard-users"
        : "${AppConfig.apiBase}/api/dashboard-users/$id";

    final request = http.MultipartRequest(
      id == null ? "POST" : "PUT",
      Uri.parse(url),
    );

    request.fields['Email'] = admin['Email']?.toString() ?? "";
    request.fields['FirstName'] = admin['FirstName']?.toString() ?? "";
    request.fields['MiddleName'] = admin['MiddleName']?.toString() ?? "";
    request.fields['LastName'] = admin['LastName']?.toString() ?? "";
    request.fields['Phone'] = admin['Phone']?.toString() ?? "";
    request.fields['Country'] = admin['Country']?.toString() ?? "";
    request.fields['City'] = admin['City']?.toString() ?? "";
    request.fields['Bank'] = admin['Bank']?.toString() ?? "";
    request.fields['Iban'] = admin['Iban']?.toString() ?? "";
    request.fields['Role'] = admin['Role']?.toString() ?? "";
    request.fields['ImagePath'] = admin['ImagePath']?.toString() ?? "";
    request.fields['NotificationHistoryPage'] = admin['NotificationHistoryPage'].toString();
    request.fields['ReportsScreen'] = admin['ReportsScreen'].toString();
    request.fields['SendNotificationPage'] = (admin['SendNotificationPage']).toString();
    request.fields['AdminChatHistoryScreen'] = (admin['AdminChatHistoryScreen']).toString();
    request.fields['AdminLiveChatDashboard'] = (admin['AdminLiveChatDashboard']).toString();
    request.fields['StatsPageTelegram'] = (admin['StatsPageTelegram']).toString();
    request.fields['StatsPage'] = (admin['StatsPage']).toString();
    request.fields['VideoManagerScreen'] = (admin['VideoManagerScreen']).toString();
    request.fields['PaymentManagementSection'] = (admin['PaymentManagementSection']).toString();
    request.fields['ApiDashboardScreen'] = (admin['ApiDashboardScreen']).toString();
    request.fields['WithdrawalsScreen'] = (admin['WithdrawalsScreen']).toString();
    request.fields['SupervisorsMarketersPage'] = (admin['SupervisorsMarketersPage']).toString();
    request.fields['SuggestionsManagementPage'] = (admin['SuggestionsManagementPage']).toString();
    request.fields['ReferralRewardsPage'] = (admin['ReferralRewardsPage']).toString();
    request.fields['SocialAccountsPage'] = (admin['SocialAccountsPage']).toString();
    request.fields['PackagesPage'] = (admin['PackagesPage']).toString();
    request.fields['AdminManagementScreen'] = (admin['AdminManagementScreen']).toString();
    request.fields['PlatformManagementPage'] = (admin['PlatformManagementPage']).toString();
    request.fields['SubscriptionsPage'] = (admin['SubscriptionsPage']).toString();
    request.fields['AdminUsersScreen'] = (admin['AdminUsersScreen']).toString();
    request.fields['UsersPage'] = (admin['UsersPage']).toString();
    request.fields['DashboardStatsSection'] = (admin['DashboardStatsSection']).toString();

    if (id == null) {
      request.fields['Password'] = admin['password'] ?? "123456";
    } else if (admin.containsKey('password') && admin['password'] != null && admin['password'].toString().isNotEmpty) {
      request.fields['Password'] = admin['password'];
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      await fetchAdmins();
    }
  }

  Future<void> deleteAdmin(int id) async {
    await http.delete(Uri.parse("${AppConfig.apiBase}/api/dashboard-users/$id"));
    fetchAdmins();
  }

  Future<void> permanentDeleteAdmin(int id, String langCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(langCode, isPermanent: true),
    );

    if (confirmed == true) {
      await http.delete(Uri.parse("${AppConfig.apiBase}/api/dashboard-users/$id/permanent"));
      fetchAdmins();
      _showSnackBar(t('admin_deleted_permanently', langCode), successGreen);
    }
  }

  final Map<String, Map<String, String>> translations = {
    'admin_management': {'ar': 'إدارة المسؤولين', 'en': 'Admin Management'},
    'search_hint': {'ar': 'ابحث بالاسم أو البريد...', 'en': 'Search by name or email...'},
    'all': {'ar': 'الكل', 'en': 'All'},
    'active': {'ar': 'نشط', 'en': 'Active'},
    'inactive': {'ar': 'غير نشط', 'en': 'Inactive'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'add_admin': {'ar': 'إضافة مسؤول', 'en': 'Add Admin'},
    'edit_admin': {'ar': 'تعديل مسؤول', 'en': 'Edit Admin'},
    'confirm_exit_title': {'ar': 'تأكيد الخروج', 'en': 'Confirm Exit'},
    'confirm_exit_content': {
      'ar': 'يوجد تغييرات غير محفوظة، هل تريد المتابعة؟',
      'en': 'There are unsaved changes, do you want to continue?'
    },
    'required_fields': {'ar': 'يرجى تعبئة الحقول المطلوبة', 'en': 'Please fill required fields'},
    'upload_image': {'ar': 'تحميل صورة', 'en': 'Upload Image'},
    'permissions': {'ar': 'الصلاحيات', 'en': 'Permissions'},
    'first_name': {'ar': 'الاسم الأول', 'en': 'First Name'},
    'middle_name': {'ar': 'الاسم الثاني', 'en': 'Middle Name'},
    'last_name': {'ar': 'الاسم الأخير', 'en': 'Last Name'},
    'phone': {'ar': 'رقم الهاتف', 'en': 'Phone Number'},
    'email': {'ar': 'البريد الإلكتروني', 'en': 'Email'},
    'country': {'ar': 'الدولة', 'en': 'Country'},
    'city': {'ar': 'المدينة', 'en': 'City'},
    'bank': {'ar': 'البنك', 'en': 'Bank'},
    'iban': {'ar': 'رقم الحساب البنكي', 'en': 'IBAN'},
    'role': {'ar': 'الدور', 'en': 'Role'},
    'status': {'ar': 'الحالة', 'en': 'Status'},
    'no_admins': {'ar': 'لا يوجد مسؤولين.', 'en': 'No admins found.'},
    'delete_admin_msg': {'ar': 'تم حذف المسؤول.', 'en': 'Admin deleted.'},
    'admin_deleted_permanently': {'ar': 'تم حذف الحساب نهائياً', 'en': 'Account permanently deleted'},
    'admin_added': {'ar': 'تم إضافة المسؤول بنجاح', 'en': 'Admin added successfully'},
    'admin_updated': {'ar': 'تم تحديث المسؤول بنجاح', 'en': 'Admin updated successfully'},
    'undo': {'ar': 'تراجع', 'en': 'Undo'},
    'role_filter_label': {'ar': 'تصفية الدور', 'en': 'Filter Role'},
    'status_filter_label': {'ar': 'تصفية الحالة', 'en': 'Filter Status'},
    'password': {'ar': 'كلمة المرور', 'en': 'Password'},
    'new_password': {'ar': 'كلمة المرور الجديدة', 'en': 'New Password'},
    'page_permissions': {'ar': 'صلاحيات الصفحات', 'en': 'Page Permissions'},
    'total_admins': {'ar': 'إجمالي المسؤولين', 'en': 'Total Admins'},
    'active_admins': {'ar': 'المسؤولين النشطين', 'en': 'Active Admins'},
    'inactive_admins': {'ar': 'المسؤولين غير النشطين', 'en': 'Inactive Admins'},
    'delete_permanent': {'ar': 'حذف نهائي', 'en': 'Delete Permanently'},
    'confirm_permanent_delete': {'ar': 'تأكيد الحذف النهائي', 'en': 'Confirm Permanent Delete'},
    'permanent_delete_warning': {
      'ar': 'هل أنت متأكد من الحذف النهائي؟ لا يمكن التراجع عن هذا الإجراء!',
      'en': 'Are you sure about permanent deletion? This action cannot be undone!'
    },
    'account_inactive': {'ar': 'الحساب غير نشط', 'en': 'Account Inactive'},
    'basic_info': {'ar': 'المعلومات الأساسية', 'en': 'Basic Information'},
    'financial_info': {'ar': 'المعلومات المالية', 'en': 'Financial Information'},
    'select_all': {'ar': 'تحديد الكل', 'en': 'Select All'},
    'deselect_all': {'ar': 'إلغاء تحديد الكل', 'en': 'Deselect All'},
    'bulk_permanent_delete_title': {'ar': 'حذف نهائي للكل', 'en': 'Bulk Permanent Delete'},
    'bulk_permanent_delete_message': {'ar': 'هل تريد حذف {} مستخدم غير نشط نهائياً؟', 'en': 'Do you want to permanently delete {} inactive users?'},
    'bulk_permanent_delete_success': {'ar': 'تم حذف {} مستخدم نهائياً', 'en': '{} users permanently deleted'},
    'bulk_permanent_delete_failed': {'ar': 'فشل الحذف النهائي', 'en': 'Permanent delete failed'},
    'bulk_permanent_delete_error': {'ar': 'حدث خطأ أثناء الحذف النهائي', 'en': 'Error during permanent delete'},
    'bulk_reactivate_title': {'ar': 'إعادة تنشيط الكل', 'en': 'Bulk Reactivate'},
    'bulk_reactivate_message': {'ar': 'هل تريد إعادة تنشيط {} مستخدم غير نشط؟', 'en': 'Do you want to reactivate {} inactive users?'},
    'bulk_reactivate_success': {'ar': 'تم إعادة تنشيط {} مستخدم', 'en': '{} users reactivated'},
    'bulk_reactivate_error': {'ar': 'حدث خطأ أثناء إعادة التنشيط', 'en': 'Error during reactivation'},
    'bulk_deactivate_title': {'ar': 'إلغاء تنشيط المحددين', 'en': 'Deactivate Selected'},
    'bulk_deactivate_message': {'ar': 'هل تريد إلغاء تنشيط {} مستخدم؟', 'en': 'Do you want to deactivate {} users?'},
    'bulk_deactivate_success': {'ar': 'تم إلغاء تنشيط {} مستخدم', 'en': '{} users deactivated'},
    'bulk_deactivate_failed': {'ar': 'فشل إلغاء التنشيط', 'en': 'Deactivate failed'},
    'bulk_deactivate_error': {'ar': 'حدث خطأ أثناء إلغاء التنشيط', 'en': 'Error during deactivation'},
    'bulk_permanent_delete_selected_title': {'ar': 'حذف نهائي للمحددين', 'en': 'Permanently Delete Selected'},
    'bulk_permanent_delete_selected_message': {'ar': 'هل تريد حذف {} مستخدم غير نشط نهائياً؟', 'en': 'Do you want to permanently delete {} inactive users?'},
    'bulk_permanent_delete_selected_success': {'ar': 'تم حذف {} مستخدم نهائياً', 'en': '{} users permanently deleted'},
    'bulk_permanent_delete_selected_failed': {'ar': 'فشل الحذف النهائي', 'en': 'Permanent delete failed'},
    'bulk_permanent_delete_selected_error': {'ar': 'حدث خطأ أثناء الحذف النهائي', 'en': 'Error during permanent delete'},
    'bulk_reactivate_selected_title': {'ar': 'إعادة تنشيط المحددين', 'en': 'Reactivate Selected'},
    'bulk_reactivate_selected_message': {'ar': 'هل تريد إعادة تنشيط {} مستخدم؟', 'en': 'Do you want to reactivate {} users?'},
    'bulk_reactivate_selected_success': {'ar': 'تم إعادة تنشيط {} مستخدم', 'en': '{} users reactivated'},
    'bulk_reactivate_selected_error': {'ar': 'حدث خطأ أثناء إعادة التنشيط', 'en': 'Error during reactivation'},
    'no_inactive_users': {'ar': 'لا يوجد مستخدمين غير نشطين', 'en': 'No inactive users'},
    'no_users_selected': {'ar': 'لم يتم تحديد أي مستخدمين', 'en': 'No users selected'},
    'no_inactive_selected': {'ar': 'لم يتم تحديد أي مستخدمين غير نشطين', 'en': 'No inactive users selected'},
    'deactivate': {'ar': 'إلغاء التنشيط', 'en': 'Deactivate'},
    'activate': {'ar': 'تنشيط', 'en': 'Activate'},
    'select_users': {'ar': 'تحديد مستخدمين', 'en': 'Select Users'},
    'cancel_selection': {'ar': 'إلغاء التحديد', 'en': 'Cancel Selection'},
    'selected_count': {'ar': 'تم تحديد {}', 'en': '{} selected'},
    'ReportsScreen': {'ar': 'التقارير', 'en': 'Reports'},
  };

  String t(String key, String langCode) {
    return translations[key]?[langCode] ?? key;
  }

  List<Map<String, dynamic>> get filteredAdmins {
    return admins.where((admin) {
      final name = '${admin['firstName']} ${admin['middleName']} ${admin['lastName']}';
      final email = admin['email'].toString();
      final matchesSearch = name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          email.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole = selectedRoleFilter == 'all' || admin['role'] == selectedRoleFilter;
      final matchesStatus = selectedStatusFilter == 'all' ||
          (selectedStatusFilter == 'active' && admin['isActive'] == true) ||
          (selectedStatusFilter == 'inactive' && admin['isActive'] == false);
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDeleteDialog(String langCode, {bool isPermanent = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _getPrimaryColor(isDark);

    return AlertDialog(
      backgroundColor: _getCardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: isPermanent ? inactiveRed : Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isPermanent ? t('confirm_permanent_delete', langCode) : t('confirm_exit_title', langCode),
              style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor(isDark)),
            ),
          ),
        ],
      ),
      content: Text(
        isPermanent ? t('permanent_delete_warning', langCode) : t('confirm_exit_content', langCode),
        style: TextStyle(fontSize: 15, color: _getTextColor(isDark)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t('cancel', langCode)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isPermanent ? inactiveRed : primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(isPermanent ? t('delete_permanent', langCode) : t('save', langCode)),
        ),
      ],
    );
  }

  final newPasswordController = TextEditingController();

  void _addOrEditAdmin({
    Map<String, dynamic>? existingAdmin,
    int? index,
    required String langCode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _getPrimaryColor(isDark);
    final lightColor = _getLightColor(isDark);
    final darkColor = _getDarkColor(isDark);
    final bgColor = _getBgColor(isDark);
    final cardColor = _getCardColor(isDark);
    final textColor = _getTextColor(isDark);

    final isAdding = existingAdmin == null;
    final isAdminRole = UserSession.role == "admin";
    final firstNameController = TextEditingController(text: existingAdmin?['firstName']);
    final middleNameController = TextEditingController(text: existingAdmin?['middleName']);
    final lastNameController = TextEditingController(text: existingAdmin?['lastName']);
    final phoneController = TextEditingController(text: existingAdmin?['phone']);
    final countryController = TextEditingController(text: existingAdmin?['country']);
    final cityController = TextEditingController(text: existingAdmin?['city']);
    final emailController = TextEditingController(text: existingAdmin?['email']);
    final bankController = TextEditingController(text: existingAdmin?['bank']);
    final ibanController = TextEditingController(text: existingAdmin?['iban']);
    Set<String> pagePermissions = {};

    if (existingAdmin != null) {
      for (var page in availablePages) {
        final permissionValue = existingAdmin[page['key']];
        if (permissionValue == 1 ||
            permissionValue == '1' ||
            permissionValue == true ||
            permissionValue == 'true' ||
            permissionValue.toString() == '1' ||
            permissionValue.toString().toLowerCase() == 'true') {
          pagePermissions.add(page['key']!);
        }
      }

      print('Loaded permissions for ${existingAdmin['email']}: $existingAdmin');
    }
    File? selectedImage;
    bool hasUnsavedChanges = false;

    final currentUser = UserSession.getUser();
    final currentUserId = currentUser?['id'];
    final passwordController = TextEditingController();
    final bool isEditingSelf = existingAdmin != null && existingAdmin['id'] == currentUserId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => WillPopScope(
            onWillPop: () async {
              if (hasUnsavedChanges) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => _buildDeleteDialog(langCode),
                ) ?? false;
                return confirm;
              }
              return true;
            },
            child: Directionality(
              textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: bgColor,
                title: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [lightColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        existingAdmin != null ? Icons.edit : Icons.person_add,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          existingAdmin != null ? t('edit_admin', langCode) : t('add_admin', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                content: SizedBox(
                  width: 600,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSectionTitle(t('basic_info', langCode), Icons.info_outline, isDark),
                        const SizedBox(height: 12),
                        _buildModernField(firstNameController, t('first_name', langCode), Icons.person, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(middleNameController, t('middle_name', langCode), Icons.person_outline, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(lastNameController, t('last_name', langCode), Icons.person, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(phoneController, t('phone', langCode), Icons.phone, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(emailController, t('email', langCode), Icons.email, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(countryController, t('country', langCode), Icons.public, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(cityController, t('city', langCode), Icons.location_city, setModalState, isDark, readOnly: !isAdminRole),

                        _buildModernField(
                          passwordController,
                          t('new_password', langCode),
                          Icons.lock_reset,
                          setModalState,
                          isDark,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(t('financial_info', langCode), Icons.account_balance, isDark),
                        const SizedBox(height: 12),
                        _buildModernField(bankController, t('bank', langCode), Icons.account_balance, setModalState, isDark, readOnly: !isAdminRole),
                        _buildModernField(ibanController, t('iban', langCode), Icons.credit_card, setModalState, isDark, readOnly: !isAdminRole),

                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null && result.files.single.path != null) {
                                setModalState(() {
                                  selectedImage = File(result.files.single.path!);
                                  hasUnsavedChanges = true;
                                });
                              }
                            },
                            icon: const Icon(Icons.cloud_upload),
                            label: Text(t('upload_image', langCode)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getAccentColor(isDark),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                          ),
                        ),

                        if (selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(selectedImage!, height: 120, width: 120, fit: BoxFit.cover),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                        _buildSectionTitle(t('page_permissions', langCode), Icons.admin_panel_settings, isDark),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isAdminRole
                                    ? () {
                                  setModalState(() {
                                    pagePermissions = availablePages.map((p) => p['key']!).toSet();
                                    hasUnsavedChanges = true;
                                  });
                                }
                                    : null,
                                icon: const Icon(Icons.done_all),
                                label: Text(t('select_all', langCode)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: primaryColor),
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isAdminRole
                                    ? () {
                                  setModalState(() {
                                    pagePermissions.clear();
                                    hasUnsavedChanges = true;
                                  });
                                }
                                    : null,
                                icon: const Icon(Icons.clear_all),
                                label: Text(t('deselect_all', langCode)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: inactiveRed),
                                  foregroundColor: inactiveRed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: lightColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: availablePages.map((page) {
                              final isChecked = pagePermissions.contains(page['key']);
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    langCode == 'ar' ? page['ar']! : page['en']!,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  value: isChecked,
                                  activeColor: primaryColor,
                                  checkColor: Colors.white,
                                  onChanged: !isAdminRole
                                      ? null
                                      : (val) {
                                    setModalState(() {
                                      if (val == true) {
                                        pagePermissions.add(page['key']!);
                                      } else {
                                        pagePermissions.remove(page['key']!);
                                      }
                                      hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(t('cancel', langCode)),
                  ),
                  if (isAdminRole)
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (firstNameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                          _showSnackBar(t('required_fields', langCode), inactiveRed);
                          return;
                        }

                        final newAdmin = {
                          'Email': emailController.text.trim(),
                          'FirstName': firstNameController.text.trim(),
                          'MiddleName': middleNameController.text.trim(),
                          'LastName': lastNameController.text.trim(),
                          'Phone': phoneController.text.trim(),
                          'Country': countryController.text.trim(),
                          'City': cityController.text.trim(),
                          'Bank': bankController.text.trim(),
                          'Iban': ibanController.text.trim(),
                          'Role': "user",
                          'ImagePath': selectedImage != null ? selectedImage!.path : "",
                        };

                        for (var page in availablePages) {
                          final hasPermission = pagePermissions.contains(page['key']!);
                          newAdmin[page['key']!] = hasPermission.toString();
                        }

                        if (existingAdmin == null) {
                          newAdmin['password'] = passwordController.text.trim().isEmpty
                              ? "123456"
                              : passwordController.text.trim();
                        } else if (passwordController.text.trim().isNotEmpty) {
                          newAdmin['password'] = passwordController.text.trim();
                        }

                        await saveAdmin(newAdmin, id: existingAdmin?['id']);
                        if (isEditingSelf) {
                          final refreshUrl = Uri.parse("${AppConfig.apiBase}/api/dashboard-users/oneUser/${currentUserId}");
                          final refreshRes = await http.get(refreshUrl);
                          if (refreshRes.statusCode == 200) {
                            final freshData = jsonDecode(refreshRes.body);
                            Map<String, bool> pageAccess = {};
                            for (var page in availablePages) {
                              pageAccess[page['key']!] = freshData[page['key']!.toLowerCase()] == 1;
                            }
                            final updatedSessionUser = {
                              'id': freshData['id'],
                              'email': freshData['email'],
                              'fullName': freshData['full_name'],
                              'role': freshData['role'],
                              'pagePermissions': pageAccess,
                            };
                            UserSession.saveUser(updatedSessionUser);
                          }
                        }

                        if (mounted) Navigator.pop(context);
                        _showSnackBar(
                          existingAdmin == null ? t('admin_added', langCode) : t('admin_updated', langCode),
                          successGreen,
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: Text(t('save', langCode)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    final lightColor = _getLightColor(isDark);
    final darkColor = _getDarkColor(isDark);
    final textColor = _getTextColor(isDark);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: darkColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildModernField(
      TextEditingController controller,
      String label,
      IconData icon,
      void Function(void Function()) setModalState,
      bool isDark, {
        bool readOnly = false,
        bool obscureText = false,
      }) {
    final primaryColor = _getPrimaryColor(isDark);
    final lightColor = _getLightColor(isDark);
    final cardColor = _getCardColor(isDark);
    final textColor = _getTextColor(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscureText,
        style: TextStyle(color: textColor, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          filled: true,
          fillColor: cardColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (_) => setModalState(() {}),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAdmins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final isArabic = langCode == 'ar';

    final primaryColor = _getPrimaryColor(isDark);
    final lightColor = _getLightColor(isDark);
    final accentColor = _getAccentColor(isDark);
    final bgColor = _getBgColor(isDark);
    final cardColor = _getCardColor(isDark);
    final textColor = _getTextColor(isDark);

    final totalAdmins = admins.length;
    final activeAdmins = admins.where((a) => a['isActive'] == true).length;
    final inactiveAdmins = admins.where((a) => a['isActive'] == false).length;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,

        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isMultiSelectMode && selectedAdmins.isNotEmpty)
              Column(
                children: [
                  FloatingActionButton.extended(
                    onPressed:()=> bulkDeactivateSelected(isArabic ? "ar":"en"),
                    backgroundColor: Colors.orange,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: Text(
                      t('deactivate', langCode),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    elevation: 4,
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.extended(
                    onPressed: ()=>bulkReactivateSelected(isArabic ? "ar":"en"),
                    backgroundColor: successGreen,
                    icon: const Icon(Icons.restore, color: Colors.white),
                    label: Text(
                      t('activate', langCode),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    elevation: 4,
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.extended(
                    onPressed: ()=>bulkPermanentDeleteSelected(isArabic ? "ar":"en"),
                    backgroundColor: inactiveRed,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: Text(
                      t('delete_permanent', langCode),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    elevation: 4,
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (!isMultiSelectMode)
              FloatingActionButton.extended(
                onPressed: () => _addOrEditAdmin(langCode: langCode),
                backgroundColor: successGreen,
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: Text(
                  t('add_admin', langCode),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                elevation: 4,
              ),
          ],
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header Card with Stats
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, lightColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Statistics Cards
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              t('total_admins', langCode),
                              totalAdmins.toString(),
                              Icons.people,
                              Colors.blue,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              t('active_admins', langCode),
                              activeAdmins.toString(),
                              Icons.check_circle,
                              successGreen,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              t('inactive_admins', langCode),
                              inactiveAdmins.toString(),
                              Icons.cancel,
                              inactiveRed,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search and Filters Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          // Search Box
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: t('search_hint', langCode),
                                hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                prefixIcon: Icon(Icons.search, color: primaryColor, size: 24),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              onChanged: (val) => setState(() => searchQuery = val),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Filter Dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedRoleFilter,
                                      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                      dropdownColor: cardColor,
                                      items: [
                                        'all',
                                        ...admins.map((e) => e['role'].toString()).toSet(),
                                      ].map((role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(
                                          role == 'all' ? t('all', langCode) : role,
                                          style: TextStyle(color: textColor, fontSize: 14),
                                        ),
                                      )).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => selectedRoleFilter = val);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedStatusFilter,
                                      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                      dropdownColor: cardColor,
                                      items: ['all', 'active', 'inactive'].map((status) {
                                        return DropdownMenuItem<String>(
                                          value: status,
                                          child: Row(
                                            children: [
                                              Icon(
                                                status == 'active'
                                                    ? Icons.check_circle
                                                    : status == 'inactive'
                                                    ? Icons.cancel
                                                    : Icons.filter_list,
                                                color: status == 'active'
                                                    ? successGreen
                                                    : status == 'inactive'
                                                    ? inactiveRed
                                                    : primaryColor,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                t(status, langCode),
                                                style: TextStyle(color: textColor, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => selectedStatusFilter = val);
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
                  ],
                ),
              ),
            ),

            // Select All Bar (in multi-select mode)
            if (isMultiSelectMode && filteredAdmins.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: lightColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lightColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: toggleMultiSelectMode,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isMultiSelectMode ? Icons.cancel : Icons.checklist,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: toggleSelectAll,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            selectedAdmins.length == filteredAdmins.length
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedAdmins.length == filteredAdmins.length
                              ? t('deselect_all', langCode)
                              : t('select_all', langCode),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${selectedAdmins.length}/${filteredAdmins.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Admins List
            filteredAdmins.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      t('no_admins', langCode),
                      style: TextStyle(fontSize: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final admin = filteredAdmins[index];
                    final fullName = '${admin['firstName']} ${admin['middleName']} ${admin['lastName']}';
                    final isActive = admin['isActive'] == true;
                    final isSelected = selectedAdmins.contains(admin['id']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [accentColor.withOpacity(0.3), accentColor.withOpacity(0.1)]
                              : isActive
                              ? [cardColor, cardColor]
                              : [Colors.red.shade50, Colors.red.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? accentColor.withOpacity(0.2)
                                : isActive
                                ? primaryColor.withOpacity(0.1)
                                : inactiveRed.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? accentColor
                              : isActive
                              ? lightColor.withOpacity(0.3)
                              : inactiveRed.withOpacity(0.3),
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: isMultiSelectMode
                              ? () {
                            setState(() {
                              if (selectedAdmins.contains(admin['id'])) {
                                selectedAdmins.remove(admin['id']);
                              } else {
                                selectedAdmins.add(admin['id']);
                              }
                            });
                          }
                              : () => _addOrEditAdmin(
                            existingAdmin: admin,
                            index: admins.indexOf(admin),
                            langCode: langCode,
                          ),
                          onLongPress: () {
                            if (!isMultiSelectMode) {
                              setState(() {
                                isMultiSelectMode = true;
                                selectedAdmins.add(admin['id']);
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                if (isMultiSelectMode)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12, right: 12),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? primaryColor : cardColor,
                                        border: Border.all(
                                          color: isSelected ? primaryColor : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isActive ? primaryColor : inactiveRed,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundColor: lightColor.withOpacity(0.2),
                                        backgroundImage: admin['profileImagePath'] != null
                                            ? FileImage(File(admin['profileImagePath']))
                                            : null,
                                        child: admin['profileImagePath'] == null
                                            ? Text(
                                          fullName[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        )
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isActive ? successGreen : inactiveRed,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: Icon(
                                          isActive ? Icons.check : Icons.close,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                              fullName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isSelected ? primaryColor : textColor,
                                              ),
                                            ),
                                          ),
                                          if (!isActive)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: inactiveRed.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                t('account_inactive', langCode),
                                                style: const TextStyle(
                                                  color: inactiveRed,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      _buildInfoRow(Icons.email, admin['email'], primaryColor, isDark),
                                      const SizedBox(height: 4),
                                      _buildInfoRow(Icons.phone, admin['phone'], accentColor, isDark),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoRow(
                                              Icons.account_balance,
                                              '${admin['bank']}',
                                              _getDarkColor(isDark),
                                              isDark,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: lightColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.shield, size: 14, color: primaryColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  admin['role'],
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isMultiSelectMode)
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: primaryColor,
                                        iconSize: 22,
                                        onPressed: () => _addOrEditAdmin(
                                          existingAdmin: admin,
                                          index: admins.indexOf(admin),
                                          langCode: langCode,
                                        ),
                                        tooltip: t('edit_admin', langCode),
                                      ),
                                      if (!isActive)
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever),
                                          color: inactiveRed,
                                          iconSize: 22,
                                          onPressed: () => permanentDeleteAdmin(admin['id'], langCode),
                                          tooltip: t('delete_permanent', langCode),
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          color: Colors.orange.shade700,
                                          iconSize: 22,
                                          onPressed: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => _buildDeleteDialog(langCode),
                                            );
                                            if (confirmed == true) {
                                              await deleteAdmin(admin['id']);
                                              _showSnackBar(t('delete_admin_msg', langCode), Colors.orange);
                                            }
                                          },
                                          tooltip: t('delete_admin_msg', langCode),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredAdmins.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    final cardColor = _getCardColor(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}