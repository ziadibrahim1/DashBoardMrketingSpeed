import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

/// Web only
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'app_config.dart';

class ReportDownload {
  static Future<void> downloadReport(String type) async {
    final url = '${AppConfig.baseUrl}withdrawals/export/$type';

    if (kIsWeb) {
      _downloadWeb(url, type);
    } else {
      await _downloadMobile(url, type);
    }
  }

  static void _downloadWeb(String url, String type) {
    html.AnchorElement(href: url)
      ..setAttribute('download', 'withdrawals.$type')
      ..click();
  }

  static Future<void> _downloadMobile(String url, String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/withdrawals.$type';

    final dio = Dio();
    await dio.download(url, filePath);

    await OpenFile.open(filePath);
  }
}
