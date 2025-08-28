enum PackageStatus { active, paused }

class LogEntry {
  final DateTime timestamp;
  final String message;

  LogEntry(this.message) : timestamp = DateTime.now();
}

class Package {
  String name;
  int id;
  double price;
  int durationDays;
  double? discount;
  List<String> features;
  int subscribers;
  bool isArchived;
  PackageStatus status;
  DateTime createdAt;
  DateTime? startDate; // للجدولة المستقبلية
  List<LogEntry> logs;
  DateTime? lastZeroSubscriberDetected; // لتتبع الإشعار الذكي

  Package({
    required this.name,
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
  })  : createdAt = createdAt ?? DateTime.now(),
        logs = logs ?? [] {
    if (subscribers == 0) {
      lastZeroSubscriberDetected = DateTime.now();
    }
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
