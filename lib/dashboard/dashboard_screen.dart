import 'package:admin_dashboard/dashboard/pages/social_accounts_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pages/AdminChatHistoryScreen.dart';
import 'pages/AdminLiveChatDashboard.dart';
import 'pages/AdminManagementScreen.dart';
import 'pages/AdminVideoManager.dart';
import 'pages/FlexManagement.dart';
import 'pages/PaymentManagement.dart';
import 'pages/PlatformManagementPage.dart';
import 'pages/ReferralRewardsPage.dart';
import 'pages/SelectTelegramUserScreen.dart';
import 'pages/SendNotificationScreen.dart';
import 'pages/StatsPageTelgram.dart';
import 'pages/SuggestionsManagementScreen.dart';
import 'pages/SupervisorsManagementScreen.dart';
import 'pages/api_dashboard.dart';
import 'pages/messages_page.dart';
import 'pages/select_user_screen.dart';
import 'pages/statistics_page.dart';
import 'pages/stats_page.dart';
import 'pages/subscriptions_page.dart';
import 'pages/users_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  bool showPlatformPage = false;
  int platformPageIndex = 0;

  bool showChatPage = false;
  int chatPageIndex = 0;

  final List<Widget> basePages = [
    const DashboardStatsSection(), // 0: إحصائيات
    const UsersPage(), // 1: المستخدمين
    const MessagesPage(), // 2: الرسائل
    const SubscriptionsPage(), // 3: الاشتراكات
    const SizedBox.shrink(), // 4: المنصات (لا تعرض شيء من هنا)
    const SizedBox.shrink(), // 5: محادثات (نتعامل معها بالقائمة المنسدلة)
    SelectUserScreen(), // 7: ملفات واتساب
    SelectTelegramUserScreen(), // 8: ملفات تليجرام
    const SendNotificationPage(), // 9: إرسال إشعار
    const PlatformManagementPage(), // 10: إدارة المنصات
    const AdminManagementScreen(), // 11: المسؤولين
    const PackagesPage(), // 12
    const SocialAccountsPage(), // 13: روابط تواصل
    const ReferralRewardsPage(), // 14: ادارة المكافئات
    const SuggestionsManagementPage(), // 15: ادارة الاقتراحات
    const SupervisorsManagementSimpleScreen(), // 16: ادارة المسوقين
    const ApiDashboardScreen(), // 17: ادارة API's
    const PaymentManagementSection(), // 18: ادارة الدفع
    AdminAboutAppScreen(), // 18: ادارة فديوهات الاستخدام
  ];

  final List<Widget> platformPages = [
    const StatsPage(), // 0: واتساب
    const StatsPageTele(), // 1: تيليجرام
    const Center(child: Text('صفحة فيسبوك')), // 2: فيسبوك
  ];

  final List<Widget> chatPages = [
    const AdminLiveChatDashboard(), // 0: المحادثات الحية
    const AdminChatHistoryScreen(), // 1: سجل المحادثات
  ];

  final List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'إحصائيات'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المستخدمين'),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'الرسائل'),
    BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'الاشتراكات'),
    BottomNavigationBarItem(icon: Icon(Icons.language), label: 'المنصات'),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'محادثات'),
    BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'ملفات واتساب'),
    BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'ملفات تليجرام'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'إرسال إشعار'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'إدارة منصات'),
    BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'المسؤولين'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'إدارة فليكس'),
    BottomNavigationBarItem(icon: Icon(Icons.link), label: 'روابط تواصل'),
    BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'ادارة المكافئات'),
    BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'ادارة الاقتراحات'),
    BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'ادارة المسوقين'),
    BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'ادارة ال API '),
    BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'ادارة الدفع '),
    BottomNavigationBarItem(icon: Icon(Icons.text_snippet), label: 'شرح الاستخدام '),
  ];

  final ScrollController _scrollController = ScrollController();
  double _dragStartX = 0;
  double _scrollStartX = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.greenAccent : Colors.blue;
    final unselectedColor = Colors.grey;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: isDark ? Colors.grey[850] : Colors.blue[100],
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
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = selectedIndex == index && !showPlatformPage && !showChatPage;

                  Widget buttonContent = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      item.icon,
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
                    // المنصات: DropdownButton داخل Card
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Card(
                        elevation: isSelected ? 6 : 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: showPlatformPage ? platformPageIndex : null,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: buttonContent,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Row(
                                  children: const [
                                    Icon(FontAwesomeIcons.whatsapp, size: 18),
                                    SizedBox(width: 8),
                                    Text("واتساب"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Row(
                                  children: const [
                                    Icon(Icons.send, size: 18),
                                    SizedBox(width: 8),
                                    Text("تيليجرام"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Row(
                                  children: const [
                                    Icon(Icons.facebook, size: 18),
                                    SizedBox(width: 8),
                                    Text("فيسبوك"),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (platformIndex) {
                              setState(() {
                                showPlatformPage = true;
                                platformPageIndex = platformIndex!;
                                showChatPage = false;
                                selectedIndex = index;
                              });
                            },
                            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  }

                  if (index == 5) {
                    // المحادثات: DropdownButton داخل Card
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Card(
                        elevation: showChatPage ? 6 : 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: showChatPage ? chatPageIndex : null,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: buttonContent,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Row(
                                  children: const [
                                    Icon(Icons.chat_bubble_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text("محادثات"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Row(
                                  children: const [
                                    Icon(Icons.history, size: 18),
                                    SizedBox(width: 8),
                                    Text("سجل المحادثات"),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (chatIndex) {
                              setState(() {
                                showChatPage = true;
                                chatPageIndex = chatIndex!;
                                showPlatformPage = false;
                                selectedIndex = index;
                              });
                            },
                            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  }

                  // باقي العناصر: Card مع InkWell
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Card(
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
              ),
            ),
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: showPlatformPage
            ? platformPages[platformPageIndex]
            : showChatPage
            ? chatPages[chatPageIndex]
            : basePages[selectedIndex],
      ),
    );
  }
}
