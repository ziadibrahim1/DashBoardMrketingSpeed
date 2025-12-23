import 'dart:convert';
import 'dart:html' as html;

class WebSession {
  static const _kUser = 'dash_user';

  static void saveUser(Map<String, dynamic> user) {
    html.window.sessionStorage[_kUser] = jsonEncode(user);
  }

  static Map<String, dynamic>? getUser() {
    final s = html.window.sessionStorage[_kUser];
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static void clear() {
    html.window.sessionStorage.remove(_kUser);
  }
}
