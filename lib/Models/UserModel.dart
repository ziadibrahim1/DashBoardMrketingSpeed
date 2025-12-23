class UserModel {
  final int id;
  final String name;
  final String email;
    String status;
  final int groups;
  final int subscriptionDaysLeft;
  final int subscriptionCount;
  final int joinedSince;
  final DateTime joinedAt;
  final bool isSubscribedNow;
  int? totalMessages;
  int? messagesThisMonth;


  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.groups,
    required this.subscriptionDaysLeft,
    required this.subscriptionCount,
    required this.joinedSince,
    required this.joinedAt,
    required this.isSubscribedNow,
    required this.totalMessages,
    required this.messagesThisMonth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['fullName'],
      email: json['email'],
      status: json['status'],
      groups: json['groups'],
      subscriptionDaysLeft: json['subscriptionDaysLeft'],
      subscriptionCount: json['subscriptionCount'],
      joinedSince: json['joinedSince'],
      joinedAt: DateTime.parse(json['created_at']),
      isSubscribedNow: json['subscriptionDaysLeft'] > 0,
      totalMessages: json['totalMessages']??"",
      messagesThisMonth: json['messagesThisMonth']??"",
    );
  }

}
