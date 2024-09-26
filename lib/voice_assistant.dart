import 'package:flutter_tts/flutter_tts.dart';
import 'package:orderly/database_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final DatabaseHelper dbHelper = DatabaseHelper();
  bool _isListening = false;
  bool _isSpeaking = false;

  VoiceAssistant();

  Future<void> startListening() async {
    if (!_isSpeaking) {
      bool available = await _speech.initialize();
      if (available) {
        print("Speech recognition started");
        _isListening = true;
        _speech.listen(
          onResult: (val) {
            print("Received speech result: ${val.recognizedWords}");
            if (val.finalResult) {
              _processQuery(val.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 5),
          cancelOnError: true,
        );
      } else {
        print("Speech recognition not available");
        _isListening = false;
      }
    }
  }

  Future<void> _processQuery(String query) async {
    print("Processing query: $query");
    _stopListening();

    if (query.trim().isEmpty || query.length < 3) {
      await speak("Sorry, I couldn't identify the product. Please try again.");
      return;
    }

    // Detect language and find the closest product match
    String? language = _detectLanguage(query);
    String? productName = await _findClosestProductMatch(query, language!);

    print("Detected language: $language and product: $productName");

    if (productName != null) {
      int quantity = await dbHelper.getRemainingProductQuantity(productName);
      String response = language == 'hindi'
          ? "$quantity $productName बचे हैं।"
          : "You have $quantity units of $productName remaining.";
      print("Responding with: $response");
      await speak(response);
    } else {
      String response = language == 'hindi'
          ? "मुझे उत्पाद का पता नहीं चला। कृपया पुनः प्रयास करें।"
          : "Sorry, I couldn't identify the product. Please try again.";
      print("Responding with: $response");
      await speak(response);
    }
  }

  Future<String?> _findClosestProductMatch(
      String query, String language) async {
    String cleanedQuery = _cleanQuery(query, language);

    // Fetch all product names from the database
    List<String> productNames = await dbHelper.getAllProductNames();

    // Find the closest match using the Levenshtein distance function
    String? closestMatch;
    int minDistance = cleanedQuery.length;

    for (String productName in productNames) {
      int distance = _calculateLevenshteinDistance(
          cleanedQuery.toLowerCase(), productName.toLowerCase());
      if (distance < minDistance) {
        minDistance = distance;
        closestMatch = productName;
      }
    }

    // Return the closest match if within an acceptable threshold
    return (minDistance <= 3) ? closestMatch : null;
  }

  int _calculateLevenshteinDistance(String s, String t) {
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<List<int>> d = List.generate(
        s.length + 1, (int i) => List<int>.filled(t.length + 1, 0));

    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = (t[j - 1] == s[i - 1]) ? 0 : 1;
        d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
    }

    return d[s.length][t.length];
  }

  String _cleanQuery(String query, String language) {
    String cleanedQuery = query.toLowerCase().trim();

    // Remove common Hindi and English phrases related to quantity
    cleanedQuery = cleanedQuery.replaceAll(
        RegExp(
            r'\b(kitne|kitna|kitni|baki|baaki|hain|hai|how much|how many|left|remain|is remaining|kya)\b'),
        '');

    return cleanedQuery.trim();
  }

  String? _detectLanguage(String query) {
    if (query.contains(RegExp(r'\b(bache|kitne|kitna|kitni|baaki|hai|kya)\b',
        caseSensitive: false))) {
      return 'hindi';
    } else if (query.contains(RegExp(
        r'\b(how much|how many|left|remain|is remaining)\b',
        caseSensitive: false))) {
      return 'english';
    } else {
      return 'hindi'; // Default to 'hindi' if there's a mix of both or if unsure
    }
  }

  Future<void> speak(String message) async {
    if (!_isSpeaking) {
      await _flutterTts.speak(message);
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void stop() {
    _stopListening();
    if (_isSpeaking) {
      _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  void reset() {
    _stopListening();
    _isSpeaking = false;
  }
}
