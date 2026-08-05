// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:rookvale/board/board.dart';
import 'package:rookvale/board/pieces.dart';
import 'package:rookvale/board/solve.dart';

/// Looks for boards with exactly one way through, and prints them.
///
/// Run with: dart run tool/find_puzzles.dart [how many] [pieces] [side]
///
/// Scattering pieces on a board almost always gives something with no way
/// through or a dozen, so this throws away nearly everything it makes. What
/// it cannot judge is whether the one way through is a way anybody would
/// enjoy finding, so it prints the board and the line for somebody to look at.
void main(List<String> args) {
  final wanted = args.isEmpty ? 8 : int.parse(args.first);
  final pieces = args.length > 1 ? int.parse(args[1]) : 5;
  final side = args.length > 2 ? int.parse(args[2]) : 4;

  final dice = Random(19);
  var tried = 0;
  var found = 0;

  while (found < wanted && tried < 200000) {
    tried++;
    final squares = <int>[for (var at = 0; at < side * side; at++) at];
    for (var i = 0; i < pieces; i++) {
      final j = i + dice.nextInt(squares.length - i);
      final held = squares[i];
      squares[i] = squares[j];
      squares[j] = held;
    }

    final board = Board.of(side, {
      for (var i = 0; i < pieces; i++)
        squares[i]: Piece.values[dice.nextInt(Piece.values.length)],
    });

    final ways = waysThrough(board);
    if (!ways.isOnlyOne) continue;
    found++;

    print('--- one way through, ${board.count} pieces, '
        '${ways.looked} positions looked at ---');
    for (var row = 0; row < side; row++) {
      final line = StringBuffer("  '");
      for (var column = 0; column < side; column++) {
        line.write(board.at(row * side + column)?.letter ?? '.');
      }
      print('$line',);
    }
    print('  ${ways.first.map((m) => '${m.from}>${m.to}').join(' ')}');
  }

  print('');
  print('kept $found of $tried');
}
