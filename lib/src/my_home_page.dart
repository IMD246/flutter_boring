import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            if (currentIndex == 0) {
              hackernews.storiesTypeSink.add(StoriesType.top);
            } else {
              hackernews.storiesTypeSink.add(StoriesType.news);
            }
            setState(() {
              currentIndex = value;
            });
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
            return _buildListArticle(articles);
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

ListView _buildListArticle(List<Article?>? articles) {
  return ListView.builder(
    key: const PageStorageKey(0),
    itemCount: articles?.length ?? 0,
    itemBuilder: (context, index) {
      final article = articles!.elementAt(index);
      return _buildItemArticle(article, context);
    },
  );
}

Widget _buildItemArticle(Article? article, BuildContext context) {
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
            HackerNewsWebPageWidget(url: article?.url ?? ""),
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
