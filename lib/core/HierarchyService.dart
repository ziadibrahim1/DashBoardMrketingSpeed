import 'dart:convert';
import 'package:admin_dashboard/core/user_session.dart';
import 'package:http/http.dart' as http;

import '../Models/Marketer.dart';

class HierarchyService {
  final String baseUrl;
  HierarchyService(this.baseUrl);

  Future<List<Supervisor>> fetchSupervisorsTree(int dashboardUserId, String role) async {
    final res = await http.get(
      Uri.parse('${baseUrl}admin/hierarchy/supervisors-tree?userId=$dashboardUserId&role=$role'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load hierarchy');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Supervisor.fromJson(e)).toList();
  }

  Future<void> updateUserStatus({
    required int dashboardUserId,
    required bool isActive,
    required bool isDeleted,
  })
  async {
    final res = await http.patch(
      Uri.parse('${baseUrl}admin/users/update-status/$dashboardUserId'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'isActive': isActive,
        'isDeleted': isDeleted,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<String?> _getToken() async {
    return UserSession.getToken();
  }

}
