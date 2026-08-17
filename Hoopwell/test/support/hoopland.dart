import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopwell/hoop/levels.dart';
import 'package:hoopwell/ui/app.dart';
import 'package:hoopwell/ui/hoop_screen.dart';
import 'package:hoopwell/ui/hoopview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the hoop when [which] is null.
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
  await tester.pumpWidget(const HoopwellApp());
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

HoopScreenState state(WidgetTester tester) =>
    tester.state<HoopScreenState>(find.byType(HoopScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a stone hole is drawn, which is where a thumb goes. Ring 0 is
/// the dark stones and ring 1 the pale.
Offset stoneAt(WidgetTester tester, int ring, int hole) {
  final where = board(tester);
  return where.topLeft +
      Metrics(state(tester).play, where.size).spot(ring, hole);
}

/// A lamp, for a tap that should land on no stone at all.
Offset lampAt(WidgetTester tester, int hole) {
  final where = board(tester);
  return where.topLeft + Metrics(state(tester).play, where.size).spot(2, hole);
}

/// Taps a hole, which lays a stone in it or lifts one out.
Future<void> tapHole(WidgetTester tester, int ring, int hole) async {
  await tester.tapAt(stoneAt(tester, ring, hole));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final aim = state(tester).pointing!;
  await tapHole(tester, aim.$1, aim.$2);
}

/// Follows the pointer until the ask lands, [most] taps at most.
Future<void> layByPointer(WidgetTester tester, {int most = 10}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
