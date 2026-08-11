import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riddlecombe/best.dart';
import 'package:riddlecombe/ui/app.dart';
import 'package:riddlecombe/ui/weave_screen.dart';
import 'package:riddlecombe/ui/weaveview.dart';

/// The bits every test that weaves a mesh needs.

/// A phone to hang the frame on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last mesh's.
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
    child: RiddlecombeApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WeaveScreenState state(WidgetTester tester) =>
    tester.state<WeaveScreenState>(find.byType(WeaveScreen));

/// Taps one strand, midway along.
Future<void> tapStrand(WidgetTester tester, int strand) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WeaveScreenState.frameKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(
      Offset(metrics.width / 2, metrics.strandY(strand))));
  await tester.pump();
}

/// Weaves a comb between two strands with two taps.
Future<void> weave(WidgetTester tester, int one, int other) async {
  await tapStrand(tester, one);
  await tapStrand(tester, other);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Riddles the mesh clean by asking the game which comb comes next.
Future<void> weaveItClean(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isClean) {
    if (guard++ > 14) fail('the riddle never came clean');
    final comb = state(tester).play.next;
    expect(comb, isNotNull, reason: 'no comb offered');
    await weave(tester, comb!.$1, comb.$2);
  }
}
