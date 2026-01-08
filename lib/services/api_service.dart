import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../dashboard/pages/Package.dart';

class ApiService {
  static final String baseUrl = '${AppConfig.baseUrl}admin/packages';

  static Future<void> savePackage(Package p, bool isArabic) async {
    final body = {
      "nameAr": p.name,
      "nameEn": p.name,
      "price": p.price,
      "durationDays": p.durationDays,
      "discount": p.discount,
      "scheduledAt": p.startDate?.toIso8601String(),
      "status": p.status == PackageStatus.active ? "active" : "inactive",
      "features": p.features.map((f) => f.toJson()).toList(),
      "categoryId": p.CategoryId,
    };

    final uri = Uri.parse('${AppConfig.baseUrl}admin/packages');

    final headers = {
      "Content-Type": "application/json",
    };

    if (p.id == 0) {
      await http.post(uri, headers: headers, body: jsonEncode(body));
    } else {
      await http.put(
        Uri.parse('$uri/${p.id}'),
        headers: headers,
        body: jsonEncode(body),
      );
    }
  }
  static Future<bool> updatePackageStatus(int packageId, PackageStatus status) async {
    final res = await http.put(
      Uri.parse('${AppConfig.baseUrl}admin/packages/$packageId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );
    return res.statusCode == 200;
  }
  static Future<bool> toggleArchive(int packageId) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/$packageId/archive'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return res.body.toLowerCase() == 'true';
    } else {
      throw Exception('Failed to archive package');
    }
  }
  static Future<void> createPackage(Package p, bool isArabic) async {
    final body = {
      "nameAr": isArabic ? p.name : p.name,
      "nameEn": isArabic ? p.name : p.name,
      "price": p.price,
      "durationDays": p.durationDays,
      "discount": p.discount,
      "scheduledAt": p.startDate?.toIso8601String(),
      "status": p.status == PackageStatus.active ? "active" : "inactive",
      "features": p.features.map((f) => f.toJson()).toList(),
      "categoryId": p.CategoryId,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    if (p.id == 0) {
      await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      await http.put(
        Uri.parse('$baseUrl/create'),
        headers: headers,
        body: jsonEncode(body),
      );
    }
  }
  static Future<void> sendNotification({
    required int packageId,
    required String method,
    required String title,
    required String content,
    DateTime? scheduledAt,
  }) async {
    final url = Uri.parse('$baseUrl/$packageId/notify');
    final body = {
      'method': method,
      'title': title,
      'content': content,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
    };

    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));

    if (res.statusCode != 200) {
      throw Exception('Failed to send notification: ${res.body}');
    }
  }
}
