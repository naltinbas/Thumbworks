import 'dart:io';

import 'package:threadwick/star/levels.dart';
import 'package:threadwick/star/play.dart';
import 'package:threadwick/star/rules.dart';

/// Walks every thread round every ring, holds the walk against the
/// divisor, and refuses the bake on any disagreement: this is what
/// `make stars` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, the aim landing it, and no
  // level landed at the opening setting.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 60) {
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

  // The two voices on every ring from three nails to twelve and every
  // skip: the strokes walked against the divisor, each stroke touching
  // the count over the divisor, every nail touched once; and skip k and
  // skip count - k drawing the same lines.
  var walked = 0;
  for (var nails = 3; nails <= Rules.most; nails++) {
    for (var skip = 1; skip < nails; skip++) {
      walked++;
      final strokes = Rules.strokes(nails, skip);
      final g = Rules.strokesByDivisor(nails, skip);
      if (strokes.length != g || strokes.any((s) => s.length != Rules.nailsAStrokeByDivisor(nails, skip))) {
        stderr.writeln('$nails NAILS SKIP $skip: WALKED ${strokes.length} STROKES OF ${strokes.map((s) => s.length)}, THE DIVISOR SAYS $g OF ${nails ~/ g}');
        exit(1);
      }
      final touched = strokes.expand((s) => s).toList()..sort();
      if (touched.length != nails || touched.asMap().entries.any((e) => e.key != e.value)) {
        stderr.writeln('$nails NAILS SKIP $skip: NAILS TOUCHED $touched');
        exit(1);
      }
      if (Rules.lines(nails, skip).toString() != Rules.lines(nails, nails - skip).toString()) {
        stderr.writeln('$nails NAILS: SKIP $skip AND SKIP ${nails - skip} DRAW DIFFERENT LINES');
        exit(1);
      }
    }
  }
  if (walked != 65) {
    stderr.writeln('$walked SETTINGS WALKED');
    exit(1);
  }

  // The one-stroke stars of each ring against Euler's count: the skips
  // sharing nothing with the count, less the two that run round the rim,
  // and every star drawn twice, by k and by count - k.
  final stars = <int, List<int>>{};
  for (var nails = 5; nails <= Rules.most; nails++) {
    final skips = Rules.oneStrokeStars(nails);
    stars[nails] = skips;
    if (skips.length != Rules.coprimes(nails) - 2 || skips.length.isOdd) {
      stderr.writeln('$nails NAILS: ONE-STROKE SKIPS $skips, EULER COUNTS ${Rules.coprimes(nails)}');
      exit(1);
    }
    for (final k in skips) {
      if (!skips.contains(nails - k)) {
        stderr.writeln('$nails NAILS: SKIP $k IS A STAR AND ${nails - k} IS NOT');
        exit(1);
      }
    }
  }
  final told = {5: '2, 3', 6: '', 7: '2, 3, 4, 5', 8: '3, 5', 9: '2, 4, 5, 7', 10: '3, 7', 11: '2, 3, 4, 5, 6, 7, 8, 9', 12: '5, 7'};
  for (final e in told.entries) {
    if (stars[e.key]!.join(', ') != e.value) {
      stderr.writeln('${e.key} NAILS: STARS BY ${stars[e.key]}, NOT ${e.value}');
      exit(1);
    }
  }
  // The named strokes: eight by two is two squares, by four four bare
  // lines; nine by three three triangles; twelve by six six lines, by two
  // two hexagons, by three three squares, by four four triangles; and six
  // by two or four is two triangles, by three three lines.
  final named = <(int, int, int, int)>[
    (8, 2, 2, 4), (8, 4, 4, 2), (9, 3, 3, 3), (12, 6, 6, 2), (12, 2, 2, 6), (12, 3, 3, 4), (12, 4, 4, 3),
    (6, 2, 2, 3), (6, 4, 2, 3), (6, 3, 3, 2), (5, 2, 1, 5), (12, 5, 1, 12), (12, 7, 1, 12),
  ];
  for (final (nails, skip, count, each) in named) {
    final strokes = Rules.strokes(nails, skip);
    if (strokes.length != count || strokes.any((s) => s.length != each)) {
      stderr.writeln('$nails NAILS SKIP $skip: ${strokes.length} STROKES OF ${strokes.map((s) => s.length)}, NOT $count OF $each');
      exit(1);
    }
  }

  stdout.writeln(
      'every thread walked nail by nail round every ring from three nails to '
      'twelve and every skip from one to a nail short of the round, 65 settings, '
      'and the strokes walked agree with the divisor on every one, as many '
      'strokes as the count and the skip share and each stroke touching the '
      'count over that, every nail touched once; skip k and skip count less k '
      'draw the same lines on all 65; the one-stroke stars of five to twelve '
      'nails are the skips sharing nothing with the count less the two round '
      'the rim, Euler\'s count less two on every ring, each star drawn by two '
      'skips: five nails 2 and 3, six none, seven 2, 3, 4 and 5, eight 3 and 5, '
      'nine 2, 4, 5 and 7, ten 3 and 7, eleven every skip from 2 to 9, twelve 5 '
      'and 7; eight by two is two squares and by four four bare lines, nine by '
      'three three triangles, twelve by six six lines through the middle, by '
      'two two hexagons, by three three squares and by four four triangles; and '
      'six by two or four is two triangles and by three three lines, so no skip '
      'threads the six-pointed star in one stroke');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(19);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${Rules.settings} settings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${Rules.settings}, and the shared factor said so first');
  }
}
