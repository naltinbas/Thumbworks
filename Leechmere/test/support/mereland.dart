import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leechmere/garden/levels.dart';
import 'package:leechmere/ui/app.dart';
import 'package:leechmere/ui/garden_screen.dart';
import 'package:leechmere/ui/gardenview.dart';
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
  await tester.pumpWidget(const LeechmereApp());
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

GardenScreenState state(WidgetTester tester) =>
    tester.state<GardenScreenState>(find.byType(GardenScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a dial through the painter's metrics.
Future<void> tapDial(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(i));
  await tester.pumpAndSettle();
}

/// Taps a dial [times] over.
Future<void> turnDial(WidgetTester tester, int i, int times) async {
  for (var k = 0; k < times; k++) {
    await tapDial(tester, i);
  }
}

/// Turns the dial the pointer says, once.
Future<void> turnByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final dial = state(tester).pointing!;
  await tapDial(tester, dial);
}

/// Follows the pointer until the ask is met, twenty turns at most.
Future<void> setByPointer(WidgetTester tester) async {
  for (var k = 0; k < 20 && !state(tester).play.isDone; k++) {
    await turnByPointer(tester);
  }
}
