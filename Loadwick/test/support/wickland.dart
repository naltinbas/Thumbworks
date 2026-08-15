import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadwick/dice/levels.dart';
import 'package:loadwick/ui/app.dart';
import 'package:loadwick/ui/stall_screen.dart';
import 'package:loadwick/ui/stallview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a stall, or on the sham when [which] is null.
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
  await tester.pumpWidget(const LoadwickApp());
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

StallScreenState state(WidgetTester tester) =>
    tester.state<StallScreenState>(find.byType(StallScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a die through the painter's metrics.
Future<void> tapDie(WidgetTester tester, int c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Taps dice one after another.
Future<void> tapAll(WidgetTester tester, List<int> dice) async {
  for (final c in dice) {
    await tapDie(tester, c);
  }
}

/// Picks the die the pointer says.
Future<void> pickByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final die = state(tester).pointing!;
  await tapDie(tester, die);
}
