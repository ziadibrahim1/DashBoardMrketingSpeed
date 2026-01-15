import 'dart:convert';

import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

class DashboardStats {
  final int groupMessages;
  final int chatMessages;
  final int memberMessages;
  final int privateGroups;

  DashboardStats({
    required this.groupMessages,
    required this.chatMessages,
    required this.memberMessages,
    required this.privateGroups,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      groupMessages: json['groupMessages'],
      chatMessages: json['chatMessages'],
      memberMessages: json['memberMessages'],
      privateGroups: json['privateGroups'],
    );
  }
  final String baseUrl = AppConfig.baseUrl;


  Future<DashboardStats> fetchDashboardStats() async {
    final response = await http.get(
      Uri.parse('${baseUrl}dashboard/stats'),
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

}
class GroupRequestModel {
  final int id;
  final String groupName;
  final String groupLink;
  final String status;

  GroupRequestModel({
    required this.id,
    required this.groupName,
    required this.groupLink,
    required this.status,
  });

  factory GroupRequestModel.fromJson(Map<String, dynamic> json) {
    return GroupRequestModel(
      id: json['id'],
      groupName: json['groupName'] ?? '',
      groupLink: json['groupLink'],
      status: json['status'],
    );
  }

  bool get isApproved => status == 'approved';
}
class CountryMessageStats {
  final int countryId;
  final String countryNameAr;
  final String countryNameEn;
  final String isoCode;
  final int messageCount;
  final double percentage;

  CountryMessageStats({
    required this.countryId,
    required this.countryNameAr,
    required this.countryNameEn,
    required this.isoCode,
    required this.messageCount,
    required this.percentage,
  });

  factory CountryMessageStats.fromJson(Map<String, dynamic> json) {
    return CountryMessageStats(
      countryId: json['countryId'] ?? 0,
      countryNameAr: json['countryNameAr'] ?? '',
      countryNameEn: json['countryNameEn'] ?? '',
      isoCode: json['isoCode'] ?? '',
      messageCount: json['messageCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}