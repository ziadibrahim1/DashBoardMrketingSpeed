class UserModel {
  final int id;
  final String name;
  final String email;
  final String status;
  final String phone;
  final String city;
  final String country;

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
  final List<UserSubscription> subscriptions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.phone,
    required this.totalMessages,
    required this.subscriptionDaysLeft,
    required this.groups,
    required this.blockedGroups,
    required this.leftGroups,
    required this.blockedChats,
    required this.subscriptionsCount,
    required this.suggestionsCount,
    required this.suggestionRepliesCount,
    required this.subscriptions,
     this.city = '',
     this.country = '',
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    final List subsJson = json['subscriptions'] ?? [];

    return UserModel(
      id: json['id'] ?? 0,
      name: json['fullName'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? 'لا يوجد',
      status: json['status'] ?? 'inactive',

      totalMessages: json['totalMessages'] ?? 0,
      subscriptionDaysLeft: json['subscriptionDaysLeft'] ?? 0,
      groups: json['groups'] ?? 0,

      blockedGroups: json['blockedGroups'] ?? 0,
      leftGroups: json['leftGroups'] ?? 0,
      blockedChats: json['blockedUsersCount'] ?? 0,
      subscriptionsCount: json['subscriptionCount'] ?? 0,
      suggestionsCount: json['suggestionsCount'] ?? 0,
      suggestionRepliesCount: json['suggestionRepliesCount'] ?? 0,
      city: json['city'] ?? '',
      country: json['country'] ?? '',


      subscriptions: subsJson
          .map((e) => UserSubscription.fromJson(e))
          .toList(),
    );
  }

}
class UserSubscription {
  final String planName;
  final double price;
  final String startDate;
  final String endDate;
  final int daysLeft;

  UserSubscription({
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.daysLeft,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      planName: json['planName'] ?? '',
      price: (json['price'] as num).toDouble(),
      startDate: json['startDate'],
      endDate: json['endDate'],
      daysLeft: json['daysLeft'] ?? 0,
    );
  }
}
