import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knuckleby/best.dart';
import 'package:knuckleby/ui/app.dart';
import 'package:knuckleby/ui/bones_screen.dart';
import 'package:knuckleby/ui/bonesview.dart';

/// The bits every test that cuts a bench needs.

/// A phone to set the tavern on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// bench's.
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
    child: KnucklebyApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BonesScreenState state(WidgetTester tester) =>
    tester.state<BonesScreenState>(find.byType(BonesScreen));

/// Taps one face of one die.
Future<void> tapFace(WidgetTester tester, int die, int face) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BonesScreenState.benchKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.faceRect(die, face).center));
  await tester.pump();
}

/// Cuts a face until it holds [pips].
Future<void> cutTo(WidgetTester tester, int die, int face, int pips) async {
  var guard = 0;
  while (state(tester).play.faces(die)[face] != pips) {
    if (guard++ > 8) fail('the face never took $pips');
    await tapFace(tester, die, face);
  }
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Makes the trade by following the game's own pointer.
Future<void> tradeIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 120) fail('the trade was never made');
    final cut = state(tester).play.pointed;
    expect(cut, isNotNull, reason: 'no cut offered');
    final (die, face, want) = cut!;
    await cutTo(tester, die, face, want);
  }
}
