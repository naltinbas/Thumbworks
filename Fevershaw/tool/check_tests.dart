import 'dart:io';

import 'package:fevershaw/village/levels.dart';
import 'package:fevershaw/village/play.dart';
import 'package:fevershaw/village/rules.dart';

/// Counts the village on every setting of the sham, holds the count to
/// Bayes' fractions, and refuses the bake on any disagreement: this is
/// what `make tests` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and no level opening landed.
  for (final level in Levels.all) {
    final (met, all) = Rules.sweep(level.meets);
    if (met != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (Play.of(level).isDone) {
      stderr.writeln('${level.name}: OPENS LANDED');
      exit(1);
    }
  }
  // Counting against chances on all 225, every count whole.
  var settings = 0, sure = 0, sureNoAlarm = 0, nineInTen = 0;
  Rules.sweep((p, c, a) {
    settings++;
    if (!Rules.whole(p, c, a)) {
      stderr.writeln('1 IN $p, $c, $a: THE VILLAGE DOES NOT COUNT WHOLE');
      exit(1);
    }
    if (Rules.byCounting(p, c, a) != Rules.byChances(p, c, a)) {
      stderr.writeln('1 IN $p, $c, $a: COUNTING ${Rules.byCounting(p, c, a)}, CHANCES ${Rules.byChances(p, c, a)}');
      exit(1);
    }
    final share = Rules.byChances(p, c, a);
    if (share == (1, 1)) {
      sure++;
      if (a == (0, 1)) sureNoAlarm++;
    }
    if (Rules.compare(share, (9, 10)) >= 0) nineInTen++;
    // The well outnumber the ill on every setting.
    final (ill, well, _, _) = Rules.counted(p, c, a);
    if (well < ill) {
      stderr.writeln('1 IN $p: THE ILL OUTNUMBER THE WELL');
      exit(1);
    }
    return false;
  });
  if (settings != 225 || sure != 45 || sureNoAlarm != 45 || nineInTen != 100) {
    stderr.writeln('$settings SETTINGS, $sure SURE, $sureNoAlarm WITH NO ALARM, $nineInTen NINE IN TEN');
    exit(1);
  }
  // Named settings.
  final named = <(int, (int, int), (int, int)), ((int, int), int, int)>{
    (100, (99, 100), (1, 100)): ((1, 2), 99000, 99000),
    (1000, (99, 100), (1, 100)): ((11, 122), 9900, 99900),
    (1000, (999, 1000), (1, 1000)): ((1, 2), 9990, 9990),
    (10, (9, 10), (1, 10)): ((1, 2), 900000, 900000),
    (2, (9, 10), (1, 10)): ((9, 10), 4500000, 500000),
  };
  for (final e in named.entries) {
    final (p, c, a) = e.key;
    final (_, _, tp, fp) = Rules.counted(p, c, a);
    if (Rules.byChances(p, c, a) != e.value.$1 || tp != e.value.$2 || fp != e.value.$3) {
      stderr.writeln('1 IN $p, $c, $a: ${Rules.byChances(p, c, a)} $tp $fp, NOT ${e.value}');
      exit(1);
    }
  }
  // The four even chances are the matched ones.
  final halves = <String>[];
  Rules.sweep((p, c, a) {
    if (Rules.byChances(p, c, a) == (1, 2)) halves.add('$p ${c.$2} ${a.$2}');
    return false;
  });
  if (halves.join(', ') != '10 10 10, 20 20 20, 100 100 100, 1000 1000 1000') {
    stderr.writeln('THE HALVES ARE $halves');
    exit(1);
  }
  if (Rules.inHundred((11, 122)) != '9.01') {
    stderr.writeln('11 IN 122 MISREAD');
    exit(1);
  }

  stdout.writeln(
      'every setting of the sham, the fever one in two to one in a thousand, '
      'the test catching nine in ten to every one and flagging the well one in '
      'ten to none, 225 settings, counted in a village of ten million souls, every '
      'count whole, the ill flagged over all flagged, and held to Bayes\' fractions '
      'of chances, the two agreeing on all 225: a flag is right exactly one time '
      'in two on four settings, each a test as sure as the fever is rare, one in '
      'ten with nine in ten, one in twenty with nineteen in twenty, one in a '
      'hundred with ninety-nine, one in a thousand with nine hundred and '
      'ninety-nine, 99,000 ill flagged against 99,000 well at one in a hundred; '
      'the fever one in a thousand and the test ninety-nine in a hundred both '
      'ways leaves a flag right 11 times in 122, 9.01 in a hundred, 9,900 ill '
      'flagged against 99,900 well; a hundred settings reach nine in ten; the '
      'flag is sure on 45 settings, every one with the alarm at none, and on none '
      'with an alarm, the well outnumbering the ill on every setting');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(23);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} settings land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the well said so first');
  }
}
