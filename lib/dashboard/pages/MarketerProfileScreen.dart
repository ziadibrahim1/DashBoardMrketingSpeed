import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للنسخ إلى الحافظة
import 'package:http/http.dart' as http;
import '../../core/app_config.dart';
import '../../core/user_session.dart';
import '../../core/web_session.dart';
import 'login_screen.dart';

class MarketerProfileScreen extends StatefulWidget {
  final int? marketerId;

  const MarketerProfileScreen({super.key, this.marketerId});

  @override
  State<MarketerProfileScreen> createState() => _MarketerProfileScreenState();
}

class _MarketerProfileScreenState extends State<MarketerProfileScreen> {
  bool loading = true;
  bool error = false;

  Map<String, dynamic>? marketer;
  Map<String, dynamic>? supervisor;

  // لوحة الألوان المحدثة
  final Color primaryColor = const Color(0xFF2563EB); // Blue
  final Color successColor = const Color(0xFF10B981); // Green
  final Color bgColor = const Color(0xFFF8FAFC);

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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : error
          ? _buildErrorUI()
          : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      centerTitle: true,
      title: const Text("ملفي الشخصي", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.white),
          onPressed: () => _confirmLogout(context),
        )
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // رأس الصفحة الملون
          _buildTopHeader(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. كروت الإحصائيات المالية
                _buildFinanceStats(),

                const SizedBox(height: 25),

                // 2. كود الخصم (Promo Code)
                _buildPromoCard(),

                const SizedBox(height: 25),

                // 3. المعلومات الشخصية (كاملة)
                _buildSectionTitle("المعلومات الشخصية"),
                _buildInfoSection([
                  _buildDataRow(Icons.location_city_rounded, "المدينة", marketer!['city'] ?? "-", Colors.redAccent),
                  _buildDataRow(Icons.public_rounded, "الدولة", marketer!['country'] ?? "-", Colors.blueAccent),
                  _buildDataRow(Icons.phone_android_rounded, "رقم الجوال", marketer!['phone'] ?? "-", Colors.green),
                ]),

                const SizedBox(height: 25),

                // 4. البيانات البنكية
                _buildSectionTitle("البيانات البنكية"),
                _buildInfoSection([
                  _buildDataRow(Icons.account_balance_rounded, "البنك", marketer!['bank'] ?? "-", Colors.indigo),
                  _buildDataRow(Icons.numbers_rounded, "رقم الحساب", marketer!['accountNumber'] ?? "-", Colors.blueGrey),
                ]),

                const SizedBox(height: 25),

                // 5. بيانات المشرف
                if (supervisor != null) ...[
                  _buildSectionTitle("المشرف المسؤول"),
                  _buildSupervisorCard(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    final String fullName = "${marketer!['firstName']} ${marketer!['lastName']}";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(fullName[0].toUpperCase(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor)),
            ),
          ),
          const SizedBox(height: 15),
          Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(marketer!['email'] ?? "", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildFinanceStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            "النقاط",
            marketer!["pointsAccumulated"].toString(),
            Icons.auto_awesome_rounded,
            primaryColor,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatItem(
            "المستحق",
            "${marketer!["totalDueAmount"]}\$",
            Icons.account_balance_wallet_rounded,
            successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    String code = marketer!["promoCode"] ?? "---";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade800]),
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
                const Text("كود الخصم الفعال", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(code, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نسخ الكود")));
            },
            icon: const Icon(Icons.copy_all_rounded, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildInfoSection(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget _buildSupervisorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark Navy
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.person_pin_rounded, color: Colors.white)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${supervisor!['firstName']} ${supervisor!['lastName']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(supervisor!['phone'] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // إجراء الاتصال
            icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: Align(alignment: Alignment.centerRight, child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
    );
  }

  // دالة تأكيد الخروج
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("خروج"),
        content: const Text("هل تريد تسجيل الخروج؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              UserSession.clear();
              WebSession.clear();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            child: const Text("خروج", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() => const Center(child: Text("حدث خطأ في تحميل البيانات"));
}