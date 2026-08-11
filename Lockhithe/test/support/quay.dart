import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockhithe/best.dart';
import 'package:lockhithe/quay/stow.dart';
import 'package:lockhithe/ui/app.dart';
import 'package:lockhithe/ui/quay_screen.dart';
import 'package:lockhithe/ui/quayview.dart';

/// The bits every test that sails a round needs.

/// A phone to lay the store on.
const phone = Size(1170, 2532);

/// A stow of eight with loops (1 5 3)(2 6)(4 7 8), in sailors' numbers:
/// the longest is three, so a following crew comes through.
const kindStow = Stow([4, 5, 0, 6, 2, 1, 7, 3]);

/// A stow of eight with a loop of six: (1 5 2)(4 7 8 6 3)? no — its
/// longest loop outruns four looks, so every crew is sunk before a door
/// opens.
const cruelStow = Stow([1, 2, 3, 4, 5, 0, 7, 6]);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last round's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  Stow? dealt,
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
    child: LockhitheApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
      dealt: dealt,
    ),
  ));
  await tester.pump();
}

QuayScreenState state(WidgetTester tester) =>
    tester.state<QuayScreenState>(find.byType(QuayScreen));

/// Where a locker stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int locker) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(QuayScreenState.storeKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.lockerRect(locker).center);
}

/// Opens a locker.
Future<void> look(WidgetTester tester, int locker) async {
  await tester.tapAt(whereIs(tester, locker));
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

/// Follows the chits until the round settles.
Future<void> followItOut(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 12) fail('the round never settled');
    final next = state(tester).play.next;
    if (next == null) fail('the loop closed early');
    await look(tester, next);
  }
}
