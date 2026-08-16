import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundhithe/road/levels.dart';
import 'package:roundhithe/road/rules.dart';
import 'package:roundhithe/ui/app.dart';
import 'package:roundhithe/ui/road_screen.dart';
import 'package:roundhithe/ui/roadview.dart';
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
  await tester.pumpWidget(const RoundhitheApp());
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

RoadScreenState state(WidgetTester tester) =>
    tester.state<RoadScreenState>(find.byType(RoadScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps village [v] through the painter's metrics.
Future<void> tapVillage(WidgetTester tester, int v) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(v));
  await tester.pumpAndSettle();
}

/// Lays or lifts the roads told as 'AB', each by its two taps.
Future<void> layRoads(WidgetTester tester, List<String> roads) async {
  for (final r in roads) {
    if (state(tester).play.isOver) return;
    await tapVillage(tester, Rules.names.indexOf(r[0]));
    await tapVillage(tester, Rules.names.indexOf(r[1]));
  }
}

/// Does what the pointer says, once: one tap.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (a, b, _) = state(tester).pointing!;
  final held = state(tester).play.held;
  await tapVillage(tester, a == b ? a : (held == a ? b : a));
}

/// Follows the pointer until the plan lands, [most] taps at most.
Future<void> planByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
