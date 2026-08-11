import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rindhope/best.dart';
import 'package:rindhope/ui/app.dart';
import 'package:rindhope/ui/cheese_screen.dart';
import 'package:rindhope/ui/cheeseview.dart';

/// The bits every test that bites a block needs.

/// A phone to lay the shelf out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last block's.
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
    child: RindhopeApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

CheeseScreenState state(WidgetTester tester) =>
    tester.state<CheeseScreenState>(find.byType(CheeseScreen));

/// Where a crumb sits, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int x, int y) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CheeseScreenState.cheeseKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.crumbRect(x, y).center);
}

/// Bites a crumb, and the grey mouse answers on its heels.
Future<void> bite(WidgetTester tester, int x, int y) async {
  await tester.tapAt(whereIs(tester, x, y));
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

/// Wins the whole block by asking the game where to bite.
Future<void> winItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 20) fail('the block never settled');
    final next = state(tester).play.next;
    if (next == null) fail('no winning bite and the block is not settled');
    await bite(tester, next.$1, next.$2);
  }
}
