import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handfast/best.dart';
import 'package:handfast/ui/app.dart';
import 'package:handfast/ui/boardview.dart';
import 'package:handfast/ui/hire_screen.dart';

/// The bits every test that gives out a day's work needs.

/// A phone to lay the board out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last day's.
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
    child: HandfastApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HireScreenState state(WidgetTester tester) =>
    tester.state<HireScreenState>(find.byType(HireScreen));

Offset _global(WidgetTester tester, Offset local) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HireScreenState.boardKey),
  );
  return box.localToGlobal(local);
}

Metrics _metrics(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HireScreenState.boardKey),
  );
  return Metrics(state(tester).play, box.size);
}

/// Taps a cell, worked out the way the game works it out.
Future<void> tapCell(WidgetTester tester, int job, int hand) async {
  await tester.tapAt(_global(tester, _metrics(tester).cellAt(job, hand).center));
  await tester.pump();
}

/// Taps the job written down the side, which takes it back off whoever has it.
Future<void> tapJob(WidgetTester tester, int job) async {
  final metrics = _metrics(tester);
  await tester.tapAt(_global(
    tester,
    Offset(metrics.names / 2, metrics.rowAt(job).center.dy),
  ));
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

/// Gives the whole day out by asking the game what to do next.
Future<void> giveItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 40) fail('the day never ended');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to give out and the day is not over');
    await tapCell(tester, next.$1, next.$2);
  }
}
