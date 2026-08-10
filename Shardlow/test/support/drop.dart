import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shardlow/best.dart';
import 'package:shardlow/ui/app.dart';
import 'package:shardlow/ui/drop_screen.dart';
import 'package:shardlow/ui/ladderview.dart';

/// The bits every test that works a ladder needs.

/// A phone to stand the ladder on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last morning's.
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
    child: ShardlowApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

DropScreenState state(WidgetTester tester) =>
    tester.state<DropScreenState>(find.byType(DropScreen));

/// Where a rung is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int rung) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(DropScreenState.ladderKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(Offset(
    (metrics.railLeft + metrics.railRight) / 2,
    metrics.yOf(rung),
  ));
}

/// Drops a pot from a rung.
Future<void> drop(WidgetTester tester, int rung) async {
  await tester.tapAt(whereIs(tester, rung));
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

/// Settles the whole morning by asking the game which rung comes next.
Future<void> settleItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the morning never settled');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to drop and it is not settled');
    await drop(tester, next);
  }
}
