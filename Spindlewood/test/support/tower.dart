import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spindlewood/best.dart';
import 'package:spindlewood/ui/app.dart';
import 'package:spindlewood/ui/tower_screen.dart';
import 'package:spindlewood/ui/towerview.dart';

/// The bits every test that raises a tower needs.

/// A phone to stand the bench on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last tower's.
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

  // In a boundary, so a screenshot can be taken of whatever a test leaves
  // on it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: SpindlewoodApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

TowerScreenState state(WidgetTester tester) =>
    tester.state<TowerScreenState>(find.byType(TowerScreen));

/// Taps one spindle's lane.
Future<void> tapSpindle(WidgetTester tester, int spindle) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(TowerScreenState.benchKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(
      Offset(metrics.spindleX(spindle), metrics.baseY - 10)));
  await tester.pump();
}

/// Moves a top round with two taps.
Future<void> lift(WidgetTester tester, int from, int to) async {
  await tapSpindle(tester, from);
  await tapSpindle(tester, to);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Raises the tower home by asking the game which move comes next.
Future<void> raiseItHome(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isHome) {
    if (guard++ > 35) fail('the tower never came home');
    final move = state(tester).play.next;
    expect(move, isNotNull, reason: 'no move offered');
    await lift(tester, move!.$1, move.$2);
  }
}
