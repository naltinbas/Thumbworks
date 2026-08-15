import 'dart:io';

import 'package:kitewick/kite/levels.dart';
import 'package:kitewick/kite/play.dart';
import 'package:kitewick/kite/rules.dart';

/// Lays out every slating of every kite to order five, holds the counts
/// to the formula and the counts across to Pascal's rows, and refuses
/// the bake on any disagreement: this is what `make kites` runs, and
/// the README quotes its ledger verbatim.
void main() {
  // Every level's label against its own sweep, the aim landing it, and
  // no level over at the opening.
  for (final level in Levels.all) {
    final met = level.slatings.where(level.meets).length;
    if (met != level.ways || level.slatings.length != Kite.byFormula(level.order)) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.slatings.length}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
    for (final s in level.slatings) {
      if (!level.kite.covers(s)) {
        stderr.writeln('${level.name}: A SLATING THAT DOES NOT COVER');
        exit(1);
      }
    }
  }

  // The two voices, orders one to five: the count laid out against two
  // to the n(n+1)/2; and to order four, every slating's count across
  // even and the counts running along Pascal's row n(n+1)/2.
  final counts = <int>[];
  for (var order = 1; order <= 5; order++) {
    final kite = Kite(order);
    final laidOut = kite.countSlatings();
    counts.add(laidOut);
    if (laidOut != Kite.byFormula(order) || kite.count != 2 * order * (order + 1)) {
      stderr.writeln('ORDER $order: $laidOut LAID OUT, ${Kite.byFormula(order)} BY THE FORMULA, ${kite.count} CELLS');
      exit(1);
    }
  }
  if (counts.toString() != '[2, 8, 64, 1024, 32768]') {
    stderr.writeln('THE COUNTS ARE $counts');
    exit(1);
  }
  final rows = <String>[];
  for (var order = 1; order <= 4; order++) {
    final kite = Kite(order);
    final half = order * (order + 1) ~/ 2;
    final histogram = List.filled(half + 1, 0);
    for (final s in kite.slatings()) {
      final across = kite.acrossCount(s);
      if (across.isOdd) {
        stderr.writeln('ORDER $order: A SLATING WITH $across ACROSS');
        exit(1);
      }
      histogram[across ~/ 2]++;
    }
    // Pascal's row: C(half, j).
    var c = 1;
    for (var j = 0; j <= half; j++) {
      if (histogram[j] != c) {
        stderr.writeln('ORDER $order: ${2 * j} ACROSS COMES ${histogram[j]} WAYS, PASCAL SAYS $c');
        exit(1);
      }
      c = c * (half - j) ~/ (j + 1);
    }
    rows.add(histogram.join(', '));
  }
  if (rows[1] != '1, 3, 3, 1' || rows[2] != '1, 6, 15, 20, 15, 6, 1' || rows[3] != '1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1') {
    stderr.writeln('THE ROWS ARE $rows');
    exit(1);
  }
  // Every row of every kite to order five has an even count of cells.
  for (var order = 1; order <= 5; order++) {
    final kite = Kite(order);
    for (final y in kite.rows) {
      if (kite.cells.where((c) => c.$2 == y).length.isOdd) {
        stderr.writeln('ORDER $order ROW $y IS ODD');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every slating of the kite laid out from the first bare cell on, orders one '
      'to five, 4, 12, 24, 40 and 60 cells: 2, 8, 64, 1,024 and 32,768 slatings, '
      'two to the n(n+1)/2 at every order; every row of every kite has an even '
      'count of cells; every slating to order four lays an even count of slates '
      'across, and the slatings sort by that count along a row of Pascal\'s '
      'triangle, 1 and 1 for the order one, 1, 3, 3, 1 for the order two, 1, 6, '
      '15, 20, 15, 6, 1 for the order three and 1, 10, 45, 120, 210, 252, 210, '
      '120, 45, 10, 1 for the order four; so the order two lays two across 3 '
      'ways of 8 and one across never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.slatings.length} slatings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.slatings.length}, and the even rows said so first');
  }
}
