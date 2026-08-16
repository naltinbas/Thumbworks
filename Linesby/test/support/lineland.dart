import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linesby/line/levels.dart';
import 'package:linesby/line/rules.dart';
import 'package:linesby/ui/app.dart';
import 'package:linesby/ui/line_screen.dart';
import 'package:linesby/ui/lineview.dart';
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
  await tester.pumpWidget(const LinesbyApp());
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

LineScreenState state(WidgetTester tester) =>
    tester.state<LineScreenState>(find.byType(LineScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps peg [p] of the field through the painter's metrics.
Future<void> tapPeg(WidgetTester tester, Peg p) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.pegAt(p));
  await tester.pumpAndSettle();
}

/// Lifts peg [i] and sets it down at [to].
Future<void> movePeg(WidgetTester tester, int i, Peg to) async {
  await tapPeg(tester, state(tester).play.pegs[i]);
  await tapPeg(tester, to);
}

/// Moves the pegs to [targets], A, B and C in turn, each straight to
/// its place, skipping over a move the field refuses until the others
/// have gone.
Future<void> setPegs(WidgetTester tester, List<Peg> targets) async {
  for (var round = 0; round < 3; round++) {
    for (var i = 0; i < 3; i++) {
      if (state(tester).play.isOver || state(tester).play.pegs[i] == targets[i]) continue;
      await movePeg(tester, i, targets[i]);
      if (state(tester).play.held != null) {
        // Refused: put the peg back down where it was.
        await tapPeg(tester, state(tester).play.pegs[i]);
      }
    }
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (i, to) = state(tester).pointing!;
  await movePeg(tester, i, to);
}

/// Follows the pointer until the triangle lands, [most] steps at most.
Future<void> landByPointer(WidgetTester tester, {int most = 6}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
