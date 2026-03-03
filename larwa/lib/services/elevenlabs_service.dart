import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ElevenLabsService {
  Future<Uint8List> synthesize(String text) async {
    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/${AppConstants.elevenLabsVoiceId}/stream');
    
    final response = await http.post(
      url,
      headers: {
        'xi-api-key': AppConstants.elevenLabsApiKey,
        'Content-Type': 'application/json',
        'accept': 'audio/mpeg', // We'll handle PCM conversion in backend or just use PCM output format
      },
      body: {
        'text': text,
        'model_id': 'eleven_flash_v2_5',
        'output_format': 'pcm_16000',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        }
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('ElevenLabs synthesis failed: ${response.body}');
    }
  }
}
