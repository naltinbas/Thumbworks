import 'dart:io';

import 'package:threefold/green/levels.dart';
import 'package:threefold/green/play.dart';
import 'package:threefold/green/rules.dart';

/// Walks every point of the green, holds the rungs to the areas, and
/// refuses the bake on any disagreement: this is what `make greens`
/// runs, and the README quotes its ledger verbatim.
void main() {
  final points = Rules.points;
  if (points.length != 91 || Rules.count != 91 || Rules.wholeArea != 288) {
    stderr.writeln('${points.length} POINTS, WHOLE ${Rules.wholeArea}');
    exit(1);
  }
  // The two voices on every point: the rungs add to the side; the three
  // triangles fill the green; each triangle is its rung's share.
  for (final p in points) {
    final (fa, fb, fc) = Rules.areas(p);
    if (Rules.rungsAdded(p) != Rules.side || fa + fb + fc != Rules.wholeArea || !Rules.areasSayRungs(p)) {
      stderr.writeln('${Rules.told(p)}: RUNGS ${Rules.rungsAdded(p)}, AREAS $fa + $fb + $fc OF ${Rules.wholeArea}');
      exit(1);
    }
    if (points.where((q) => q == p).length != 1) {
      stderr.writeln('${Rules.told(p)} COMES TWICE');
      exit(1);
    }
  }
  // The corners and the middle in doubled coordinates.
  if (Rules.doubled((0, 12, 0)) != (0, 0) || Rules.doubled((0, 0, 12)) != (24, 0) || Rules.doubled((12, 0, 0)) != (12, 12) || Rules.doubled((4, 4, 4)) != (12, 4)) {
    stderr.writeln('THE CORNERS ARE OFF');
    exit(1);
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final met = points.where(level.meets).length;
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of 91, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The named areas.
  if (Rules.areas((4, 4, 4)) != (96, 96, 96) || Rules.areas((1, 2, 9)) != (24, 48, 216) || Rules.areas((0, 6, 6)) != (0, 144, 144) || Rules.areas((2, 4, 6)) != (48, 96, 144)) {
    stderr.writeln('THE NAMED AREAS ARE OFF: ${Rules.areas((4, 4, 4))} ${Rules.areas((1, 2, 9))} ${Rules.areas((0, 6, 6))} ${Rules.areas((2, 4, 6))}');
    exit(1);
  }
  final edges = points.where((p) => [p.$1, p.$2, p.$3].contains(0)).length;
  final corners = points.where((p) => [p.$1, p.$2, p.$3].contains(12)).length;
  if (edges != 36 || corners != 3) {
    stderr.writeln('$edges ON THE SIDES, $corners AT THE CORNERS');
    exit(1);
  }

  stdout.writeln(
      'every point of the lattice on the green of side twelve walked, 91 points, '
      '36 of them on the sides and 3 at the corners: the three distances to the '
      'sides, read off the lattice in rungs, add up to twelve on every one, and '
      'the three triangles each point makes with the sides, worked as whole '
      'numbers of cells, fill the green of 288 exactly on every one, each '
      'triangle its rung\'s twelfth; the middle stands 4, 4 and 4 with triangles '
      'of 96 each, six points stand 1, 2 and 9, three stand on a side six from '
      'each of the others, six have one distance twice another and the third the '
      'two added, 2, 4 and 6, and no point adds to more than the height, nor less');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 91 points ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the 91, and the three triangles said so first');
  }
}
