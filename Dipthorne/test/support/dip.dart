import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dipthorne/best.dart';
import 'package:dipthorne/ui/app.dart';
import 'package:dipthorne/ui/dip_screen.dart';
import 'package:dipthorne/ui/ringview.dart';

/// The bits every test that runs a dip needs.

/// A phone to stand the ring on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last dip's.
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
    child: DipthorneApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

DipScreenState state(WidgetTester tester) =>
    tester.state<DipScreenState>(find.byType(DipScreen));

/// Where a seat stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int seat) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(DipScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.seatAt(seat));
}

/// Takes a seat, before the rhyme starts.
Future<void> stand(WidgetTester tester, int seat) async {
  await tester.tapAt(whereIs(tester, seat));
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

/// Runs the whole count with the Count button.
Future<void> countItOut(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 30) fail('the dip never ended');
    await press(tester, 'Count');
  }
}
