// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:rookvale/board/puzzles.dart';
import 'package:rookvale/board/solve.dart';

/// Walks every puzzle's whole tree and says what it found.
///
/// Run with: dart run tool/check_puzzles.dart
///
/// One way through is the whole design. Two ways and a player can stumble
/// into the end without working anything out; none and the puzzle is a
/// mistake.
void main() {
  for (var i = 0; i < Puzzles.count; i++) {
    final puzzle = Puzzles.at(i);
    final board = puzzle.board;
    final ways = waysThrough(board);

    print('${(i + 1).toString().padLeft(2)} ${puzzle.name.padRight(20)} '
        '${board.count} pieces  '
        '${ways.count} way${ways.count == 1 ? '' : 's'} through  '
        '${board.moves.length} first moves  '
        '${ways.looked.toString().padLeft(4)} positions  '
        '${ways.first.map((m) => '${m.from}>${m.to}').join(' ')}');
  }
}
