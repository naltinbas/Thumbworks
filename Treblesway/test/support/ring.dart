import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treblesway/best.dart';
import 'package:treblesway/ui/app.dart';
import 'package:treblesway/ui/ring_screen.dart';

/// The bits every test that rings a peal needs.

/// A phone to hang the bells in.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last peal's.
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
    child: TrebleswayApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RingScreenState state(WidgetTester tester) =>
    tester.state<RingScreenState>(find.byType(RingScreen));

/// Rings a change by the name on its button.
Future<void> ring(WidgetTester tester, String change) async {
  final button = find.text(change);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
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

/// Rings the whole peal by asking the game which change keeps it alive.
Future<void> ringItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 30) fail('the peal never came round');
    final next = state(tester).play.next;
    if (next == null) fail('no change keeps it alive and it is not home');
    await ring(tester, next.name);
  }
}
