// import 'dart:convert';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:to_do_app_boring/parsing/json_parsing.dart';

// void main() {
//   test(
//     "parses item.json over a network",
//     () async {
//       const url = "https://hacker-news.firebaseio.com/v0/beststories.json";
//       final res = await http.get(Uri.parse(url));
//       if (res.statusCode == 200) {
//         final idsList = jsonDecode(res.body) as List;
//         if (idsList.isNotEmpty) {
//           final storyUrl =
//               "https://hacker-news.firebaseio.com/v0/item/${idsList.first}.json";
//           final storyRes = await http.get(Uri.parse(storyUrl));
//           if (storyRes.statusCode == 200) {
//             final article = parseArticle(storyRes.body);
//             if (article != null) {
//               expect(article.by, "dynamicwebpaige");
//             } else {
//               throwsA(fail("failed"));
//             }
//           }
//         } else {
//           throwsA(fail("failed"));
//         }
//       } else {
//         throwsA(fail("failed"));
//       }
//     },
//   );
// }
