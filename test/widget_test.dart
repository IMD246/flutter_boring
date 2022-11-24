// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_app_boring/main.dart';

void main() {
  testWidgets('Clicking tile open icon', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.ac_unit), findsNothing);

    await tester.tap(find.byType(ExpansionTile).first);

    await tester.pump();

    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
  });
}
