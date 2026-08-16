import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cofferwick/coffer/levels.dart';
import 'package:cofferwick/ui/app.dart';
import 'package:cofferwick/ui/coffer_screen.dart';
import 'package:cofferwick/ui/cofferview.dart';
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
  await tester.pumpWidget(const CofferwickApp());
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

CofferScreenState state(WidgetTester tester) =>
    tester.state<CofferScreenState>(find.byType(CofferScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps coin [i] through the painter's metrics.
Future<void> tapCoin(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.coinAt(i));
  await tester.pumpAndSettle();
}

/// Turns the coins to [want], first coffer first, each coin that
/// differs turned once.
Future<void> lay(WidgetTester tester, List<bool> want) async {
  for (var i = 0; i < want.length; i++) {
    if (state(tester).play.isOver) return;
    if (state(tester).play.coins[i] != want[i]) await tapCoin(tester, i);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapCoin(tester, state(tester).pointing!);
}

/// Follows the pointer until the coins land, [most] steps at most.
Future<void> layByPointer(WidgetTester tester, {int most = 8}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
