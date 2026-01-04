import 'dart:convert';
import 'package:admin_dashboard/core/user_session.dart';
import 'package:http/http.dart' as http;

import 'app_config.dart';

class ConversationModel {
  final int id;
  final int? userId;
  final int? agentId;
  final String userName;
  final String status;
  final String email;
  final String phone;
  final String country;
  final String city;
  final bool hasUnread;
  final SubscriptionModel? subscription;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final int? unreadCount;



  ConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    this.hasUnread = false,
    this.subscription,
    this.lastMessageAt,
    this.lastMessage,
    this.unreadCount,
    this.agentId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final sub = user?['subscriptionDetails'];

    return ConversationModel(
      id: json['id'],
      userId: json['userId'],
      status: json['status'] ?? '',
      userName: user?['first_name'] ?? 'Unknown',
      email: user?['email'] ?? 'Unknown',
      phone: user?['phone'] ?? 'Unknown',
      country: user?['country'] != null ? (user['country']['nameAr'] ?? user['country']['nameEn'] ?? 'غير معروف') : 'غير معروف',
      city: user?['city'] != null? (user['city']['nameAr'] ?? user['city']['nameEn'] ?? 'غير معروف') : 'غير معروف',
      hasUnread: json['hasUnread'] ?? false,
      subscription: sub != null ? SubscriptionModel.fromJson(sub) : null,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : null,
      lastMessage: json['lastMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      agentId: json['agentId'] ??0,


    );
  }
  ConversationModel copyWith({
    bool? hasUnread,
    String? status,
  }) {
    return ConversationModel(
      id: id,
      userName: userName,
      status: status ?? this.status,
      hasUnread: hasUnread ?? this.hasUnread,
      email: email,
      phone: phone,
      country: country,
      city: city,
      subscription: subscription, userId: userId,
      lastMessageAt: lastMessageAt,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      agentId: agentId,
    );
  }
}

class SubscriptionModel {
  final String planName;
  final double price;
  final String startDate;
  final String endDate;
  final int daysLeft;
  final bool? isActive;

  SubscriptionModel({
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.daysLeft,
    this.isActive,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['startDate'] ?? '');
    final end = DateTime.tryParse(json['endDate'] ?? '');
    int daysLeft = 0;

    if (end != null) {
      final now = DateTime.now();
      daysLeft = end.difference(now).inDays;
      if (daysLeft < 0) daysLeft = 0; // لو انتهى الاشتراك خليها صفر
    }
    return SubscriptionModel(
      planName: json['planName'] ?? 'بدون خطة',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      daysLeft: daysLeft,
      isActive: json['isActive'],
    );
  }
}
class ChatMessage {
  final int id;
  final String sender;
  final String? text;
  final String? attachmentUrl;
  final DateTime sentAt;
  final String? status;
  // 'sending', 'sent', 'delivered', 'read'

  ChatMessage({
    required this.id,
    required this.sender,
    this.text,
    this.attachmentUrl,
    required this.sentAt,
    this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      text: json['messageText'],
      attachmentUrl: json['attachmentUrl'],
      sentAt: DateTime.parse(json['sentAt']),
      status: json['status'],
    );
  }

  ChatMessage copyWith({
    int? id,
    String? sender,
    String? text,
    String? attachmentUrl,
    DateTime? sentAt,
    String? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
    );
  }
}

// ChatApi for REST fallback
class ChatApi {
  static Future<List<ChatMessage>> getMessages(int conversationId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}admin/conversations/$conversationId/messages'),
    );

    final data = jsonDecode(res.body) as List;
    return data.map((e) => ChatMessage.fromJson(e)).toList();
  }

  static Future<void> sendMessage(

      int conversationId,
      String? text,
      ) async {
    final agentId  = UserSession.userId;
    await http.post(
      Uri.parse('${AppConfig.baseUrl}admin/conversations/$conversationId/messages'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "messageText": text,
        "AgentId": agentId
      }),
    );
  }
}
class AdminChatHistoryModel {
  final int id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final bool online;
  late final String tag;

  AdminChatHistoryModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.online,
    required this.tag,
  });

  factory AdminChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return AdminChatHistoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      timestamp: DateTime.parse(json['lastMessageAt']),
      online: json['online'] ?? false,
      tag: json['tag'] ?? 'بانتظار الرد',
    );
  }
}
class AdminChatHistoryApi {
  static Future<List<AdminChatHistoryModel>> fetchHistory() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}admin/conversations/history'),
    );

    final List data = jsonDecode(res.body);
    return data
        .map((e) => AdminChatHistoryModel.fromJson(e))
        .toList();
  }

  static Future<void> closeConversation(int conversationId) async {
    await http.put(
      Uri.parse(
        '${AppConfig.baseUrl}admin/conversations/$conversationId/close',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode("closed"),
    );
  }

}
