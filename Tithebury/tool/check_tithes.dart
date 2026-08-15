import 'dart:io';

import 'package:tithebury/tithe/levels.dart';
import 'package:tithebury/tithe/play.dart';
import 'package:tithebury/tithe/rules.dart';

/// Sweeps every number on the dial, holds the tithe by the count against
/// the tithe by the formula, and refuses the bake on any disagreement:
/// this is what `make tithes` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the sweep, the aim landing it, and no
  // level landed at the opening number.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 500) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The two voices on every number to 500 and on every tithe of one,
  // which runs past the dial: the count against the formula.
  var abundant = 0, oddAbundant = 0;
  final oneShort = <int>[], perfect = <int>[], friends = <int>[];
  for (var n = 1; n <= Rules.most; n++) {
    final t = Rules.tithe(n);
    if (t != Rules.titheByFormula(n) || (t >= 1 && Rules.tithe(t) != Rules.titheByFormula(t))) {
      stderr.writeln('$n: THE COUNT SAYS $t, THE FORMULA ${Rules.titheByFormula(n)}');
      exit(1);
    }
    if (t > n) {
      abundant++;
      if (n.isOdd) oddAbundant++;
    }
    if (t == n - 1) oneShort.add(n);
    if (t == n) perfect.add(n);
    if (t != n && t >= 1 && Rules.tithe(t) == n) friends.add(n);
  }
  if (abundant != 121 || oddAbundant != 0) {
    stderr.writeln('$abundant ABUNDANT, $oddAbundant ODD');
    exit(1);
  }
  if (Rules.tithe(945) <= 945 || Rules.tithe(945) != Rules.titheByFormula(945)) {
    stderr.writeln('945 IS NOT ABUNDANT: ${Rules.tithe(945)}');
    exit(1);
  }
  for (var n = 1; n < 945; n += 2) {
    if (Rules.tithe(n) > n) {
      stderr.writeln('$n IS ODD AND ABUNDANT');
      exit(1);
    }
  }
  // The one-short numbers are exactly the powers of two, and every
  // power of two on the dial comes one short.
  if (oneShort.toString() != '[1, 2, 4, 8, 16, 32, 64, 128, 256]' || oneShort.any((n) => !Rules.isPowerOfTwo(n))) {
    stderr.writeln('ONE SHORT: $oneShort');
    exit(1);
  }
  for (var n = 1; n <= Rules.most; n *= 2) {
    if (Rules.tithe(n) != n - 1) {
      stderr.writeln('$n GETS ${Rules.tithe(n)}');
      exit(1);
    }
  }
  // The perfect numbers are Euclid's, and the friends are 220 and 284.
  if (perfect.toString() != '[6, 28, 496]' || Rules.euclidPerfect.toString() != '[6, 28, 496]') {
    stderr.writeln('PERFECT: $perfect, EUCLID: ${Rules.euclidPerfect}');
    exit(1);
  }
  if (friends.toString() != '[220, 284]' || Rules.tithe(220) != 284 || Rules.tithe(284) != 220) {
    stderr.writeln('FRIENDS: $friends');
    exit(1);
  }
  // The named divisors.
  if (Rules.divisors(28).toString() != '[1, 2, 4, 7, 14]' || Rules.divisors(496).toString() != '[1, 2, 4, 8, 16, 31, 62, 124, 248]' ||
      Rules.divisors(220).toString() != '[1, 2, 4, 5, 10, 11, 20, 22, 44, 55, 110]' || Rules.divisors(284).toString() != '[1, 2, 4, 71, 142]' ||
      Rules.divisors(120).length != 15 || Rules.tithe(120) != 240 || Rules.tithe(672) != 1344 || Rules.tithe(12) != 16 || Rules.tithe(18) != 21 || Rules.tithe(256) != 255) {
    stderr.writeln('THE NAMED DIVISORS ARE OFF');
    exit(1);
  }
  final twiceOver = <int>[for (var n = 1; n <= 700; n++) if (Rules.tithe(n) == 2 * n) n];
  if (twiceOver.toString() != '[120, 672]') {
    stderr.writeln('TWICE OVER: $twiceOver');
    exit(1);
  }

  stdout.writeln(
      'every number from 1 to 500 swept, its proper divisors added up by trying '
      'each in turn and by the formula from the prime factors, and the two agree '
      'on all 500 and on all their tithes besides: 6, 28 and 496 add up to '
      'themselves and no other does, and they are Euclid\'s three, 2 by 3, 4 by 7 '
      'and 16 by 31; 220 and 284 pay each other, 1, 2, 4, 5, 10, 11, 20, 22, 44, '
      '55 and 110 making 284 and 1, 2, 4, 71 and 142 making 220, and no other '
      'number under 500 has a partner; 121 of the 500 get more than themselves '
      'back, every one even, the first odd one being 945; 120 gets exactly twice '
      'itself, 240 from fifteen divisors, and the next to do it is 672; and nine '
      'numbers come one short, exactly the powers of two from 1 to 256, so no '
      'power of two adds up to itself');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(17);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 500 numbers ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the 500, and the one short said so first');
  }
}
