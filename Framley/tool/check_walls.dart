import 'dart:io';

import 'package:framley/wall/levels.dart';
import 'package:framley/wall/rules.dart';

/// Finds every hanging of every wall two ways, holds the smallest frame
/// off the rim, and refuses the bake on any disagreement: this is what
/// `make walls` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the search.
  for (final level in Levels.all) {
    final found = Rules.hangings(level.width, level.height, level.sizes, fixed: level.fixed, smallestOnRim: level.smallestOnRim);
    if (found.length != level.ways) {
      stderr.writeln('${level.name}: search finds ${found.length}, label says ${level.ways}');
      exit(1);
    }
    for (final hanging in found) {
      if (!level.meets(hanging)) {
        stderr.writeln('${level.name}: A HANGING FOUND DOES NOT MEET THE ASK');
        exit(1);
      }
    }
  }

  // The three walls: rows and columns agree, the four hangings are one
  // turned and mirrored, the areas add up, the codes read, and the
  // smallest frame is off the rim in every one, walled in.
  final walls = [
    (32, 33, Levels.nine),
    (61, 69, Levels.otherNine),
    (47, 65, Levels.ten),
  ];
  final codes = <String>[];
  final walledIn = <String>[];
  for (final (w, h, sizes) in walls) {
    final area = sizes.fold(0, (sum, s) => sum + s * s);
    if (area != w * h) {
      stderr.writeln('$w x $h: THE AREAS DO NOT ADD UP: $area');
      exit(1);
    }
    if (sizes.toSet().length != sizes.length) {
      stderr.writeln('$w x $h: TWO FRAMES ALIKE');
      exit(1);
    }
    final rows = Rules.hangings(w, h, sizes);
    final cols = Rules.hangings(w, h, sizes, byColumns: true);
    if (rows.length != 4 || cols.length != 4) {
      stderr.writeln('$w x $h: ${rows.length} BY ROWS, ${cols.length} BY COLUMNS');
      exit(1);
    }
    final rowsTold = rows.map((r) => r.told).toSet();
    final colsTold = cols.map((c) => c.told).toSet();
    if (rowsTold.length != 4 || !rowsTold.containsAll(colsTold)) {
      stderr.writeln('$w x $h: THE TWO READINGS FIND DIFFERENT HANGINGS');
      exit(1);
    }
    final images = Rules.images(w, h, rows.first).map((i) => i.told).toSet();
    if (images.length != 4 || !images.containsAll(rowsTold)) {
      stderr.writeln('$w x $h: THE FOUR ARE NOT ONE TURNED AND MIRRORED');
      exit(1);
    }
    codes.add(Rules.bouwkamp(w, h, rows.first));
    final smallest = sizes.reduce((a, b) => a < b ? a : b);
    for (final hanging in rows) {
      final (x, y) = hanging[smallest]!;
      if (Rules.touchesRim(w, h, smallest, x, y)) {
        stderr.writeln('$w x $h: THE SMALLEST FRAME IS ON THE RIM');
        exit(1);
      }
      // Every hanging covers the wall exactly: the frames' cells are
      // all inside and never two on a cell.
      final grid = List.generate(h, (_) => List.filled(w, 0));
      for (final e in hanging.entries) {
        for (var j = e.value.$2; j < e.value.$2 + e.key; j++) {
          for (var i = e.value.$1; i < e.value.$1 + e.key; i++) {
            grid[j][i]++;
          }
        }
      }
      if (grid.any((row) => row.any((c) => c != 1))) {
        stderr.writeln('$w x $h: A HANGING DOES NOT COVER THE WALL ONCE');
        exit(1);
      }
    }
    final near = Rules.neighbours(w, h, rows.first, smallest);
    walledIn.add('by ${near.sublist(0, near.length - 1).join(', ')} and ${near.last}');
    // The well: the smallest frame held to the rim finds nothing, and
    // every other frame is wider than it, which is why.
    final rim = Rules.hangings(w, h, sizes, smallestOnRim: true);
    if (rim.isNotEmpty) {
      stderr.writeln('$w x $h: A HANGING WITH THE SMALLEST ON THE RIM');
      exit(1);
    }
    if (sizes.where((s) => s != smallest).any((s) => s <= smallest)) {
      stderr.writeln('$w x $h: A FRAME NO WIDER THAN THE SMALLEST');
      exit(1);
    }
  }
  if (codes.join(' ') != '(18,14)(4,10)(15,7)(1,9)(8) (36,25)(9,16)(2,7)(33,5)(28) (25,22)(3,19)(17,11)(6,5)(24)(23)') {
    stderr.writeln('THE CODES READ ${codes.join(' ')}');
    exit(1);
  }
  if (walledIn.join('; ') != 'by 7, 8, 9 and 10; by 5, 7, 9 and 36; by 11, 19, 22 and 25') {
    stderr.writeln('THE SMALLEST FRAMES ARE WALLED IN ${walledIn.join('; ')}');
    exit(1);
  }

  stdout.writeln(
      'every hanging of the nine frames 1, 4, 7, 8, 9, 10, 14, 15 and 18 on the '
      'thirty-two by thirty-three wall found by hanging at the first bare cell, top '
      'row first, and found again column by column: 4 hangings, one but for turning '
      'and mirroring, its code (18,14)(4,10)(15,7)(1,9)(8) read row by row; the nine '
      '2, 5, 7, 9, 16, 25, 28, 33 and 36 on sixty-one by sixty-nine the same, 4 '
      'hangings, code (36,25)(9,16)(2,7)(33,5)(28); the ten 3, 5, 6, 11, 17, 19, 22, '
      '23, 24 and 25 on forty-seven by sixty-five the same, 4 hangings, code '
      '(25,22)(3,19)(17,11)(6,5)(24)(23); the areas add up, 1,056, 4,209 and 3,055, '
      'and every hanging covers its wall once; in every hanging the smallest frame '
      'is off the rim, walled in by 7, 8, 9 and 10, by 5, 7, 9 and 36, and by 11, '
      '19, 22 and 25, and with the smallest held to the rim there is no hanging at '
      'all, as the well says: on the rim it would sit at the bottom of a well as '
      'wide as itself, and every other frame is wider');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(!level.winnable
        ? ' ${number + 1} $name ${level.task}: none of the 4, and the well said so first'
        : level.ways == 1
            ? ' ${number + 1} $name ${level.task}: 1 hanging fills it'
            : ' ${number + 1} $name ${level.task}: ${level.ways} hangings fill it, one but for turning and mirroring');
  }
}
