import 'dart:io';

import 'package:baizewell/table/levels.dart';
import 'package:baizewell/table/rules.dart';

/// Rolls the ball step by step on every table of the sham, holds the
/// roll to the parity rule, and refuses the bake on any disagreement:
/// this is what `make tables` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (met, all) = Rules.sweep(level.meets);
    if (met != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
  }
  // The roll against the rule on every table to twelve, and on out to
  // thirty a side.
  var tables = 0, far = 0, right = 0, top = 0, home = 0, straight = 0, mostBounces = 0;
  final mostAt = <(int, int)>[];
  for (var p = 2; p <= 30; p++) {
    for (var q = 2; q <= 30; q++) {
      final (corners, bounces, steps) = Rules.roll(p, q);
      if (corners.last != Rules.pocketByParity(p, q) || bounces != Rules.bouncesByFormula(p, q) || steps != Rules.stepsByFormula(p, q)) {
        stderr.writeln('$p BY $q: ROLLED ${corners.last} $bounces $steps, RULE ${Rules.pocketByParity(p, q)} ${Rules.bouncesByFormula(p, q)} ${Rules.stepsByFormula(p, q)}');
        exit(1);
      }
      if (corners.last == (0, 0)) {
        stderr.writeln('$p BY $q: THE BALL CAME HOME');
        exit(1);
      }
      if (p <= 12 && q <= 12) {
        tables++;
        if (corners.last == (p, q)) far++;
        if (corners.last == (p, 0)) right++;
        if (corners.last == (0, q)) top++;
        if (corners.last == (0, 0)) home++;
        if (bounces == 0) straight++;
        if (bounces > mostBounces) {
          mostBounces = bounces;
          mostAt.clear();
        }
        if (bounces == mostBounces) mostAt.add((p, q));
      }
    }
  }
  if (tables != 121 || far != 39 || right != 41 || top != 41 || home != 0 || straight != 11 || mostBounces != 21 || mostAt.toString() != '[(11, 12), (12, 11)]') {
    stderr.writeln('$tables TABLES: FAR $far RIGHT $right TOP $top HOME $home STRAIGHT $straight MOST $mostBounces AT $mostAt');
    exit(1);
  }
  // Named tables.
  final named = <(int, int), (String, int, int)>{
    (2, 3): ('the right pocket', 3, 6),
    (2, 4): ('the top pocket', 1, 4),
    (5, 7): ('the far pocket', 10, 35),
    (12, 11): ('the right pocket', 21, 132),
    (12, 12): ('the far pocket', 0, 12),
  };
  for (final e in named.entries) {
    final (p, q) = e.key;
    final (corners, bounces, steps) = Rules.roll(p, q);
    if (Rules.pocketName(p, q, corners.last) != e.value.$1 || bounces != e.value.$2 || steps != e.value.$3) {
      stderr.writeln('$p BY $q: ${Rules.pocketName(p, q, corners.last)} $bounces $steps, NOT ${e.value}');
      exit(1);
    }
  }
  // The parity rule's heart: the tables crossed along and up are coprime.
  for (var p = 2; p <= 30; p++) {
    for (var q = 2; q <= 30; q++) {
      final g = Rules.gcd(p, q);
      if (Rules.gcd(q ~/ g, p ~/ g) != 1) {
        stderr.writeln('$p BY $q: THE COUNTS SHARE A FACTOR');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'the ball rolled step by step from the home corner on every table of two '
      'to thirty a side, 841 tables, and held to the unfolding: it pockets after '
      'the least common multiple of the sides in steps, having crossed q/g tables '
      'along and p/g up, g the sides\' common factor, and lands right when the '
      'count along is odd and left when even, top when the count up is odd and '
      'bottom when even, with bounces one less than each count together, the roll '
      'and the rule agreeing on all 841; the two counts share no factor, so both '
      'are never even, and the ball never comes home; on the sham\'s 121 tables '
      'of two to twelve a side 39 pocket far, 41 right, 41 top and none home, '
      'the eleven squares run straight, the two by three bounces 3 times in 6 '
      'steps, the two by four once in 4, the five by seven 10 times in 35, and '
      'the eleven by twelve and twelve by eleven 21 times in 132, the most');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} tables land it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the parity said so first');
  }
}
