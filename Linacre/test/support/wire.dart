import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linacre/best.dart';
import 'package:linacre/ui/app.dart';
import 'package:linacre/ui/netview.dart';
import 'package:linacre/ui/wire_screen.dart';

/// The bits every test that plays a round needs.

/// A phone to lay the line out on.
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
    child: LinacreApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WireScreenState state(WidgetTester tester) =>
    tester.state<WireScreenState>(find.byType(WireScreen));

/// Where a wire bows out to, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int wire) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WireScreenState.netKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.bendOf(wire));
}

/// Touches a wire: cuts it or braces it, whichever part the player has.
Future<void> touch(WidgetTester tester, int wire) async {
  await tester.tapAt(whereIs(tester, wire));
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

/// Plays the whole round by asking the game which wire wins.
Future<void> winItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 12) fail('the round never ended');
    final next = state(tester).play.next;
    if (next == null) fail('no winning wire and the round is not over');
    await touch(tester, next);
  }
}
