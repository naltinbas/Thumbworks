// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:wickfell/lamps/grid.dart';
import 'package:wickfell/lamps/solve.dart';

/// Says what each size of board is like, and looks for good ones to ship.
///
/// Run with: dart run tool/boards.dart
///
/// Two things are worth knowing about a size. How many of its boards can be
/// turned off at all — on a five by five it is one in four, and a game that
/// handed over one of the other three would be a game that cannot be finished
/// — and how many presses the hardest of them takes.
void main() {
  for (final size in const [(3, 3), (4, 4), (5, 5), (5, 4), (6, 6)]) {
    final grid = Grid(size.$1, size.$2);
    final sums = Sums(grid);
    final dice = Random(5);

    var could = 0;
    var deepest = 0;
    for (var i = 0; i < 4000; i++) {
      final board = _someBoard(dice, grid.lamps);
      final answer = sums.answer(board);
      if (!answer.canBeDone) continue;
      could++;
      if (answer.fewest > deepest) deepest = answer.fewest;
    }

    print('${grid.across}x${grid.down}  '
        '${grid.lamps.toString().padLeft(2)} lamps  '
        '${sums.spare} sets of presses change nothing  '
        '1 board in ${1 << sums.spare} can be turned off  '
        '($could of 4000 tried)  '
        'hardest seen: $deepest presses');
  }

  print('');
  print('boards worth shipping, five by five:');
  final grid = Grid(5, 5);
  final sums = Sums(grid);
  final dice = Random(11);
  var found = 0;
  for (var i = 0; i < 200000 && found < 8; i++) {
    final board = _someBoard(dice, grid.lamps);
    final answer = sums.answer(board);
    if (!answer.canBeDone || answer.fewest < 7) continue;
    found++;
    print('  0x${board.toRadixString(16)}  ${answer.fewest} presses  '
        '${grid.litOn(board)} lit');
    for (var row = 0; row < grid.down; row++) {
      final line = StringBuffer('    ');
      for (var column = 0; column < grid.across; column++) {
        line.write(grid.isLit(board, row * grid.across + column) ? 'O' : '.');
      }
      print('$line');
    }
  }
}

int _someBoard(Random dice, int lamps) {
  var board = 0;
  for (var at = 0; at < lamps; at++) {
    if (dice.nextBool()) board |= 1 << at;
  }
  return board;
}
