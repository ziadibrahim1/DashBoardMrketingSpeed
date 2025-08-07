import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة تكاملات الـ APIs'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ابحث عن خدمة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    );
  }

  void _handleMenuAction(String action, ApiService service) {
    switch (action) {
      case 'edit':
        _showEditDialog(service);
        break;
      case 'test':
        _showSnack("تم إرسال رسالة اختبار لـ ${service.name}");
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

  void _showEditDialog(ApiService service) {
    final controller = TextEditingController(text: service.apiKey);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تعديل مفتاح ${service.name}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "API Key"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                service.apiKey = controller.text;
              });
              Navigator.pop(context);
              _showSnack("تم حفظ المفتاح لـ ${service.name}");
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
    final isConnected = service.status == ConnectionStatus.connected;
    final cardColor = isConnected ? Colors.green[50] : Colors.grey[200];

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
                          color: isConnected ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isConnected ? 'متصل' : 'غير متصل',
                          style: TextStyle(
                            color: isConnected ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "آخر اتصال: ${Utils.timeAgo(service.lastConnected)}",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "API Key: ${Utils.obscureKey(service.apiKey)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: onAction,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('تعديل المفتاح')),
                PopupMenuItem(value: 'test', child: Text('إرسال اختبار')),
                PopupMenuItem(value: 'toggle', child: Text('تفعيل / تعطيل')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ApiServiceDetails extends StatelessWidget {
  final ApiService service;
  const ApiServiceDetails({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تفاصيل ${service.name}")),
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
            Text("الحالة: ${service.status == ConnectionStatus.connected ? "متصل" : "غير متصل"}"),
            const SizedBox(height: 12),
            Text("آخر اتصال: ${Utils.timeAgo(service.lastConnected)}"),
            const SizedBox(height: 12),
            Text("API Key: ${service.apiKey.isNotEmpty ? service.apiKey : "غير مضاف"}"),
          ],
        ),
      ),
    );
  }
}

class Utils {
  static String timeAgo(DateTime? time) {
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

  static String obscureKey(String key) {
    if (key.isEmpty) return "غير مضاف";
    if (key.length <= 6) return "****";
    return key.substring(0, 4) + "****" + key.substring(key.length - 2);
  }
}
