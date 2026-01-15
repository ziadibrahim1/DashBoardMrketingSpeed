import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';

enum PackageStatus { active, paused }

class LogEntry {
  final DateTime timestamp;
  final String message;

  LogEntry(this.message) : timestamp = DateTime.now();
}

class Package {
  String nameAr;
  String nameEn;
  int id;
  double price;
  int durationDays;
  double? discount;
  List<PackageFeature> features;
  int subscribers;
  bool isArchived;
  PackageStatus status;
  DateTime createdAt;
  DateTime? startDate; // للجدولة المستقبلية
  List<LogEntry> logs;
  DateTime? lastZeroSubscriberDetected; // لتتبع الإشعار الذكي
  int CategoryId = 1;


  Package({
    required this.nameAr,
    required this.nameEn,
    required this.id,
    required this.price,
    required this.durationDays,
    this.discount,
    required this.features,
    required this.subscribers,
    this.isArchived = false,
    this.status = PackageStatus.active,
    DateTime? createdAt,
    this.startDate,
    List<LogEntry>? logs,
    this.lastZeroSubscriberDetected,
    this.CategoryId = 1,
  })  : createdAt = createdAt ?? DateTime.now(),
        logs = logs ?? [] {
    if (subscribers == 0) {
      lastZeroSubscriberDetected = DateTime.now();
    }
  }
  factory Package.fromJson(Map<String, dynamic> json, bool isArabic) {
    final subscribers = json['subscriber_count'] ?? 0;
    return Package(
      id: json['id'],
      nameAr: isArabic ? json['name'] : json['nameEn'],
      nameEn: isArabic ? json['nameEn'] : json['name'],
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'],
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => PackageFeature.fromJson(f, isArabic))
          .toList(),
      subscribers: subscribers,
      isArchived: json['archived'] == 1 || json['archived'] == true,
      status: json['status'] == 'active'
          ? PackageStatus.active
          : PackageStatus.paused,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      startDate: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
        CategoryId : json['categoryId'],

      // مهم 👇 عشان البانر الذكي
      lastZeroSubscriberDetected:
      subscribers == 0 ? DateTime.now() : null,
    );
  }
  Map<String, dynamic> toJson(bool isArabic) {
    return {
      "nameAr": nameAr ,
      "nameEn": nameEn,
      "price": price,
      "durationDays": durationDays,
      "discount": discount,
      "status": status == PackageStatus.active ? "active" : "inactive",
      "scheduledAt": startDate?.toIso8601String(),
      "features": features.map((f) => f.toJson()).toList(),
      "categoryId": CategoryId,
    };
  }

  void addLog(String msg) {
    logs.insert(0, LogEntry(msg));
  }
  bool get isScheduledFuture {
    if (startDate == null) return false;
    return startDate!.isAfter(DateTime.now());
  }
  bool get shouldShowInactiveBanner {
    if (subscribers > 0) return false;
    if (lastZeroSubscriberDetected == null) return true;
    final diff = DateTime.now().difference(lastZeroSubscriberDetected!);
    return diff.inDays >= 30;
  }
}
class PackageFeature {
  final String feature;
  final String? featureAr;
  final String? featureEn;
  final int limitCount;

  PackageFeature({
    required this.feature,
    this.featureAr,
    this.featureEn,
    required this.limitCount,
  });

  factory PackageFeature.fromJson(Map<String, dynamic> json, bool isArabic) {
    return PackageFeature(
      feature: json['feature'],
      featureAr: json['featureAr'],
      featureEn: json['featureEn'],
      limitCount: json['limitCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "feature": feature ?? '',
      "featureAr": featureAr ?? feature ?? '',
      "featureEn": featureEn ?? feature ?? '',
      "limitCount": limitCount,
    };
  }
}
