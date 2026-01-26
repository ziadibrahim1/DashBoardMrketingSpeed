// lib/services/reports_api_service.dart
import 'dart:typed_data';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

class ReportsApiService {
  static final String baseUrl = '${AppConfig.baseUrl}reports';
  final String? authToken;

  ReportsApiService({this.authToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // 1️⃣ تقرير الاشتراكات - يرجع PDF مباشرة
  Future<Uint8List> getSubscriptionsPdf() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير الاشتراكات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 2️⃣ تقرير الرسائل - يرجع PDF مباشرة
  Future<Uint8List> getMessagesPdf(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/pdf?period=$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير الرسائل');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 3️⃣ تقرير المجموعات - يرجع PDF مباشرة
  Future<Uint8List> getGroupsPdf(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/pdf?period=$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير المجموعات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 4️⃣ تقرير العملاء الجدد - يرجع PDF مباشرة
  Future<Uint8List> getNewCustomersPdf(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/new-customers/pdf?period=$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير العملاء');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 5️⃣ تقرير الباقات الأكثر طلباً - يرجع PDF مباشرة
  Future<Uint8List> getPopularPackagesPdf() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/popular-packages/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير الباقات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 6️⃣ تقرير المحادثات - يرجع PDF مباشرة
  Future<Uint8List> getConversationsPdf() async {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/pdf'),
        headers: _headers,
      );
      print('body : ${response.toString()}');
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير المحادثات');
      }

  }

  // 7️⃣ تقرير المكافآت - يرجع PDF مباشرة
  Future<Uint8List> getRewardsPdf() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feature-grants/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير المكافآت');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 8️⃣ تقرير المسوقين - يرجع PDF مباشرة
  Future<Uint8List> getMarketersPdf() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/supervisors-marketers/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير المسوقين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 9️⃣ تقرير الاقتراحات - يرجع PDF مباشرة
  Future<Uint8List> getSuggestionsPdf(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suggestions-report/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير الاقتراحات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 🔟 تقرير الباقات المتاحة - يرجع PDF مباشرة
  Future<Uint8List> getPackagesDetailsPdf() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/packages-features/pdf'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('فشل تحميل تقرير الباقات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}