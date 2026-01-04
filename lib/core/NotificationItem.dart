class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String targetAudience;
  final String destination;
  final String? scheduleAt;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.targetAudience,
    required this.destination,
    this.scheduleAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      targetAudience: json['targetAudience'] ?? '',
      destination: json['destination'] ?? '',
      scheduleAt: json['scheduleAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
