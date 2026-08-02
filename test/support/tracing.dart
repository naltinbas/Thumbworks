/// Playing the game from a test: where a word is on a board, and how to drag
/// a thumb across it.
///
/// A generated board is not known in advance, so a test that wants to find a
/// word on one has to look for it the way a player does.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/grid_geometry.dart';

/// Where on the screen the middle of a square is, worked out with the same
/// geometry the view lays itself out with.
Offset middleOf(WidgetTester tester, Board board, Spot spot) {
  final box = tester.getRect(find.byType(BoardView));
  return box.topLeft + GridGeometry.fit(box.size, board.size).centreOf(spot);
}

/// Drags across every square in [path] and leaves the finger down, which is
/// what a picture of a word being traced needs.
Future<TestGesture> thumbAcross(
  WidgetTester tester,
  Board board,
  List<Spot> path,
) async {
  final gesture =
      await tester.startGesture(middleOf(tester, board, path.first));
  await tester.pump();
  for (final spot in path.skip(1)) {
    await gesture.moveTo(middleOf(tester, board, spot));
    await tester.pump();
  }
  return gesture;
}

/// Traces [word] on the board on screen and lifts, the way a player finding
/// it would.
Future<void> traceWord(
  WidgetTester tester,
  Board board,
  String word,
) async {
  final path = pathFor(board, word);
  if (path == null) throw StateError('$word is not on this board');
  final gesture = await thumbAcross(tester, board, path);
  await gesture.up();
  await tester.pump();
}

/// Where a word is on the board, or null if it is not on it.
List<Spot>? pathFor(Board board, String word) {
  final path = <Spot>[];

  bool walk(Spot at, int letter) {
    if (path.contains(at)) return false;
    if (board.letterAt(at) != word[letter]) return false;
    path.add(at);
    if (letter == word.length - 1) return true;
    for (final next in around(board, at)) {
      if (walk(next, letter + 1)) return true;
    }
    path.removeLast();
    return false;
  }

  for (var row = 0; row < board.size; row++) {
    for (var col = 0; col < board.size; col++) {
      if (walk(Spot(row, col), 0)) return path;
    }
  }
  return null;
}

/// A trace of four squares that spells nothing, for a refusal.
List<Spot>? pathSpellingNothing(Board board) {
  final path = <Spot>[];

  bool walk(Spot at) {
    if (path.contains(at)) return false;
    path.add(at);
    if (path.length == 4) {
      if (board.judge(path) == Refusal.unknown) return true;
    } else {
      for (final next in around(board, at)) {
        if (walk(next)) return true;
      }
    }
    path.removeLast();
    return false;
  }

  for (var row = 0; row < board.size; row++) {
    for (var col = 0; col < board.size; col++) {
      if (walk(Spot(row, col))) return path;
    }
  }
  return null;
}

/// The squares a trace can go to from here.
List<Spot> around(Board board, Spot spot) => [
      for (var dr = -1; dr <= 1; dr++)
        for (var dc = -1; dc <= 1; dc++)
          if (dr != 0 || dc != 0)
            if (board.inside(Spot(spot.row + dr, spot.col + dc)))
              Spot(spot.row + dr, spot.col + dc),
    ];
