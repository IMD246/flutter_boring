// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsBlocError extends Error {
  final String message;
  PrefsBlocError({
    required this.message,
  });
}

class PrefState {
  final bool showWebView;
  PrefState({
    required this.showWebView,
  });
}

class PrefBloc {
  final _currentPrefs = BehaviorSubject<PrefState>.seeded(
    PrefState(
      showWebView: true,
    ),
  );

  final _showWebViewPrefs = StreamController<bool>();

  PrefBloc() {
    _loadSharedPrefs();
    _showWebViewPrefs.stream.listen((event) {
      _savedNewPrefs(PrefState(showWebView: event));
    });
  }

  Stream<PrefState> get currentPrefs => _currentPrefs.stream;

  Sink<bool> get showWebViewPref => _showWebViewPrefs.sink;

  void close() {
    _showWebViewPrefs.close();
    _currentPrefs.close();
  }

  Future<void> _loadSharedPrefs() async {
    final sharedPref = await SharedPreferences.getInstance();
    final showWebView = sharedPref.getBool('showWebView') ?? true;
    _currentPrefs.add(
      PrefState(
        showWebView: showWebView,
      ),
    );
  }

  Future<void> _savedNewPrefs(PrefState prefState) async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setBool('showWebView', prefState.showWebView);
    _currentPrefs.add(prefState);
  }
}
