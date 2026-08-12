import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanglemere/best.dart';
import 'package:tanglemere/ui/app.dart';
import 'package:tanglemere/ui/web_screen.dart';
import 'package:tanglemere/ui/webview.dart';

/// The bits every test that weaves a web needs.

/// A phone to hang the loom on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last web's.
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
    child: TanglemereApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WebScreenState state(WidgetTester tester) =>
    tester.state<WebScreenState>(find.byType(WebScreen));

/// Taps one thread at its middle.
Future<void> tapThread(WidgetTester tester, int thread) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WebScreenState.loomKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  final (a, b) = state(tester).play.rules.edges[thread];
  final from = metrics.postAt(a);
  final to = metrics.postAt(b);
  // Long chords cross at the middle, so walk along the thread until
  // the hit-test agrees the point is this thread's.
  for (final t in const [0.5, 0.33, 0.67, 0.25, 0.75, 0.4, 0.6]) {
    final at = Offset.lerp(from, to, t)!;
    if (metrics.threadAt(at) == thread) {
      await tester.tapAt(box.localToGlobal(at));
      await tester.pump();
      return;
    }
  }
  fail('no point on thread $thread hit-tests to it');
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Weaves to the end by asking the game which thread comes next.
Future<void> weaveItOut(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 12) fail('the weave never settled');
    final thread = state(tester).play.next;
    expect(thread, isNotNull, reason: 'no thread offered');
    await tapThread(tester, thread!);
  }
}
