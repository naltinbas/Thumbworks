import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hollowmarch/best.dart';
import 'package:hollowmarch/pegs/field.dart';
import 'package:hollowmarch/pegs/runs.dart';
import 'package:hollowmarch/pegs/solve.dart';
import 'package:hollowmarch/ui/app.dart';
import 'package:hollowmarch/ui/board_screen.dart';
import 'package:hollowmarch/ui/hollows.dart';

/// The bits every test that plays a board needs.

/// A phone to lay the board out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last board's.
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
    child: HollowmarchApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Where a hollow is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int hollow) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BoardScreenState.boardKey),
  );
  final metrics = Metrics(state(tester).play.field, box.size);
  return box.localToGlobal(metrics.middleOf(hollow));
}

/// Taps a hollow.
Future<void> touch(WidgetTester tester, int hollow) async {
  await tester.tapAt(whereIs(tester, hollow));
  await tester.pump();
}

/// Makes a jump the way a finger does: let go of whatever was on the move if
/// it is not this peg, take this one, then tap where it is going.
Future<void> hop(WidgetTester tester, Jump jump) async {
  if (state(tester).play.carrying >= 0 &&
      state(tester).play.carrying != jump.from) {
    await press(tester, 'Let go');
  }
  if (state(tester).holding != jump.from) await touch(tester, jump.from);
  await touch(tester, jump.to);
}

/// Lets go of the peg on the move, if one is.
Future<void> letGo(WidgetTester tester) async {
  if (state(tester).play.carrying < 0) return;
  await press(tester, 'Let go');
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Plays a board down to one peg through the screen.
///
/// The fewest way where that can be worked out, and any way at all on the big
/// board, where it cannot: what this is for is showing that the screen can be
/// played, and the par is checked elsewhere.
Future<void> playItOut(WidgetTester tester, {int? most}) async {
  final board = state(tester).board;
  final fewest = Runs.fewest(board.field, board.start);
  final route = fewest?.$2 ?? Solver(board.field).from(board.start)?.jumps;
  if (route == null) return;

  var made = 0;
  for (final jump in route) {
    if (most != null && made >= most) return;
    await hop(tester, jump);
    made++;
  }
}

/// Plays the first few jumps of the fewest way through.
Future<void> playSome(WidgetTester tester, int jumps) =>
    playItOut(tester, most: jumps);
