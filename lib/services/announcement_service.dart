import 'package:flutter_tts/flutter_tts.dart';

class AnnouncementService {
  final FlutterTts _flutterTts;
  String _language;

  AnnouncementService({String initialLanguage = "hi-IN"})
      : _flutterTts = FlutterTts(),
        _language = initialLanguage;

  Future<void> initialize() async {
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void setLanguage(String language) {
    _language = language;
    _flutterTts.setLanguage(language);
  }

  Future<void> announce(String text) async {
    var result = await _flutterTts.speak(text);
    if (result == 1) {
      print("TTS is speaking in $_language: $text");
    } else {
      print("TTS failed to speak");
    }
  }

  void announceStock(String productName, int quantity) {
    String announcement;

    if (_language == "hi-IN") {
      announcement = "$productName के $quantity शेष हैं";
    } else if (_language == "bn-IN") {
      announcement = "$productName এর $quantity টি বাকি আছে"; // Bengali
    } else {
      announcement = "There are $quantity $productName left"; // English
    }

    announce(announcement);
  }
}
