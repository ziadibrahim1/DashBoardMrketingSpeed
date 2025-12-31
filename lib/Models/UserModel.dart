class UserModel {
  final int id;
  final String name;
  final String email;
  final String status;
  final String phone;

  final int totalMessages;
  final int subscriptionDaysLeft;
  final int groups;

  // حقول جديدة
  final int blockedGroups;
  final int leftGroups;
  final int blockedChats;
  final int subscriptionsCount;
  final int suggestionsCount;
  final int suggestionRepliesCount;


  // حقول الاشتراك الجديدة
  final String? planName;
  final double? price;
  final String? startDate;
  final String? endDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.totalMessages,
    required this.subscriptionDaysLeft,
    required this.groups,
    required this.blockedGroups,
    required this.leftGroups,
    required this.blockedChats,
    required this.subscriptionsCount,
    required this.suggestionsCount,
    required this.suggestionRepliesCount,
    this.phone = 'N/A',
    this.planName,
    this.price,
    this.startDate,
    this.endDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final sub = json['latestSubscription'];

    return UserModel(
      id: json['id'] ?? 0,
      name: json['fullName'] ?? 'Unknown',
      email: json['email'] ?? 'noemail@example.com',
      status: json['status'] ?? 'inactive',
      phone: json['phone'] ?? 'لايوجد',

      totalMessages: json['totalMessages'] ?? 0,
      subscriptionDaysLeft: json['subscriptionDaysLeft'] ?? 0,
      groups: json['groups'] ?? 0,

      blockedGroups: json['blockedGroups'] ?? 0,
      leftGroups: json['leftGroups'] ?? 0,
      blockedChats: json['blockedChats'] ?? 0,
      subscriptionsCount: json['subscriptionsCount'] ?? 0,
      suggestionsCount: json['suggestionsCount'] ?? 0,
      suggestionRepliesCount: json['suggestionRepliesCount'] ?? 0,

      planName: sub?['planName'],
      price: sub?['price'] != null
          ? (sub['price'] as num).toDouble()
          : null,
      startDate: sub?['startDate'],
      endDate: sub?['endDate'],
    );
  }


}
