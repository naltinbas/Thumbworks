import 'dart:io';

import 'package:loadwick/dice/levels.dart';
import 'package:loadwick/dice/rules.dart';

/// Counts every roll of every pair of Efron's dice, sweeps every die of
/// faces up to six against them, and refuses the bake on any
/// disagreement: this is what `make dice` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the count.
  for (final level in Levels.all) {
    final landing = level.choices.where(level.lands).length;
    if (landing != level.ways || level.choices.length != level.picks) {
      stderr.writeln('${level.name}: $landing of ${level.choices.length} picks land, label says ${level.ways} of ${level.picks}');
      exit(1);
    }
  }

  // The ring: each beats the next 24 rolls of 36, and no die beats all
  // the others; the wins of every pair are counted, and wins, ties and
  // losses come to thirty-six.
  const ring = [(0, 1), (1, 2), (2, 3), (3, 0)];
  for (final (x, y) in ring) {
    if (Rules.wins(Rules.dice[x], Rules.dice[y]) != 24) {
      stderr.writeln('${Rules.names[x]} WINS ${Rules.wins(Rules.dice[x], Rules.dice[y])} AGAINST ${Rules.names[y]}');
      exit(1);
    }
  }
  if (Rules.champions.isNotEmpty) {
    stderr.writeln('CHAMPIONS ${Rules.champions}');
    exit(1);
  }
  final table = <String>[];
  for (var x = 0; x < 4; x++) {
    for (var y = 0; y < 4; y++) {
      if (x == y) continue;
      final w = Rules.wins(Rules.dice[x], Rules.dice[y]), t = Rules.ties(Rules.dice[x], Rules.dice[y]), l = Rules.wins(Rules.dice[y], Rules.dice[x]);
      if (w + t + l != 36) {
        stderr.writeln('${Rules.names[x]} AGAINST ${Rules.names[y]}: $w + $t + $l');
        exit(1);
      }
      table.add('${Rules.names[x]} against ${Rules.names[y]} $w');
    }
  }
  // Every die of faces nought to six against the four.
  final (all, beatingAll, beatingNone, each) = Rules.sweep();
  if (all != 924 || beatingAll == 0) {
    stderr.writeln('THE SWEEP: $all DICE, $beatingAll BEATING ALL');
    exit(1);
  }

  stdout.writeln(
      'every roll of every pair of Efron\'s dice counted, thirty-six a pair, '
      'wins and ties and losses coming to thirty-six every time: A beats B, B '
      'beats C, C beats D and D beats A, 24 rolls of 36 each, a ring, and no die '
      'of the four beats every other, though C beats A as well, 20 rolls; the '
      'wins run ${table.join(', ')}; every die of six faces from nought to six '
      'swept against the four, $all dice, ${each[0]} beating A, ${each[1]} B, '
      '${each[2]} C and ${each[3]} D, $beatingAll beating all four and '
      '$beatingNone none of them; the house rolling A is beaten by 2 picks of 3, '
      'B by 1, C by 1, D by 1, and the champion by none of 4');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(17);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.picks} picks land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.picks}, and the ring said so first');
  }
}
