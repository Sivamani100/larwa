// lib/services/backend_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class BackendService {
  static const _baseUrl = AppConstants.backendUrl;
  static const Duration _defaultTimeout = Duration(seconds: 12);

  /// Trigger AI callback — send a reply via AI outbound call
  static Future<Map<String, dynamic>> triggerCallback({
    required String toNumber,
    required String message,
    required String callerName,
    required String callLogId,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/callback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to_number': toNumber,
            'your_message': message,
            'caller_name': callerName,
            'call_log_id': callLogId,
          }),
        )
        .timeout(_defaultTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Callback failed: ${response.body}');
    }
  }

  /// Fetch streaming text response from Claude via backend
  Future<void> streamAiResponse(
    List<Map<String, String>> messages,
    Function(String sentence) onSentence,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$_baseUrl/ai-response'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'messages': messages});

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('AI stream failed: ${response.statusCode}');
      }

      String buffer = "";
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;

        // Split by sentence terminators to feed TTS early
        // Matches . ! ? followed by space or end of string
        final parts = buffer.split(RegExp(r'(?<=[.!?])\s+'));

        // If we found terminators, send the complete sentences
        if (parts.length > 1) {
          for (int i = 0; i < parts.length - 1; i++) {
            if (parts[i].trim().isNotEmpty) {
              onSentence(parts[i].trim());
            }
          }
          // Keep the last partial sentence in buffer
          buffer = parts.last;
        }
      }

      // Send final bit
      if (buffer.trim().isNotEmpty) {
        onSentence(buffer.trim());
      }
    } finally {
      client.close();
    }
  }

  /// Fetch raw PCM bytes from backend TTS
  Future<Uint8List> getTtsPcm(String text) async {
    // Current backend has tts_service but might not have a public route yet
    // I'll add a helper to fetch it or implement client-side fallback
    final response = await http
        .post(
          Uri.parse('$_baseUrl/tts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(_defaultTimeout);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('TTS fetch failed');
  }

  /// Send full transcript for post-call processing
  Future<void> processCall({
    required String callerNumber,
    required List<Map<String, String>> transcript,
  }) async {
    await http
        .post(
          Uri.parse('$_baseUrl/process-call'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'caller_number': callerNumber,
            'transcript': transcript,
          }),
        )
        .timeout(_defaultTimeout);
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
