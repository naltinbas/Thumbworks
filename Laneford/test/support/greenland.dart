import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laneford/green/levels.dart';
import 'package:laneford/ui/app.dart';
import 'package:laneford/ui/green_screen.dart';
import 'package:laneford/ui/greenview.dart';
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
  await tester.pumpWidget(const LanefordApp());
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

GreenScreenState state(WidgetTester tester) =>
    tester.state<GreenScreenState>(find.byType(GreenScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps hamlet [h] through the painter's metrics.
Future<void> tapHamlet(WidgetTester tester, int h) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.hamlet(h));
  await tester.pumpAndSettle();
}

/// Taps grid point (x, y).
Future<void> tapPoint(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at((x, y)));
  await tester.pumpAndSettle();
}

/// Takes hamlet [h] and stands it on (x, y).
Future<void> moveHamlet(WidgetTester tester, int h, int x, int y) async {
  await tapHamlet(tester, h);
  await tapPoint(tester, x, y);
}

/// Does what the pointer says, once: takes the hamlet if not held, else
/// stands it.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (h, point) = state(tester).pointing!;
  if (state(tester).play.held != h) {
    if (state(tester).play.held != null) {
      await tapHamlet(tester, state(tester).play.held!);
    }
    await tapHamlet(tester, h);
  }
  await tapPoint(tester, point.$1, point.$2);
}

/// Follows the pointer until the green is clear, [most] steps at most.
Future<void> layByPointer(WidgetTester tester, {int most = 30}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
