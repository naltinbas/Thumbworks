import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whistlecote/whistle/levels.dart';
import 'package:whistlecote/ui/app.dart';
import 'package:whistlecote/ui/whistle_screen.dart';
import 'package:whistlecote/ui/moorview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a set of calls, or on the sham when [which] is null.
Future<void> open(
  WidgetTester tester, {
  int? which,
  Size? screen,
}) async {
  SharedPreferences.setMockInitialValues({});
  if (screen != null) {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(const WhistlecoteApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

WhistleScreenState state(WidgetTester tester) =>
    tester.state<WhistleScreenState>(find.byType(WhistleScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a whistle through the painter's metrics.
Future<void> tapNode(WidgetTester tester, int k) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(k));
  await tester.pumpAndSettle();
}

/// Taps whistles one after another.
Future<void> tapAll(WidgetTester tester, List<int> nodes) async {
  for (final k in nodes) {
    await tapNode(tester, k);
  }
}

/// Marks every whistle as the pointer says.
Future<void> markByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 30) {
    await press(tester, 'Show me');
    final (_, k) = state(tester).pointing!;
    await tapNode(tester, k);
  }
}
