import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mousewold/best.dart';
import 'package:mousewold/ui/app.dart';
import 'package:mousewold/ui/chase_screen.dart';
import 'package:mousewold/ui/chaseview.dart';

/// The bits every test that runs a chase needs.

/// A phone to lay the ground on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// ground's.
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
    child: MousewoldApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ChaseScreenState state(WidgetTester tester) =>
    tester.state<ChaseScreenState>(find.byType(ChaseScreen));

/// Steps the cat by tapping a post.
Future<void> tapPost(WidgetTester tester, int post) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ChaseScreenState.groundKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.postAt(post)));
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

/// Corners the mouse by asking the game which step comes next.
Future<void> chaseIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 12) fail('the mouse was never cornered');
    final post = state(tester).play.next;
    expect(post, isNotNull, reason: 'no step offered');
    await tapPost(tester, post!);
  }
  expect(state(tester).play.caught, isTrue);
}
