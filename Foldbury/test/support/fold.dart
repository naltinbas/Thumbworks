import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldbury/best.dart';
import 'package:foldbury/fold/play.dart';
import 'package:foldbury/ui/app.dart';
import 'package:foldbury/ui/fold_screen.dart';
import 'package:foldbury/ui/foldview.dart';

/// The bits every test that watches a night needs.

/// A phone to lay the fold out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last night's.
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
    child: FoldburyApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FoldScreenState state(WidgetTester tester) =>
    tester.state<FoldScreenState>(find.byType(FoldScreen));

/// Where a gate stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int gate) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FoldScreenState.foldKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(gate));
}

/// Touches a gate: posts a shepherd there, or stands one down.
Future<void> post(WidgetTester tester, int gate) async {
  await tester.tapAt(whereIs(tester, gate));
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

/// Watches the whole night by asking the game where to post next.
Future<void> watchItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 12) fail('the night never ended');
    final next = state(tester).play.next;
    if (next == null) fail('no gate keeps it at the fewest');
    await post(tester, next);
  }
}

/// A run of posts whose last one raises what the night can still be watched
/// with, found by trying, so a test can walk a player into the mistake the
/// game is meant to call out.
List<int>? costing(Play play, [int depth = 2]) {
  for (var gate = 0; gate < play.fold.count; gate++) {
    if ((play.posted >> gate) & 1 != 0) continue;
    if (play.touch(gate).couldStillBe > play.fold.fewest) return [gate];
  }
  if (depth == 0) return null;
  for (var gate = 0; gate < play.fold.count; gate++) {
    if ((play.posted >> gate) & 1 != 0) continue;
    final rest = costing(play.touch(gate), depth - 1);
    if (rest != null) return [gate, ...rest];
  }
  return null;
}
