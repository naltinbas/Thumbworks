import 'dart:io';

import 'package:cogsley/train/levels.dart';
import 'package:cogsley/train/rules.dart';

/// Sweeps every placing of every train, holds the turning to the mesh
/// law and the speeds walked to the formula, and refuses the bake on
/// any disagreement: this is what `make trains` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.width, level.height, level.fixed, level.tray, level.meets);
    if (met != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (first != null && !level.meets(first)) {
      stderr.writeln('${level.name}: THE FIRST PLACING DOES NOT LAND');
      exit(1);
    }
    // On every placing: no jam without a ring; a jam is an odd ring; the
    // speed walked equals the formula for every turning gear.
    Rules.sweep(level.width, level.height, level.fixed, level.tray, (gears) {
      final (way, jam) = Rules.turning(gears, 0);
      if (jam && !gears.asMap().keys.any((g) => Rules.inRing(gears, g))) {
        stderr.writeln('${level.name}: A JAM WITH NO RING: $gears');
        exit(1);
      }
      if (!jam) {
        for (var g = 1; g < gears.length; g++) {
          if (way[g] == 0) continue;
          final walked = Rules.speedWalked(gears, 0, g);
          if (walked != Rules.speed(gears[0], gears[g])) {
            stderr.writeln('${level.name}: SPEED WALKED $walked, FORMULA ${Rules.speed(gears[0], gears[g])}: $gears');
            exit(1);
          }
        }
      }
      return false;
    });
  }
  // The rings of three: two placings ring the crank, and both jam.
  final dead = Levels.at(4);
  final (rings, _, ring) = Rules.sweep(dead.width, dead.height, dead.fixed, dead.tray, (g) => g.length == 3 && Rules.apart(g) && Rules.inRing(g, 0));
  if (rings != 2 || ring == null || !Rules.turning(ring, 0).$2 || ring.toString() != '[(0, 0, 1), (3, 0, 2), (0, 4, 3)]') {
    stderr.writeln('THE RINGS OF THREE: $rings, $ring');
    exit(1);
  }
  // The ring of four turns, two with the crank and two against.
  final four = Levels.at(3);
  final (_, _, f4) = Rules.sweep(four.width, four.height, four.fixed, four.tray, four.meets);
  if (Rules.turning(f4!, 0).toString() != '([1, -1, -1, 1], false)') {
    stderr.writeln('THE RING OF FOUR TURNS ${Rules.turning(f4, 0)}');
    exit(1);
  }
  // Rings on the pegboard: every ring of gears of one to three on a
  // nine-by-nine round a crank of one at its middle, three gears, jams,
  // and every ring of four gears of one turns.
  var rings3 = 0, rings4 = 0, jams3 = 0, turns4 = 0;
  final pegs = [for (var y = 0; y < 9; y++) for (var x = 0; x < 9; x++) (x, y)];
  for (final r1 in [1, 2, 3]) {
    for (final r2 in [1, 2, 3]) {
      for (final p1 in pegs) {
        for (final p2 in pegs) {
          if (p1 == p2 || p1 == (4, 4) || p2 == (4, 4)) continue;
          final gears = [(4, 4, 1), (p1.$1, p1.$2, r1), (p2.$1, p2.$2, r2)];
          if (!Rules.apart(gears) || !Rules.inRing(gears, 0)) continue;
          rings3++;
          if (Rules.turning(gears, 0).$2) jams3++;
        }
      }
    }
  }
  if (rings3 == 0 || jams3 != rings3) {
    stderr.writeln('RINGS OF THREE $rings3, JAMMING $jams3');
    exit(1);
  }
  // Rings of four gears of one round the crank on the nine-by-nine.
  final (met4, _, _) = Rules.sweep(9, 9, [(4, 4, 1)], [1, 1, 1], (g) {
    final (way, jam) = Rules.turning(g, 0);
    if (!Rules.inRing(g, 0)) return false;
    rings4++;
    if (!jam && way.every((w) => w != 0)) turns4++;
    return !jam;
  });
  if (rings4 == 0 || turns4 != rings4 || met4 != turns4) {
    stderr.writeln('RINGS OF FOUR $rings4, TURNING $turns4');
    exit(1);
  }

  stdout.writeln(
      'every placing of every train swept on its pegboard, gears meshing when '
      'their pegs lie the sum of their radii apart exactly and overlapping when '
      'less, the turning walked mesh by mesh from the crank, each mesh reversing '
      'the way, and the speeds walked held to the crank\'s radius over the gear\'s '
      'own on every turning gear of every placing: a gear of one on the peg '
      'between a crank and a mill of two, six pegs apart, turns the mill the same '
      'way and once a turn, 1 placing of 5; two gears of one on the pegs two and '
      'four along turn a mill of one six pegs off against the crank, 1 placing of '
      '275; a gear of one three pegs along turns a mill of one twice for a crank '
      'of two five pegs off, 1 placing of 11; three gears of one round a crank of '
      'one make a turning ring in 1 placing of 159, the square, two gears with '
      'the crank and two against; a gear of two and a gear of three ring a crank '
      'of one in 2 placings of 8, three, four and five apart, and both jam, and '
      'on the nine-by-nine every ring of three gears of one to three round a '
      'crank of one at the middle jams, $rings3 rings, and every ring of four '
      'gears of one round it turns, $rings4 rings');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.settings} placings lands it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.settings}, and the odd ring said so first');
  }
}
