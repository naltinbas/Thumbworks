import 'dart:io';

import 'package:candleford/party/levels.dart';
import 'package:candleford/party/rules.dart';

/// Works every party as an exact fraction, holds the fraction to a
/// literal count on small years, and refuses the bake on any
/// disagreement: this is what `make parties` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the sweep of its dial.
  for (final level in Levels.all) {
    var met = 0;
    for (var n = 1; n <= level.cap; n++) {
      if (level.meets(n)) met++;
    }
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.cap}, label says ${level.ways}');
      exit(1);
    }
  }

  // The named facts.
  final facts = <String, String>{
    '365 22': '47.5695',
    '365 23': '50.7297',
    '365 40': '89.1231',
    '365 41': '90.3151',
    '365 56': '98.8332',
    '365 57': '99.0122',
    '365 10': '11.6948',
    '365 30': '70.6316',
    '365 50': '97.0373',
    '365 60': '99.4122',
    '12 4': '42.7083',
    '12 5': '61.8055',
    '12 12': '99.9946',
  };
  for (final e in facts.entries) {
    final parts = e.key.split(' ');
    final got = Rules.inHundred(int.parse(parts[0]), int.parse(parts[1]), places: 4);
    if (got != e.value) {
      stderr.writeln('${e.key}: $got, NOT ${e.value}');
      exit(1);
    }
  }
  if (Rules.fewest(365, 1, 2) != 23 || Rules.fewest(365, 9, 10) != 41 || Rules.fewest(365, 99, 100) != 57 || Rules.fewest(365, 1, 1) != 366 || Rules.fewest(12, 1, 2) != 5 || Rules.fewest(12, 1, 1) != 13) {
    stderr.writeln('THE FEWEST ARE ${Rules.fewest(365, 1, 2)}, ${Rules.fewest(365, 9, 10)}, ${Rules.fewest(365, 99, 100)}, ${Rules.fewest(365, 1, 1)}, ${Rules.fewest(12, 1, 2)}, ${Rules.fewest(12, 1, 1)}');
    exit(1);
  }
  // Certain at 366 and not at 365, by exact digits.
  if (!Rules.certain(365, 366) || Rules.certain(365, 365) || !Rules.certain(12, 13) || Rules.certain(12, 12)) {
    stderr.writeln('CERTAINTY MISJUDGED');
    exit(1);
  }
  final (p365, q365) = Rules.shared(365, 365);
  final shortBy = q365 - p365;
  if (shortBy.toString().length != 779 || q365.toString().length != 936 || shortBy <= BigInt.zero) {
    stderr.writeln('365 GUESTS: SHORT BY ${shortBy.toString().length} DIGITS OVER ${q365.toString().length}');
    exit(1);
  }
  // The literal walk on small years agrees with the fraction.
  final walks = <(int, int, int)>[(7, 5, 16807), (7, 8, 5764801), (12, 6, 2985984), (5, 7, 78125)];
  for (final (days, n, all) in walks) {
    final (ws, wa) = Rules.sharedByWalk(days, n);
    final (fs, fa) = Rules.shared(days, n);
    if (wa != BigInt.from(all) || ws * fa != fs * wa) {
      stderr.writeln('YEAR $days, $n GUESTS: WALK $ws/$wa, FRACTION $fs/$fa');
      exit(1);
    }
  }

  stdout.writeln(
      'every party of one to 366 guests of a 365-day year worked as an exact '
      'fraction, no two sharing being 365 down to 365 - n + 1 over 365 to the n: '
      'a shared birthday is more likely than not from 23 guests, 50.7297 in a '
      'hundred, 22 having 47.5695; nine in ten from 41, 90.3151, 40 having '
      '89.1231; ninety-nine in a hundred from 57, 99.0122, 56 having 98.8332; '
      'certain from 366, and short of certain at 365 by a hair, 365 factorial over '
      '365 to the 365th, a number of 779 digits over one of 936; a shared birth '
      'month is more likely than not from 5 guests of a twelve-month year, '
      '61.8055, and certain from 13; and the fraction agrees with a literal count '
      'of every way to give the guests a day, 16,807 ways for five guests of a '
      'seven-day week, 5,764,801 for eight, 2,985,984 for six guests of twelve '
      'months and 78,125 for seven guests of a five-day week');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(24);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: 1 of the ${level.settings} settings lands it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the fraction said so first');
  }
}
