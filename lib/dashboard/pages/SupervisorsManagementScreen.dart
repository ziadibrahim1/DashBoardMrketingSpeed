import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../Models/Marketer.dart';
import '../../core/DashboardUserService.dart';
import '../../core/HierarchyService.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import '../../core/web_session.dart';
import '../../providers/app_providers.dart';
import 'SimpleSupervisorDialog.dart';
import 'login_screen.dart';

class SupervisorsMarketersPage extends StatefulWidget {
  const SupervisorsMarketersPage({Key? key}) : super(key: key);

  @override
  State<SupervisorsMarketersPage> createState() =>
      _SupervisorsMarketersPageState();
}

class _SupervisorsMarketersPageState extends State<SupervisorsMarketersPage> {
  List<Supervisor> supervisors = [];
  Supervisor? selectedSupervisor;
  User? selectedUser;
  bool showEditPanel = false;
  User? editingUser;
  bool isEditingSupervisor = false;
  bool isAdding = false;
  bool isAdminEd = false;
  late Future<void> _loadFuture;
  final hierarchyService = HierarchyService(AppConfig.baseUrl);
  String currentRole = '';
  late bool addSuper;
  bool addMarketer = false;
  bool isSupervisorCollapsed = true;
  late bool isArabic;
  late bool isDark;

  // دالة للحصول على الألوان بناءً على الوضع
  Map<String, Color> _getColors(bool isDark) {
    if (isDark) {
      // ألوان خضراء للوضع الداكن
      return {
        'primary': const Color(0xFF388E3C),
        'secondary': const Color(0xFF4CAF50),
        'light': const Color(0xFF81C784),
        'background': const Color(0xFF0F172A),
        'sidebar': const Color(0xFF1E293B),
        'card': const Color(0xFF1E293B),
        'text': const Color(0xFFD7EFDC),
        'button': const Color(0xFF2E7D32),
      };
    } else {
      // ألوان زرقاء للوضع الفاتح
      return {
        'primary': const Color(0xFF1E40AF),
        'secondary': const Color(0xFF3B82F6),
        'light': const Color(0xFF60A5FA),
        'background': const Color(0xFFF8FAFC),
        'sidebar': Colors.white,
        'card': Colors.white,
        'text': Colors.blue.shade900,
        'button': Colors.blue.shade700,
      };
    }
  }

  Future<void> _loadData() async {
    final currentUser = await UserSession.getUser();
    if (currentUser == null) return;
    currentRole = currentUser['role'];

    final int dashboardUserId = currentUser['id'];

    final result =
    await hierarchyService.fetchSupervisorsTree(dashboardUserId, currentRole);

    setState(() {
      supervisors = result;
      if (supervisors.isNotEmpty) {
        selectedSupervisor = supervisors.first;
        selectedUser = selectedSupervisor;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  String tr(String ar, String en) => isArabic ? ar : en;

  void selectSupervisor(Supervisor sup) {
    setState(() {
      selectedSupervisor = sup;
      selectedUser = sup;
      editingUser = null;
      showEditPanel = false;
    });
  }

  void selectMarketer(Marketer marketer) {
    setState(() {
      selectedUser = marketer;
      editingUser = null;
      showEditPanel = false;
    });
  }

  Future<void> _reloadPage() async {
    setState(() {
      _loadFuture = _loadData();
      selectedUser = null;
      selectedSupervisor = null;
      showEditPanel = false;
      editingUser = null;
    });
  }

  void openAddEdit(
      bool isAddMarketer,
      bool isAddSupervisor, {
        User? user,
        required bool supervisor,
      }) {
    setState(() {
      isAdminEd = currentRole == 'admin';
      addSuper = isAddSupervisor;
      addMarketer = isAddMarketer;
      editingUser = user;
      isEditingSupervisor = supervisor;
      isAdding = user == null;
      showEditPanel = true;
    });
  }

  void closeAddEdit() {
    setState(() {
      editingUser = null;
      showEditPanel = false;
    });
  }

  String generateReviewLink() {
    final random = Random();
    final randomStr =
    List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join();
    return 'http://review.link/$randomStr';
  }

  void showSupervisorOptions(Supervisor sup) {
    if (currentRole != 'admin') return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr('تعديل', 'Edit')),
              onTap: () {
                Navigator.pop(context);
                openAddEdit(true, false, user: sup, supervisor: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(tr('حذف', 'Delete')),
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirmation(sup, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  void onSaveUser(User newUser) async {
    final service = DashboardUserService(baseUrl: AppConfig.baseUrl);
    final bool isEdit = editingUser != null;

    try {
      Map<String, dynamic> result;
      print(' super data $newUser');
      // ================= SUPERVISOR =================
      if (newUser is Supervisor) {
        if (isEdit) {
          // -------- تعديل مشرف --------
          result = await service.updateSupervisor(
            supervisorId: newUser.id,
            body: {
              'FullName': '${newUser.firstName} ${newUser.lastName}',
              'Email': newUser.email,
              'Phone': newUser.phone,
              'Country': newUser.country,
              'City': newUser.city,
              'Age': newUser.age,
              'Bank': newUser.bank,
              'AccountNumber': newUser.accountNumber,
              'Role': "Supervisor",
              'isActive': newUser.status == UserStatus.active,
              'Password': newUser.password,
              'PointPrice': newUser.pointPrice,
              'AmountDue': newUser.totalDueAmount,
            },
          );
        } else {
          // -------- إضافة مشرف --------
          result = await service.createSupervisor(
            fullName: '${newUser.firstName} ${newUser.lastName}',
            email: newUser.email,
            phone: newUser.phone,
            password: newUser.password,
            Role: "Supervisor",
            Country: newUser.country,
            City: newUser.city,
            Age: newUser.age!,
            Bank: newUser.bank,
            AccountNumber: newUser.accountNumber,
            AmountDue: newUser.totalDueAmount,
            PointPrice: newUser.pointPrice,
            isWithdrawalPending: false,
          );
        }
      }

      // ================= MARKETER =================
      else if (newUser is Marketer) {
        final supervisorId = selectedSupervisor?.id;

        if (supervisorId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("يرجى اختيار مشرف")),
          );
          return;
        }

        if (isEdit) {
          // -------- تعديل مسوق --------
          result = await service.updateMarketer(
            marketerId: newUser.id,
            body: {
              'FullName': '${newUser.firstName} ${newUser.lastName}',
              'Email': newUser.email,
              'Phone': newUser.phone,
              'Country': newUser.country,
              'City': newUser.city,
              'Age': newUser.age,
              'Bank': newUser.bank,
              'AccountNumber': newUser.accountNumber,
              'PointPrice': newUser.pointPrice,
              'TotalDueAmount': newUser.totalDueAmount,
              'PointsAccumulated': newUser.points,
              'Password': newUser.password,
              'SupervisorId': supervisorId,
            },
          );
        } else {
          // -------- إضافة مسوق --------
          result = await service.createMarketer(
            fullName: '${newUser.firstName} ${newUser.lastName}',
            email: newUser.email,
            phone: newUser.phone,
            password: newUser.password,
            supervisorId: supervisorId,
            Country: newUser.country,
            City: newUser.city,
            Age: newUser.age!,
            Bank: newUser.bank,
            AccountNumber: newUser.accountNumber,
            PointPrice: newUser.pointPrice,
            TotalDueAmount: newUser.totalDueAmount,
            PointsAccumulated: newUser.points,
          );
        }
      } else {
        return;
      }

      // ================= UI UPDATE =================
      if (result['success'] == true) {
        final res = await http.post(
          Uri.parse('${AppConfig.baseUrl}admin/user/send-credentials'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': result['userEmail'],
            'promoCode': result['promoCode'],
            'password': result['userPassword'],
          }),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  result['message'] ?? tr('تم الحفظ بنجاح', 'Saved successfully'))),
        );

        await _reloadPage(); // 🔥 إعادة تحميل كاملة
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ:  ')),
      );
    }
  }

  void showMarketerOptions(Marketer marketer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr('تعديل', 'Edit')),
              onTap: () {
                Navigator.pop(context);
                openAddEdit(false, false, user: marketer, supervisor: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(tr('حذف', 'Delete')),
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirmation(marketer, isDark);
              },
            ),
            ListTile(
              leading: Icon(marketer.status == UserStatus.active
                  ? Icons.pause
                  : Icons.play_arrow),
              title: Text(marketer.status == UserStatus.active
                  ? tr('تجميد', 'Freeze')
                  : tr('تفعيل', 'Activate')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  marketer.status = marketer.status == UserStatus.active
                      ? UserStatus.frozen
                      : UserStatus.active;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    UserSession.clear();
    WebSession.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد تسجيل الخروج"),
        content: const Text(
          "هل أنت متأكد من تسجيل الخروج؟\nلن تتمكن من الرجوع إلا بعد تسجيل الدخول مرة أخرى.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String getSupervisorStats(Supervisor sup) {
    int totalPoints = sup.marketers.fold(0, (p, m) => p + m.points);
    double totalDue = sup.marketers.fold(0.0, (p, m) => p + m.totalDueAmount);
    return '${tr('عدد المسوقين', 'Marketers')}: ${sup.marketers.length}             '
        '${tr('إجمالي النقاط', 'Total Points')}: $totalPoints  ';
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    isArabic = localeProvider.locale.languageCode == 'ar';
    isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors['background']!,
        body: FutureBuilder(
          future: _loadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors['primary']!,
                  ),
                ),
              );
            }

            return Row(
              children: [
                // --- القائمة الجانبية (Sidebar) ---
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: colors['sidebar']!,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(4, 0),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // رأس القائمة الجانبية
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tr('المشرفين', 'Supervisors'),
                              style: TextStyle(
                                color: colors['text'],
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                            if (currentRole == 'admin')
                              _buildIconButton(
                                icon: Icons.person_add_alt_1_rounded,
                                onPressed: () => openAddEdit(
                                    false, true, user: null, supervisor: true),
                              ),
                          ],
                        ),
                      ),
                      const Divider(indent: 20, endIndent: 20),

                      // قائمة المشرفين
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: supervisors.length,
                          itemBuilder: (context, index) {
                            final sup = supervisors[index];
                            final isSelected = sup == selectedSupervisor;
                            return _buildSupervisorListTile(sup, isSelected, colors);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // --- منطقة المحتوى الرئيسية (Main Content) ---
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showEditPanel
                        ? AddEditUserWidget(
                      user: editingUser,
                      addSuper: addSuper,
                      addMarketer: addMarketer,
                      isSupervisor: isEditingSupervisor,
                      isAdmin: currentRole == 'admin',
                      isArabic: isArabic,
                      supervisorId: selectedSupervisor?.id,
                      onCancel: closeAddEdit,
                      onSave: onSaveUser,
                      generateReviewLink: generateReviewLink,
                    )
                        : Container(
                      key: ValueKey(selectedUser?.email ?? 'empty'),
                      child: selectedUser == null
                          ? _buildEmptyState(colors)
                          : selectedUser is Supervisor
                          ? buildSupervisorDetails(
                          selectedUser as Supervisor, colors)
                          : buildMarketerDetails(
                          selectedUser as Marketer, colors),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // زر التحديث
            FloatingActionButton(
              heroTag: 'refresh',
              backgroundColor: colors['button'],
              elevation: 4,
              child: Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                            tr('جاري تحديث البيانات...', 'Refreshing data...')),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                await _reloadPage();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(tr('تم التحديث بنجاح', 'Refreshed successfully')),
                      ],
                    ),
                    backgroundColor: colors['button'],
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // زر تسجيل الخروج (إذا كان موجود)
            if (currentRole != 'admin') _buildLogoutFAB(),
          ],
        ),
      ),
    );
  }

// ويدجت فرعي لزر الإضافة الصغير في السايدبار
  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF388E3C).withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20, color: isDark ? const Color(0xFF81C784) : Colors.blueAccent),
      ),
    );
  }

// تصميم الـ Tile الخاص بالمشرف في القائمة الجانبية
  Widget _buildSupervisorListTile(
      Supervisor sup, bool isSelected, Map<String, Color> colors) {
    return GestureDetector(
      onTap: () => selectSupervisor(sup),
      onLongPress: () => showSupervisorOptions(sup),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors['primary']!.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors['primary']!.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
              isSelected ? colors['primary']! : Colors.grey.withOpacity(0.2),
              child: Text(
                sup.firstName[0],
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sup.firstName} ${sup.lastName}',
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      color: colors['text'],
                    ),
                  ),
                  Text(
                    '${sup.marketers.length} مسوقين',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (sup.status == UserStatus.frozen)
              const Icon(Icons.pause_circle_filled,
                  size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }

// تصميم حالة "لا يوجد اختيار"
  Widget _buildEmptyState(Map<String, Color> colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.select_all_rounded,
              size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            tr('يرجى اختيار مشرف أو مسوق لعرض التفاصيل',
                'Please select a supervisor or marketer'),
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

// تصميم زر تسجيل الخروج
  Widget _buildLogoutFAB() {
    return FloatingActionButton.extended(
      backgroundColor: Colors.redAccent,
      elevation: 4,
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      label: Text(tr("تسجيل الخروج", "Logout"),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      onPressed: () => _confirmLogout(context),
    );
  }

  Widget buildSupervisorDetails(Supervisor sup, Map<String, Color> colors) {
    final textColor = colors['text']!;
    final double totalDue = sup.totalDueAmount * sup.pointPrice;
    final bool hasDue = totalDue > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 0,
          child: Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('المشرف المسؤول', 'Supervising Manager'),
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11)),
                            Text('${sup.firstName} ${sup.lastName}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      _buildExpandButton(colors),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: isSupervisorCollapsed
                        ? const SizedBox.shrink()
                        : Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            const Divider(color: Colors.white24),
                            buildDetailRow(
                                tr('الاسم الأول', 'First Name'),
                                sup.firstName,
                                Colors.white,
                                colors),
                            buildDetailRow(
                                tr('الاسم الأخير', 'Last Name'),
                                sup.lastName,
                                Colors.white,
                                colors),
                            buildDetailRow(tr('العمر', 'Age'),
                                sup.age.toString(), Colors.white, colors),
                            buildDetailRow(tr('الدولة', 'Country'),
                                sup.country, Colors.white, colors),
                            buildDetailRow(tr('المدينة', 'City'),
                                sup.city, Colors.white, colors),
                            buildDetailRow(tr('اسم البنك', 'Bank Name'),
                                sup.bank, Colors.white, colors),
                            buildDetailRow(
                                tr('رقم الحساب', 'Account Number'),
                                sup.accountNumber,
                                Colors.white,
                                colors),
                            buildDetailRow(tr('رقم الهاتف', 'Phone'),
                                sup.phone, Colors.white, colors),
                            buildDetailRow(tr('البريد الإلكتروني', 'Email'),
                                sup.email, Colors.white, colors),
                            buildDetailRow(tr('النقاط', 'Points'),
                                sup.totalDueAmount.toString(), Colors.white, colors),
                            buildDetailRow(
                                tr('المستحق', 'Due Amount'),
                                (sup.totalDueAmount * sup.pointPrice)
                                    .toString(),
                                Colors.white,
                                colors),
                            _buildActionButton(
                              label: sup.isWithdrawalPending
                                  ? 'في انتظار الموافقة ⏳'
                                  : (hasDue
                                  ? 'طلب صرف المبلغ المستحق : $totalDue'
                                  : 'لا يوجد رصيد مستحق'),
                              icon: Icons.edit,
                              color: Colors.white.withOpacity(0.2),
                              onPressed: (hasDue && !sup.isWithdrawalPending)
                                  ? () async {
                                setState(() {
                                  sup.isWithdrawalPending = true;
                                });

                                print('تم الضغط على زر الصرف ✅');

                                try {
                                  final res = await http.post(
                                    Uri.parse(
                                        '${AppConfig.baseUrl}withdrawals/subrequest'),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      "supervisorId": sup.id,
                                    }),
                                  );

                                  print('Status Code: ${res.statusCode}');
                                  print('Response: ${res.body}');

                                  if (res.statusCode != 200) {
                                    setState(() {
                                      sup.isWithdrawalPending = false;
                                    });
                                  }
                                } catch (e) {
                                  print('خطأ في الاتصال ❌ $e');
                                  setState(() {
                                    sup.isWithdrawalPending = false;
                                  });
                                }
                              }
                                  : null,
                            ),
                            if (currentRole == 'admin')
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: _buildActionButton(
                                            label: tr('تعديل', 'Edit'),
                                            icon: Icons.edit,
                                            color: Colors.white
                                                .withOpacity(0.2),
                                            onPressed: () =>
                                                openAddEdit(false, false,
                                                    user: sup,
                                                    supervisor: true))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: _buildActionButton(
                                            label: tr('حذف', 'Delete'),
                                            icon: Icons.delete,
                                            color: Colors.redAccent
                                                .withOpacity(0.8),
                                            onPressed: () =>
                                                showDeleteConfirmation(
                                                    sup, isDark))),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('المسوقين التابعين', 'Managed Team'),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              _buildIconButton(
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => openAddEdit(
                      true, false, user: null, supervisor: false)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sup.marketers.length,
            itemBuilder: (context, index) {
              final marketer = sup.marketers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors['card']!,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? colors['primary']!.withOpacity(0.1)
                        : colors['primary']!.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => selectMarketer(marketer),
                    onLongPress: () => showMarketerOptions(marketer),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                                    : [Colors.blue.shade400, Colors.blue.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                marketer.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${marketer.firstName} ${marketer.lastName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors['text'],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 12, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${marketer.country}, ${marketer.city}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${marketer.points} pts',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildMarketerDetails(Marketer marketer, Map<String, Color> colors) {
    final textColor = colors['text']!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors['card']!,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: colors['primary']!.withOpacity(0.1),
                  child: Icon(Icons.person,
                      color: isDark ? colors['light'] : colors['text']),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('بيانات المسوق', 'Marketer Profile'),
                      style: TextStyle(
                          fontSize: 12, color: textColor.withOpacity(0.6)),
                    ),
                    Text(
                      '${marketer.firstName} ${marketer.lastName}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),
            _buildSectionTitle(
                tr('المعلومات الشخصية', 'Personal Info'),
                Icons.contact_mail_outlined,
                textColor),
            buildDetailRow(tr('الاسم الأول', 'First Name'),
                marketer.firstName, textColor, colors),
            buildDetailRow(tr('الاسم الأخير', 'Last Name'),
                marketer.lastName, textColor, colors),
            buildDetailRow(tr('العمر', 'Age'), marketer.age.toString(),
                textColor, colors),
            buildDetailRow(tr('الدولة', 'Country'), marketer.country,
                textColor, colors),
            buildDetailRow(tr('المدينة', 'City'), marketer.city, textColor,
                colors),
            buildDetailRow(tr('رقم الهاتف', 'Phone'), marketer.phone,
                textColor, colors),
            buildDetailRow(tr('البريد الإلكتروني', 'Email'), marketer.email,
                textColor, colors),
            const SizedBox(height: 20),
            _buildSectionTitle(tr('البيانات البنكية', 'Bank Details'),
                Icons.account_balance_wallet_outlined, textColor),
            buildDetailRow(tr('اسم البنك', 'Bank Name'), marketer.bank,
                textColor, colors),
            buildDetailRow(tr('رقم الحساب', 'Account Number'),
                marketer.accountNumber, textColor, colors),
            const SizedBox(height: 20),
            _buildSectionTitle(tr('الأداء المالي', 'Financial Performance'),
                Icons.trending_up_rounded, textColor),
            buildDetailRow(tr('النقاط المجمعة', 'Points Collected'),
                marketer.points.toString(), textColor, colors),
            buildDetailRow(tr('سعر النقطة', 'Point Price'),
                marketer.pointPrice.toStringAsFixed(2), textColor, colors),
            buildDetailRow(
                tr('إجمالي المبلغ المستحق', 'Total Due Amount'),
                (marketer.points * marketer.pointPrice).toStringAsFixed(2),
                Colors.green.shade600,
                colors),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors['primary']!.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colors['primary']!.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('كود الخصم', 'Discount Code'),
                            style: TextStyle(
                                fontSize: 11,
                                color: textColor.withOpacity(0.6))),
                        Text(marketer.discountCode,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  _buildActionButton(
                    label: tr('نسخ', 'Copy'),
                    icon: Icons.copy_rounded,
                    color: colors['primary']!,
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: marketer.discountCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(tr('تم نسخ الكود', 'Code copied')),
                            behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            buildWithdrawButton(marketer, colors),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: tr('تعديل', 'Edit'),
                    icon: Icons.edit_note_rounded,
                    color: colors['button']!,
                    onPressed: () => openAddEdit(false, false,
                        user: marketer, supervisor: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: tr('حذف', 'Delete'),
                    icon: Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    onPressed: () => showDeleteConfirmation(marketer, isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWithdrawButton(Marketer marketer, Map<String, Color> colors) {
    final double totalDue = marketer.points * marketer.pointPrice;
    final bool hasDue = totalDue > 0;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payments_rounded,
            size: 20, color: Colors.white),
        label: Text(
          marketer.isWithdrawalPending
              ? 'في انتظار الموافقة ⏳'
              : (hasDue
              ? 'طلب صرف المبلغ المستحق : $totalDue'
              : 'لا يوجد رصيد مستحق'),
          style:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: marketer.isWithdrawalPending
              ? Colors.orange
              : (hasDue ? colors['button'] : Colors.grey),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (hasDue && !marketer.isWithdrawalPending)
            ? () async {
          setState(() {
            marketer.isWithdrawalPending = true;
          });
          try {
            final res = await http.post(
              Uri.parse('${AppConfig.baseUrl}withdrawals/request'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({"marketerId": marketer.id}),
            );

            if (res.statusCode == 200) {
              print('تم إرسال طلب الصرف بنجاح ⏳');
            } else {
              setState(() {
                marketer.isWithdrawalPending = false;
              });
            }
          } catch (e) {
            setState(() {
              marketer.isWithdrawalPending = false;
            });
          }
        }
            : null,
      ),
    );
  }

// ويدجت فرعي لعناوين الأقسام داخل التفاصيل
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.6),
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String value, Color textColor,
      Map<String, Color> colors) {
    IconData getIcon(String label) {
      if (label.contains('الاسم') || label.contains('Name')) return Icons.badge_outlined;
      if (label.contains('الهاتف') || label.contains('Phone')) return Icons.phone_android_rounded;
      if (label.contains('البريد') || label.contains('Email')) return Icons.alternate_email_rounded;
      if (label.contains('المدينة') || label.contains('City') || label.contains('الدولة')) return Icons.location_on_outlined;
      if (label.contains('البنك') || label.contains('Bank')) return Icons.account_balance_rounded;
      if (label.contains('الحساب') || label.contains('Account')) return Icons.credit_card_rounded;
      if (label.contains('العمر') || label.contains('Age')) return Icons.cake_outlined;
      return Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors['primary']!.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(getIcon(label),
              size: 18, color: textColor.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(User user, bool isDark) {
    final colors = _getColors(isDark);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors['card']!,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_rounded,
                    color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                tr('تأكيد الحذف', 'Delete Confirmation'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colors['text'],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${tr('هل أنت متأكد من حذف', 'Are you sure you want to delete')} "
                    "${user.firstName} ${user.lastName}؟",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        tr('إلغاء', 'Cancel'),
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final service = DashboardUserService(
                            baseUrl: AppConfig.baseUrl);
                        var res = '';
                        try {
                          if (user is Supervisor) {
                            final result = await service.deleteSupervisor(
                                user.id);
                            res = result['message'];
                          } else if (user is Marketer) {
                            final result = await service.deleteMarketer(
                                user.id);
                            res = result['message'];
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: colors['button'],
                            ),
                          );

                          await _reloadPage();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  tr('حدث خطأ أثناء الحذف', 'Delete failed')),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: Text(
                        tr('حذف', 'Delete'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          overlayColor: Colors.white.withOpacity(0.1),
        ).copyWith(
          mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        ),
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16),
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildExpandButton(Map<String, Color> colors) {
    final primaryColor = colors['primary']!;

    return Tooltip(
      message: isSupervisorCollapsed
          ? tr('إظهار التفاصيل', 'Expand')
          : tr('إخفاء التفاصيل', 'Collapse'),
      child: InkWell(
        onTap: () => setState(() => isSupervisorCollapsed = !isSupervisorCollapsed),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSupervisorCollapsed
                ? primaryColor.withOpacity(0.15)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isSupervisorCollapsed
                ? [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSupervisorCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    tr('عرض البيانات', 'Show Data'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              AnimatedRotation(
                turns: isSupervisorCollapsed ? 0.5 : 0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.bounceOut,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}