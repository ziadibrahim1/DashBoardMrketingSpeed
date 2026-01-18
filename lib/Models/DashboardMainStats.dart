class DashboardMainStats {
  final int totalUsers;
  final int totalAdmins;
  final int annualSubscribers;
  final int whatsappMessages;
  final int telegramMessages;
  final int whatsappGroups;
  final int telegramChannels;
  final Map<String, int> platformMessages;
  final Map<String, int> monthlySubscriptions;

  DashboardMainStats.fromJson(Map<String, dynamic> json)
      : totalUsers = json['totalUsers'],
        totalAdmins = json['totalAdmins'],
        annualSubscribers = json['annualSubscribers'],
        whatsappMessages = json['whatsappMessages'],
        telegramMessages = json['telegramMessages'],
        whatsappGroups = json['whatsappGroups'],
        telegramChannels = json['telegramChannels'],
        platformMessages = Map<String, int>.from(json['platformMessages']),
        monthlySubscriptions =
        Map<String, int>.from(json['monthlySubscriptions']);
}
