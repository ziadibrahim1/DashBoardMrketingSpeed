class SubscriptionModel {
  final int id;
  final String? user;
  final String email;
  final int userId;
    String? type;
    String? startDate;
    String? endDate;
    String? status;
    int? RemainingCount;

  SubscriptionModel({
    required this.id,
    required this.user,
    required this.email,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.RemainingCount,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // نجيب الاسم أو نستخدم UserId كبديل
    String? username = json['userName'] ?? json['user'];
    if (username == null || username.isEmpty) {
      username = 'User #${json['userId'] ?? 'Unknown'}';
    }

    // التاريخ
    String formatDate(dynamic date) {
      if (date == null) return 'دائم';
      try {
        return date.toString().substring(0, 10);
      } catch (_) {
        return 'دائم';
      }
    }

    return SubscriptionModel(
      id: json['subscriptionId'] ?? 0,
      user: username,
      email: json['email'] ?? '',
      userId: json['userId'] ?? 0,
      type: json['planName'] ?? 'Free',
      startDate: formatDate(json['startDate']),
      endDate: formatDate(json['endDate']),
      status: json['status'] ?? (json['isActive'] == true ? 'active' : 'expired'),
      RemainingCount: json['remainingCount'] ?? 0,
    );
  }

}
