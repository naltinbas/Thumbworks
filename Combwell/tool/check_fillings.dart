import 'dart:io';

import 'package:combwell/comb/levels.dart';
import 'package:combwell/comb/rules.dart';

/// Walks every filling of every comb, holds the twelve fillings of the
/// whole comb to be one comb turned and reflected, checks the sum by
/// the rows, and refuses the bake on any disagreement: this is what
/// `make fillings` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the walk, and every filling found held
  // to be magic and to keep the given cells.
  for (final level in Levels.all) {
    final rules = level.rules;
    final found = rules.fillings(level.given);
    if (found.length != level.ways) {
      stderr.writeln('${level.name}: the walk finds ${found.length} fillings, label says ${level.ways}');
      exit(1);
    }
    for (final f in found) {
      if (!rules.magic(f)) {
        stderr.writeln('${level.name}: THE FILLING $f IS NOT MAGIC');
        exit(1);
      }
      for (var c = 0; c < Rules.cells; c++) {
        if (level.given[c] != 0 && f[c] != level.given[c]) {
          stderr.writeln('${level.name}: THE FILLING $f MOVES A GIVEN CELL');
          exit(1);
        }
      }
      if (f.toSet().length != Rules.cells || f.any((v) => v < 1 || v > Rules.cells)) {
        stderr.writeln('${level.name}: THE FILLING $f REPEATS OR STRAYS');
        exit(1);
      }
    }
    // The given cells are Adams' comb where given.
    for (var c = 0; c < Rules.cells; c++) {
      if (level.given[c] != 0 && level.given[c] != Levels.adams[c]) {
        stderr.writeln('${level.name}: GIVEN CELL $c IS ${level.given[c]}, NOT ADAMS\' ${Levels.adams[c]}');
        exit(1);
      }
    }
  }

  // The whole comb: twelve fillings, all of them Adams' comb carried by
  // one of the twelve turnings and reflections, and Adams' comb itself
  // magic; the lines are fifteen, five each way, each cell on three.
  final whole = const Rules(38).fillings(List.filled(Rules.cells, 0));
  final symmetries = Rules.symmetries;
  if (symmetries.length != 12 || symmetries.map((s) => s.toString()).toSet().length != 12) {
    stderr.writeln('THE SYMMETRIES ARE ${symmetries.length}');
    exit(1);
  }
  final images = {for (final s in symmetries) Rules.carry(Levels.adams, s).toString()};
  if (whole.length != 12 || images.length != 12 || !whole.every((f) => images.contains(f.toString()))) {
    stderr.writeln('THE WHOLE COMB: ${whole.length} FILLINGS, ${images.length} IMAGES, images hold ${whole.where((f) => images.contains(f.toString())).length}');
    exit(1);
  }
  if (!const Rules(38).magic(Levels.adams)) {
    stderr.writeln('ADAMS\' COMB IS NOT MAGIC');
    exit(1);
  }
  if (Rules.lines.length != 15) {
    stderr.writeln('${Rules.lines.length} LINES');
    exit(1);
  }
  for (var c = 0; c < Rules.cells; c++) {
    if (Rules.linesOf(c).length != 3) {
      stderr.writeln('CELL $c ON ${Rules.linesOf(c).length} LINES');
      exit(1);
    }
  }
  // The rows take every cell once, so five rows come to 1 + ... + 19 =
  // 190, and 190 is 5 times 38: no other sum can be, and the walk
  // finds none for 37 or 39.
  final rowCells = {for (final row in Rules.rows) ...row};
  if (rowCells.length != Rules.cells || 5 * 38 != 190 || 190 != Rules.cells * (Rules.cells + 1) ~/ 2) {
    stderr.writeln('THE ROWS DO NOT TAKE THE COMB ONCE');
    exit(1);
  }
  final off = <int, int>{};
  for (final s in [36, 37, 39, 40]) {
    off[s] = Rules(s).fillings(List.filled(Rules.cells, 0)).length;
    if (off[s] != 0) {
      stderr.writeln('${off[s]} FILLINGS SUM TO $s');
      exit(1);
    }
  }

  stdout.writeln(
      'every filling of the comb walked, forced cell by forced cell, for the sums '
      '36 to 40 with nothing given and for every comb on the sham as given: the '
      'whole comb sums to 38 twelve ways and to 36, 37, 39 or 40 never, since the '
      'five rows take every number from 1 to 19 once, 190 between them, which is '
      'five 38s; the twelve fillings are one comb carried by the six turnings and '
      'six reflections of the hexagon, the comb Adams found in 1957, 3, 17, 18 '
      'across the top, and each of the fifteen lines, five each way, sums to 38 in '
      'it; the last four cells fill 1 way, the last seven 1, the last ten 1, the '
      'whole comb 12, and the thirty-seven never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} filling${level.ways == 1 ? '' : 's'} land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none, and the rows said so first');
  }
}
