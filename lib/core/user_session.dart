import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class UserSession {
  static const _kUserKey = 'current_user';

  static const _kTokenKey = 'jwt_token';
  static Map<String, dynamic>? _cachedUser;
  static void saveToken(String token) {
    html.window.sessionStorage[_kTokenKey] = token;
  }

  static String? getToken() {
    return html.window.sessionStorage[_kTokenKey];
  }
  /// -------------------------------
  /// 🔐 جلب المستخدم من السيشن
  /// -------------------------------
  static Map<String, dynamic>? getUser() {
    if (_cachedUser != null) return _cachedUser;

    final json = html.window.sessionStorage[_kUserKey];
    if (json == null) return null;

    _cachedUser = jsonDecode(json) as Map<String, dynamic>;
    return _cachedUser;
  }


  /// -------------------------------
  /// 💾 حفظ المستخدم في السيشن
  /// -------------------------------
  static void saveUser(Map<String, dynamic> user) {
    _cachedUser = user;
    html.window.sessionStorage[_kUserKey] = jsonEncode(user);
  }

  /// -------------------------------
  static void clear() {
    _cachedUser = null;
    html.window.sessionStorage.remove(_kUserKey);
  }

  /// -------------------------------
  /// 🌐 Getters
  /// -------------------------------
  static int? get userId => getUser()?['id'];
  static String? get role => getUser()?['role'];
  static String? get name => getUser()?['fullName'] ?? getUser()?['email'];
  static String? get email => getUser()?['email'];
  static String? get firstName => getUser()?['firstName'];
  static String? get middleName => getUser()?['middleName'];
  static String? get lastName => getUser()?['lastName'];
  static String? get phone => getUser()?['phone'];
  static String? get country => getUser()?['country'];
  static String? get city => getUser()?['city'];
  static String? get bank => getUser()?['bank'];
  static String? get iban => getUser()?['iban'];
  static String? get imagePath => getUser()?['imagePath'];
  static String? get theme => getUser()?['theme'];
  static bool get isActive => getUser()?['isActive'] == true;
  static bool get langAr => getUser()?['langAr'] == true;

  /// -------------------------------
  /// 🟩 تحويل الصلاحيات لماب قوية
  /// -------------------------------
  static Map<String, List<String>> get permissions {
    final user = getUser();
    if (user == null || user['permissions'] == null) return {};

    final perms = user['permissions'] as Map<String, dynamic>;
    return perms.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  /// -------------------------------
  /// 🟥 فحص وجود الصلاحية فقط
  /// -------------------------------
  static bool hasPermission(String category, String action) {
    final user = getUser();
    if (user == null) return false;

    final perms = user['permissions'] as Map<String, dynamic>?;
    if (perms == null) return false;

    if (!perms.containsKey(category)) return false;

    return perms[category].contains(action);
  }

  /// ---------------------------------------------------------
  /// ✅ ✨✨ الدالة الجديدة — فحص الصلاحية + رسالة منع موحدة ✨✨
  /// ---------------------------------------------------------
  static bool checkPermission(
      BuildContext context,
      String category,
      String action, {
        VoidCallback? onDenied,
      })
  {
    if (!hasPermission(category, action)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ لا تملك صلاحية: $category → $action"),
          backgroundColor: Colors.red,
        ),
      );
      if (onDenied != null) onDenied();
      return false;
    }
    return true;
  }
}
//120363029228676020@g.us
//14849727957-1471078734@g.us