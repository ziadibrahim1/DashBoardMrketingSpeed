import 'dart:convert';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'PayoutTransaction.dart';
import 'app_config.dart';

class WithdrawalRequest {
  final int id;
  final String marketerName;
  final String supervisorName; // جديد
  final int points;
  final double amount;
  final String bank;
  final String accountNumber;
  final DateTime requestedAt;
  final DateTime? reviewedAt; // جديد
  final String? rejectReason;  // جديد
  final String status;
  final PayoutTransaction? payout;

  WithdrawalRequest({
    required this.id,
    required this.marketerName,
    required this.supervisorName,
    required this.points,
    required this.amount,
    required this.bank,
    required this.accountNumber,
    required this.requestedAt,
    this.reviewedAt,
    this.rejectReason,
    required this.status,
    this.payout, // ✅
  });


  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      marketerName: json['marketerName'],
      supervisorName: json['supervisorName'] ?? '',
      points: json['requestedPoints'],
      amount: (json['requestedAmount'] as num).toDouble(),
      bank: json['bank'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      requestedAt: DateTime.parse(json['requestedAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      rejectReason: json['rejectReason'],
      status: json['status'] ??'pending',

      // ⭐ أهم سطر
      payout: json['payout'] != null
          ? PayoutTransaction.fromJson(json['payout'])
          : null,
    );
  }

}

class WithdrawalsService {
  static Future<List<WithdrawalRequest>> fetchPending() async {
    return _fetchFromEndpoint('withdrawals/pending');
  }

  static Future<List<WithdrawalRequest>> fetchHistory() async {
    return _fetchFromEndpoint('withdrawals/history');
  }

  static Future<List<WithdrawalRequest>> _fetchFromEndpoint(String endpoint) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: {'Authorization': ''}, // ضع التوكن إذا لزم
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load $endpoint');
    }

    final List data = jsonDecode(res.body);
    print(data);
    return data.map((e) => WithdrawalRequest.fromJson(e)).toList();
  }

  static Future<void> approve(int id, String method, String ref) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}withdrawals/$id/approve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'adminId': 1,
        'paymentMethod': method,
        'referenceNumber': ref,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Approve failed');
    }
  }

  static Future<void> reject(int id, String reason) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}withdrawals/$id/reject'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'adminId': 1,
        'reason': reason,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Reject failed');
    }
  }

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
