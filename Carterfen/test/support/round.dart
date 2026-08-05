import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carterfen/best.dart';
import 'package:carterfen/round/shortest.dart';
import 'package:carterfen/ui/app.dart';
import 'package:carterfen/ui/fen.dart';
import 'package:carterfen/ui/round_screen.dart';

/// The bits every test that drives a round needs.

/// A phone to lay the map out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last round's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: CarterfenApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RoundScreenState state(WidgetTester tester) =>
    tester.state<RoundScreenState>(find.byType(RoundScreen));

/// Where a place is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int stop) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RoundScreenState.fenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(stop));
}

/// Drives to a place.
Future<void> driveTo(WidgetTester tester, int stop) async {
  await tester.tapAt(whereIs(tester, stop));
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Drives the shortest round there is, one call at a time.
Future<void> driveItAll(WidgetTester tester) async {
  final round = state(tester).round;
  for (final stop in Rounder(round.moor).work().order.skip(1)) {
    await driveTo(tester, stop);
  }
}
