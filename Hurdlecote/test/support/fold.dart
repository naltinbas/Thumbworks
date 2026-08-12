import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hurdlecote/best.dart';
import 'package:hurdlecote/ui/app.dart';
import 'package:hurdlecote/ui/fold_screen.dart';
import 'package:hurdlecote/ui/foldview.dart';

/// The bits every test that fences a green needs.

/// A phone to lay the green on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// green's.
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
    child: HurdlecoteApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FoldScreenState state(WidgetTester tester) =>
    tester.state<FoldScreenState>(find.byType(FoldScreen));

/// Taps one crossing of the green.
Future<void> tapCross(WidgetTester tester, (int, int) spot) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FoldScreenState.greenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.crossAt(spot.$1, spot.$2)));
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

/// Settles the green by asking the game which hurdle comes next.
Future<void> fenceIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 10) fail('the green never settled');
    final play = state(tester).play;
    final fence = play.finished;
    expect(fence, isNotNull, reason: 'no fence offered');
    final next = play.nextOf(fence!);
    await tapCross(tester, next ?? play.posts.first);
  }
}
