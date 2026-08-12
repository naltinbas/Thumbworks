import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peckhollow/best.dart';
import 'package:peckhollow/ui/app.dart';
import 'package:peckhollow/ui/yard_screen.dart';
import 'package:peckhollow/ui/yardview.dart';

/// The bits every test that flips a yard needs.

/// A phone to dig the hollow in.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// yard's.
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
    child: PeckhollowApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

/// Taps one arrow of the yard, at its bowed middle.
Future<void> tapArrow(WidgetTester tester, int at) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(YardScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.arcMid(at)));
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

/// Crowns the yard by asking the game which flip comes next.
Future<void> crownIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 8) fail('the crowning never stood');
    final arrow = state(tester).play.next;
    expect(arrow, isNotNull, reason: 'no flip offered');
    await tapArrow(tester, arrow!);
  }
}
