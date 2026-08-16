import 'dart:io';

import 'package:trebleworth/heap/levels.dart';
import 'package:trebleworth/heap/play.dart';
import 'package:trebleworth/heap/rules.dart';

/// Sweeps every number to 500 for its heaps of three and two, holds the
/// heaps of three to the odd squares of 8n + 3, and refuses the bake on
/// any disagreement: this is what `make heaps` runs, and the README
/// quotes its ledger verbatim.
void main() {
  if (Rules.triangles.take(8).toList().toString() != '[0, 1, 3, 6, 10, 15, 21, 28]' || Rules.triangles.length != 32 || Rules.triangles.last != 496) {
    stderr.writeln('THE TRIANGLES ARE ${Rules.triangles}');
    exit(1);
  }
  // Every number to 500: three heaps always, matched one for one with
  // the odd squares of 8n + 3, both by heap and by root; two heaps not
  // always.
  final twoMisses = <int>[], singles = <int>[];
  var most = 0, mostAt = 0;
  for (var n = 0; n <= Rules.top; n++) {
    final three = Rules.heaps(n, 3), squares = Rules.oddSquares(n);
    if (three.isEmpty) {
      stderr.writeln('$n IS NOT THREE HEAPS');
      exit(1);
    }
    if (three.length != squares.length) {
      stderr.writeln('$n: ${three.length} HEAPS, ${squares.length} WAYS IN ODD SQUARES');
      exit(1);
    }
    // Heap for heap: the roots 2k+1 of the heaps' k are the odd squares'
    // roots, as sorted lists.
    final fromHeaps = three.map((h) => (h.map((t) => 2 * Rules.triangles.indexOf(t) + 1).toList()..sort()).join(',')).toSet();
    final fromSquares = squares.map((s) => s.join(',')).toSet();
    if (fromHeaps.length != three.length || !fromHeaps.containsAll(fromSquares)) {
      stderr.writeln('$n: THE HEAPS AND THE SQUARES DO NOT MATCH ONE FOR ONE');
      exit(1);
    }
    for (final h in three) {
      if (h.fold<int>(0, (a, b) => a + b) != n || h.any((t) => !Rules.isTriangular(t))) {
        stderr.writeln('$n: A BAD HEAP $h');
        exit(1);
      }
    }
    if (three.length == 1) singles.add(n);
    if (three.length > most) {
      most = three.length;
      mostAt = n;
    }
    if (Rules.heaps(n, 2).isEmpty) twoMisses.add(n);
  }
  if (twoMisses.length != 212 || twoMisses.take(5).toList().toString() != '[5, 8, 14, 17, 19]' || singles.toString() != '[0, 1, 2, 4, 5, 8, 11, 14, 20, 29, 50, 53]' || most != 16 || mostAt != 406) {
    stderr.writeln('TWO MISSES ${twoMisses.length}, SINGLES $singles, MOST $most AT $mostAt');
    exit(1);
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final met = Rules.heaps(level.number, level.slots).length;
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(List<int?>.of(aim))) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The named heaps.
  if (Rules.heaps(20, 3).map(Rules.told).join(', ') != '10 + 10 + 0' || Rules.heaps(20, 2).map(Rules.told).join(', ') != '10 + 10' ||
      Rules.heaps(47, 3).map(Rules.told).join(', ') != '45 + 1 + 1, 36 + 10 + 1' || Rules.heaps(47, 2).isNotEmpty ||
      Rules.heaps(100, 3).map(Rules.told).join(', ') != '55 + 45 + 0, 78 + 21 + 1, 91 + 6 + 3, 66 + 28 + 6, 45 + 45 + 10, 36 + 36 + 28' ||
      Rules.heaps(12, 2).map(Rules.told).join(', ') != '6 + 6' || Rules.heaps(12, 3).map(Rules.told).join(', ') != '6 + 6 + 0, 10 + 1 + 1, 6 + 3 + 3' ||
      Rules.heaps(5, 2).isNotEmpty || Rules.heaps(5, 3).map(Rules.told).join(', ') != '3 + 1 + 1' ||
      Rules.oddSquares(20).toString() != '[[1, 9, 9]]' || Rules.oddSquares(47).toString() != '[[3, 3, 19], [3, 9, 17]]' || Rules.oddSquares(5).toString() != '[[3, 3, 5]]' ||
      8 * 20 + 3 != 163 || 8 * 47 + 3 != 379 || 8 * 5 + 3 != 43) {
    stderr.writeln('THE NAMED HEAPS ARE OFF');
    exit(1);
  }
  final pairs = <int>{};
  for (final a in [0, 1, 3]) {
    for (final b in [0, 1, 3]) {
      pairs.add(a + b);
    }
  }
  if ((pairs.toList()..sort()).toString() != '[0, 1, 2, 3, 4, 6]') {
    stderr.writeln('THE PAIRS BELOW FIVE ARE $pairs');
    exit(1);
  }

  stdout.writeln(
      'every number from 0 to 500 swept for its heaps of three triangular numbers, '
      'nought allowed, and of two: every one is three heaps, 406 the most ways '
      'with sixteen and twelve numbers one way alone, 0, 1, 2, 4, 5, 8, 11, 14, 20, '
      '29, 50 and 53; the heaps of three of every n match the ways 8n + 3 is three '
      'odd squares, one for one by the roots 2k + 1, on all 501; two heaps miss 212 '
      'of the 501, 5, 8, 14, 17 and 19 first; twenty is 10 + 10 + 0 alone, '
      'forty-seven 45 + 1 + 1 or 36 + 10 + 1 and no two heaps, a hundred six ways, '
      'twelve is 6 + 6 from two, and five is 3 + 1 + 1 from three but no two, the '
      'pairs of 0, 1 and 3 adding to 0, 1, 2, 3, 4 and 6');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} heap${level.ways == 1 ? '' : 's'} of the shelf ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: no heap of the shelf, and the six pairs said so first');
  }
}
