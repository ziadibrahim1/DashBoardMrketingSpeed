import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const NotificationsHistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل الإشعارات"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: history.isEmpty
            ? const Center(child: Text("لا يوجد إشعارات بعد"))
            : LayoutBuilder(
          builder: (context, constraints) {
            bool useGrid = constraints.maxWidth > 800;
            return useGrid
                ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 3.2,
              ),
              itemCount: history.length,
              itemBuilder: (context, index) =>
                  _buildCard(history[index], isDark),
            )
                : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) =>
                  _buildCard(history[index], isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, bool isDark) {
    final time = DateFormat('yyyy/MM/dd – HH:mm').format(DateTime.parse(item['time']));

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (item['imageBytes'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  item['imageBytes'] as Uint8List,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.notifications, size: 60, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['message'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.send, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        "إلى: ${item['to']}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
