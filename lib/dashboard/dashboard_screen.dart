import 'package:admin_dashboard/dashboard/pages/WithdrawalsScreen.dart';
import 'package:admin_dashboard/dashboard/pages/statistics_page.dart' show DashboardStatsSection;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../core/user_session.dart'; // 👈 استيراد UserSession
import 'pages/AdminManagementScreen.dart';
import 'pages/AdminVideoManager.dart';
import 'pages/FlexManagement.dart';
import 'pages/NotificationHistoryPage.dart';
import 'pages/StatsPageTelgram.dart';
import 'pages/AdminLiveChatDashboard.dart';
import 'pages/AdminChatHistoryScreen.dart';
import 'pages/SendNotificationScreen.dart';
import 'pages/ReferralRewardsPage.dart';
import 'pages/SuggestionsManagementScreen.dart';
import 'pages/SupervisorsManagementScreen.dart';
import 'pages/PaymentManagement.dart';
import 'pages/login_screen.dart';
import 'pages/messages_page.dart';
import 'pages/stats_page.dart';
import 'pages/subscriptions_page.dart';
import 'pages/users_page.dart';

class DashboardScreen extends StatefulWidget {
  final String currentUserName;
  final VoidCallback onLogout;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final bool isArabic;

  const DashboardScreen({
    super.key,
    required this.currentUserName,
    required this.onLogout,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.isArabic,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  bool showPlatformPage = false;
  int platformPageIndex = 0;
  bool showChatPage = false;
  int chatPageIndex = 0;
  bool showNoti = false;
  int NotiPageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _dragStartX = 0;
  double _scrollStartX = 0;

  // 👇 Helper للتحقق من الصلاحيات
  bool _hasPermission(String permissionKey) {
    final user = UserSession.getUser();
    if (user == null) return false;

    // Admin له كل الصلاحيات
    if (user['role'] == 'admin') return true;

    // التحقق من الصلاحية المحددة
    final permission = user[permissionKey];
    return permission == 1 || permission == '1' || permission == true;
  }

  final List<Widget> platformPages = [
    const StatsPage(),
    const StatsPageTelegram(),
    const Center(child: Text('صفحة فيسبوك')),
  ];

  final List<Widget> chatPages = [
    const AdminLiveChatDashboard(),
    const AdminChatHistoryScreen(),
  ];

  final List<Widget> notification = [
    const SendNotificationPage(),
    const NotificationHistoryPage(),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 👇 بناء قائمة الـ Navigation Items بناءً على الصلاحيات
  List<NavigationItem> _buildNavigationItems(bool isArabic) {
    List<NavigationItem> items = [];

    // إحصائيات Dashboard
    if (_hasPermission('DashboardStatsSection')) {
      items.add(NavigationItem(
        icon: Icons.insights,
        labelAr: 'إحصائيات',
        labelEn: 'Statistics',
        pageIndex: items.length,
      ));
    }

    if (_hasPermission('UsersPage')) {
      items.add(NavigationItem(
        icon: Icons.people,
        labelAr: 'المستخدمين',
        labelEn: 'Users',
        pageIndex: items.length,
      ));
    }

    // شاشة المستخدمين الإداريين
    if (_hasPermission('AdminUsersScreen')) {
      items.add(NavigationItem(
        icon: Icons.message,
        labelAr: 'الرسائل',
        labelEn: 'Messages',
        pageIndex: items.length,
      ));
    }

    // الاشتراكات
    if (_hasPermission('SubscriptionsPage')) {
      items.add(NavigationItem(
        icon: Icons.subscriptions,
        labelAr: 'الاشتراكات',
        labelEn: 'Subscriptions',
        pageIndex: items.length,
      ));
    }

    // المنصات (WhatsApp, Telegram, Facebook)
    if (_hasPermission('StatsPage') || _hasPermission('StatsPageTelegram')) {
      items.add(NavigationItem(
        icon: Icons.language,
        labelAr: 'المنصات',
        labelEn: 'Platforms',
        pageIndex: items.length,
        isDropdown: true,
        dropdownType: 'platform',
      ));
    }

    // المحادثات
    if (_hasPermission('AdminLiveChatDashboard') || _hasPermission('AdminChatHistoryScreen')) {
      items.add(NavigationItem(
        icon: Icons.chat_bubble_outline,
        labelAr: 'محادثات',
        labelEn: 'Chats',
        pageIndex: items.length,
        isDropdown: true,
        dropdownType: 'chat',
      ));
    }

    // الإشعارات
    if (_hasPermission('SendNotificationPage') || _hasPermission('NotificationHistoryPage')) {
      items.add(NavigationItem(
        icon: Icons.notifications,
        labelAr: 'الاشعارات',
        labelEn: 'Notifications',
        pageIndex: items.length,
        isDropdown: true,
        dropdownType: 'notification',
      ));
    }

    // المسؤولين
    if (_hasPermission('AdminManagementScreen')) {
      items.add(NavigationItem(
        icon: FontAwesomeIcons.userTie,
        labelAr: 'المسؤولين',
        labelEn: 'Admins',
        pageIndex: items.length,
      ));
    }

    // إدارة فليكس (الباقات)
    if (_hasPermission('PackagesPage')) {
      items.add(NavigationItem(
        icon: Icons.account_balance_wallet,
        labelAr: 'إدارة فليكس',
        labelEn: 'Manage Flex',
        pageIndex: items.length,
      ));
    }

    // إدارة المكافآت
    if (_hasPermission('ReferralRewardsPage')) {
      items.add(NavigationItem(
        icon: Icons.card_giftcard,
        labelAr: 'ادارة المكافئات',
        labelEn: 'Manage Rewards',
        pageIndex: items.length,
      ));
    }

    // إدارة الاقتراحات
    if (_hasPermission('SuggestionsManagementPage')) {
      items.add(NavigationItem(
        icon: Icons.text_snippet,
        labelAr: 'ادارة الاقتراحات',
        labelEn: 'Manage Suggestions',
        pageIndex: items.length,
      ));
    }

    // إدارة المسوقين والمشرفين
    if (_hasPermission('SupervisorsMarketersPage')) {
      items.add(NavigationItem(
        icon: FontAwesomeIcons.bullhorn,
        labelAr: 'ادارة المسوقين',
        labelEn: 'Manage Marketers',
        pageIndex: items.length,
      ));
    }

    // السحوبات المالية
    if (_hasPermission('WithdrawalsScreen')) {
      items.add(NavigationItem(
        icon: Icons.balance,
        labelAr: 'الحسابات',
        labelEn: 'Financial',
        pageIndex: items.length,
      ));
    }

    // إدارة الدفع
    if (_hasPermission('PaymentManagementSection')) {
      items.add(NavigationItem(
        icon: Icons.payment,
        labelAr: 'ادارة الدفع',
        labelEn: 'Manage Payments',
        pageIndex: items.length,
      ));
    }

    // شرح الاستخدام (الفيديوهات)
    if (_hasPermission('VideoManagerScreen')) {
      items.add(NavigationItem(
        icon: Icons.report_outlined,
        labelAr: 'شرح الاستخدام',
        labelEn: 'User Guide',
        pageIndex: items.length,
      ));
    }
    if (_hasPermission('VideoManagerScreen')) {
      items.add(NavigationItem(
        icon: Icons.data_exploration_sharp ,
        labelAr: 'التقارير',
        labelEn: 'Reports',
        pageIndex: items.length,
      ));
    }

    return items;
  }

  List<Widget> _buildPages(bool isArabic) {
    List<Widget> pages = [];

    if (_hasPermission('DashboardStatsSection')) {
      pages.add(DashboardStatsSection());
    }

    if (_hasPermission('UsersPage')) {
      pages.add(const UsersPage());
    }

    if (_hasPermission('AdminUsersScreen')) {
      pages.add(const AdminUsersScreen());
    }

    if (_hasPermission('SubscriptionsPage')) {
      pages.add(const SubscriptionsPage());
    }

    // المنصات (placeholder للـ dropdown)
    if (_hasPermission('StatsPage') || _hasPermission('StatsPageTelegram')) {
      pages.add(const SizedBox.shrink());
    }

    // المحادثات (placeholder للـ dropdown)
    if (_hasPermission('AdminLiveChatDashboard') || _hasPermission('AdminChatHistoryScreen')) {
      pages.add(const SizedBox.shrink());
    }

    // الإشعارات (placeholder للـ dropdown)
    if (_hasPermission('SendNotificationPage') || _hasPermission('NotificationHistoryPage')) {
      pages.add(const SizedBox.shrink());
    }

    if (_hasPermission('AdminManagementScreen')) {
      pages.add(const AdminManagementScreen());
    }

    if (_hasPermission('PackagesPage')) {
      pages.add(PackagesPage(isArabic: isArabic));
    }

    if (_hasPermission('ReferralRewardsPage')) {
      pages.add(const ReferralRewardsPage());
    }

    if (_hasPermission('SuggestionsManagementPage')) {
      pages.add(const SuggestionsManagementPage());
    }

    if (_hasPermission('SupervisorsMarketersPage')) {
      pages.add(const SupervisorsMarketersPage());
    }

    if (_hasPermission('WithdrawalsScreen')) {
      pages.add(const WithdrawalsScreen());
    }

    if (_hasPermission('PaymentManagementSection')) {
      pages.add(const PaymentManagementSection());
    }

    if (_hasPermission('VideoManagerScreen')) {
      pages.add(VideoManagerScreen());
    }

    if (_hasPermission('VideoManagerScreen')) {
      pages.add(VideoManagerScreen());
    }

    return pages;
  }

  Widget _buildDropdownButton({
    required bool isDark,
    required bool isSelected,
    required int? value,
    required Widget buttonContent,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Card(
        color: isSelected ? Colors.white : isDark ? Colors.green.shade800 : Colors.blue.shade800,
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: buttonContent,
            ),
            items: items,
            onChanged: onChanged,
            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<int> _buildDropdownItem(
      IconData icon, String label, int value, bool isSelected, bool isDark) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : isDark ? Colors.green.shade800 : Colors.blue.shade800),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : isDark ? Colors.green.shade800 : Colors.blue.shade800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.green : Colors.blue;
    final unselectedColor = Colors.white;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final locale = Localizations.localeOf(context);
    final isRTL = ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);

    // 👇 بناء العناصر والصفحات بناءً على الصلاحيات
    final navigationItems = _buildNavigationItems(isArabic);
    final pages = _buildPages(isArabic);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: isDark ? Colors.grey[850] : Color(0xFFAFDBF5),
            height: 60,
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                _dragStartX = details.globalPosition.dx;
                _scrollStartX = _scrollController.offset;
              },
              onHorizontalDragUpdate: (details) {
                double dragDistance = _dragStartX - details.globalPosition.dx;
                double newPosition = _scrollStartX + dragDistance;
                if (newPosition < 0) newPosition = 0;
                if (newPosition > _scrollController.position.maxScrollExtent) {
                  newPosition = _scrollController.position.maxScrollExtent;
                }
                _scrollController.jumpTo(newPosition);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: navigationItems.map((item) {
                    final isSelected = selectedIndex == item.pageIndex &&
                        !showPlatformPage &&
                        !showChatPage &&
                        !showNoti;

                    Widget buttonContent = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isArabic ? item.labelAr : item.labelEn,
                          style: TextStyle(
                            color: isSelected ? selectedColor : unselectedColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );

                    // Dropdown للمنصات
                    if (item.isDropdown && item.dropdownType == 'platform') {
                      List<DropdownMenuItem<int>> dropdownItems = [];

                      if (_hasPermission('StatsPage')) {
                        dropdownItems.add(_buildDropdownItem(
                          FontAwesomeIcons.whatsapp,
                          isArabic ? 'واتساب' : 'WhatsApp',
                          0,
                          isSelected,
                          isDark,
                        ));
                      }

                      if (_hasPermission('StatsPageTelegram')) {
                        dropdownItems.add(_buildDropdownItem(
                          Icons.send,
                          isArabic ? 'تيليجرام' : 'Telegram',
                          1,
                          isSelected,
                          isDark,
                        ));
                      }

                      return _buildDropdownButton(
                        isDark: isDark,
                        isSelected: showPlatformPage,
                        value: showPlatformPage ? platformPageIndex : null,
                        buttonContent: buttonContent,
                        items: dropdownItems,
                        onChanged: (platformIndex) {
                          setState(() {
                            showPlatformPage = true;
                            platformPageIndex = platformIndex!;
                            showChatPage = false;
                            showNoti = false;
                            selectedIndex = item.pageIndex;
                          });
                        },
                      );
                    }

                    // Dropdown للمحادثات
                    if (item.isDropdown && item.dropdownType == 'chat') {
                      List<DropdownMenuItem<int>> dropdownItems = [];

                      if (_hasPermission('AdminLiveChatDashboard')) {
                        dropdownItems.add(_buildDropdownItem(
                          Icons.chat_bubble_outline,
                          isArabic ? 'محادثات' : 'Conversations',
                          0,
                          isSelected,
                          isDark,
                        ));
                      }

                      if (_hasPermission('AdminChatHistoryScreen')) {
                        dropdownItems.add(_buildDropdownItem(
                          Icons.history,
                          isArabic ? 'سجل المحادثات' : 'Chat archive',
                          1,
                          isSelected,
                          isDark,
                        ));
                      }

                      return _buildDropdownButton(
                        isDark: isDark,
                        isSelected: showChatPage,
                        value: showChatPage ? chatPageIndex : null,
                        buttonContent: buttonContent,
                        items: dropdownItems,
                        onChanged: (chatIndex) {
                          setState(() {
                            showChatPage = true;
                            chatPageIndex = chatIndex!;
                            showPlatformPage = false;
                            selectedIndex = item.pageIndex;
                            showNoti = false;
                          });
                        },
                      );
                    }

                    // Dropdown للإشعارات
                    if (item.isDropdown && item.dropdownType == 'notification') {
                      List<DropdownMenuItem<int>> dropdownItems = [];

                      if (_hasPermission('SendNotificationPage')) {
                        dropdownItems.add(_buildDropdownItem(
                          Icons.notification_add,
                          isArabic ? 'إرسال الاشعارات' : 'Send Notifications',
                          0,
                          isSelected,
                          isDark,
                        ));
                      }

                      if (_hasPermission('NotificationHistoryPage')) {
                        dropdownItems.add(_buildDropdownItem(
                          Icons.history,
                          isArabic ? 'سجل الاشعارات' : 'Notifications archive',
                          1,
                          isSelected,
                          isDark,
                        ));
                      }

                      return _buildDropdownButton(
                        isDark: isDark,
                        isSelected: showNoti,
                        value: showNoti ? NotiPageIndex : null,
                        buttonContent: buttonContent,
                        items: dropdownItems,
                        onChanged: (notiIndex) {
                          setState(() {
                            showChatPage = false;
                            showPlatformPage = false;
                            selectedIndex = item.pageIndex;
                            showNoti = true;
                            NotiPageIndex = notiIndex!;
                          });
                        },
                      );
                    }

                    // زر عادي
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Card(
                        color: isSelected ? Colors.white : isDark ? Colors.green.shade800 : Colors.blue.shade800,
                        elevation: isSelected ? 6 : 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedIndex = item.pageIndex;
                              showPlatformPage = false;
                              showChatPage = false;
                              showNoti = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: buttonContent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: showPlatformPage
                  ? platformPages[platformPageIndex]
                  : showNoti
                  ? notification[NotiPageIndex]
                  : showChatPage
                  ? chatPages[chatPageIndex]
                  : pages[selectedIndex],
            ),
            MovableSpeedDial(
              isDark: isDark,
              isRTL: isRTL,
              currentUserName: widget.currentUserName,
            ),
          ],
        ),
      ),
    );
  }
}

// 👇 Model للـ Navigation Items
class NavigationItem {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final int pageIndex;
  final bool isDropdown;
  final String? dropdownType;

  NavigationItem({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
    required this.pageIndex,
    this.isDropdown = false,
    this.dropdownType,
  });
}

// MovableSpeedDial يبقى كما هو...
class MovableSpeedDial extends StatefulWidget {
  final bool isDark;
  final bool isRTL;
  final String currentUserName;

  const MovableSpeedDial({
    super.key,
    required this.isDark,
    required this.isRTL,
    required this.currentUserName,
  });

  @override
  _MovableSpeedDialState createState() => _MovableSpeedDialState();
}

class _MovableSpeedDialState extends State<MovableSpeedDial> {
  Offset position = const Offset(50, 50);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        position = Offset(
          MediaQuery.of(context).size.width - 200,
          MediaQuery.of(context).size.height - 140,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: SpeedDial(
          icon: Icons.person,
          label: Text(
            widget.currentUserName,
            style: const TextStyle(color: Colors.white),
          ),
          activeIcon: Icons.close,
          backgroundColor:
          widget.isDark ? Colors.green.shade700.withOpacity(.9) : Colors.blue.shade700.withOpacity(.9),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.person),
              label: widget.isRTL ? 'عرض الملف الشخصي' : 'Open profile',
              onTap: () {},
            ),
            SpeedDialChild(
              child: const Icon(Icons.logout),
              label: widget.isRTL ? 'تسجيل خروج' : 'Logout',
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}