import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import '../../core/web_session.dart';
import 'login_screen.dart';

class MarketerProfileScreen extends StatefulWidget {
  final int? marketerId;
  final bool isArabic;

  const MarketerProfileScreen({
    super.key,
    this.marketerId,
    this.isArabic = true,
  });

  @override
  State<MarketerProfileScreen> createState() => _MarketerProfileScreenState();
}

class _MarketerProfileScreenState extends State<MarketerProfileScreen> {
  bool loading = true;
  bool error = false;

  Map<String, dynamic>? marketer;
  Map<String, dynamic>? supervisor;

  // لوحة الألوان - تتغير حسب الوضع
  Color get primaryColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2E7D32) : const Color(0xFF2563EB);
  }

  Color get successColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF43A047) : const Color(0xFF10B981);
  }

  Color get bgColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D2818) : const Color(0xFFF8FAFC);
  }

  Future<void> loadData() async {
    try {
      final dashboardUserId = widget.marketerId ?? UserSession.userId;
      if (dashboardUserId == null) throw Exception("User ID is null");

      final url = Uri.parse("${AppConfig.baseUrl}admin/Hierarchy/tree");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"dashboardUserId": dashboardUserId}),
      );

      if (res.statusCode != 200) throw Exception();
      final data = jsonDecode(res.body);

      if (data["marketer"] != null) {
        setState(() {
          marketer = data["marketer"];
          supervisor = data["supervisor"];
          error = false;
        });
      } else {
        error = true;
      }
    } catch (e) {
      error = true;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: _buildAppBar(isDark),
        body: loading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : error
            ? _buildErrorUI()
            : _buildMainContent(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      centerTitle: true,
      title: Text(
        widget.isArabic ? "ملفي الشخصي" : "My Profile",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.white),
          onPressed: () => _confirmLogout(context),
        )
      ],
    );
  }

  Widget _buildMainContent(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTopHeader(isDark),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                _buildFinanceStats(isDark),

                const SizedBox(height: 25),

                _buildPromoCard(isDark),

                const SizedBox(height: 25),

                _buildSectionTitle(widget.isArabic ? "المعلومات الشخصية" : "Personal Information"),
                _buildInfoSection([
                  _buildDataRow(
                    Icons.location_city_rounded,
                    widget.isArabic ? "المدينة" : "City",
                    marketer!['city'] ?? "-",
                    Colors.redAccent,
                    isDark,
                  ),
                  _buildDataRow(
                    Icons.public_rounded,
                    widget.isArabic ? "الدولة" : "Country",
                    marketer!['country'] ?? "-",
                    Colors.blueAccent,
                    isDark,
                  ),
                  _buildDataRow(
                    Icons.phone_android_rounded,
                    widget.isArabic ? "رقم الجوال" : "Phone Number",
                    marketer!['phone'] ?? "-",
                    Colors.green,
                    isDark,
                  ),
                ], isDark),

                const SizedBox(height: 25),

                _buildSectionTitle(widget.isArabic ? "البيانات البنكية" : "Banking Information"),
                _buildInfoSection([
                  _buildDataRow(
                    Icons.account_balance_rounded,
                    widget.isArabic ? "البنك" : "Bank",
                    marketer!['bank'] ?? "-",
                    Colors.indigo,
                    isDark,
                  ),
                  _buildDataRow(
                    Icons.numbers_rounded,
                    widget.isArabic ? "رقم الحساب" : "Account Number",
                    marketer!['accountNumber'] ?? "-",
                    Colors.blueGrey,
                    isDark,
                  ),
                ], isDark),

                const SizedBox(height: 25),

                if (supervisor != null) ...[
                  _buildSectionTitle(widget.isArabic ? "المشرف المسؤول" : "Supervisor"),
                  _buildSupervisorCard(isDark),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(bool isDark) {
    final String fullName = "${marketer!['firstName']} ${marketer!['lastName']}";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                fullName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            marketer!['email'] ?? "",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            widget.isArabic ? "النقاط" : "Points",
            marketer!["pointsAccumulated"].toString(),
            Icons.auto_awesome_rounded,
            primaryColor,
            isDark,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatItem(
            widget.isArabic ? "المستحق" : "Due Amount",
            "${marketer!["totalDueAmount"]}\$",
            Icons.account_balance_wallet_rounded,
            successColor,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(bool isDark) {
    String code = marketer!["promoCode"] ?? "---";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isArabic ? "كود الخصم الفعال" : "Active Promo Code",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isArabic ? "تم نسخ الكود" : "Code copied",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy_all_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildInfoSection(List<Widget> rows, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, Color iconColor, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white70 : Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSupervisorCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B5E20) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white12,
            child: Icon(Icons.person_pin_rounded, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${supervisor!['firstName']} ${supervisor!['lastName']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  supervisor!['phone'] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final phone = supervisor!['phone'];
              if (phone != null && phone.toString().isNotEmpty) {
                _makePhoneCall(phone.toString());
              }
            },
            icon: const Icon(
              Icons.phone_in_talk_rounded,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;

    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        right: widget.isArabic ? 5 : 0,
        left: widget.isArabic ? 0 : 5,
      ),
      child: Align(
        alignment: widget.isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.isArabic ? "خروج" : "Logout"),
        content: Text(
          widget.isArabic ? "هل تريد تسجيل الخروج؟" : "Do you want to logout?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isArabic ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              UserSession.clear();
              WebSession.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: Text(
              widget.isArabic ? "خروج" : "Logout",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() => Center(
    child: Text(
      widget.isArabic ? "حدث خطأ في تحميل البيانات" : "Error loading data",
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87,
      ),
    ),
  );
}