import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staddlestone/best.dart';
import 'package:staddlestone/ui/app.dart';
import 'package:staddlestone/ui/yard_screen.dart';
import 'package:staddlestone/ui/yardview.dart';

/// The bits every test that works a yard needs.

/// A phone to lay the yard out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last yard's.
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
    child: StaddlestoneApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

/// Where a staddle is on the screen, worked out the way the game works it
/// out.
Offset whereIs(WidgetTester tester, int staddle) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(YardScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(
    Offset(metrics.middleOf(staddle), metrics.ground - metrics.thick * 2),
  );
}

/// Taps a staddle: lifts, sets down, or puts back.
Future<void> tapStaddle(WidgetTester tester, int staddle) async {
  await tester.tapAt(whereIs(tester, staddle));
  await tester.pump();
}

/// Moves the top stone of one staddle to another.
Future<void> move(WidgetTester tester, int from, int to) async {
  await tapStaddle(tester, from);
  await tapStaddle(tester, to);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Works the whole yard by asking the game what to move next.
Future<void> workItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 70) fail('the stack never came home');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to move and the stack is not home');
    await move(tester, next.$1, next.$2);
  }
}
