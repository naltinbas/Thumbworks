import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mintcombe/coin/levels.dart';
import 'package:mintcombe/ui/app.dart';
import 'package:mintcombe/ui/coin_screen.dart';
import 'package:mintcombe/ui/coinview.dart';
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
  await tester.pumpWidget(const MintcombeApp());
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

CoinScreenState state(WidgetTester tester) =>
    tester.state<CoinScreenState>(find.byType(CoinScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps [coin] on the rack through the painter's metrics.
Future<void> tapRack(WidgetTester tester, int coin) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.rackAt(coin));
  await tester.pumpAndSettle();
}

/// Taps [coin] where it lies on the counter.
Future<void> tapCounter(WidgetTester tester, int coin) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.counterAt(coin)!);
  await tester.pumpAndSettle();
}

/// Lays the [coins] in turn from the rack.
Future<void> lay(WidgetTester tester, List<int> coins) async {
  for (final c in coins) {
    if (state(tester).play.isOver) return;
    await tapRack(tester, c);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (coin, lift) = state(tester).pointing!;
  if (lift) {
    await tapCounter(tester, coin);
  } else {
    await tapRack(tester, coin);
  }
}

/// Follows the pointer until the price is paid, [most] steps at most.
Future<void> payByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
