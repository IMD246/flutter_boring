import 'dart:async';
import 'dart:collection';

import 'package:to_do_app_boring/enum/enum.dart';
import 'package:to_do_app_boring/models/article.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class HackerNewsBloc {
  Stream<UnmodifiableListView<Article?>> get streamArticle => _subjectArticle.stream;

  final BehaviorSubject<UnmodifiableListView<Article?>> _subjectArticle =
      BehaviorSubject<UnmodifiableListView<Article>>();

  final _storiesTypeController = StreamController<StoriesType>();

  Sink<StoriesType> get storiesTypeSink => _storiesTypeController.sink;

  Stream<bool> get isLoadingStream => _subjectLoading.stream;

  final BehaviorSubject<bool> _subjectLoading =
      BehaviorSubject<bool>.seeded(false);
  List<Article?> _articles = [];
  HackerNewsBloc() {
    _getArticlesAndUpdate(_bestIds);
    _storiesTypeController.stream.listen((event) {
      List<String> ids;
      if (event.name == StoriesType.top.name) {
        ids = _bestIds;
      } else {
        ids = _newIds;
      }
      _getArticlesAndUpdate(ids);
    });
  }
  final _newIds = [
    "9129911",
    "9129199",
    "9127761",
    "9128141",
    "9128264",
    "9127792",
  ];
  final _bestIds = [
    "9127792",
    "9129248",
    "9127092",
    "9128367",
    "9038733",
  ];
  _getArticlesAndUpdate(List<String> ids) async {
    _subjectLoading.add(true);
    await getArticles(ids);
    _subjectArticle.add(UnmodifiableListView(_articles));
    _subjectLoading.add(false);
  }

  Future<void> getArticles(List<String> ids) async {
    final futureArticle = ids.map((e) => getArticle(e));
    final articles = await Future.wait(futureArticle);
    _articles = articles;
  }

  Future<Article?> getArticle(String id) async {
    final storyUrl = "https://hacker-news.firebaseio.com/v0/item/$id.json";
    final storyRes = await http.get(Uri.parse(storyUrl));
    if (storyRes.statusCode == 200) {
      final article = parseArticle(storyRes.body);
      return article;
    } else {
      return null;
    }
  }
}
