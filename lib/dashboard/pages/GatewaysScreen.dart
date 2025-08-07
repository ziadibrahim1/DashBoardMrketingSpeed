import 'package:flutter/material.dart';

class GatewaysScreen extends StatelessWidget {
  const GatewaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text('بوابة PayTabs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Merchant ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Server Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text('حفظ الإعدادات'),
          ),
        ],
      ),
    );
  }
}