import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cairnfall/best.dart';
import 'package:cairnfall/stones/cairn.dart';
import 'package:cairnfall/ui/app.dart';
import 'package:cairnfall/ui/round_screen.dart';

/// The bits every test that plays a round needs.

/// A phone to lay the cairns out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last round's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  bool showWorth = false,
  Size screen = phone,
  Duration theirPause = const Duration(milliseconds: 750),
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(CairnfallApp(
    key: ValueKey(_openings++),
    opensAt: which,
    best: best,
    showWorth: showWorth,
    theirPause: theirPause,
  ));
  await tester.pump();
}

RoundScreenState state(WidgetTester tester) =>
    tester.state<RoundScreenState>(find.byType(RoundScreen));

/// Taps a cairn by which one it is in the row, counting the ones still there.
Future<void> pickCairn(WidgetTester tester, int at) async {
  final cairn = state(tester).play.cairns[at];
  // Matched on the front of the label, because with the numbers on show it
  // carries what the cairn is worth as well.
  await tester.tap(
    find.bySemanticsLabel(
      RegExp('^${cairn.rule.name}, ${cairn.stones} stones'),
    ),
  );
  await tester.pump();
}

/// Takes stones off the cairn that has been picked.
Future<void> take(WidgetTester tester, int stones) async {
  await tester.tap(find.bySemanticsLabel('take $stones'));
  await tester.pump();
}

/// Picks a cairn and takes from it in one go.
Future<void> takeFrom(WidgetTester tester, int at, int stones) async {
  await pickCairn(tester, at);
  await take(tester, stones);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Lets the other player have its move.
Future<void> letThemMove(
  WidgetTester tester, {
  Duration pause = const Duration(milliseconds: 750),
}) async {
  await tester.pump(pause + const Duration(milliseconds: 20));
}

/// Plays a whole round by the arithmetic, both sides, to the last stone.
Future<void> playItOut(WidgetTester tester, {int most = 200}) async {
  for (var turn = 0; turn < most; turn++) {
    if (state(tester).play.isOver) return;
    if (state(tester).theirs) {
      await letThemMove(tester);
      continue;
    }
    final play = state(tester).play;
    final move = play.bestMove(CairnfallApp.worth);
    await takeFrom(tester, move.cairn, move.stones);
  }
}

/// Which cairn in the row has a rule, for a test that wants a particular one.
int cairnWith(WidgetTester tester, Rule rule) =>
    state(tester).play.cairns.indexWhere((cairn) => cairn.rule == rule);
