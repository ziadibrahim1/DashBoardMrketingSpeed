class FeatureGrant {
  final int id;
  final String referrer;
  final String email;
  final String feature;
  final int granted;
  final DateTime? date;
  final String addedBy;
  final String reason;

  FeatureGrant({
    required this.id,
    required this.referrer,
    required this.email,
    required this.feature,
    required this.granted,
    required this.date,
    required this.addedBy,
    required this.reason,
  });

  factory FeatureGrant.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
      if (parsedDate != null && parsedDate.year == 1) parsedDate = null;
    }

    return FeatureGrant(
      id: json['id'] ?? 0,
      referrer: json['referrer']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      feature: json['featureName']?.toString() ?? '-',
      granted: json['grantedCount'] ?? 0,
      addedBy: json['addedBy']?.toString() ?? '-',
      reason: json['reason']?.toString() ?? '-',
      date: parsedDate,
    );
  }
}
