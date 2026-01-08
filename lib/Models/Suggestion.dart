class Suggestion {
  final int id;
  final String contentAr;
  final String contentEn;
  bool isStarred;
  DateTime createdAt;
  String? adminReply;
  bool isNew;
  String username;

  Suggestion({
    required this.id,
    required this.contentAr,
    required this.contentEn,
    required this.createdAt,
    this.isStarred = false,
    this.adminReply,
    this.isNew = false,
    this.username = 'مستخدم',
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    final created = DateTime.parse(json['createdAt']);
    final now = DateTime.now();

    final isNew = now.difference(created).inDays <= 7;

    return Suggestion(
      id: json['id'],
      contentAr: json['suggestionAr'],
      contentEn: json['suggestionEn'],
      isStarred: json['isStarred'] ?? false,
      createdAt: created,
      adminReply: json['replyText'],
      isNew: isNew,
      username: json['username'] ?? '',
    );
  }

  String getContent(bool isArabic) =>
      isArabic ? contentAr : contentEn;
}
