import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowsley/pair/levels.dart';
import 'package:knowsley/ui/app.dart';
import 'package:knowsley/ui/pair_screen.dart';
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
  await tester.pumpWidget(const KnowsleyApp());
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

PairScreenState state(WidgetTester tester) =>
    tester.state<PairScreenState>(find.byType(PairScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps [which], 'x' or 'y', by one, up or down, on its dial.
Future<void> turn(WidgetTester tester, String which, int by) async {
  await tester.tap(find.byKey(Key('$which${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the dials to (x, y): y up first, then x, then y down, so the
/// pair stays a pair all the way; stops if the ask ends first.
Future<void> setPair(WidgetTester tester, int x, int y) async {
  Future<void> run(String which, int by, bool Function() go) async {
    while (go() && !state(tester).play.isOver) {
      await turn(tester, which, by);
    }
  }

  await run('y', 1, () => state(tester).play.y < y);
  await run('x', -1, () => state(tester).play.x > x);
  await run('x', 1, () => state(tester).play.x < x);
  await run('y', -1, () => state(tester).play.y > y);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which, by);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> pairByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
