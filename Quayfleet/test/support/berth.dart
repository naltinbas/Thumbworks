import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quayfleet/best.dart';
import 'package:quayfleet/ui/app.dart';
import 'package:quayfleet/ui/berth_screen.dart';
import 'package:quayfleet/ui/bookview.dart';

/// The bits every test that works a day needs.

/// A phone to lay the book out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last day's.
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
    child: QuayfleetApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BerthScreenState state(WidgetTester tester) =>
    tester.state<BerthScreenState>(find.byType(BerthScreen));

/// Where a ship's line in the book is, worked out the way the game works it
/// out.
Offset whereIs(WidgetTester tester, int ship) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BerthScreenState.bookKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.barOf(ship).center);
}

/// Gives a ship the berth, or takes it back.
Future<void> berth(WidgetTester tester, int ship) async {
  await tester.tapAt(whereIs(tester, ship));
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

/// Works the whole day by asking the game which ship to take next.
Future<void> workItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 40) fail('the day never ended');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to take and the day is not over');
    await berth(tester, next);
  }
}
