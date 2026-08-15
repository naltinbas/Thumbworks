import 'dart:io';

import 'package:squarebrook/stones/levels.dart';
import 'package:squarebrook/stones/rules.dart';

/// Sweeps every picking of stones for every number on the sham, makes
/// every number to a thousand with the fewest squares, holds Lagrange
/// and Legendre to the sweep, and refuses the bake on any disagreement:
/// this is what `make pickings` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (making, all) = Rules.sweep(level.number, level.count);
    if (making != level.ways || all != level.pickings) {
      stderr.writeln('${level.name}: sweep finds $making of $all, label says ${level.ways} of ${level.pickings}');
      exit(1);
    }
    if (Rules.makings(level.number, level.count).length != making) {
      stderr.writeln('${level.name}: THE MAKINGS DISAGREE WITH THE SWEEP');
      exit(1);
    }
    for (final m in Rules.makings(level.number, level.count)) {
      if (m.length != level.count || m.fold(0, (a, b) => a + b) != level.number) {
        stderr.writeln('${level.name}: MAKING $m IS NOT ONE');
        exit(1);
      }
    }
  }

  // Every number to a thousand: four squares suffice (Lagrange), and
  // three exactly when the number is not four to a power times seven
  // more than a multiple of eight (Legendre); by eight, a square leaves
  // 0, 1 or 4, and three of those never leave 7.
  var threes = 0;
  final failing = <int>[];
  for (var n = 1; n <= 1000; n++) {
    final fewest = Rules.fewest(n);
    if (fewest > 4) {
      stderr.writeln('$n WANTS $fewest SQUARES');
      exit(1);
    }
    if ((fewest <= 3) != Rules.threeSuffice(n)) {
      stderr.writeln('$n: THE SWEEP SAYS $fewest, LEGENDRE SAYS ${Rules.threeSuffice(n) ? 'THREE' : 'FOUR'}');
      exit(1);
    }
    if (fewest <= 3) {
      threes++;
    } else if (failing.length < 8) {
      failing.add(n);
    }
  }
  if (Rules.leavings(3).contains(7) || !Rules.leavings(4).contains(7)) {
    stderr.writeln('THE LEAVINGS BY EIGHT: THREE ${Rules.leavings(3)}, FOUR ${Rules.leavings(4)}');
    exit(1);
  }
  for (var s = 0; s < 100; s++) {
    if (![0, 1, 4].contains(s * s % 8)) {
      stderr.writeln('$s SQUARED LEAVES ${s * s % 8} BY EIGHT');
      exit(1);
    }
  }

  stdout.writeln(
      'every picking of stones swept for the numbers on the sham, and every '
      'number from one to a thousand made with the fewest squares by the sweep: '
      'four squares suffice for all thousand, as Lagrange said, and three '
      'suffice for $threes of them, exactly the numbers not four to a power '
      'times seven more than a multiple of eight, as Legendre said, the first '
      'that want four being ${failing.join(', ')}; a square leaves 0, 1 or 4 by '
      'eight, and three of those never leave 7; twelve is three squares 1 way of '
      '10, fifty two squares 2 ways of 28, twenty-three four 1 way of 35, '
      'ninety-nine three 3 ways of 165, and seven three squares never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(20);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.pickings} pickings make${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.pickings}, and eight said so first');
  }
}
