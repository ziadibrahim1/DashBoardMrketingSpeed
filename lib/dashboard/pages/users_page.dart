import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/UserModel.dart';
import '../../core/app_config.dart';
import 'UserDetailsPage.dart';

// ------------------------------------
// 🎨 تحسين الثوابت والألوان
// ------------------------------------
const Color primaryColor = Color(0xFF4CAF50); // أخضر/أزرق حيوي للتركيز
const Color accentColor = Color(0xFF2196F3); // لون ثانوي للخيارات
const Color darkBgColor = Color(0xFF1E272C); // خلفية غامقة أنيقة
const Color darkCardColor = Color(0xFF2C3E50); // لون البطاقة في الوضع الداكن

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // ... (نفس المتغيرات)
  String selectedStatusFilter = 'all';
  String selectedSubscriptionFilter = 'all';
  String searchQuery = '';
  int currentPage = 0;
  final int usersPerPage = 20;

  List<UserModel> allUsers = [];
  bool isLoading = false;
  // ----------------------------

  // ----------------------------
  // 🔥 تحميل كل المستخدمين (نفسها)
  // ----------------------------
  Future<void> loadUsers() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${AppConfig.apiBase}/api/users/all");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
print(data.toString());
        setState(() {
          allUsers = List<UserModel>.from(
            data.map((u) => UserModel.fromJson(u)),
          );
        });
      }
    } catch (e) {
      print("❌ Error loading users: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // ------------------------------------
  // 🔨 عنصر قائمة منسدلة محسن (Filter Dropdown)
  // ------------------------------------
  Widget _buildFilterDropdown({
    required String title,
    required String value,
    required Map<String, String> items,
    required void Function(String) onChanged,
    required bool isDark, // ممرر جديد
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // حواف مدورة أكثر
            color: isDark ? darkCardColor : Colors.white,
            border: Border.all(
              color: isDark ? darkCardColor : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade200)
                    .withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down,
                  color: isDark ? primaryColor : accentColor),
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87, fontSize: 14),
              dropdownColor: isDark ? darkCardColor : Colors.white,
              items: items.entries
                  .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                  )))
                  .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------
  // 🏷 شارة الحالة محسنة (Status Badge)
  // ------------------------------------
  Widget _statusBadge(String status, bool isArabic) {
    final isActive = status == 'active';
    final color = isActive ? primaryColor : Colors.orange.shade700;
    final bgColor = isActive ? primaryColor.withOpacity(0.15) : Colors.orange.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16), // حواف مدورة
      ),
      child: Text(
        isActive
            ? (isArabic ? '✅ فعال' : '✅ Active')
            : (isArabic ? '⚠️ غير فعال' : '⚠️ Inactive'),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ------------------------------------
  // 👑 شارة الاشتراك محسنة (Subscription Badge)
  // ------------------------------------
  Widget _subscriptionBadge(bool activeNow, bool isArabic) {
    final color = activeNow ? primaryColor : Colors.red.shade700;
    final bgColor = activeNow ? primaryColor.withOpacity(0.15) : Colors.red.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        activeNow
            ? (isArabic ? '🌟 مشترك' : '🌟 Active Sub')
            : (isArabic ? '❌ منتهي' : '❌ Expired'),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ------------------------------------
  // ⚙ أزرار الخيارات محسنة (Options Buttons)
  // ------------------------------------
  Widget _optionsButtons(UserModel user, bool isDark) {
    final isActive = user.status == 'active';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: isActive
              ? (Localizations.localeOf(context).languageCode == 'ar'
              ? 'تعطيل المستخدم'
              : 'Deactivate User')
              : (Localizations.localeOf(context).languageCode == 'ar'
              ? 'تفعيل المستخدم'
              : 'Activate User'),
          child: InkWell(
            onTap: () async {
              // ... (نفس منطق التبديل)
              final url = Uri.parse(
                  "${AppConfig.apiBase}/api/users/toggle-status/${user.id}");
              final res = await http.put(url);

              if (res.statusCode == 200) {
                final newStatus = jsonDecode(res.body)['status'];
                setState(() => user.status = newStatus);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.orange.shade100 : primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? Icons.block : Icons.check_circle_outline,
                color: isActive ? Colors.orange.shade700 : primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: Localizations.localeOf(context).languageCode == 'ar'
              ? 'تفاصيل المستخدم'
              : 'User Details',
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailsPage(user: user),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: accentColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------
  // 📊 جدول البيانات المحسن (DataTable)
  // ------------------------------------
  Widget _buildDataTable(
      bool isDark, bool isArabic, List<UserModel> paginatedUsers) {
    // ----------------------------
    // شاشة التحميل (Loading Indicator)
    // ----------------------------
    if (isLoading && allUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }
    // ----------------------------
    // لا يوجد بيانات (No Data)
    // ----------------------------
    if (paginatedUsers.isEmpty && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  size: 60, color: isDark ? Colors.white54 : Colors.grey),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'لا توجد نتائج مطابقة'
                    : 'No matching users found',
                style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'حاول تغيير الفلاتر أو البحث.' : 'Try changing filters or search query.',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------
    // الجدول الفعلي
    // ----------------------------
    return DataTable(
      // تصميم أفضل للجدول
      columnSpacing: 20,
      headingRowHeight: 56,
      dataRowHeight: 64,
      horizontalMargin: 20,
      dividerThickness: isDark ? 0.3 : 1,
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? darkCardColor : Colors.white, // خلفية موحدة
        borderRadius: BorderRadius.circular(12),
      ),
      columns: [
        DataColumn(label: Text(isArabic ? 'الاسم' : 'Name')),
        DataColumn(label: Text(isArabic ? 'البريد' : 'Email')),
        DataColumn(label: Text(isArabic ? 'الحالة' : 'Status')),
        DataColumn(label: Text(isArabic ? 'جروبات' : 'Groups')),
        DataColumn(label: Text(isArabic ? 'متبقي' : 'Days Left')),
        DataColumn(label: Text(isArabic ? 'اشتراكات' : 'Sub Count')),
        DataColumn(label: Text(isArabic ? 'الانضمام' : 'Joined')),
        DataColumn(label: Text(isArabic ? 'مشترك الآن؟' : 'Active Sub')),
        DataColumn(label: Text(isArabic ?"الرسائل":"Total Msg")),
        DataColumn(label: Text(isArabic ?"هذا الشهر":"This Month")),
        DataColumn(label: Text(isArabic ? 'خيارات' : 'Options')),


      ],
      rows: paginatedUsers.map((user) {
        return DataRow(
          cells: [
            DataCell(Text(user.name)),
            DataCell(Text(user.email)),
            DataCell(_statusBadge(user.status, isArabic)), // استخدام المحسّن
            DataCell(Text("${user.groups}")),
            DataCell(Text("${user.subscriptionDaysLeft}")),
            DataCell(Text("${user.subscriptionCount}")),
            DataCell(Text("${user.joinedAt.toString().split(' ')[0]}")),
            DataCell(_subscriptionBadge(user.isSubscribedNow, isArabic)),
            DataCell(Text("${user.totalMessages}")),
            DataCell(Text("${user.messagesThisMonth}")),
            DataCell(_optionsButtons(user, isDark)), // استخدام المحسّن
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------
    // تهيئة البيانات والفلاتر (نفسها)
    // ------------------------------------
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    List<UserModel> filteredUsers = allUsers.where((user) {

      final matchesStatus =
          selectedStatusFilter == 'all' || user.status == selectedStatusFilter;

      final matchesSubscription = selectedSubscriptionFilter == 'all' ||
          (selectedSubscriptionFilter == 'activeOnly' &&
              user.subscriptionDaysLeft > 0) ||
          (selectedSubscriptionFilter == 'expiredOnly' &&
              user.subscriptionDaysLeft <= 0);

      final matchesSearch =
      user.name.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesStatus && matchesSubscription && matchesSearch;
    }).toList();

    final totalPages = (filteredUsers.length / usersPerPage).ceil();
    final paginatedUsers =
    filteredUsers.skip(currentPage * usersPerPage).take(usersPerPage).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900; // شاشات صغيرة
        final isTinyScreen = constraints.maxWidth < 600; // موبايل

        // ------------------------------------
        // تخطيط الصفحة (Main Layout)
        // ------------------------------------
        return Padding(
          padding: EdgeInsets.all(isTinyScreen ? 16 : 32), // تباعد أكبر
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              //  عنوان الصفحة محسّن
              // -------------------------
              Row(
                children: [
                  Icon(Icons.supervised_user_circle_rounded, // أيقونة أفضل
                      size: isTinyScreen ? 28 : 36,
                      color: primaryColor), // استخدام اللون الرئيسي
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      isArabic ? 'لوحة إدارة المستخدمين' : 'User Management Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: isTinyScreen ? 22 : 30, // حجم أكبر
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // زر تحديث
                  IconButton(
                    icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.grey.shade700, size: 28),
                    onPressed: isLoading ? null : loadUsers,
                    tooltip: isArabic ? 'تحديث القائمة' : 'Refresh List',
                  ),
                ],
              ),

              const SizedBox(height: 30), // تباعد أكبر

              // -------------------------
              //  فلاتر البحث (Responsive) محسّنة
              // -------------------------
              isSmallScreen
                  ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          title: isArabic ? 'حالة المستخدم' : 'User Status',
                          value: selectedStatusFilter,
                          isDark: isDark,
                          items: {
                            'all': isArabic ? 'الكل (الحالة)' : 'All Statuses',
                            'active': isArabic ? 'فعال' : 'Active',
                            'inactive': isArabic ? 'غير فعال' : 'Inactive',
                          },
                          onChanged: (v) {
                            setState(() {
                              selectedStatusFilter = v;
                              currentPage = 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFilterDropdown(
                          title: isArabic ? 'حالة الاشتراك' : 'Subscription Status',
                          value: selectedSubscriptionFilter,
                          isDark: isDark,
                          items: {
                            'all': isArabic ? 'الكل (اشتراك)' : 'All Subscriptions',
                            'activeOnly': isArabic ? 'مشترك حالياً' : 'Active Only',
                            'expiredOnly': isArabic ? 'منتهي' : 'Expired Only',
                          },
                          onChanged: (v) {
                            setState(() {
                              selectedSubscriptionFilter = v;
                              currentPage = 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(isDark, isArabic), // استخدام حقل البحث المحسّن
                ],
              )
                  : Row(
                children: [
                  _buildFilterDropdown(
                    title: isArabic ? 'حالة المستخدم' : 'User Status',
                    value: selectedStatusFilter,
                    isDark: isDark,
                    items: {
                      'all': isArabic ? 'الكل (الحالة)' : 'All Statuses',
                      'active': isArabic ? 'فعال' : 'Active',
                      'inactive': isArabic ? 'غير فعال' : 'Inactive',
                    },
                    onChanged: (v) {
                      setState(() {
                        selectedStatusFilter = v;
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildFilterDropdown(
                    title: isArabic ? 'حالة الاشتراك' : 'Subscription Status',
                    value: selectedSubscriptionFilter,
                    isDark: isDark,
                    items: {
                      'all': isArabic ? 'الكل (اشتراك)' : 'All Subscriptions',
                      'activeOnly': isArabic ? 'مشترك حالياً' : 'Active Only',
                      'expiredOnly': isArabic ? 'منتهي' : 'Expired Only',
                    },
                    onChanged: (v) {
                      setState(() {
                        selectedSubscriptionFilter = v;
                        currentPage = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _buildSearchField(isDark, isArabic)), // استخدام حقل البحث المحسّن
                ],
              ),

              const SizedBox(height: 30), // تباعد أكبر

              // -------------------------
              //  الجدول + شاشة التحميل
              // -------------------------
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? darkCardColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey.shade300)
                            .withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading && allUsers.isEmpty
                      ? const Center(
                      child: CircularProgressIndicator(color: primaryColor))
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: constraints.maxWidth < 1100
                              ? 1100
                              : constraints.maxWidth - 64), // -64 للـ Padding
                      child: SingleChildScrollView(
                        child:
                        _buildDataTable(isDark, isArabic, paginatedUsers),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------
              // Pagination محسّن
              // -------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isArabic
                        ? 'عرض ${currentPage * usersPerPage + 1}-${(currentPage + 1) * usersPerPage < filteredUsers.length ? (currentPage + 1) * usersPerPage : filteredUsers.length} من ${filteredUsers.length}'
                        : 'Showing ${currentPage * usersPerPage + 1}-${(currentPage + 1) * usersPerPage < filteredUsers.length ? (currentPage + 1) * usersPerPage : filteredUsers.length} of ${filteredUsers.length}',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isDark ? darkCardColor : Colors.grey.shade300),
                      color: isDark ? darkCardColor : Colors.white,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_rounded,
                              size: 18, color: currentPage > 0 ? accentColor : Colors.grey),
                          onPressed: currentPage > 0
                              ? () => setState(() => currentPage--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${currentPage + 1} / $totalPages",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: currentPage < totalPages - 1 ? accentColor : Colors.grey),
                          onPressed: currentPage < totalPages - 1
                              ? () => setState(() => currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------
  // 🔍 حقل البحث المحسّن (Search Field)
  // ------------------------------------
  Widget _buildSearchField(bool isDark, bool isArabic) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? darkCardColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // حواف مدورة
          borderSide: BorderSide.none, // إزالة الحدود الصلبة
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? darkCardColor : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2), // التركيز باللون الرئيسي
        ),
        labelText: isArabic ? '🔍 البحث بالاسم...' : '🔍 Search by name...',
        labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade600),
        suffixIcon: Icon(Icons.search,
            color: isDark ? Colors.white70 : Colors.grey.shade600),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      onChanged: (v) {
        setState(() {
          searchQuery = v;
          currentPage = 0;
        });
      },
    );
  }
}