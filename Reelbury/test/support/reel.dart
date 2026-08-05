import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelbury/best.dart';
import 'package:reelbury/reel/stable.dart';
import 'package:reelbury/ui/app.dart';
import 'package:reelbury/ui/floor.dart';
import 'package:reelbury/ui/round_screen.dart';

/// The bits every test that pairs a round up needs.

/// A phone to lay the hall out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last round's.
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
    child: ReelburyApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RoundScreenState state(WidgetTester tester) =>
    tester.state<RoundScreenState>(find.byType(RoundScreen));

/// Where somebody is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int who, {required bool caller}) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RoundScreenState.floorKey),
  );
  final metrics = Metrics(state(tester).play.count, box.size);
  return box.localToGlobal(metrics.chipAt(who, caller: caller).center);
}

/// Taps somebody.
Future<void> touch(WidgetTester tester, int who, {required bool caller}) async {
  await tester.tapAt(whereIs(tester, who, caller: caller));
  await tester.pump();
}

/// Puts a couple together the way a finger does.
Future<void> pair(WidgetTester tester, int caller, int dancer) async {
  await touch(tester, caller, caller: true);
  await touch(tester, dancer, caller: false);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Lays the pairing that holds out, one couple at a time.
Future<void> pairThemUp(WidgetTester tester) async {
  final round = state(tester).round;
  final answer = Stable.byAsking(round.hall);
  for (var caller = 0; caller < round.count; caller++) {
    await pair(tester, caller, answer[caller]);
  }
}

/// A pairing that is full but does not hold: the answer with two dancers
/// swapped, which always leaves somebody wanting to swap back.
Future<void> pairThemWrong(WidgetTester tester) async {
  final round = state(tester).round;
  final answer = Stable.byAsking(round.hall);
  for (var caller = 0; caller < round.count; caller++) {
    final swapped = caller == 0
        ? answer[1]
        : caller == 1
            ? answer[0]
            : answer[caller];
    await pair(tester, caller, swapped);
  }
}
