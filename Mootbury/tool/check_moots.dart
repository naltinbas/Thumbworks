import 'dart:io';

import 'package:mootbury/moot/levels.dart';
import 'package:mootbury/moot/play.dart';
import 'package:mootbury/moot/rules.dart';

/// Shares every moot of the sham both ways, holds the dealing to the
/// divisor and Hamilton to the quota, and refuses the bake on any
/// disagreement: this is what `make moots` runs, and the README quotes
/// its ledger verbatim.
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
  // On every set of hamlets and every moot to sixty seats: the shares add
  // to the seats; Hamilton keeps within quota; the dealing agrees with
  // the divisor; and Jefferson never falls.
  final sets = <List<int>>[
    [6, 6, 2],
    [12, 7, 4, 2],
    [5, 3, 1],
    [9, 5, 3, 1],
    [48, 20, 20, 12],
  ];
  var moots = 0;
  for (final pops in sets) {
    final total = pops.fold(0, (a, b) => a + b);
    for (var s = 1; s <= 60; s++) {
      moots++;
      final h = Rules.hamilton(pops, s), j = Rules.jeffersonDealt(pops, s), d = Rules.jeffersonByDivisor(pops, s);
      if (h.fold(0, (a, b) => a + b) != s || j.fold(0, (a, b) => a + b) != s) {
        stderr.writeln('$pops AT $s: THE SHARES DO NOT ADD TO THE SEATS');
        exit(1);
      }
      for (var i = 0; i < pops.length; i++) {
        final floor = pops[i] * s ~/ total, ceil = (pops[i] * s + total - 1) ~/ total;
        if (h[i] < floor || h[i] > ceil) {
          stderr.writeln('$pops AT $s: HAMILTON BREAKS THE QUOTA');
          exit(1);
        }
      }
      if (j.toString() != d.toString()) {
        stderr.writeln('$pops AT $s: DEALT $j, DIVISOR $d');
        exit(1);
      }
      if (Rules.jeffersonFalls(pops, s)) {
        stderr.writeln('$pops AT $s: JEFFERSON FALLS');
        exit(1);
      }
    }
  }
  if (moots != 300) {
    stderr.writeln('$moots MOOTS');
    exit(1);
  }
  // The named facts.
  if (Rules.hamilton([6, 6, 2], 10).toString() != '[4, 4, 2]' || Rules.hamilton([6, 6, 2], 11).toString() != '[5, 5, 1]' || Rules.hamilton([6, 6, 2], 3).toString() != '[1, 1, 1]' || Rules.hamilton([6, 6, 2], 4).toString() != '[2, 2, 0]') {
    stderr.writeln('SIX SIX TWO MISSHARED');
    exit(1);
  }
  if (Rules.hamilton([12, 7, 4, 2], 19).toString() != '[9, 5, 3, 2]' || Rules.hamilton([12, 7, 4, 2], 20).toString() != '[10, 6, 3, 1]' || Rules.loser([12, 7, 4, 2], 19) != 3) {
    stderr.writeln('THE FOUR HAMLETS MISSHARED');
    exit(1);
  }
  if (Rules.jeffersonDealt([5, 3, 1], 7).toString() != '[5, 2, 0]' || Rules.hamilton([5, 3, 1], 7).toString() != '[4, 2, 1]' || Rules.quotaWords(Rules.quotas([5, 3, 1], 7)[0]) != '3 8/9') {
    stderr.writeln('FIVE THREE ONE MISSHARED');
    exit(1);
  }
  final alabamas = <int>[], overs = <int>[], wholes = <int>[];
  Rules.sweep((s) {
    if (Rules.alabama([6, 6, 2], s)) alabamas.add(s);
    if (Rules.overQuota([5, 3, 1], s)) overs.add(s);
    if (Rules.wholeQuotas([6, 6, 2], s)) wholes.add(s);
    return false;
  });
  if (alabamas.toString() != '[3, 10, 17, 24]' || overs.toString() != '[7, 16, 25]' || wholes.toString() != '[7, 14, 21, 28]') {
    stderr.writeln('ALABAMA $alabamas OVER $overs WHOLE $wholes');
    exit(1);
  }

  stdout.writeln(
      'every moot of two to thirty seats on the sham shared two ways, by largest '
      'remainders and by dealing a seat at a time, and every moot to sixty on five '
      'sets of hamlets besides, 300 moots, the dealing held to the divisor reading '
      'on every one and largest remainders held within the quota on every one: '
      'among Ash and Beck of six hundred and Cote of two, ten seats share 4, 4, 2 '
      'and eleven 5, 5, 1, Cote losing a seat as the moot grows, and so at 3, 17 '
      'and 24 seats, four moots of the 29; among twelve, seven, four and two '
      'hundred only the moot of nineteen loses a hamlet a seat, 9, 5, 3, 2 then '
      '10, 6, 3, 1; among five, three and one hundred the dealing gives seven '
      'seats 5, 2, 0 against quotas of 3 8/9, 2 1/3 and 7/9, more than a quota '
      'rounded up, at 7, 16 and 25 seats, where largest remainders give 4, 2, 1; '
      'six, six and two hundred come to whole quotas at 7, 14, 21 and 28 seats; '
      'and dealt a seat at a time no hamlet ever loses a seat as the moot grows, '
      'on any of the 300');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(21);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} moots land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the dealing said so first');
  }
}
