import 'dart:convert';

class JsonParsing {
  static List<int> parseTopStories(String jsonString) {
    return List<int>.from(jsonDecode(jsonString));
  }
}
