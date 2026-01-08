import 'dart:convert';
import 'package:admin_dashboard/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'Suggestion.dart';

class SuggestionsService {
  static final baseUrl = AppConfig.baseUrl;

  static Future<List<Suggestion>> fetchSuggestions(bool isArabic) async {
    final response = await http.get(Uri.parse('${baseUrl}suggestions'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Suggestion.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
  static Future<void> toggleStar(int suggestionId, bool value) async {
    final response = await http.post(
      Uri.parse('${baseUrl}suggestions/star?id=$suggestionId&value=$value'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle star');
    }
  }
  static Future<void> replyToSuggestion(int id, String reply) async {
    final response = await http.post(
      Uri.parse('${baseUrl}suggestions/reply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'suggestionId': id,
        'replyText': reply,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reply to suggestion');
    }
  }
}
