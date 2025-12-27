import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Web only
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'app_config.dart';

class ReportDownload {
  static Future<void> downloadReport(
      String type, {
        DateTimeRange? dateRange,
        String? role,
        String? status,
        RangeValues? pointsRange,
      }) async {
    final query = <String, String>{};

    if (dateRange != null) {
      query['from'] = dateRange.start.toIso8601String();
      query['to'] = dateRange.end.toIso8601String();
    }

    if (role != null && role.isNotEmpty) {
      query['role'] = role;
    }

    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    if (pointsRange != null) {
      query['pointsFrom'] = pointsRange.start.toInt().toString();
      query['pointsTo'] = pointsRange.end.toInt().toString();
    }

    final uri = Uri.parse(
      '${AppConfig.baseUrl}withdrawals/export/$type',
    ).replace(queryParameters: query);

    if (kIsWeb) {
      _downloadWeb(uri.toString(), type);
    } else {
      await _downloadMobile(uri.toString(), type);
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
