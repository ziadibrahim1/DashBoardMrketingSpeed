
class SubscriptionsReportDto {
  final int totalMonthly;
  final double totalRevenue;

  SubscriptionsReportDto({
    required this.totalMonthly,
    required this.totalRevenue,
  });

  factory SubscriptionsReportDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionsReportDto(
      totalMonthly: json['totalMonthly'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class MessagesReportDto {
  final String period;
  final int total;
  final List<PeriodData> data;

  MessagesReportDto({
    required this.period,
    required this.total,
    required this.data,
  });

  factory MessagesReportDto.fromJson(Map<String, dynamic> json) {
    return MessagesReportDto(
      period: json['period'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => PeriodData.fromJson(e))
          .toList(),
    );
  }
}

class PeriodData {
  final String label;
  final int count;

  PeriodData({required this.label, required this.count});

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class GroupsReportDto {
  final String period;
  final int total;
  final List<PeriodData> data;

  GroupsReportDto({
    required this.period,
    required this.total,
    required this.data,
  });

  factory GroupsReportDto.fromJson(Map<String, dynamic> json) {
    return GroupsReportDto(
      period: json['period'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => PeriodData.fromJson(e))
          .toList(),
    );
  }
}

class NewCustomersReportDto {
  final String period;
  final int total;
  final List<CustomerPeriodData> data;

  NewCustomersReportDto({
    required this.period,
    required this.total,
    required this.data,
  });

  factory NewCustomersReportDto.fromJson(Map<String, dynamic> json) {
    return NewCustomersReportDto(
      period: json['period'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => CustomerPeriodData.fromJson(e))
          .toList(),
    );
  }
}

class CustomerPeriodData {
  final String label;
  final int count;
  final int withSubscription;

  CustomerPeriodData({
    required this.label,
    required this.count,
    required this.withSubscription,
  });

  factory CustomerPeriodData.fromJson(Map<String, dynamic> json) {
    return CustomerPeriodData(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
      withSubscription: json['withSubscription'] ?? 0,
    );
  }
}

class PopularPackagesReportDto {
  final List<PackageStats> packages;

  PopularPackagesReportDto({required this.packages});

  factory PopularPackagesReportDto.fromJson(Map<String, dynamic> json) {
    return PopularPackagesReportDto(
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackageStats.fromJson(e))
          .toList(),
    );
  }
}

class PackageStats {
  final String nameAr;
  final String nameEn;
  final int subscriberCount;
  final double totalRevenue;

  PackageStats({
    required this.nameAr,
    required this.nameEn,
    required this.subscriberCount,
    required this.totalRevenue,
  });

  factory PackageStats.fromJson(Map<String, dynamic> json) {
    return PackageStats(
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      subscriberCount: json['subscriberCount'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class ConversationsReportDto {
  final int totalMonthly;
  final int active;
  final int closed;
  final double avgDurationMinutes;

  ConversationsReportDto({
    required this.totalMonthly,
    required this.active,
    required this.closed,
    required this.avgDurationMinutes,
  });

  factory ConversationsReportDto.fromJson(Map<String, dynamic> json) {
    return ConversationsReportDto(
      totalMonthly: json['totalMonthly'] ?? 0,
      active: json['active'] ?? 0,
      closed: json['closed'] ?? 0,
      avgDurationMinutes: (json['avgDurationMinutes'] ?? 0).toDouble(),
    );
  }
}

class RewardsReportDto {
  final int totalGranted;
  final int totalUsed;
  final int totalRemaining;
  final List<RewardBreakdown> breakdown;

  RewardsReportDto({
    required this.totalGranted,
    required this.totalUsed,
    required this.totalRemaining,
    required this.breakdown,
  });

  factory RewardsReportDto.fromJson(Map<String, dynamic> json) {
    return RewardsReportDto(
      totalGranted: json['totalGranted'] ?? 0,
      totalUsed: json['totalUsed'] ?? 0,
      totalRemaining: json['totalRemaining'] ?? 0,
      breakdown: (json['breakdown'] as List? ?? [])
          .map((e) => RewardBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class RewardBreakdown {
  final String reason;
  final int count;

  RewardBreakdown({required this.reason, required this.count});

  factory RewardBreakdown.fromJson(Map<String, dynamic> json) {
    return RewardBreakdown(
      reason: json['reason'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class MarketersReportDto {
  final int totalMarketers;
  final int activeMarketers;
  final int frozenMarketers;
  final int totalSupervisors;
  final int activeSupervisors;
  final List<MarketerStats> topMarketers;

  MarketersReportDto({
    required this.totalMarketers,
    required this.activeMarketers,
    required this.frozenMarketers,
    required this.totalSupervisors,
    required this.activeSupervisors,
    required this.topMarketers,
  });

  factory MarketersReportDto.fromJson(Map<String, dynamic> json) {
    return MarketersReportDto(
      totalMarketers: json['totalMarketers'] ?? 0,
      activeMarketers: json['activeMarketers'] ?? 0,
      frozenMarketers: json['frozenMarketers'] ?? 0,
      totalSupervisors: json['totalSupervisors'] ?? 0,
      activeSupervisors: json['activeSupervisors'] ?? 0,
      topMarketers: (json['topMarketers'] as List? ?? [])
          .map((e) => MarketerStats.fromJson(e))
          .toList(),
    );
  }
}

class MarketerStats {
  final String name;
  final int points;
  final String promoCode;

  MarketerStats({
    required this.name,
    required this.points,
    required this.promoCode,
  });

  factory MarketerStats.fromJson(Map<String, dynamic> json) {
    return MarketerStats(
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      promoCode: json['promoCode'] ?? '',
    );
  }
}

class SuggestionsReportDto {
  final String period;
  final int total;
  final int starred;
  final List<PeriodData> data;

  SuggestionsReportDto({
    required this.period,
    required this.total,
    required this.starred,
    required this.data,
  });

  factory SuggestionsReportDto.fromJson(Map<String, dynamic> json) {
    return SuggestionsReportDto(
      period: json['period'] ?? '',
      total: json['total'] ?? 0,
      starred: json['starred'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => PeriodData.fromJson(e))
          .toList(),
    );
  }
}

class PackagesDetailsReportDto {
  final List<PackageDetails> packages;

  PackagesDetailsReportDto({required this.packages});

  factory PackagesDetailsReportDto.fromJson(Map<String, dynamic> json) {
    return PackagesDetailsReportDto(
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackageDetails.fromJson(e))
          .toList(),
    );
  }
}

class PackageDetails {
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final int durationDays;
  final int subscriberCount;
  final List<FeatureDetails> features;

  PackageDetails({
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    required this.durationDays,
    required this.subscriberCount,
    required this.features,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      subscriberCount: json['subscriberCount'] ?? 0,
      features: (json['features'] as List? ?? [])
          .map((e) => FeatureDetails.fromJson(e))
          .toList(),
    );
  }
}

class FeatureDetails {
  final String featureAr;
  final String featureEn;
  final int limitCount;

  FeatureDetails({
    required this.featureAr,
    required this.featureEn,
    required this.limitCount,
  });

  factory FeatureDetails.fromJson(Map<String, dynamic> json) {
    return FeatureDetails(
      featureAr: json['featureAr'] ?? '',
      featureEn: json['featureEn'] ?? '',
      limitCount: json['limitCount'] ?? 0,
    );
  }
}