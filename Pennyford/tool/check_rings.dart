import 'dart:io';
import 'dart:math';

import 'package:pennyford/ring/levels.dart';
import 'package:pennyford/ring/play.dart';
import 'package:pennyford/ring/rules.dart';

/// Sweeps every setting of the two coins, holds the count by the angle
/// against the count by the measure, and refuses the bake on any
/// disagreement: this is what `make rings` runs, and the README quotes
/// its ledger verbatim.
void main() {
  String deg(double d) => d.toStringAsFixed(1);

  // Every level's label against the sweep, the aim landing it, and no
  // level landed at the opening setting.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 36) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The two voices on every setting: the count by the angle against the
  // count by the measure; the spare never negative and under one coin's
  // angle; and the count never falling as the middle grows or the ring
  // shrinks.
  var biggest = 0;
  (int, int)? biggestAt;
  for (var middle = 1; middle <= Rules.most; middle++) {
    for (var ring = 1; ring <= Rules.most; ring++) {
      final byAngle = Rules.mostRound(middle, ring), byMeasure = Rules.mostMeasured(middle, ring);
      if (byAngle != byMeasure) {
        stderr.writeln('MIDDLE $middle RING $ring: $byAngle BY THE ANGLE, $byMeasure BY THE MEASURE');
        exit(1);
      }
      final spare = Rules.spare(middle, ring), each = Rules.span(middle, ring) * 180 / pi;
      if (spare < 0 || spare >= each) {
        stderr.writeln('MIDDLE $middle RING $ring: $spare TO SPARE OF $each');
        exit(1);
      }
      if (middle > 1 && Rules.mostRound(middle - 1, ring) > byAngle || ring > 1 && Rules.mostRound(middle, ring - 1) < byAngle) {
        stderr.writeln('MIDDLE $middle RING $ring: THE COUNT GOES THE WRONG WAY');
        exit(1);
      }
      if (byAngle > biggest) {
        biggest = byAngle;
        biggestAt = (middle, ring);
      }
    }
  }

  // The named facts: equal coins take sixty degrees to within a
  // thousand-millionth, six fit with nothing to spare and seven never;
  // a ring coin no smaller than the middle never fits seven; the spares
  // of the asks; and the biggest ring.
  for (var n = 1; n <= Rules.most; n++) {
    if ((Rules.span(n, n) * 180 / pi - 60).abs() > 1e-9 || !Rules.fits(n, n, 6) || Rules.fits(n, n, 7) || Rules.spare(n, n) != 0) {
      stderr.writeln('EQUAL COINS OF $n: ${Rules.span(n, n) * 180 / pi} DEGREES, ${Rules.mostRound(n, n)} FIT');
      exit(1);
    }
  }
  final named = <(int, int, int, String)>[
    (1, 2, 4, '25.5'), (5, 4, 6, '43.3'), (6, 5, 6, '35.6'), (3, 2, 7, '29.9'), (6, 4, 7, '29.9'), (4, 3, 7, '4.7'),
    (3, 1, 12, '12.5'), (6, 2, 12, '12.5'), (6, 1, 21, '15.0'), (6, 5, 6, '35.6'), (5, 3, 8, '7.6'),
  ];
  for (final (middle, ring, count, spare) in named) {
    if (Rules.mostRound(middle, ring) != count || deg(Rules.spare(middle, ring)) != spare) {
      stderr.writeln('MIDDLE $middle RING $ring: ${Rules.mostRound(middle, ring)} FIT, ${deg(Rules.spare(middle, ring))} TO SPARE, NOT $count AND $spare');
      exit(1);
    }
  }
  if (biggest != 21 || biggestAt != (6, 1)) {
    stderr.writeln('THE BIGGEST RING IS $biggest AT $biggestAt');
    exit(1);
  }
  // Seven fit at a ring of no more than 0.766 of the middle, the sine
  // of a seventh of a turn over one less it: threes round a four fit,
  // three quarters, and fours round a five do not, four fifths.
  final seventh = sin(pi / 7) / (1 - sin(pi / 7));
  if (!Rules.fits(4, 3, 7) || Rules.fits(5, 4, 7) || Rules.fits(4, 3, 8) || seventh.toStringAsFixed(3) != '0.766' || 3 / 4 > seventh || 4 / 5 < seventh) {
    stderr.writeln('THE SEVENS ARE OFF: $seventh');
    exit(1);
  }

  stdout.writeln(
      'every setting of the middle coin and the ring coins swept, one to six each, '
      '36 settings, the count that fits worked by the angle, twice the arcsine of '
      'ring over middle plus ring into a full turn, and by the measure, the coins '
      'set at equal angles and neighbours held apart by twice the ring, and the '
      'two agree on all 36: equal coins take 60.0 degrees each to within a '
      'thousand-millionth, six fit with nothing to spare and a seventh never, and '
      'a ring coin no smaller than the middle never fits seven; four fit 6 ways, '
      'twos round a one with 25.5 degrees to spare; six fit 8 ways, the six equal '
      'pairs and fours round a five and fives round a six; seven fit 3 ways, twos '
      'round a three and fours round a six with 29.9 degrees to spare and threes '
      'round a four with 4.7, while fours round a five do not; twelve fit 2 ways, '
      'ones round a three and twos round a six with 12.5 to spare; and ones round '
      'a six fit twenty-one, the most of the 36, with 15.0 to spare');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${Rules.settings} settings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${Rules.settings}, and the sixty degrees said so first');
  }
}
