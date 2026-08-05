import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rookvale/best.dart';
import 'package:rookvale/ui/app.dart';
import 'package:rookvale/ui/board_screen.dart';

/// The bits every test that solves a puzzle needs.

/// A phone to lay a board out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last puzzle's.
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

  await tester.pumpWidget(RookvaleApp(
    key: ValueKey(_openings++),
    opensAt: which,
    best: best,
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Taps a square by its number. Matched on the front of the label, because it
/// carries what is standing there as well.
Future<void> tapSquare(WidgetTester tester, int square) async {
  await tester.tap(find.bySemanticsLabel(RegExp('^square ${square + 1},')));
  await tester.pump();
}

/// Makes a capture: tap the piece, then what it takes.
///
/// A piece that is already picked is left alone, because tapping it again is
/// how a player lets go of it.
Future<void> capture(WidgetTester tester, int from, int to) async {
  if (state(tester).picked != from) await tapSquare(tester, from);
  await tapSquare(tester, to);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Solves the puzzle by asking for each capture and making it.
Future<void> solveIt(WidgetTester tester, {int most = 12}) async {
  for (var turn = 0; turn < most; turn++) {
    if (state(tester).play.isOver) return;
    final next = state(tester).play.nextTake;
    if (next == null) return;
    await capture(tester, next.from, next.to);
  }
}
