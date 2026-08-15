import 'dart:io';

import 'package:cubewick/hex/levels.dart';
import 'package:cubewick/hex/rules.dart';

/// Sweeps every tiling of every hexagon, holds MacMahon's product and
/// the stacks of cubes to the sweep, and refuses the bake on any
/// disagreement: this is what `make tilings` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and the sweep against the
  // product and the stacks where the hexagon is whole.
  for (final level in Levels.all) {
    final h = level.hexagon;
    final swept = h.count();
    if (swept != level.ways) {
      stderr.writeln('${level.name}: sweep finds $swept tilings, label says ${level.ways}');
      exit(1);
    }
    if (level.chipped.isEmpty) {
      final product = Hexagon.macmahon(level.a, level.b, level.c);
      final stacks = Hexagon.stacks(level.a, level.b, level.c);
      if (product != swept || stacks != swept) {
        stderr.writeln('${level.name}: sweep $swept, MacMahon $product, stacks $stacks');
        exit(1);
      }
      if (h.ups.length != h.downs.length || h.triangles.length != 2 * (level.a * level.b + level.b * level.c + level.c * level.a)) {
        stderr.writeln('${level.name}: ${h.ups.length} up, ${h.downs.length} down');
        exit(1);
      }
    } else {
      if (h.ups.length != 10 || h.downs.length != 12) {
        stderr.writeln('${level.name}: ${h.ups.length} up, ${h.downs.length} down');
        exit(1);
      }
      // Every laying leaves two down triangles bare: try every partial
      // tiling that covers all ten up triangles.
      var layings = 0;
      final free = {...h.downs};
      void grow(int k) {
        if (k == h.ups.length) {
          layings++;
          if (free.length != 2 || free.any((t) => t.$1)) {
            stderr.writeln('${level.name}: A LAYING LEFT ${free.length} BARE');
            exit(1);
          }
          return;
        }
        for (final d in Hexagon.mates(h.ups[k])) {
          if (!free.remove(d)) continue;
          grow(k + 1);
          free.add(d);
        }
      }

      grow(0);
      if (layings != 172) {
        stderr.writeln('${level.name}: $layings layings');
        exit(1);
      }
    }
  }

  // Every hexagon of sides up to three, and the four-box: sweep, product
  // and stacks agree.
  var boxes = 0;
  for (var a = 1; a <= 3; a++) {
    for (var b = a; b <= 3; b++) {
      for (var c = b; c <= 3; c++) {
        final swept = Hexagon(a, b, c).count();
        if (swept != Hexagon.macmahon(a, b, c) || swept != Hexagon.stacks(a, b, c)) {
          stderr.writeln('$a $b $c: sweep $swept, MacMahon ${Hexagon.macmahon(a, b, c)}, stacks ${Hexagon.stacks(a, b, c)}');
          exit(1);
        }
        boxes++;
      }
    }
  }
  final four = Hexagon(4, 4, 4).count();
  if (four != 232848 || Hexagon.macmahon(4, 4, 4) != 232848 || Hexagon.stacks(4, 4, 4) != 232848) {
    stderr.writeln('THE FOUR-BOX: $four');
    exit(1);
  }
  // The leans read as the faces of cubes: the first tiling of the
  // one-box is the empty box seen from above, three lozenges of three
  // different leans meeting in the middle.
  final one = Hexagon(1, 1, 1).first()!;
  if ({for (final l in one) Hexagon.lean(l)}.length != 3) {
    stderr.writeln('THE ONE-BOX TILING DOES NOT SHOW THREE FACES');
    exit(1);
  }

  stdout.writeln(
      'every tiling of every hexagon of sides up to three swept, $boxes '
      'hexagons, and the four-box besides, and every count is MacMahon\'s '
      'product exactly and the count of stacks of cubes in the box, walked '
      'separately: 2 for the one-box, 6 for the flat box, 20, 175, 980, and '
      '232,848 for the four-box; and the chipped box, ten triangles up and '
      'twelve down, leaves two down triangles bare in every one of its 172 '
      'layings');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} tilings, and ${level.ways} stacks of cubes in the box'
        : ' ${number + 1} $name ${level.task}: none, and the triangles said so first, ten up and twelve down');
  }
}
