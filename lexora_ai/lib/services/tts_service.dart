import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speakUS(String text) async {
    await initialize();
    await _tts.setLanguage('en-US');
    await _tts.speak(text);
  }

  Future<void> speakUK(String text) async {
    await initialize();
    await _tts.setLanguage('en-GB');
    await _tts.speak(text);
  }

  Future<void> speak(String text, {String language = 'en-US', double rate = 0.5}) async {
    await initialize();
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  Future<void> stop() async => await _tts.stop();

  Future<void> setSpeed(double rate) async {
    await _tts.setSpeechRate(rate);
  }
}
