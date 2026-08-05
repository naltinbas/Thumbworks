import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trestlewick/best.dart';
import 'package:trestlewick/ui/app.dart';
import 'package:trestlewick/ui/frameview.dart';
import 'package:trestlewick/ui/raise_screen.dart';

/// The bits every test that raises a frame needs.

/// A phone to lay the site out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last frame's.
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
    child: TrestlewickApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RaiseScreenState state(WidgetTester tester) =>
    tester.state<RaiseScreenState>(find.byType(RaiseScreen));

/// Where a timber is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int timber) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RaiseScreenState.frameKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(timber));
}

/// Puts the crews on a timber, or takes them off it.
Future<void> put(WidgetTester tester, int timber) async {
  await tester.tapAt(whereIs(tester, timber));
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

/// Raises the whole frame by asking the game what to put the crews on.
Future<void> raiseItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 30) fail('the frame never went up');
    await press(tester, 'Show me');
    await press(tester, 'Raise the day');
  }
}
