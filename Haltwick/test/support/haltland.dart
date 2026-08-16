import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haltwick/wait/levels.dart';
import 'package:haltwick/ui/app.dart';
import 'package:haltwick/ui/wait_screen.dart';
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
  await tester.pumpWidget(const HaltwickApp());
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

WaitScreenState state(WidgetTester tester) =>
    tester.state<WaitScreenState>(find.byType(WaitScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps a gap's dial, 'g1' or 'g2', up or down by one.
Future<void> turn(WidgetTester tester, String which, int by) async {
  await tester.tap(find.byKey(Key('$which${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Steps the dials to the gaps [first] and [second], the first down
/// before up so the third gap keeps a minute; stops if the ask ends.
Future<void> setGaps(WidgetTester tester, int first, int second) async {
  Future<void> run(String which, int by, bool Function() go) async {
    while (go() && !state(tester).play.isOver) {
      await turn(tester, which, by);
    }
  }

  await run('g1', -1, () => state(tester).play.first > first);
  await run('g2', -1, () => state(tester).play.second > second);
  await run('g1', 1, () => state(tester).play.first < first);
  await run('g2', 1, () => state(tester).play.second < second);
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await turn(tester, which, by);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> gapsByPointer(WidgetTester tester, {int most = 60}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
