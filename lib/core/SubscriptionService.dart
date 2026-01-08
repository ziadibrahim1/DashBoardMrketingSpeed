import 'dart:convert';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

import '../Models/SubscriptionModel.dart';

class SubscriptionService {
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static final baseUrl = '${AppConfig.baseUrl}admin/subscriptions';
  static Future<void> updateSubscriptionDates(
      int id,
      DateTime startDate,
      DateTime endDate,
      )
  async {
    await http.put(
      Uri.parse('${AppConfig.baseUrl}admin/subscriptions/$id/dates'),
      headers: headers,
      body: jsonEncode({
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      }),
    );
  }
  static Future<Map<String, dynamic>> fetchSubscriptions({
    String status = 'all',
    String type = 'all',
    String search = '',
    int page = 1,
    int pageSize = 20,
  })
  async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'status': status,
      'type': type,
      'search': search,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load subscriptions');
    }
  }

  static Future<SubscriptionModel> renew(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$id/renew'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to renew subscription');
    }
    return SubscriptionModel.fromJson(jsonDecode(response.body));
  }

  static Future<void> freeze(int subscriptionId) async {
    final url = Uri.parse('$baseUrl/$subscriptionId/freeze');
    final res = await http.post(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to freeze subscription');
    }
  }

  static Future<void> unfreeze(int subscriptionId) async {
    final url = Uri.parse('$baseUrl/$subscriptionId/unfreeze');
    final res = await http.post(url, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('Failed to unfreeze subscription');
    }
  }

  static Future<void> addGiftGroups({
    required int subscriptionId,
    required int groupsCount,
  required int userId,
  })
  async {
    final response = await http.post(
      Uri.parse('$baseUrl/$subscriptionId/$userId/gift-groups'),
      headers: headers,
      body: jsonEncode(groupsCount),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add gift groups');
    }
  }
  static Future<void> addGiftDays({
    required int subscriptionId,
    required int DaysCount,
  required int userId,
  })
  async {
    final response = await http.post(
      Uri.parse('$baseUrl/$subscriptionId/$userId/add-gift-days'),
      headers: headers,
      body: jsonEncode(DaysCount),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add gift groups');
    }
  }


}
