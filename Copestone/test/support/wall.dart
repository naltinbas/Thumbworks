import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:copestone/best.dart';
import 'package:copestone/ui/app.dart';
import 'package:copestone/ui/palette.dart';
import 'package:copestone/ui/wall_screen.dart';

/// The bits every test that walls a pitch needs.

/// A phone to raise the fell on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// pitch's.
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
    child: CopestoneApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WallScreenState state(WidgetTester tester) =>
    tester.state<WallScreenState>(find.byType(WallScreen));

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Lays a course from the heap of one kind.
Future<void> lay(WidgetTester tester, int kind) =>
    press(tester, Palette.kindNames[kind]);

/// Raises the wall by asking the game which kind keeps the height.
Future<void> raiseIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 14) fail('the wall never stood');
    final kind = state(tester).play.next;
    expect(kind, isNotNull, reason: 'no course offered');
    await lay(tester, kind!);
  }
}
