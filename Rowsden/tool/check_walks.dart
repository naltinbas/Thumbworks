import 'dart:io';

import 'package:rowsden/school/levels.dart';
import 'package:rowsden/school/rules.dart';

/// Sweeps every filling of every week, holds Kirkman's own week to
/// the sweep, and refuses the bake on any disagreement: this is what
/// `make walks` runs, and the README quotes its ledger verbatim.
void main() {
  if (Rules.days.length != 280) {
    stderr.writeln('${Rules.days.length} DAYS');
    exit(1);
  }
  // Every level: the label against the sweep. A filling is a choice of
  // one of the 280 days for each day to fill; those repeating no pair
  // are counted by the walk, and for the week asking every pair the
  // walk checks the pairs met as well.
  for (final level in Levels.all) {
    final (noRepeat, _) = Rules.completions(level.given, level.more);
    var ways = noRepeat;
    if (level.allPairs) {
      // Every filling in full, no pruning: none may repeat a pair and all
      // 36 must be met.
      ways = 0;
      var tried = 0;
      final chosen = <Day>[...level.given];
      void grow(int left) {
        if (left == 0) {
          tried++;
          if (Rules.noPairTwice(chosen) && Rules.pairsMet(chosen).length == 36) ways++;
          return;
        }
        for (final day in Rules.days) {
          chosen.add(day);
          grow(left - 1);
          chosen.removeLast();
        }
      }

      grow(level.more);
      if (tried != level.fillings) {
        stderr.writeln('${level.name}: $tried fillings tried');
        exit(1);
      }
    }
    var fillings = 1;
    for (var i = 0; i < level.more; i++) {
      fillings *= 280;
    }
    if (ways != level.ways || fillings != level.fillings) {
      stderr.writeln('${level.name}: sweep finds $ways of $fillings, label says ${level.ways} of ${level.fillings}');
      exit(1);
    }
  }

  // Kirkman's own week: rows, columns, the two slants; no pair twice,
  // all 36 met, and it is a completion of every level's given days.
  final week = Rules.affineWeek;
  if (!Rules.noPairTwice(week) || Rules.pairsMet(week).length != 36) {
    stderr.writeln('THE AFFINE WEEK REPEATS OR MISSES A PAIR');
    exit(1);
  }
  for (final level in Levels.all) {
    for (var d = 0; d < level.given.length; d++) {
      if ('${level.given[d]}' != '${week[d]}') {
        stderr.writeln('${level.name}: GIVEN DAY $d IS NOT KIRKMAN\'S');
        exit(1);
      }
    }
  }
  // The counts multiply: 36 second days, 2 third days each, 1 fourth
  // day each, 72 weeks.
  var thirds = 0, fourths = 0;
  final used1 = Rules.pairsMet([week[0]]);
  for (final day2 in Rules.days) {
    final p2 = Rules.pairsOfDay(day2);
    if (p2.any(used1.contains)) continue;
    final (int t, _) = Rules.completions([week[0], day2], 1);
    if (t != 2) {
      stderr.writeln('A SECOND DAY WITH $t THIRD DAYS');
      exit(1);
    }
    thirds += t;
    for (final day3 in Rules.days) {
      final p3 = Rules.pairsOfDay(day3);
      if (p3.any(used1.contains) || p3.any(p2.contains)) continue;
      final (int f, _) = Rules.completions([week[0], day2, day3], 1);
      if (f != 1) {
        stderr.writeln('A THIRD DAY WITH $f FOURTH DAYS');
        exit(1);
      }
      fourths += f;
    }
  }
  if (thirds != 72 || fourths != 72) {
    stderr.writeln('THE COUNTS DO NOT MULTIPLY: $thirds $fourths');
    exit(1);
  }
  // Three days meet 27 pairs at the most, and four days are exactly
  // what nine girls need.
  if (Rules.daysNeeded != 4) {
    stderr.writeln('THE ARITHMETIC MOVED');
    exit(1);
  }
  var most = 0;
  {
    final used = Rules.pairsMet([week[0]]);
    for (final day2 in Rules.days) {
      final p2 = Rules.pairsOfDay(day2);
      if (p2.any(used.contains)) continue;
      for (final day3 in Rules.days) {
        final p3 = Rules.pairsOfDay(day3);
        if (p3.any(used.contains) || p3.any(p2.contains)) continue;
        final met = <int>{...used, ...p2, ...p3}.length;
        if (met > most) most = met;
      }
    }
  }
  if (most != 27) {
    stderr.writeln('THREE DAYS MEET $most PAIRS');
    exit(1);
  }

  stdout.writeln(
      'every filling of every week swept, one of the 280 walks of nine '
      'in rows of three to each day to fill: from the first day given, '
      '36 second days repeat no pair, 2 third days after each of those, 1 '
      'fourth day after each of those, 72 weeks in all of the 21,952,000 '
      'fillings, and every one of the 72 walks all 36 pairs; Kirkman\'s '
      'own week, rows, columns and the two slants of the three-by-three, '
      'is one of them; and three days meet 27 pairs at the most, so no '
      'filling of two more days walks every pair, all 78,400 tried');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.fillings)} fillings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.fillings)}, and two new a day said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
