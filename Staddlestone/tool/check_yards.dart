// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:staddlestone/mill/fewest.dart';
import 'package:staddlestone/mill/yard.dart';
import 'package:staddlestone/mill/yards.dart';

/// Walks every shipped yard: the fewest by the walk, the doubling number, and
/// how many standings there are to hold.
void main() {
  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final started = DateTime.now();
    final moves = Moves(yard.stones);
    final start = Standing(List.filled(yard.stones, 0));
    final walked = moves.from(start);
    final doubling = Moves.doublingSays(yard.stones);
    final took = DateTime.now().difference(started).inMilliseconds;

    print('${(number + 1).toString().padLeft(2)} '
        '${yard.name.padRight(16)} '
        '${yard.stones} stones  '
        '${moves.standings.toString().padLeft(4)} standings  '
        'walked ${walked.toString().padLeft(2)}  '
        'doubling says ${doubling.toString().padLeft(2)}  '
        'written down ${yard.fewest.toString().padLeft(2)}  '
        '${took}ms'
        '${walked == doubling ? '' : '  THE TWO DISAGREE'}'
        '${walked == yard.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }

  // And the doubling holds beyond what ships.
  for (var stones = 7; stones <= 9; stones++) {
    final moves = Moves(stones);
    final start = Standing(List.filled(stones, 0));
    final walked = moves.from(start);
    print('   $stones stones off the book: walked $walked, doubling says '
        '${Moves.doublingSays(stones)}'
        '${walked == Moves.doublingSays(stones) ? '' : '  DISAGREE'}');
  }
}
