import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotwick/ring/levels.dart';
import 'package:lotwick/ui/app.dart';
import 'package:lotwick/ui/ring_screen.dart';
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
  await tester.pumpWidget(const LotwickApp());
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

RingScreenState state(WidgetTester tester) =>
    tester.state<RingScreenState>(find.byType(RingScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Steps one dial: [name] 'worth', 'bid' or 'rival', [by] 1 or -1.
Future<void> step(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Walks the three dials to a setting, a crown a tap.
Future<void> setDials(WidgetTester tester, int worth, int bid, int rival,
    {int most = 60}) async {
  const names = ['worth', 'bid', 'rival'];
  final want = [worth, bid, rival];
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    final at = [was.worth, was.bid, was.rival];
    var dial = -1;
    for (var i = 0; i < 3; i++) {
      if (at[i] != want[i]) {
        dial = i;
        break;
      }
    }
    if (dial < 0) return;
    await step(tester, names[dial], at[dial] < want[dial] ? 1 : -1);
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (dial, by) = state(tester).pointing!;
  await step(tester, const ['worth', 'bid', 'rival'][dial], by);
}

/// Follows the pointer until the setting lands, [most] taps at most.
Future<void> setByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
