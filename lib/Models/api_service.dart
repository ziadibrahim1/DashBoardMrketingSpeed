import 'dart:convert';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final baseUrl = AppConfig.baseUrl;

  /* =======================================================
     🟦 جلب الدول
     ======================================================= */
  static Future<List<dynamic>> getCountries() async {
    final res = await http.get(Uri.parse('${baseUrl}ourGroups/countries'));
    return jsonDecode(res.body);
  }

  /* =======================================================
     🟦 حفظ / إضافة دولة
     ======================================================= */
  static Future<void> saveCountry(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${baseUrl}ourGroups/countries/save'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nameAr': data['nameAr'],
        'nameEn': data['nameEn'],
        'isoCode': data['isoCode'],
        'phoneCode': data['phoneCode'],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  /* =======================================================
     🟦 جلب المجالات
     ======================================================= */
  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(Uri.parse('${baseUrl}ourGroups/categories'));
    return jsonDecode(res.body);
  }

  /* =======================================================
     🟦 حفظ / إضافة مجال (Category)
     ======================================================= */
  static Future<void> saveCategory(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${baseUrl}ourGroups/categories/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nameAr': data['nameAr'],
        'nameEn': data['nameEn'],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }

  /* =======================================================
     🟦 جلب الجروبات
     ======================================================= */
  static Future<List<dynamic>> getGroups() async {
    final res = await http.get(Uri.parse('${baseUrl}ourGroups/groups'));
    return jsonDecode(res.body);
  }

  /* =======================================================
     🟩 حفظ جروب جديد
     ======================================================= */
  static Future<bool> saveGroup(Map<String, dynamic> body) async {
    // تحضير البيانات بالشكل المطلوب من الـ API
    final requestBody = {
      'id': 0, // 0 للإضافة الجديدة
      'groupName': body['groupName'] ?? '',
      'description': body['description'] ?? body['groupName'] ?? 'No description',
      'inviteLink': body['inviteLink'] ?? '',
      'countryId': body['countryId'] ?? 0,
      'categoryId': body['categoryId'] ?? 0,
      'isHidden': body['isHidden'] ?? false,
      'sendingStatus': body['sendingStatus'] ?? 'open',
      'platformId': body['platformId'] ?? 1,
    };

    final response = await http.post(
      Uri.parse('${baseUrl}ourGroups/groups/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print("Request body: $requestBody");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response.statusCode == 200;
  }

  /* =======================================================
     🟨 تحديث جروب موجود
     ======================================================= */
  static Future<void> updateGroup(int groupId, Map<String, dynamic> updates) async {
    // جلب بيانات الجروب الحالية أولاً
    final groups = await getGroups();
    final currentGroup = groups.firstWhere(
          (g) => g['id'] == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    // دمج البيانات الحالية مع التحديثات
    final requestBody = {
      'id': groupId,
      'groupName': updates['groupName'] ?? currentGroup['groupName'] ?? '',
      'description': updates['description'] ?? currentGroup['description'] ?? updates['groupName'] ?? currentGroup['groupName'] ?? 'No description',
      'inviteLink': updates['inviteLink'] ?? currentGroup['inviteLink'] ?? '',
      'countryId': updates['countryId'] ?? currentGroup['countryId'] ?? 0,
      'categoryId': updates['categoryId'] ?? currentGroup['categoryId'] ?? 0,
      'isHidden': updates.containsKey('isHidden')
          ? updates['isHidden']
          : (currentGroup['isHidden'] ?? false),
      'sendingStatus': updates['sendingStatus'] ?? currentGroup['sendingStatus'] ?? 'open',
      'platformId': updates['platformId'] ?? currentGroup['platformId'] ?? 1,
    };

    final response = await http.post(
      Uri.parse('${baseUrl}ourGroups/groups/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print("Update Request body: $requestBody");
    print("Update Response status: ${response.statusCode}");
    print("Update Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to update group: ${response.body}');
    }
  }

  /* =======================================================
     🟥 حذف جروب
     ======================================================= */
  static Future<void> deleteGroup(int groupId) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}ourGroups/groups/$groupId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete group');
    }
  }
}