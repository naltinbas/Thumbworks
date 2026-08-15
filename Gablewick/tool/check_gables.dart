import 'dart:io';

import 'package:gablewick/gable/levels.dart';
import 'package:gablewick/gable/play.dart';
import 'package:gablewick/gable/rules.dart';

/// Works the area of every triangle with whole sides to fifteen two ways,
/// holds Heron to the height, and refuses the bake on any disagreement:
/// this is what `make gables` runs, and the README quotes its ledger
/// verbatim.
void main() {
  final all = Rules.triangles;
  if (all.length != 372) {
    stderr.writeln('${all.length} TRIANGLES');
    exit(1);
  }
  // The two voices on every triangle: Heron against the height; and the
  // whole areas found, each a multiple of six, each with an even side.
  final whole = <String>[];
  for (final (a, b, c) in all) {
    if (Rules.sixteenAreaSquared(a, b, c) != Rules.sixteenAreaSquaredByHeight(a, b, c)) {
      stderr.writeln('$a-$b-$c: HERON SAYS ${Rules.sixteenAreaSquared(a, b, c)}, THE HEIGHT ${Rules.sixteenAreaSquaredByHeight(a, b, c)}');
      exit(1);
    }
    final area = Rules.wholeArea(a, b, c);
    if (area == null) continue;
    if (16 * area * area != Rules.sixteenAreaSquared(a, b, c) || area % 6 != 0 || Rules.allOdd(a, b, c)) {
      stderr.writeln('$a-$b-$c: AREA $area');
      exit(1);
    }
    whole.add('$a-$b-$c $area');
  }
  if (whole.join(', ') != '3-4-5 6, 4-13-15 24, 5-5-6 12, 5-5-8 12, 5-12-13 30, 6-8-10 24, 9-12-15 54, 10-10-12 48, 10-13-13 60, 13-14-15 84') {
    stderr.writeln('THE WHOLE AREAS ARE $whole');
    exit(1);
  }
  // Three odd sides give an odd product, on every closing triple of odd
  // sides to fifteen.
  for (var a = 1; a <= 15; a += 2) {
    for (var b = a; b <= 15; b += 2) {
      for (var c = b; c <= 15; c += 2) {
        if (Rules.closes(a, b, c) && Rules.sixteenAreaSquared(a, b, c).isEven) {
          stderr.writeln('$a-$b-$c: AN EVEN PRODUCT FROM ODD SIDES');
          exit(1);
        }
      }
    }
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final met = all.where((t) => level.meets(t.$1, t.$2, t.$3)).length;
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of 372, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim.$1, aim.$2, aim.$3)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The halves: 5-5-6 and 5-5-8 are two 3-4-5s back to back; 10-10-12 two
  // 6-8-10s, 10-13-13 two 5-12-13s; 13-14-15 splits along the 14 into
  // 5-12-13 and 9-12-15; and 4-13-15 is a 9-12-15 less a 5-12-13, the
  // two on one line with the 12 shared, 9 less 5 being the 4.
  if (Rules.wholeArea(5, 5, 6) != 2 * 6 || Rules.wholeArea(5, 5, 8) != 2 * 6 || Rules.wholeArea(10, 10, 12) != 2 * 24 || Rules.wholeArea(10, 13, 13) != 2 * 30 ||
      Rules.wholeArea(13, 14, 15) != 30 + 54 || 5 + 9 != 14 || Rules.wholeArea(4, 13, 15) != 54 - 30 || 9 - 5 != 4 || 5 * 5 + 12 * 12 != 13 * 13 || 9 * 9 + 12 * 12 != 15 * 15) {
    stderr.writeln('THE HALVES ARE OFF');
    exit(1);
  }
  if (Rules.sixteenAreaSquared(3, 4, 6) != 455 || Rules.wholeArea(3, 4, 6) != null) {
    stderr.writeln('THE OPENING IS OFF');
    exit(1);
  }

  stdout.writeln(
      'every triangle with whole sides to fifteen, 372 of them, its area worked '
      'twice, by Heron and by the height with the foot of the perpendicular found '
      'in whole numbers, and the two agree on every one: ten have a whole area, '
      '3-4-5 with 6, 5-5-6 and 5-5-8 with 12, 4-13-15 and 6-8-10 with 24, 5-12-13 '
      'with 30, 10-10-12 with 48, 9-12-15 with 54, 10-13-13 with 60 and 13-14-15 '
      'with 84, every area a multiple of six and every one with an even side; '
      'four are right-angled, four have two sides alike and no right angle, two '
      'have no two sides alike and no right angle; and three odd sides never '
      'square up, the perimeter and the perimeter less twice each side being all '
      'odd on every odd triple to fifteen, so their product is odd and never '
      'sixteen times anything');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 372 triangles land it'
        : ' ${number + 1} $name ${level.task}: none of the 372, and the odd product said so first');
  }
}
