import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';

class GatewaysScreen extends StatelessWidget {
  const GatewaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
            Text(isArabic?'بوابة PayTabs':'PayTabs',
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
            label:  Text(isArabic?'حفظ الإعدادات':'Save Settings'),
          ),
        ],
      ),
    );
  }
}