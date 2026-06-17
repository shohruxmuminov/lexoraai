import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (e) {},
      onStatus: (_) {},
    );
    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable) await initialize();
    if (!_isAvailable) return;

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async => await _speech.stop();

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isAvailable;
}
