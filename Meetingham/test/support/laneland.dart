import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meetingham/lane/levels.dart';
import 'package:meetingham/lane/rules.dart';
import 'package:meetingham/ui/app.dart';
import 'package:meetingham/ui/lane_screen.dart';
import 'package:meetingham/ui/laneview.dart';
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
  await tester.pumpWidget(const MeetinghamApp());
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

LaneScreenState state(WidgetTester tester) =>
    tester.state<LaneScreenState>(find.byType(LaneScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the post [paces] from the corner on the side of gate [which]
/// (0 D on BC, 1 E on CA, 2 F on AB) through the painter's metrics.
Future<void> tapGate(WidgetTester tester, int which, int paces) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  final p = which == 0 ? Rules.gateD(paces) : which == 1 ? Rules.gateE(paces) : Rules.gateF(paces);
  await tester.tapAt(room.topLeft + metrics.at(p));
  await tester.pumpAndSettle();
}

/// Sets the three gates, D then E then F.
Future<void> setGates(WidgetTester tester, int d, int e, int f) async {
  final want = [d, e, f];
  for (var i = 0; i < 3; i++) {
    if (state(tester).play.gates[i] != want[i] && !state(tester).play.isOver) await tapGate(tester, i, want[i]);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (which, paces) = state(tester).pointing!;
  await tapGate(tester, which, paces);
}

/// Follows the pointer until the lanes meet as asked, [most] steps at
/// most.
Future<void> laneByPointer(WidgetTester tester, {int most = 6}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
