import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marrowden/best.dart';
import 'package:marrowden/ui/app.dart';
import 'package:marrowden/ui/show_screen.dart';

/// The bits every test that judges a bench needs.

/// A phone to raise the tent on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// bench's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  List<List<int>>? Function(int number)? deals,
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
    child: MarrowdenApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
      dealsFor: deals,
    ),
  ));
  await tester.pump();
}

ShowScreenState state(WidgetTester tester) =>
    tester.state<ShowScreenState>(find.byType(ShowScreen));

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Judges sittings by the rule until the bench closes.
Future<void> judgeIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 2500) fail('the bench never closed');
    final play = state(tester).play;
    if (!play.judging) {
      await press(tester, 'Next sitting');
      continue;
    }
    await press(tester, play.ruleTakes ? 'Take it' : 'Wave it by');
  }
}
