import 'dart:convert';
import 'dart:math';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;

import 'DashboardStats.dart';

class AdminApi {
  static final String baseUrl = AppConfig.baseUrl;

  Future<List<AdminUser>> getUsers() async {
    final res = await http.get(
      Uri.parse('${baseUrl}admin/users-with-details'),
    );

    final data = jsonDecode(res.body);
    return (data['users'] as List)
        .map((e) => AdminUser.fromJson(e))
        .toList();
  }




  Future<List<MessageLog>> getUserMessages(int userId) async {
    final res = await http.get(
      Uri.parse('${baseUrl}admin/users/$userId/messages'),
    );

    final data = jsonDecode(res.body);
    return (data['messages'] as List)
        .map((e) => MessageLog.fromJson(e))
        .toList();
  }
  Future<List<GroupModel>> getGroups(int userId) async {
    final res = await http.get(
      Uri.parse('${baseUrl}admin/groups/$userId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => GroupModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل تحميل الجروبات');
    }
  }

  Future<void> sendMessage({
    required int userId,
    String? recipient, // مستخدم فردي (اختياري)
    List<String>? groupIds, // جروبات (اختياري)
    required String message,
  })
  async {
    final body = {
      'userId': userId,
      'message': message,
    };

    if (recipient != null && recipient.isNotEmpty) {
      body['recipient'] = recipient;
    }

    if (groupIds != null && groupIds.isNotEmpty) {
      body['groupIds'] = groupIds;
    }

    final res = await http.post(
      Uri.parse('${baseUrl}admin/send-to-groups/${userId}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('فشل الإرسال');
    }
  }
  Future<void> randomDelay() async {
    final random = Random();
    final seconds = 15 + random.nextInt(11); // من 15 إلى 25
    await Future.delayed(Duration(seconds: seconds));
  }
  Future<void> sendMessagesWithRandomDelay({
    required int userId,
    required List<String> groupIds,
    required String message,
  }) async {
    for (final groupId in groupIds) {
      await sendMessage(
        userId: userId,
        groupIds: [groupId], // جروب واحد في كل مرة
        message: message,
      );

      // تأخير عشوائي بين كل رسالة
      await randomDelay();
    }
  }
  Future<void> sendToRecipientsWithRandomDelay({
    required int userId,
    required List<String> recipients,
    required String message,
  }) async {
    for (final recipient in recipients) {
      await sendMessage(
        userId: userId,
        recipient: recipient,
        message: message,
      );

      await randomDelay();
    }
  }


}

class AdminUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String subscriptionStatus;
  final String connectionStatus;
  final String accessToken;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscriptionStatus,
    required this.connectionStatus,
    required this.accessToken,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      name:
      '${json['first_name']} ${json['last_name'] ?? ''}'.trim(),
      email: json['email'],
      phone: json['phone'],
      subscriptionStatus: json['subscription_status'],
      connectionStatus: json['connection_status'],
      accessToken: json['accessToken'],
    );
  }
}
class MessageLog {
  final int id;
  final String recipient;
  final String message;
  final String status;
  final DateTime createdAt;

  MessageLog({
    required this.id,
    required this.recipient,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory MessageLog.fromJson(Map<String, dynamic> json) {
    return MessageLog(
      id: json['id'],
      recipient: json['recipient'],
      message: json['body'],
      status: json['status'],
      createdAt: DateTime.parse(json['attemptedAt']),
    );
  }
}
class GroupModel {
  final String id;
  final String name;
  final int participantCount;

  GroupModel({
    required this.id,
    required this.name,
    required this.participantCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      participantCount: json['participantCount'] ?? 0,
    );
  }
}
