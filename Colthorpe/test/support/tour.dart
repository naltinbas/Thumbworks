import 'package:colthorpe/best.dart';
import 'package:colthorpe/ui/app.dart';
import 'package:colthorpe/ui/tour_screen.dart';
import 'package:colthorpe/ui/tourview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that rides a round needs.

/// A phone to lay the yard out on.
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
    child: ColthorpeApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

TourScreenState state(WidgetTester tester) =>
    tester.state<TourScreenState>(find.byType(TourScreen));

/// Where a paddock lies, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int paddock) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(TourScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(paddock));
}

/// Rides the colt to a paddock.
Future<void> ride(WidgetTester tester, int paddock) async {
  await tester.tapAt(whereIs(tester, paddock));
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

/// Rides the whole round by asking the game which jump keeps it alive.
Future<void> rideItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 40) fail('the round never came home');
    final next = state(tester).play.next;
    if (next == null) fail('no jump keeps the round alive');
    await ride(tester, next);
  }
}
