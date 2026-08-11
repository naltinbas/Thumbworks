import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staplemere/best.dart';
import 'package:staplemere/ui/app.dart';
import 'package:staplemere/ui/yard_screen.dart';
import 'package:staplemere/ui/yardview.dart';
import 'package:staplemere/yard/play.dart';

/// The bits every test that plays a morning needs.

/// A phone to lay the yard out on.
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
    child: StaplemereApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

/// Where a slot stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int slot) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(YardScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(
    Offset(metrics.middleOf(slot), metrics.ground - 4),
  );
}

/// Sets the arriving bale down on a pile, or on the ground one past them.
Future<void> put(WidgetTester tester, int slot) async {
  await tester.tapAt(whereIs(tester, slot));
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

/// Plays the whole morning by asking the game where each bale should go.
Future<void> pileItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the morning never ended');
    final next = state(tester).play.next;
    if (next == null) fail('no place for the bale and the cart is not empty');
    await put(tester, next);
  }
}

/// A run of placements whose last one raises what the morning can still end
/// in, found by trying, so a test can walk a player into the mistake the
/// game is meant to call out.
List<int>? costing(Play play, [int depth = 3]) {
  for (var slot = 0; slot <= play.standing; slot++) {
    if (!play.mayRest(slot)) continue;
    if (play.put(slot).couldStillBe > play.deal.fewest) return [slot];
  }
  if (depth == 0) return null;
  for (var slot = 0; slot <= play.standing; slot++) {
    if (!play.mayRest(slot)) continue;
    final rest = costing(play.put(slot), depth - 1);
    if (rest != null) return [slot, ...rest];
  }
  return null;
}
