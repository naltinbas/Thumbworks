import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pursebury/duel/levels.dart';
import 'package:pursebury/ui/app.dart';
import 'package:pursebury/ui/duel_screen.dart';
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
  await tester.pumpWidget(const PurseburyApp());
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

DuelScreenState state(WidgetTester tester) =>
    tester.state<DuelScreenState>(find.byType(DuelScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Turns a dial one step: [name] 'Ash' or 'Birch', [by] 1 or -1.
Future<void> turn(WidgetTester tester, String name, int by) async {
  await tester.tap(find.byKey(Key('$name${by > 0 ? '+1' : '-1'}')));
  await tester.pumpAndSettle();
}

/// Turns the coin over once.
Future<void> turnCoin(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('coin')));
  await tester.pumpAndSettle();
}

/// Sets the purses and the coin from where they stand, a step a tap,
/// the coin first, then Ash, then Birch.
Future<void> setDuel(WidgetTester tester, int ash, int birch, {int coin = 1}) async {
  while (state(tester).play.coin != coin && !state(tester).play.isOver) {
    await turnCoin(tester);
  }
  while (state(tester).play.ash != ash && !state(tester).play.isOver) {
    await turn(tester, 'Ash', (ash - state(tester).play.ash).sign);
  }
  while (state(tester).play.birch != birch && !state(tester).play.isOver) {
    await turn(tester, 'Birch', (birch - state(tester).play.birch).sign);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, by) = state(tester).pointing!;
  if (which == 2) {
    await turnCoin(tester);
  } else {
    await turn(tester, which == 0 ? 'Ash' : 'Birch', by);
  }
}

/// Follows the pointer until the duel lands, [most] steps at most.
Future<void> stakeByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
