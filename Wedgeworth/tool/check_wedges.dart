import 'dart:io';

import 'package:wedgeworth/wedge/levels.dart';
import 'package:wedgeworth/wedge/rules.dart';

/// Sweeps every corner on the sham with the angle sum as an exact
/// fraction, holds it against Euler's count, and refuses the bake on
/// any disagreement: this is what `make wedges` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (meeting, all) = Rules.sweep(level.meets);
    if (meeting != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $meeting of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
  }

  // The angle sum against Euler's count, on the sham and out to twelve
  // sides and twelve faces: the corners that close are exactly the ones
  // Euler counts, and (p - 2)(q - 2) < 4 names them a third way.
  var closing = 0, flat = 0, over = 0;
  final closers = <(int, int)>[];
  for (var p = 3; p <= 12; p++) {
    for (var q = 3; q <= 12; q++) {
      final closes = Rules.closes(p, q);
      final euler = Rules.euler(p, q);
      final small = (p - 2) * (q - 2) < 4;
      if (closes != (euler != null) || closes != small) {
        stderr.writeln('THE ANGLE AND THE COUNT DISAGREE AT $p SIDES, $q FACES');
        exit(1);
      }
      if (euler != null) {
        final (v, e, f) = euler;
        if (v - e + f != 2 || p * f != 2 * e || q * v != 2 * e) {
          stderr.writeln('EULER\'S COUNT DOES NOT ADD UP AT $p, $q: $v $e $f');
          exit(1);
        }
        closers.add((p, q));
      }
      if (p <= 8 && q <= 8) {
        if (closes) closing++;
        if (Rules.flat(p, q)) flat++;
        if (Rules.overlaps(p, q)) over++;
      }
    }
  }
  if (closers.toString() != '[(3, 3), (3, 4), (3, 5), (4, 3), (5, 3)]') {
    stderr.writeln('THE CLOSERS ARE $closers');
    exit(1);
  }
  if (closing != 5 || flat != 3 || over != 28) {
    stderr.writeln('$closing CLOSE, $flat FLAT, $over OVER');
    exit(1);
  }
  final counts = closers.map((c) => Rules.euler(c.$1, c.$2)!).toList();
  if (counts.toString() != '[(4, 6, 4), (6, 12, 8), (12, 30, 20), (8, 12, 6), (20, 30, 12)]') {
    stderr.writeln('THE COUNTS ARE $counts');
    exit(1);
  }
  // The gaps, told: the closers leave 180, 120, 60, 90 and 36 degrees.
  final gaps = closers.map((c) => Rules.degrees(Rules.gap(c.$1, c.$2))).toList();
  if (gaps.toString() != '[180, 120, 60, 90, 36]') {
    stderr.writeln('THE GAPS ARE $gaps');
    exit(1);
  }
  // The flat three are the tilings; three heptagons overlap by 180/7.
  for (final (p, q) in [(3, 6), (4, 4), (6, 3)]) {
    if (!Rules.flat(p, q) || Rules.tiling(p, q) == null) {
      stderr.writeln('$p, $q IS NOT FLAT');
      exit(1);
    }
  }
  if (Rules.degrees(Rules.gap(7, 3)) != '-25 5/7') {
    stderr.writeln('THREE HEPTAGONS: ${Rules.degrees(Rules.gap(7, 3))}');
    exit(1);
  }

  stdout.writeln(
      'every corner of three to eight faces of three to eight sides swept, 36 '
      'settings, the angle sum kept as an exact fraction of a degree and held '
      'against Euler\'s count of corners, edges and faces: five corners close, '
      'three, four and five triangles, three squares and three pentagons, with '
      '180, 120, 60, 90 and 36 degrees to spare, and Euler\'s count is a whole '
      'number for exactly those five, the tetrahedron 4 corners 6 edges 4 faces, '
      'the octahedron 6 12 8, the icosahedron 12 30 20, the cube 8 12 6 and the '
      'dodecahedron 20 30 12, each two by Euler; three settings lie flat, six '
      'triangles, four squares and three hexagons, the three tilings, and 28 '
      'overlap; out to twelve sides and twelve faces, 100 settings, still the '
      'same five close and no more');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(20);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} settings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the angle said so first');
  }
}
