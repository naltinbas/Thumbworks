import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ropeford/ford/levels.dart';
import 'package:ropeford/ui/app.dart';
import 'package:ropeford/ui/ford_screen.dart';
import 'package:ropeford/ui/fordview.dart';
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
  await tester.pumpWidget(const RopefordApp());
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

FordScreenState state(WidgetTester tester) =>
    tester.state<FordScreenState>(find.byType(FordScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps stone [k] of the ford through the painter's metrics.
Future<void> tapStone(WidgetTester tester, int k) async {
  final room = board(tester);
  await tester.tapAt(room.topLeft + Metrics(room.size).centre(k));
  await tester.pumpAndSettle();
}

/// Hops along [stones] in turn, stopping if the ask ends first or a tap
/// changes nothing, which would otherwise go unnoticed.
Future<void> hopAlong(WidgetTester tester, List<int> stones) async {
  for (final stone in stones) {
    if (state(tester).play.isOver) return;
    final was = state(tester).play.at;
    await tapStone(tester, stone);
    if (state(tester).play.at == was) return;
  }
}

/// Does what the pointer says, once.
Future<void> hopByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapStone(tester, state(tester).pointing!);
}

/// Follows the pointer until the ask lands, [most] hops at most.
Future<void> crossByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await hopByPointer(tester);
  }
}
