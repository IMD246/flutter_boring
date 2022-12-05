// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'package:to_do_app_boring/enum/enum.dart';
import 'package:to_do_app_boring/jsonParsing/json_parsing.dart';
import 'package:to_do_app_boring/models/article.dart';

class HackerNewsBloc {
  late HashMap<int, Article> _cachedArticles;
  Stream<UnmodifiableListView<Article?>> get topStreamArticle =>
      _topSubjectArticle.stream;

  final BehaviorSubject<UnmodifiableListView<Article?>> _topSubjectArticle =
      BehaviorSubject<UnmodifiableListView<Article>>();

  Stream<UnmodifiableListView<Article?>> get newStreamArticle =>
      _newSubjectArticle.stream;

  final BehaviorSubject<UnmodifiableListView<Article?>> _newSubjectArticle =
      BehaviorSubject<UnmodifiableListView<Article>>();

  final _storiesTypeController = StreamController<StoriesType>();

  Sink<StoriesType> get storiesTypeSink => _storiesTypeController.sink;

  Stream<bool> get isLoadingStream => _subjectLoading.stream;

  final BehaviorSubject<bool> _subjectLoading =
      BehaviorSubject<bool>.seeded(false);
  List<Article?> _articles = [];
  HackerNewsBloc() {
    _initializeArticles();

    _cachedArticles = HashMap<int, Article>();

    _storiesTypeController.stream.listen((event) async {
      _getArticlesAndUpdate(_topSubjectArticle, await _getIds(StoriesType.top));
      _getArticlesAndUpdate(
        _newSubjectArticle,
        await _getIds(StoriesType.news),
      );
    });
  }

  _initializeArticles() async {
    _getArticlesAndUpdate(_topSubjectArticle, await _getIds(StoriesType.top));
    _getArticlesAndUpdate(
      _newSubjectArticle,
      await _getIds(StoriesType.news),
    );
  }

  Future<List<int>> _getIds(StoriesType storiesType) async {
    final pathUrl = storiesType == StoriesType.top ? 'top' : 'new';
    final url = "$_baseURL${pathUrl}stories.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HackerNewApiError(
        message: "Stories ${storiesType.name} counldn't be fetched",
      );
    }
    return JsonParsing.parseTopStories(response.body);
  }

  static const String _baseURL = 'https://hacker-news.firebaseio.com/v0/';

  _getArticlesAndUpdate(BehaviorSubject<UnmodifiableListView<Article?>> subject,
      List<int> ids) async {
    _subjectLoading.add(true);
    await _getArticles(ids);
    subject.add(UnmodifiableListView(_articles));
    _subjectLoading.add(false);
  }

  Future<void> _getArticles(List<int> ids) async {
    final futureArticle = ids.map((e) => _getArticle(e));
    final articles = await Future.wait(futureArticle);
    _articles = articles.take(10).toList();
  }

  Future<Article?> _getArticle(int id) async {
    if (!_cachedArticles.containsKey(id)) {
      final storyUrl = "${_baseURL}item/$id.json";
      final storyRes = await http.get(Uri.parse(storyUrl));
      if (storyRes.statusCode == 200) {
        _cachedArticles[id] = parseArticle(storyRes.body)!;
        return _cachedArticles[id];
      }
      throw HackerNewApiError(message: "Article $id couldn't fetched");
    }
    return _cachedArticles[id];
  }
}

class HackerNewApiError extends Error {
  final String message;
  HackerNewApiError({
    required this.message,
  });
}
