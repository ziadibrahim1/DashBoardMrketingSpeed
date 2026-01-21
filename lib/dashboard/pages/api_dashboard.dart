import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Models/VideoDto.dart';
import '../../providers/app_providers.dart';
import 'package:provider/provider.dart';

// Enum للحالة
enum ConnectionStatus { connected, disconnected }

// موديل الخدمة
class ApiService {
  final String name;
  final IconData icon;
  final Color iconColor;
  ConnectionStatus status;
  String apiKey;
  DateTime? lastConnected;

  ApiService({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.apiKey,
    this.lastConnected,
  });
}

class ApiDashboardScreen extends StatefulWidget {
  const ApiDashboardScreen({super.key});

  @override
  State<ApiDashboardScreen> createState() => _ApiDashboardScreenState();
}

class _ApiDashboardScreenState extends State<ApiDashboardScreen> {
  List<ApiService> allServices = [
    ApiService(
      name: "WhatsApp",
      icon: FontAwesomeIcons.whatsapp,
      iconColor: Colors.green,
      status: ConnectionStatus.connected,
      apiKey: "sk_whatsapp_1234",
      lastConnected: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ApiService(
      name: "Telegram",
      icon: FontAwesomeIcons.telegram,
      iconColor: Colors.blue,
      status: ConnectionStatus.disconnected,
      apiKey: "",
    ),
    ApiService(
      name: "Haraj",
      icon: FontAwesomeIcons.store,
      iconColor: Colors.orange,
      status: ConnectionStatus.connected,
      apiKey: "sk_haraj_5678",
      lastConnected: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ApiService(
      name: "Facebook",
      icon: FontAwesomeIcons.facebook,
      iconColor: Colors.blueAccent,
      status: ConnectionStatus.connected,
      apiKey: "sk_fb_1234",
      lastConnected: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    ApiService(
      name: "Instagram",
      icon: FontAwesomeIcons.instagram,
      iconColor: Colors.purple,
      status: ConnectionStatus.disconnected,
      apiKey: "",
    ),
    ApiService(
      name: "TikTok",
      icon: FontAwesomeIcons.tiktok,
      iconColor: Colors.black,
      status: ConnectionStatus.connected,
      apiKey: "sk_tiktok_9981",
      lastConnected: DateTime.now().subtract(const Duration(minutes: 42)),
    ),
    ApiService(
      name: "X (Twitter)",
      icon: FontAwesomeIcons.xTwitter,
      iconColor: Colors.black,
      status: ConnectionStatus.connected,
      apiKey: "sk_x_3382",
      lastConnected: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ApiService(
      name: "Email",
      icon: FontAwesomeIcons.envelope,
      iconColor: Colors.redAccent,
      status: ConnectionStatus.connected,
      apiKey: "sk_email_3333",
      lastConnected: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    ApiService(
      name: "SMS",
      icon: FontAwesomeIcons.sms,
      iconColor: Colors.deepOrange,
      status: ConnectionStatus.disconnected,
      apiKey: "",
    ),
  ];

  List<ApiService> displayedServices = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedServices = allServices;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.green : Colors.blue;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isRTL = localeProvider.locale.languageCode == 'ar';
        final loc = AppLocalizations(localeProvider.locale.languageCode);
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(isRTL ? 'إدارة تكاملات الـ APIs' : 'API Integrations Management'),
              centerTitle: true,
              backgroundColor: isDark ? Colors.green[900] : primaryColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: isRTL ? 'ابحث عن خدمة...' : 'Search for a service...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    ),
                    onChanged: (query) {
                      setState(() {
                        displayedServices = allServices
                            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: displayedServices.length,
                      itemBuilder: (context, index) {
                        final service = displayedServices[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApiServiceDetails(service: service),
                            ),
                          ),
                          child: ApiServiceCard(
                            service: service,
                            onAction: (action) => _handleMenuAction(action, service),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, ApiService service) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isRTL = localeProvider.locale.languageCode == 'ar';

    switch (action) {
      case 'edit':
        _showEditDialog(service, isRTL);
        break;
      case 'test':
        _showSnack(isRTL ? "تم إرسال رسالة اختبار لـ ${service.name}" : "Test message sent to ${service.name}");
        break;
      case 'toggle':
        setState(() {
          service.status = service.status == ConnectionStatus.connected
              ? ConnectionStatus.disconnected
              : ConnectionStatus.connected;
        });
        break;
    }
  }

  void _showEditDialog(ApiService service, bool isRTL) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController(text: service.apiKey);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(isRTL ? "تعديل مفتاح ${service.name}" : "Edit ${service.name} Key"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: isRTL ? "API Key" : "API Key",
            filled: true,
            fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[50],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRTL ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                service.apiKey = controller.text;
              });
              Navigator.pop(context);
              _showSnack(isRTL ? "تم حفظ المفتاح لـ ${service.name}" : "Key saved for ${service.name}");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.green : Colors.blue,
            ),
            child: Text(isRTL ? "حفظ" : "Save"),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.green[800] : Colors.blue,
      ),
    );
  }
}

class ApiServiceCard extends StatelessWidget {
  final ApiService service;
  final Function(String action) onAction;

  const ApiServiceCard({
    super.key,
    required this.service,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isConnected = service.status == ConnectionStatus.connected;
    final primaryColor = isDark ? Colors.green : Colors.blue;

    final cardColor = isConnected
        ? isDark
        ? Colors.green[700]?.withOpacity(0.1)
        : Colors.blue[100]
        : isDark
        ? Colors.grey[850]
        : Colors.grey[200];

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isRTL = localeProvider.locale.languageCode == 'ar';

        return Card(
          elevation: 3,
          color: cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: service.iconColor.withOpacity(0.1),
                  child: FaIcon(service.icon, color: service.iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? isDark
                                  ? Colors.green[800]?.withOpacity(0.3)
                                  : Colors.green[100]
                                  : isDark
                                  ? Colors.red[900]?.withOpacity(0.3)
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isConnected
                                  ? (isRTL ? 'متصل' : 'Connected')
                                  : (isRTL ? 'غير متصل' : 'Disconnected'),
                              style: TextStyle(
                                color: isConnected
                                    ? isDark
                                    ? Colors.green[300]
                                    : Colors.green[800]
                                    : isDark
                                    ? Colors.red[300]
                                    : Colors.red[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isRTL
                                ? "آخر اتصال: ${Utils.timeAgoAr(service.lastConnected)}"
                                : "Last connected: ${Utils.timeAgoEn(service.lastConnected)}",
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[300] : Colors.black54
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isRTL
                            ? "مفتاح API: ${Utils.obscureKey(service.apiKey)}"
                            : "API Key: ${Utils.obscureKey(service.apiKey)}",
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: onAction,
                  itemBuilder: (context) => isRTL
                      ? [
                    const PopupMenuItem(value: 'edit', child: Text('تعديل المفتاح')),
                    const PopupMenuItem(value: 'test', child: Text('إرسال اختبار')),
                    const PopupMenuItem(value: 'toggle', child: Text('تفعيل / تعطيل')),
                  ]
                      : [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Key')),
                    const PopupMenuItem(value: 'test', child: Text('Send Test')),
                    const PopupMenuItem(value: 'toggle', child: Text('Enable/Disable')),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ApiServiceDetails extends StatelessWidget {
  final ApiService service;
  const ApiServiceDetails({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final isRTL = localeProvider.locale.languageCode == 'ar';

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(isRTL ? "تفاصيل ${service.name}" : "${service.name} Details"),
              backgroundColor: isDark ? Colors.green[900] : Colors.blue,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: service.iconColor.withOpacity(0.2),
                        child: FaIcon(service.icon, size: 30, color: service.iconColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        service.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isRTL
                        ? "الحالة: ${service.status == ConnectionStatus.connected ? "متصل" : "غير متصل"}"
                        : "Status: ${service.status == ConnectionStatus.connected ? "Connected" : "Disconnected"}",
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRTL
                        ? "آخر اتصال: ${Utils.timeAgoAr(service.lastConnected)}"
                        : "Last connected: ${Utils.timeAgoEn(service.lastConnected)}",
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRTL
                        ? "مفتاح API: ${service.apiKey.isNotEmpty ? service.apiKey : "غير مضاف"}"
                        : "API Key: ${service.apiKey.isNotEmpty ? service.apiKey : "Not added"}",
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Utils {
  static String timeAgoAr(DateTime? time) {
    if (time == null) return "-";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} دقيقة";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} ساعة";
    } else {
      return "${diff.inDays} يوم";
    }
  }

  static String timeAgoEn(DateTime? time) {
    if (time == null) return "-";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago";
    } else {
      return "${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago";
    }
  }

  static String obscureKey(String key) {
    if (key.isEmpty) return "";
    if (key.length <= 6) return "****";
    return key.substring(0, 4) + "****" + key.substring(key.length - 2);
  }
}