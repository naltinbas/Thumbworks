import 'package:caskleigh/cask/levels.dart';
import 'package:caskleigh/cask/rules.dart';
import 'package:caskleigh/ui/app.dart';
import 'package:caskleigh/ui/cask_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  await tester.pumpWidget(const CaskleighApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few asks only until it scrolls.
      await tester.scrollUntilVisible(tile, 80,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

CaskScreenState state(WidgetTester tester) =>
    tester.state<CaskScreenState>(find.byType(CaskScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps one end of the run: [name] 'first' or 'last', [by] 1 or -1.
Future<void> step(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Walks the run to [first] and [last] a cask a tap, taking whichever
/// end can move without the run crossing itself.
Future<void> setRun(WidgetTester tester, int first, int last,
    {int most = 120}) async {
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    if (was.first == first && was.last == last) return;
    final byLast = (last - was.last).sign;
    if (byLast != 0 && Rules.validRun(was.first, was.last + byLast)) {
      await step(tester, 'last', byLast);
    } else {
      await step(tester, 'first', (first - was.first).sign);
    }
    // A tap that changes nothing means the run cannot get there.
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  await step(tester, which, by);
}

/// Follows the pointer until the run lands, [most] taps at most.
Future<void> pourByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
