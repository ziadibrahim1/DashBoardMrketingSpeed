import 'dart:convert';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/report_item.dart';

class ReportsApiService {
  static const String baseUrl = '${AppConfig.apiBase}/api/reports';
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };


  Future<SubscriptionsReportDto> getSubscriptionsReport() async {
    try {
      final url = '$baseUrl/subscriptions';
      print('CALLING => $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('STATUS => ${response.statusCode}');
      print('BODY => ${response.body}');

      if (response.statusCode == 200) {
        return SubscriptionsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير الاشتراكات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<MessagesReportDto> getMessagesReport(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return MessagesReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير الرسائل');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<GroupsReportDto> getGroupsReport(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return GroupsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير المجموعات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<NewCustomersReportDto> getNewCustomersReport(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/new-customers/$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return NewCustomersReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير العملاء الجدد');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<PopularPackagesReportDto> getPopularPackagesReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/popular-packages'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return PopularPackagesReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير الباقات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<ConversationsReportDto> getConversationsReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ConversationsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير المحادثات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<RewardsReportDto> getRewardsReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rewards'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return RewardsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير المكافآت');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<MarketersReportDto> getMarketersReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return MarketersReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير المسوقين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<SuggestionsReportDto> getSuggestionsReport(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suggestions/$period'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return SuggestionsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تقرير الاقتراحات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  Future<PackagesDetailsReportDto> getPackagesDetailsReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/packages-details'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return PackagesDetailsReportDto.fromJson(json.decode(response.body));
      } else {
        throw Exception('فشل تحميل تفاصيل الباقات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}