import 'dart:convert';
import 'dart:developer';

class JsonParsing {
  static List<int> parseTopStories(String jsonString) {
    log("check top stories: ${List<int>.from(jsonDecode(jsonString)).first}");
    return List<int>.from(jsonDecode(jsonString));
  }
}
