import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rimsbury/roll/levels.dart';
import 'package:rimsbury/ui/app.dart';
import 'package:rimsbury/ui/roll_screen.dart';
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
  await tester.pumpWidget(const RimsburyApp());
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

RollScreenState state(WidgetTester tester) =>
    tester.state<RollScreenState>(find.byType(RollScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'hoop' or 'roller', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Sends the roller round the other side.
Future<void> flip(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('side')));
  await tester.pumpAndSettle();
}

/// Sets the hoop, the roller and the side from where they stand, a step
/// a tap, the side first, then the hoop, then the roller.
Future<void> setCoins(WidgetTester tester, int hoop, int coin, {bool inside = false}) async {
  if (state(tester).play.inside != inside && !state(tester).play.isOver) await flip(tester);
  while (state(tester).play.hoop != hoop && !state(tester).play.isOver) {
    await turn(tester, 'hoop', (hoop - state(tester).play.hoop).sign);
  }
  while (state(tester).play.coin != coin && !state(tester).play.isOver) {
    await turn(tester, 'roller', (coin - state(tester).play.coin).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  if (which == 2) {
    await flip(tester);
  } else {
    await turn(tester, which == 0 ? 'hoop' : 'roller', by);
  }
}

/// Follows the pointer until the roll lands, [most] steps at most.
Future<void> rollByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
