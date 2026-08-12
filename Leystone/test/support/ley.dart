import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leystone/best.dart';
import 'package:leystone/ui/app.dart';
import 'package:leystone/ui/ley_screen.dart';
import 'package:leystone/ui/leyview.dart';

/// The bits every test that raises a ring needs.

/// A phone to lay the moor on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// green's.
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

  // In a boundary, so a screenshot can be taken of whatever a test
  // leaves on it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: LeystoneApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

LeyScreenState state(WidgetTester tester) =>
    tester.state<LeyScreenState>(find.byType(LeyScreen));

/// Taps one berth of the green.
Future<void> tapBerth(WidgetTester tester, (int, int) berth) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(LeyScreenState.greenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.berthAt(berth.$1, berth.$2)));
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

/// Raises the ring by asking the game which berth comes next.
Future<void> raiseIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 12) fail('the ring never stood');
    final play = state(tester).play;
    final ring = play.finished;
    expect(ring, isNotNull, reason: 'no ring offered');
    await tapBerth(tester, play.nextOf(ring!)!);
  }
}
