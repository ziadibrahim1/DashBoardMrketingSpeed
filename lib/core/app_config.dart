class AppConfig {
  static const String apiBase = 'http://marketingspeed.online:5002';
  //http://marketingspeed.online:5002
  //https://localhost:7222
  static const String loginPath = '/api/admin/Auth/login';
  static String get loginUrl => '$apiBase$loginPath';

  static const String usersPath = '/api/admin/users';
  static String get usersUrl => '$apiBase$usersPath';

  static const String baseUrlPath = '/api/';
  static String get baseUrl => '$apiBase$baseUrlPath';

  // ✅ إضافة SignalR Hub URL
  static String get chatHubUrl => '$apiBase/chatHub';
}