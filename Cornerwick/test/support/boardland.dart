import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cornerwick/square/levels.dart';
import 'package:cornerwick/square/rules.dart';
import 'package:cornerwick/ui/app.dart';
import 'package:cornerwick/ui/square_screen.dart';
import 'package:cornerwick/ui/squareview.dart';
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
  await tester.pumpWidget(const CornerwickApp());
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

SquareScreenState state(WidgetTester tester) =>
    tester.state<SquareScreenState>(find.byType(SquareScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps peg [p] through the painter's metrics.
Future<void> tapPeg(WidgetTester tester, Peg p) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.pegAt(p));
  await tester.pumpAndSettle();
}

/// Sets the pegs in turn.
Future<void> setPegs(WidgetTester tester, List<Peg> pegs) async {
  for (final p in pegs) {
    if (state(tester).play.isOver) return;
    await tapPeg(tester, p);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (peg, _) = state(tester).pointing!;
  await tapPeg(tester, peg);
}

/// Follows the pointer until the four lands, [most] steps at most.
Future<void> pegsByPointer(WidgetTester tester, {int most = 12}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
