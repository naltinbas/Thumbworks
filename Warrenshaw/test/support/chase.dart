import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warrenshaw/best.dart';
import 'package:warrenshaw/ui/app.dart';
import 'package:warrenshaw/ui/chase_screen.dart';
import 'package:warrenshaw/ui/warren_view.dart';

/// The bits every test that plays a chase needs.

/// A phone to lay the map out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last map's.
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
    child: WarrenshawApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ChaseScreenState state(WidgetTester tester) =>
    tester.state<ChaseScreenState>(find.byType(ChaseScreen));

/// Where a place is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int place) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ChaseScreenState.mapKey),
  );
  final metrics = Metrics(state(tester).play.chart, box.size);
  return box.localToGlobal(metrics.middleOf(place));
}

/// Taps a place.
Future<void> touch(WidgetTester tester, int place) async {
  await tester.tapAt(whereIs(tester, place));
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

/// Wins the chase by taking the best move over and over.
Future<void> chaseItDown(WidgetTester tester, {int most = 30}) async {
  for (var turn = 0; turn < most; turn++) {
    final screen = state(tester);
    if (screen.play.isDone) return;
    final next = screen.play.next;
    if (next == null) return;
    await touch(tester, next);
  }
}
