import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quirebeck/best.dart';
import 'package:quirebeck/ui/app.dart';
import 'package:quirebeck/ui/quire_screen.dart';

/// The bits every test that weaves a quire needs.

/// A phone to lay the bench on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// quire's.
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
    child: QuirebeckApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

QuireScreenState state(WidgetTester tester) =>
    tester.state<QuireScreenState>(find.byType(QuireScreen));

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// One weave, by its button.
Future<void> weave(WidgetTester tester, bool inward) =>
    press(tester, inward ? 'Weave in' : 'Weave out');

/// Settles the quire by asking the game which weave comes next.
Future<void> weaveIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 8) fail('the quire never settled');
    final inward = state(tester).play.next;
    expect(inward, isNotNull, reason: 'no weave offered');
    await weave(tester, inward!);
  }
  expect(state(tester).play.isDone, isTrue);
}
