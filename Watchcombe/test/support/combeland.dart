import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchcombe/yard/levels.dart';
import 'package:watchcombe/ui/app.dart';
import 'package:watchcombe/ui/board_screen.dart';
import 'package:watchcombe/ui/boardview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a yard, or on the sham when [which] is null.
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
  await tester.pumpWidget(const WatchcombeApp());
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

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a flag through the painter's metrics.
Future<void> tapFlag(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Taps flags one after another.
Future<void> tapAll(WidgetTester tester, List<int> squares) async {
  for (final c in squares) {
    await tapFlag(tester, c);
  }
}

/// Posts every watchman as the pointer says.
Future<void> postByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (_, c) = state(tester).pointing!;
    await tapFlag(tester, c);
  }
}
