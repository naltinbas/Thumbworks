import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packwold/best.dart';
import 'package:packwold/fit/cover.dart';
import 'package:packwold/ui/app.dart';
import 'package:packwold/ui/board_screen.dart';
import 'package:packwold/ui/ground.dart';

/// The bits every test that packs a box needs.

/// A phone to lay the box out on.
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

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: PackwoldApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Where a square of the box is on the screen, worked out the way the game
/// works it out.
Offset whereIs(WidgetTester tester, int row, int column) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BoardScreenState.boxKey),
  );
  final metrics = Metrics(state(tester).play.box, box.size);
  return box.localToGlobal(metrics.squareAt(row, column).center);
}

/// The row and column of a cell of the box.
(int, int) squareOf(WidgetTester tester, int cell) {
  final box = state(tester).play.box;
  for (var row = 0; row < box.deep; row++) {
    for (var column = 0; column < box.wide; column++) {
      if (box.at(row, column) == cell) return (row, column);
    }
  }
  return (-1, -1);
}

/// Taps a square of the box.
Future<void> touch(WidgetTester tester, int row, int column) async {
  await tester.tapAt(whereIs(tester, row, column));
  await tester.pump();
}

/// Takes a piece out of the tray.
Future<void> pick(WidgetTester tester, String letter) async {
  await tester.tap(find.bySemanticsLabel(RegExp('^the $letter piece')));
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

/// Puts a piece where a placement has it, through the screen: out of the
/// tray, turned and flipped until it lies that way, then tapped down.
Future<void> lay(WidgetTester tester, Placement want) async {
  await pick(tester, want.letter);

  // Four turns come back to where it started, so the fifth press is a flip
  // and the next three turns cover the other four ways it can lie.
  for (var turn = 0; turn < 9; turn++) {
    if (state(tester).play.shapeOf(want.piece).picture == want.shape.picture) {
      break;
    }
    await press(tester, turn == 4 ? 'Flip' : 'Turn');
  }

  final anchor = want.shape.cells.first;
  await touch(tester, want.row + anchor.$1, want.column + anchor.$2);
}

/// Packs the box by asking what goes next and doing it.
Future<void> packIt(WidgetTester tester, {int most = 24}) async {
  for (var turn = 0; turn < most; turn++) {
    final screen = state(tester);
    if (screen.play.isDone) return;
    final step = screen.guide.next(screen.play);
    if (step == null) return;
    if (step.wrong) {
      final (row, column) = squareOf(tester, step.cells.first);
      await touch(tester, row, column);
      continue;
    }
    await lay(tester, step.where);
  }
}
