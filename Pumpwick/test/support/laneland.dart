import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pumpwick/lane/levels.dart';
import 'package:pumpwick/ui/app.dart';
import 'package:pumpwick/ui/lane_screen.dart';
import 'package:pumpwick/ui/laneview.dart';
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
  await tester.pumpWidget(const PumpwickApp());
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

LaneScreenState state(WidgetTester tester) =>
    tester.state<LaneScreenState>(find.byType(LaneScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the lane at [spot], which rolls the pump a step that way.
Future<void> tapSpot(WidgetTester tester, int spot) async {
  final room = board(tester);
  final m = Metrics(room.size);
  await tester.tapAt(room.topLeft + Offset(m.xOf(spot), m.middle));
  await tester.pumpAndSettle();
}

/// Rolls the pump to [spot], a step at a time.
Future<void> rollTo(WidgetTester tester, int spot) async {
  var guard = 0;
  while (!state(tester).play.isOver &&
      state(tester).play.spot != spot &&
      guard < 20) {
    final was = state(tester).play.spot;
    await tapSpot(tester, spot);
    if (state(tester).play.spot == was) return;
    guard++;
  }
}

/// Does what the pointer says, once.
Future<void> rollByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final way = state(tester).pointing!;
  await tapSpot(tester, state(tester).play.spot + way);
}

/// Follows the pointer until the ask lands, [most] steps at most.
Future<void> rollAllByPointer(WidgetTester tester, {int most = 16}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await rollByPointer(tester);
  }
}
