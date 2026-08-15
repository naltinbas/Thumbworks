import 'dart:io';

import 'package:ellwick/rung/levels.dart';
import 'package:ellwick/rung/play.dart';
import 'package:ellwick/rung/rules.dart';

/// Sweeps every side and diagonal to the top of the dials, holds the
/// sweep against the ladder and its algebra, and refuses the bake on
/// any disagreement: this is what `make rungs` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the aim landing it, and no
  // level landed at the opening setting.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 14400) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2) || !Rules.rungs.contains(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, or is off the ladder; the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The ladder: its rungs, their misses turning over, and the algebra
  // that turns them, checked at every one of the 14,400 pairs.
  final rungs = Rules.rungs;
  if (rungs.toString() != '[(1, 1), (2, 3), (5, 7), (12, 17), (29, 41), (70, 99)]') {
    stderr.writeln('THE RUNGS ARE $rungs');
    exit(1);
  }
  for (var i = 0; i < rungs.length; i++) {
    final (s, d) = rungs[i];
    if (Rules.miss(s, d) != (i.isEven ? -1 : 1)) {
      stderr.writeln('RUNG ${i + 1} ($s, $d) MISSES BY ${Rules.miss(s, d)}');
      exit(1);
    }
  }
  final ones = <(int, int)>[];
  for (var side = 1; side <= Rules.most; side++) {
    for (var diagonal = 1; diagonal <= Rules.most; diagonal++) {
      final (s, d) = Rules.climb(side, diagonal);
      if (Rules.miss(s, d) != -Rules.miss(side, diagonal)) {
        stderr.writeln('THE ALGEBRA FAILS AT ($side, $diagonal)');
        exit(1);
      }
      if (Rules.miss(side, diagonal).abs() == 1) ones.add((side, diagonal));
      if (Rules.miss(side, diagonal) == 0) {
        stderr.writeln('A TRUE DIAGONAL AT ($side, $diagonal)');
        exit(1);
      }
    }
  }
  if (ones.toString() != rungs.toString()) {
    stderr.writeln('THE MISSES OF ONE ARE $ones, THE RUNGS $rungs');
    exit(1);
  }
  // The records are the rungs and no other, and the thousandths.
  if (Rules.records.toString() != rungs.toString()) {
    stderr.writeln('THE RECORDS ARE ${Rules.records}');
    exit(1);
  }
  final thousandths = <(int, int)>[];
  for (var side = 1; side <= Rules.most; side++) {
    for (var diagonal = 1; diagonal <= Rules.most; diagonal++) {
      if (Rules.off(side, diagonal) < 0.001) thousandths.add((side, diagonal));
    }
  }
  if (thousandths.toString() != '[(29, 41), (41, 58), (53, 75), (58, 82), (70, 99), (75, 106), (82, 116)]') {
    stderr.writeln('THE THOUSANDTHS ARE $thousandths');
    exit(1);
  }
  String off(int s, int d) => Rules.off(s, d).toStringAsFixed(5);
  if (off(29, 41) != '0.00042' || off(70, 99) != '0.00007' || off(12, 17) != '0.00245' || off(5, 7) != '0.01421') {
    stderr.writeln('THE OFFS ARE ${off(29, 41)}, ${off(70, 99)}, ${off(12, 17)}, ${off(5, 7)}');
    exit(1);
  }
  // The named misses.
  if (Rules.miss(70, 99) != 1 || 99 * 99 != 9801 || Rules.miss(29, 41) != -1 || 41 * 41 != 1681 || Rules.miss(12, 17) != 1 || Rules.miss(1, 2) != 2) {
    stderr.writeln('THE NAMED MISSES ARE OFF');
    exit(1);
  }

  stdout.writeln(
      'every side and diagonal to 120 swept with whole numbers, 14,400 pairs: the '
      'diagonal squared misses twice the side squared by one over at (2, 3), (12, '
      '17) and (70, 99), 9,801 to 9,800, by one under at (1, 1), (5, 7) and (29, '
      '41), 1,681 to 1,682, and by nought never; the ladder from (1, 1), side plus '
      'diagonal and twice the side plus the diagonal, climbs through exactly '
      'those six pairs and no other, its miss turning over at every rung, and the '
      'algebra turns it over at every one of the 14,400 pairs; the pairs that come '
      'nearer the true diagonal than every smaller side does, the diagonal the '
      'nearest for its side, are the six rungs and no other; and seven pairs come '
      'within a thousandth of the true diagonal, (29, 41) first at 0.00042 over '
      'and (70, 99) nearest at 0.00007, while 17 over 12 misses by 0.00245');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 14,400 pairs land it'
        : ' ${number + 1} $name ${level.task}: none of the 14,400, and the halving said so first');
  }
}
