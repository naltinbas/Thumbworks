import 'dart:io';

import 'package:fridayford/almanac/levels.dart';
import 'package:fridayford/almanac/rules.dart';

/// Sweeps the fourteen kinds of year, holds the offsets of the
/// thirteenths to cover the week, walks two hundred real years by the
/// phone's own calendar, and refuses the bake on any disagreement:
/// this is what `make years` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (meeting, all) = Rules.sweep(level.meets);
    if (meeting != level.ways || all != level.kinds) {
      stderr.writeln('${level.name}: sweep finds $meeting of $all, label says ${level.ways} of ${level.kinds}');
      exit(1);
    }
  }

  // The offsets of the thirteenths cover the week, common and leap, so
  // every kind of year has a Friday the thirteenth; and no kind has more
  // than three.
  for (final isLeap in [false, true]) {
    final off = Rules.offsets(isLeap).toSet();
    if (off.length != 7) {
      stderr.writeln('${isLeap ? 'LEAP' : 'COMMON'}: THE OFFSETS COVER ${off.length} DAYS');
      exit(1);
    }
  }
  var most = 0, fewest = 12;
  for (final (_, f) in Rules.kinds) {
    if (f.length > most) most = f.length;
    if (f.length < fewest) fewest = f.length;
  }
  if (fewest != 1 || most != 3) {
    stderr.writeln('THE KINDS HAVE FROM $fewest TO $most FRIDAYS');
    exit(1);
  }

  // Two hundred real years, 1901 to 2100, read by the phone's own
  // calendar: each is one of the fourteen kinds and has the Fridays the
  // kind says, one to three of them.
  var walked = 0, threes = 0, ones = 0;
  final threeYears = <int>[];
  for (var y = 1901; y <= 2100; y++) {
    final ((first, isLeap), fridays) = Rules.real(y);
    if (fridays.toString() != Rules.fridays(first, isLeap).toString()) {
      stderr.writeln('$y: THE CALENDAR SAYS $fridays, THE KIND SAYS ${Rules.fridays(first, isLeap)}');
      exit(1);
    }
    if (fridays.isEmpty || fridays.length > 3) {
      stderr.writeln('$y: ${fridays.length} FRIDAYS');
      exit(1);
    }
    walked++;
    if (fridays.length == 3) {
      threes++;
      if (threeYears.length < 6) threeYears.add(y);
    }
    if (fridays.length == 1) ones++;
  }

  stdout.writeln(
      'all fourteen kinds of year swept, seven days for the first of January '
      'and February short or long, and the thirteenths of the months fall nought, '
      'three, three, six, one, four, six, two, five, nought, three and five days '
      'along the week from the first in a common year and nought, three, four, '
      'nought, two, five, nought, three, six, one, four and six in a leap year, '
      'every day of the week among them either way, so every kind has a Friday '
      'the thirteenth, one to three of them and never more; $walked real years '
      'walked day by day from 1901 to 2100 by the calendar itself, each of the '
      'kind its first day and its February say and each with the Fridays its kind '
      'says, $ones with one, $threes with three, the first of them '
      '${threeYears.join(', ')}; one Friday comes 6 kinds of 14, two 6, three 2, '
      'November\'s 2, and none never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(20);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.kinds} kinds of year land it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.kinds}, and the offsets said so first');
  }
}
