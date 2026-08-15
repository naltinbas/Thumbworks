import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milesworth/lane/levels.dart';
import 'package:milesworth/ui/app.dart';
import 'package:milesworth/ui/lane_screen.dart';
import 'package:milesworth/ui/laneview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a lane, or on the sham when [which] is null.
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
  await tester.pumpWidget(const MilesworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LaneScreenState state(WidgetTester tester) =>
    tester.state<LaneScreenState>(find.byType(LaneScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a milestone through the painter's metrics.
Future<void> tapStone(WidgetTester tester, int stone) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(stone));
  await tester.pumpAndSettle();
}

/// Marks milestones one after another.
Future<void> markAll(WidgetTester tester, List<int> stones) async {
  for (final stone in stones) {
    await tapStone(tester, stone);
  }
}

/// Marks by the pointer until the run lands.
Future<void> markByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 8) {
    await press(tester, 'Show me');
    final (_, stone) = state(tester).pointing!;
    await tapStone(tester, stone);
  }
}
