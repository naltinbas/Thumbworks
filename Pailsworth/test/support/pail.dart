import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pailsworth/best.dart';
import 'package:pailsworth/pail/play.dart';
import 'package:pailsworth/ui/app.dart';
import 'package:pailsworth/ui/pail_screen.dart';
import 'package:pailsworth/ui/pailview.dart';

/// The bits every test that runs an errand needs.

/// A phone to stand the well on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last errand's.
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
    child: PailsworthApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

PailScreenState state(WidgetTester tester) =>
    tester.state<PailScreenState>(find.byType(PailScreen));

/// Taps one end: a pail, the spring, or the drain.
Future<void> tapEnd(WidgetTester tester, int end) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(PailScreenState.wellKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  final at = end == Play.spring
      ? metrics.springRect().center
      : end == Play.drain
          ? metrics.drainRect().center
          : metrics.pailRect(end).center;
  await tester.tapAt(box.localToGlobal(at));
  await tester.pump();
}

/// Pours with two taps.
Future<void> pourFrom(WidgetTester tester, int from, int to) async {
  await tapEnd(tester, from);
  await tapEnd(tester, to);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Runs the errand by asking the game which pour comes next.
Future<void> runItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the errand never ran');
    final pour = state(tester).play.next;
    expect(pour, isNotNull, reason: 'no pour offered');
    await pourFrom(tester, pour!.$1, pour.$2);
  }
}
