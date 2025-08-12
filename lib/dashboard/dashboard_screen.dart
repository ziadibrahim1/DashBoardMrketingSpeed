import 'package:admin_dashboard/dashboard/pages/statistics_page.dart' show DashboardStatsSection;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import 'pages/AdminManagementScreen.dart';
import 'pages/AdminVideoManager.dart';
import 'pages/FlexManagement.dart';
import 'pages/StatsPageTelgram.dart';
import 'pages/AdminLiveChatDashboard.dart';
import 'pages/AdminChatHistoryScreen.dart';
import 'pages/SelectTelegramUserScreen.dart';
import 'pages/SendNotificationScreen.dart';
import 'pages/PlatformManagementPage.dart';
import 'pages/ReferralRewardsPage.dart';
import 'pages/SuggestionsManagementScreen.dart';
import 'pages/SupervisorsManagementScreen.dart';
import 'pages/PaymentManagement.dart';
import 'pages/api_dashboard.dart';
import 'pages/login_screen.dart';
import 'pages/messages_page.dart';
import 'pages/select_user_screen.dart';
import 'pages/social_accounts_page.dart';
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
  final ScrollController _scrollController = ScrollController();
  double _dragStartX = 0;
  double _scrollStartX = 0;


  final List<Widget> platformPages = [
    const StatsPage(), // واتساب
    const StatsPageTelegram(), // تيليجرام
    const Center(child: Text('صفحة فيسبوك')), // فيسبوك
  ];

  final List<Widget> chatPages = [
    const AdminLiveChatDashboard(), // المحادثات الحية
    const AdminChatHistoryScreen(), // سجل المحادثات
  ];



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: Icon(Icons.insights), label: widget.isArabic ? 'إحصائيات' : 'Statistics'),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: widget.isArabic ? 'المستخدمين' : 'Users'),
      BottomNavigationBarItem(icon: Icon(Icons.message), label: widget.isArabic ? 'الرسائل' : 'Messages'),
      BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: widget.isArabic ? 'الاشتراكات' : 'Subscriptions'),
      BottomNavigationBarItem(icon: Icon(Icons.language), label: widget.isArabic ? 'المنصات' : 'Platforms'),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: widget.isArabic ? 'محادثات' : 'Chats'),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: widget.isArabic ? 'إرسال إشعار' : 'Send Notification'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: widget.isArabic ? 'إدارة منصات' : 'Manage Platforms'),
      BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.userTie), label: widget.isArabic ? 'المسؤولين' : 'Admins'),
      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: widget.isArabic ? 'إدارة فليكس' : 'Manage Flex'),
      BottomNavigationBarItem(icon: Icon(Icons.link), label: widget.isArabic ? 'روابط تواصل' : 'Contact Links'),
      BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: widget.isArabic ? 'ادارة المكافئات' : 'Manage Rewards'),
      BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: widget.isArabic ? 'ادارة الاقتراحات' : 'Manage Suggestions'),
      BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bullhorn), label: widget.isArabic ? 'ادارة المسوقين' : 'Manage Marketers'),
      BottomNavigationBarItem(icon: Icon(Icons.code), label: widget.isArabic ? 'ادارة ال API ' : 'Manage API'),
      BottomNavigationBarItem(icon: Icon(Icons.payment), label: widget.isArabic ? 'ادارة الدفع ' : 'Manage Payments'),
      BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: widget.isArabic ? 'شرح الاستخدام ' : 'User Guide'),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.green : Colors.blue;
    final unselectedColor = Colors.white;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    final locale = Localizations.localeOf(context);
    final isRTL = ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    final List<Widget> basePages = [
      DashboardStatsSection(), // إحصائيات
      const UsersPage(), // المستخدمين
      const MessagesPage(), // الرسائل
      const SubscriptionsPage(), // الاشتراكات
      const SizedBox.shrink(), // منصات (غير مستخدمة مباشرة)
      const SizedBox.shrink(), // محادثات (منسدلة)
      const SendNotificationPage(), // إرسال إشعار
      const PlatformManagementPage(), // إدارة منصات
      const AdminManagementScreen(), // المسؤولين
       PackagesPage( isArabic: isArabic), // إدارة فليكس
      const SocialAccountsPage(), // روابط تواصل
      const ReferralRewardsPage(), // ادارة المكافئات
      const SuggestionsManagementPage(), // ادارة الاقتراحات
      const SupervisorsMarketersPage(), // ادارة المسوقين
      const ApiDashboardScreen(), // ادارة API's
      const PaymentManagementSection(), // ادارة الدفع
      AdminAboutAppScreen(), // إدارة فيديوهات الاستخدام
    ];

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
                  children: [
                    ...List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = selectedIndex == index && !showPlatformPage && !showChatPage;

                      Widget buttonContent = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconTheme(
                            data: IconThemeData(
                              color: isSelected ? (isDark ? Colors.green : Colors.blue) : Colors.white,
                            ),
                            child: item.icon,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.label!,
                            style: TextStyle(
                              color: isSelected ? selectedColor : unselectedColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      );

                      if (index == 4) {
                        return _buildDropdownButton(
                          isDark: isDark,
                          isSelected: showPlatformPage,
                          value: showPlatformPage ? platformPageIndex : null,
                          buttonContent: buttonContent,
                          items: [
                            _buildDropdownItem(FontAwesomeIcons.whatsapp,isArabic? 'واتساب':'WhatsApp', 0, isSelected, isDark),
                            _buildDropdownItem(Icons.send,isArabic? 'تيليجرام':'Telegram', 1, isSelected, isDark),
                            _buildDropdownItem(Icons.facebook, isArabic?'فيسبوك':'Facebook', 2, isSelected, isDark),
                          ],
                          onChanged: (platformIndex) {
                            setState(() {
                              showPlatformPage = true;
                              platformPageIndex = platformIndex!;
                              showChatPage = false;
                              selectedIndex = index;
                            });
                          },
                        );
                      }

                      if (index == 5) {
                        return _buildDropdownButton(
                          isDark: isDark,
                          isSelected: showChatPage,
                          value: showChatPage ? chatPageIndex : null,
                          buttonContent: buttonContent,
                          items: [
                            _buildDropdownItem(Icons.chat_bubble_outline,isArabic? 'محادثات':'Conversations', 0, isSelected, isDark),
                            _buildDropdownItem(Icons.history,isArabic? 'سجل المحادثات':'Chat archive', 1, isSelected, isDark),
                          ],
                          onChanged: (chatIndex) {
                            setState(() {
                              showChatPage = true;
                              chatPageIndex = chatIndex!;
                              showPlatformPage = false;
                              selectedIndex = index;
                            });
                          },
                        );
                      }

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
                                selectedIndex = index;
                                showPlatformPage = false;
                                showChatPage = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: buttonContent,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),

        body:Stack(
            children: [ AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: showPlatformPage
              ? platformPages[platformPageIndex]
              : showChatPage
              ? chatPages[chatPageIndex]
              : basePages[selectedIndex],
        ),
         MovableSpeedDial(
          isDark: isDark,
          isRTL: isRTL,
          currentUserName: widget.currentUserName,
        ),
     ] ),
      ),
    );
  }
}

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
  late Offset position;

  @override
  void initState() {
    super.initState();
    // القيم الافتراضية: أسفل يمين
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        position = Offset(
          MediaQuery.of(context).size.width - 200, // يمين
          MediaQuery.of(context).size.height - 140, // أسفل
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
              onTap: () {
                // show profile dialog
              },
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
