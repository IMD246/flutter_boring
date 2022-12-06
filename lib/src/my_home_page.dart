import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:to_do_app_boring/bloc/pref_bloc.dart';
import 'package:to_do_app_boring/enum/enum.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bloc/hacker_news_bloc.dart';
import '../models/article.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  final hackernews = HackerNewsBloc();
  final prefBloc = PrefBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter boring demo"),
        centerTitle: true,
        leading: LoadingWidget(
          isLoading: hackernews.isLoadingStream,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          if (currentIndex != value) {
            setState(() {
              currentIndex = value;
            });
            if (currentIndex == 0) {
              hackernews.storiesTypeSink.add(StoriesType.top);
            } else if (currentIndex == 1) {
              hackernews.storiesTypeSink.add(StoriesType.news);
            } else {
              _showPrefsSheet(context, prefBloc);
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            label: "Top",
            icon: Icon(Icons.arrow_drop_up),
          ),
          BottomNavigationBarItem(
            label: "New",
            icon: Icon(
              Icons.new_releases,
            ),
          ),
          BottomNavigationBarItem(
            label: "Preferences",
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: StreamBuilder<UnmodifiableListView<Article?>>(
        stream: currentIndex == 0
            ? hackernews.topStreamArticle
            : hackernews.newStreamArticle,
        initialData: UnmodifiableListView([]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final articles = snapshot.data;
            return _buildListArticle(articles, prefBloc);
          } else {
            return Column(
              children: const [
                Spacer(),
                Center(child: CircularProgressIndicator()),
                Spacer(),
              ],
            );
          }
        },
      ),
    );
  }
}

ListView _buildListArticle(List<Article?>? articles, PrefBloc prefBloc) {
  return ListView.builder(
    key: const PageStorageKey(0),
    itemCount: articles?.length ?? 0,
    itemBuilder: (context, index) {
      final article = articles!.elementAt(index);
      return _buildItemArticle(article, context, prefBloc);
    },
  );
}

Widget _buildItemArticle(
    Article? article, BuildContext context, PrefBloc prefBloc) {
  return Padding(
    key: PageStorageKey(article?.text),
    padding: const EdgeInsets.all(
      16,
    ),
    child: ExpansionTile(
      title: Text(
        article?.title ?? "Null",
      ),
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${article?.descendants ?? "0"} comments"),
                IconButton(
                  onPressed: () {
                    if (article?.url != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return HackerNewsWebPage(url: article!.url!);
                          },
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.launch),
                )
              ],
            ),
            StreamBuilder<PrefState>(
              stream: prefBloc.currentPrefs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.showWebView) {
                    return HackerNewsWebPageWidget(url: article?.url ?? "");
                  }
                }
                return Container();
              },
            ),
          ],
        ),
      ],
    ),
  );
}

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, required this.isLoading});
  final Stream<bool> isLoading;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.isLoading,
      builder: (context, snapshot) {
        _controller.forward().then((_) {
          _controller.reverse();
        });
        return FadeTransition(
          opacity: Tween<double>(begin: .5, end: 1).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeIn,
            ),
          ),
          child: const Icon(
            FontAwesomeIcons.squareHackerNews,
          ),
        );
      },
    );
  }
}

class HackerNewsWebPageWidget extends StatelessWidget {
  const HackerNewsWebPageWidget({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: WebView(
        initialUrl: 'https://flutter.dev',
        javascriptMode: JavascriptMode.unrestricted,
        // ignore: prefer_collection_literals
        gestureRecognizers: Set()
          ..add(
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          ),
      ),
    );
  }
}

class HackerNewsWebPage extends StatelessWidget {
  const HackerNewsWebPage({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web Page"),
      ),
      body: WebView(
        initialUrl: 'https://flutter.dev',
        javascriptMode: JavascriptMode.unrestricted,
        // ignore: prefer_collection_literals
        gestureRecognizers: Set()
          ..add(
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          ),
      ),
    );
  }
}

void _showPrefsSheet(BuildContext context, PrefBloc prefBloc) async {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Scaffold(
        body: Center(
          child: StreamBuilder<PrefState>(
            stream: prefBloc.currentPrefs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Switch(
                  value: snapshot.data!.showWebView,
                  onChanged: (value) {
                    prefBloc.showWebViewPref.add(value);
                  },
                );
              }
              return const Text("No thing");
            },
          ),
        ),
      );
    },
  );
}
