import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queenscote/watch/levels.dart';
import 'package:queenscote/watch/play.dart';
import 'package:queenscote/ui/app.dart';
import 'package:queenscote/ui/watch_screen.dart';
import 'package:queenscote/ui/watchview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const QueenscoteApp());
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

WatchScreenState state(WidgetTester tester) =>
    tester.state<WatchScreenState>(find.byType(WatchScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps square [i] through the painter's metrics.
Future<void> tapSquare(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.rect(i).center);
  await tester.pumpAndSettle();
}

/// Sets queens on every square of [squares], in turn.
Future<void> setAll(WidgetTester tester, List<int> squares) async {
  for (final q in squares) {
    await tapSquare(tester, q);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (aim, square) = state(tester).pointing!;
  switch (aim) {
    case Aim.set:
    case Aim.lift:
      await tapSquare(tester, square);
  }
}

/// Follows the pointer until the board is watched, [most] steps at most.
Future<void> watchByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
