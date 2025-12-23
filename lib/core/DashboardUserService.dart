import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/app_config.dart';

class DashboardUserService {
  final String baseUrl;

  DashboardUserService({required this.baseUrl});

  Future<Map<String, dynamic>> createSupervisor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String Role,
    required String Country,
    required String City,
    required double Age,
    required String Bank,
    required String AccountNumber,
  })
  async {
    final response = await http.post(
      Uri.parse('${baseUrl}admin/S_M_Users/create-supervisor'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'FullName': fullName,
        'Email': email,
        'Phone': phone,
        'Password': password,
        'Role': Role,
        'Country': Country,
        'City': City,
        'Age': Age,
        'Bank': Bank,
        'AccountNumber': AccountNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create supervisor');
    }
  }

  // ---------------------------
  // تعديل مشرف
  // ---------------------------
  Future<Map<String, dynamic>> updateSupervisor({
    required int supervisorId,
    required Map<String, dynamic> body,
  })
  async {
    final res = await http.put(
      Uri.parse('${baseUrl}admin/S_M_Users/update-supervisor/$supervisorId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return jsonDecode(res.body);
  }
  // ---------------------------
  // حذف مشرف
  // ---------------------------
  Future<Map<String, dynamic>>
  deleteSupervisor(int supervisorId) async {
    final res = await http.delete(
      Uri.parse('${baseUrl}admin/S_M_Users/delete-supervisor/$supervisorId'),
    );
    return jsonDecode(res.body);
  }


  // ---------------------------
  // تعديل مسوق
  // ---------------------------
  Future<Map<String, dynamic>> updateMarketer({required int marketerId, required Map<String, dynamic> body,})
  async {
    print('body $body');
    final res = await http.put(
      Uri.parse('${baseUrl}admin/S_M_Users/update-marketer/$marketerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return jsonDecode(res.body);
  }

  // ---------------------------
  // حذف مسوق
  // ---------------------------
  Future<Map<String, dynamic>> deleteMarketer(int marketerId)
  async {
    final res = await http.delete(
      Uri.parse('${baseUrl}admin/S_M_Users/delete-marketer/$marketerId'),
    );

    return jsonDecode(res.body);
  }
  Future<Map<String, dynamic>> createMarketer({
    required String fullName,
    required String email,
    required String phone,
    required String password, required int supervisorId,
    required String Country,
    required String City,
    required double Age,
    required String Bank,
    required String AccountNumber,
    required double PointPrice,
    required double TotalDueAmount,
    required int PointsAccumulated,
  })
  async {

    final response = await http.post(
      Uri.parse('${baseUrl}admin/S_M_Users/marketers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'FullName': fullName,
        'Email': email,
        'Phone': phone,
        'Password': password,
        'supervisorId': supervisorId,
        'Country': Country,
        'City': City,
        'Age': Age,
        'Bank': Bank,
        'AccountNumber': AccountNumber,
        'PointPrice': PointPrice,
        'TotalDueAmount': TotalDueAmount,
        'PointsAccumulated': PointsAccumulated,

      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {

      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create marketer: ${response.body}');
    }
  }
}
