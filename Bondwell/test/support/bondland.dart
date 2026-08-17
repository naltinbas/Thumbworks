import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bondwell/bond/levels.dart';
import 'package:bondwell/bond/rules.dart';
import 'package:bondwell/ui/app.dart';
import 'package:bondwell/ui/purse_screen.dart';
import 'package:bondwell/ui/purseview.dart';
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
  await tester.pumpWidget(const BondwellApp());
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

PurseScreenState state(WidgetTester tester) =>
    tester.state<PurseScreenState>(find.byType(PurseScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> pressKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps purse [i] on the board, which drops a coin in.
Future<void> tapPurse(WidgetTester tester, int i) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + Metrics(room.size).at(i));
  await tester.pumpAndSettle();
}

/// Steps purse [i] by [by] on its dial.
Future<void> stepPurse(WidgetTester tester, int i, int by) async {
  await pressKey(
      tester, '${Rules.names[i]}${by > 0 ? '+' : ''}$by');
}

/// Fills the purses to [purses], taking coins out before putting any
/// in, since the chest can only give what it holds. Stops if the ask
/// ends first or a tap changes nothing.
Future<void> setPurses(WidgetTester tester, List<int> purses) async {
  for (final falling in [true, false]) {
    for (var i = 0; i < Rules.heirs; i++) {
      while (!state(tester).play.isOver &&
          state(tester).play.purses[i] != purses[i]) {
        final was = state(tester).play.purses[i];
        final gap = purses[i] - was;
        if (falling != (gap < 0)) break;
        final by = gap >= 3 ? 3 : (gap <= -3 ? -3 : (gap > 0 ? 1 : -1));
        await stepPurse(tester, i, by);
        if (state(tester).play.purses[i] == was) return;
      }
    }
  }
}

/// Does what the pointer says, once.
Future<void> stepByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  await stepPurse(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> divideByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await stepByPointer(tester);
  }
}
