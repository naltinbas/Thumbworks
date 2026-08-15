import 'dart:io';

import 'package:leechmere/garden/levels.dart';
import 'package:leechmere/garden/rules.dart';

/// Sweeps every setting of the loads with exact fractions, the equal
/// loads apart, holds the seasons to Ash's lead, and refuses the bake on
/// any disagreement: this is what `make loads` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (meeting, all) = level.equalLoads ? Rules.sweepEqual(level.meets) : Rules.sweep(level.meets);
    if (meeting != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $meeting of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
  }

  // Ash cures the bigger share in both seasons at every load; the year
  // is the seasons weighed by the loads; with equal loads Ash is ahead
  // in every one of the 25 settings; and every reversal of the 625 has
  // the loads uneven.
  for (final n in Rules.loads) {
    for (var s = 0; s < 2; s++) {
      if (Rules.compare(Rules.season(0, s, n), Rules.season(1, s, n)) <= 0) {
        stderr.writeln('ASH IS NOT AHEAD IN ${Rules.seasons[s]} AT $n');
        exit(1);
      }
    }
  }
  var reversals = 0, uneven = 0;
  for (final a1 in Rules.loads) {
    for (final a2 in Rules.loads) {
      for (final b1 in Rules.loads) {
        for (final b2 in Rules.loads) {
          final ash = Rules.year(0, a1, a2), birch = Rules.year(1, b1, b2);
          if (ash.$2 != a1 + a2 || birch.$2 != b1 + b2) {
            stderr.writeln('THE YEAR DOES NOT ADD THE SEASONS');
            exit(1);
          }
          if (Rules.compare(ash, birch) < 0) {
            reversals++;
            if (a1 != b1 || a2 != b2) uneven++;
          }
        }
      }
    }
  }
  if (reversals != 154 || uneven != reversals) {
    stderr.writeln('$reversals REVERSALS, $uneven WITH UNEVEN LOADS');
    exit(1);
  }
  final (equalReversals, equalAll) = Rules.sweepEqual((a1, a2, b1, b2) => Rules.compare(Rules.year(0, a1, a2), Rules.year(1, b1, b2)) < 0);
  if (equalReversals != 0 || equalAll != 25) {
    stderr.writeln('$equalReversals REVERSALS WITH EQUAL LOADS OF $equalAll');
    exit(1);
  }
  // The weighing, the second voice: with the loads alike, Ash's year is
  // Birch's plus one in ten exactly, since Ash cures one more in ten in
  // each season and the two years weigh the seasons alike. Checked as
  // fractions, cross-multiplied.
  final (tenths, equalAgain) = Rules.sweepEqual((a1, a2, b1, b2) {
    final ash = Rules.year(0, a1, a2), birch = Rules.year(1, b1, b2);
    return (ash.$1 * birch.$2 - birch.$1 * ash.$2) * 10 == ash.$2 * birch.$2;
  });
  if (tenths != 25 || equalAgain != 25) {
    stderr.writeln('ASH IS NOT ONE IN TEN AHEAD WITH EQUAL LOADS: $tenths OF $equalAgain');
    exit(1);
  }

  stdout.writeln(
      'every setting of the four loads swept with exact fractions, ten to fifty '
      'patients a healer a season in tens, 625 settings: Ash cures the bigger '
      'share in spring, nine in ten to eight, and in autumn, three in ten to two, '
      'at every load, and still cures the smaller share of the year in 154 '
      'settings, every one of them with the loads uneven, since the year is the '
      'seasons weighed by the patients seen; with the loads alike for both '
      'healers, 25 settings, Ash is ahead in the year every time, by one in ten '
      'exactly; the two years '
      'come level in 24 settings, Ash falls a fifth or more behind in 17, and '
      'down to two in five in 25; the reversal comes 154 ways of 625, the level '
      'year 24, the wide reversal 17, Ash down to two in five 25, and the '
      'reversal with equal loads never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(29);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} settings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the weighing said so first');
  }
}
