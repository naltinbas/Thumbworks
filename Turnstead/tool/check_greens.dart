// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:turnstead/green/greens.dart';
import 'package:turnstead/green/rules.dart';

/// Walks every shipped green and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_greens.dart  (or `make greens`)
void main() {
  // The wheel covers every pair once, size by size, first.
  for (var sides = 4; sides <= 12; sides += 2) {
    final met = <String>{};
    for (var round = 0; round < sides - 1; round++) {
      final seen = <int>{};
      for (final (a, b) in Rules.wheelRound(sides, round)) {
        if (!seen.add(a) || !seen.add(b)) {
          throw StateError('the wheel doubles a side at $sides, $round');
        }
        if (!met.add('$a-$b')) {
          throw StateError('the wheel repeats $a-$b at $sides');
        }
      }
      if (seen.length != sides) {
        throw StateError('the wheel benches a side at $sides, $round');
      }
    }
    if (met.length != sides * (sides - 1) ~/ 2) {
      throw StateError('the wheel misses pairs at $sides');
    }
  }
  print('the wheel writes every card from four to twelve sides, every '
      'pair exactly once\n');

  var wrong = 0;
  for (var number = 0; number < Greens.count; number++) {
    final green = Greens.at(number);
    final writable =
        Rules.canStillFinish(green.sides, {}, [], green.rounds - 1);

    final agree = writable == green.possible;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${green.name.padRight(16)} '
        '${green.sides} sides in ${green.rounds} rounds  '
        '${writable ? "the card writes" : "no card fits"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong green${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped greens are not what they claim');
  }
}
