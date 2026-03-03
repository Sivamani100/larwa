import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants.dart';

class DeepgramService {
  WebSocketChannel? _channel;
  final _transcriptController = StreamController<String>.broadcast();
  bool _isConnecting = false;

  Stream<String> get transcriptStream => _transcriptController.stream;

  void connect() {
    if (_channel != null || _isConnecting) return;
    _isConnecting = true;
    final url =
        'wss://api.deepgram.com/v1/listen?model=nova-2-phonecall&encoding=linear16&sample_rate=16000&channels=1&interim_results=true&smart_format=true';
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
      protocols: ['Token', AppConstants.deepgramApiKey],
    );

    _channel?.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final transcript =
            data['channel']?['alternatives']?[0]?['transcript'] ?? '';
        final isFinal = data['is_final'] ?? false;

        if (isFinal && transcript.isNotEmpty) {
          _transcriptController.add(transcript);
        }
      },
      onError: (_) {
        _channel = null;
        _isConnecting = false;
      },
      onDone: () {
        _channel = null;
        _isConnecting = false;
      },
    );

    _isConnecting = false;
  }

  void feedAudio(Uint8List chunk) {
    if (_channel == null) {
      connect();
    }
    _channel?.sink.add(chunk);
  }

  void close() {
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }
}
