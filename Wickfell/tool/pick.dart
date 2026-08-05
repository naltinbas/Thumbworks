// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:wickfell/lamps/grid.dart';
import 'package:wickfell/lamps/solve.dart';

/// Finds boards of a size that take a given number of presses.
///
/// Run with: dart run tool/pick.dart across down fewest [how many]
void main(List<String> args) {
  final across = int.parse(args[0]);
  final down = int.parse(args[1]);
  final fewest = int.parse(args[2]);
  final wanted = args.length > 3 ? int.parse(args[3]) : 2;

  final grid = Grid(across, down);
  final sums = Sums(grid);
  final dice = Random(across * 100 + down * 10 + fewest);

  var found = 0;
  for (var i = 0; i < 400000 && found < wanted; i++) {
    var board = 0;
    for (var at = 0; at < grid.lamps; at++) {
      if (dice.nextBool()) board |= 1 << at;
    }
    final answer = sums.answer(board);
    if (!answer.canBeDone || answer.fewest != fewest) continue;
    found++;

    final rows = <String>[];
    for (var row = 0; row < down; row++) {
      final line = StringBuffer();
      for (var column = 0; column < across; column++) {
        line.write(grid.isLit(board, row * across + column) ? 'O' : '.');
      }
      rows.add("        '$line',");
    }
    print('    Level(');
    print("      name: '',");
    print('      across: $across,');
    print('      presses: ${answer.fewest},');
    print('      rows: [');
    rows.forEach(print);
    print('      ],');
    print('    ),');
  }
}
