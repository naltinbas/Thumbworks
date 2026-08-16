import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrowmere/ways/levels.dart';
import 'package:arrowmere/ui/app.dart';
import 'package:arrowmere/ui/ways_screen.dart';
import 'package:arrowmere/ui/wayview.dart';
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
  await tester.pumpWidget(const ArrowmereApp());
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

WaysScreenState state(WidgetTester tester) =>
    tester.state<WaysScreenState>(find.byType(WaysScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps street [s] of the village through the painter's metrics.
Future<void> tapStreet(WidgetTester tester, int s) async {
  final room = board(tester);
  await tester.tapAt(
      room.topLeft + Metrics(state(tester).play.village, room.size).middle(s));
  await tester.pumpAndSettle();
}

/// Turns the streets of [streets] in turn, stopping if the ask ends
/// first or a tap changes nothing.
Future<void> turnAll(WidgetTester tester, List<int> streets) async {
  for (final s in streets) {
    if (state(tester).play.isOver) return;
    final was = List.of(state(tester).play.arrows);
    await tapStreet(tester, s);
    if (state(tester).play.arrows.toString() == was.toString()) return;
  }
}

/// Does what the pointer says, once.
Future<void> turnByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapStreet(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] turns at most.
Future<void> pointAllByPointer(WidgetTester tester, {int most = 8}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await turnByPointer(tester);
  }
}
