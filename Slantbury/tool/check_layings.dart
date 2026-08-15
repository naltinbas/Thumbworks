import 'dart:io';

import 'package:slantbury/pieces/geometry.dart';
import 'package:slantbury/pieces/levels.dart';
import 'package:slantbury/pieces/rules.dart';

/// Sweeps every laying of the four pieces inside every frame, holds
/// the areas to Cassini's identity, checks the slants, and refuses the
/// bake on any disagreement: this is what `make layings` runs, and the
/// README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and its first laying against
  // the exact geometry.
  var swept = 0;
  for (final level in Levels.all) {
    final rules = level.rules;
    final (landing, all, first) = rules.sweep(overlapAllowed2: level.overlapAllowed2, mustFill: level.mustFill);
    swept += all;
    if (landing != level.ways || all != level.layings) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.layings}');
      exit(1);
    }
    if ((first != null) != level.winnable) {
      stderr.writeln('${level.name}: first laying $first');
      exit(1);
    }
    if (first != null) {
      final overlap = rules.overlapOf(first), gap = rules.gapOf(first);
      if (overlap > level.overlapAllowed2 || (level.mustFill && gap.sign != 0)) {
        stderr.writeln('${level.name}: THE FIRST LAYING SHARES $overlap AND LEAVES $gap');
        exit(1);
      }
      for (var p = 0; p < 4; p++) {
        if (!rules.inside(p, first[p])) {
          stderr.writeln('${level.name}: PIECE $p LIES OUTSIDE');
          exit(1);
        }
      }
    }
    // The pieces' areas add to the square, twice over.
    var pieces2 = Q.zero;
    for (final piece in rules.pieces) {
      pieces2 = pieces2 + piece.area2;
    }
    if (pieces2 != rules.pieces2 || pieces2 != Q(2 * level.side * level.side)) {
      stderr.writeln('${level.name}: PIECES COME TO $pieces2, NOT ${rules.pieces2}');
      exit(1);
    }
  }

  // Cassini: a Fibonacci number squared and the product of its two
  // neighbours differ by one, the sign turning each step; the frames
  // here are those neighbours, and their bare or shared square is that
  // one, found again by the exact geometry of the sliver.
  for (var n = 2; n <= 40; n++) {
    final cassini = fibonacci(n - 1) * fibonacci(n + 1) - fibonacci(n) * fibonacci(n);
    if (cassini != (n.isEven ? -1 : 1)) {
      stderr.writeln('CASSINI FAILS AT $n: $cassini');
      exit(1);
    }
  }
  final frame = Rules(side: 8, width: 13, height: 5);
  final aimFrame = frame.sweep(overlapAllowed2: Q.zero, mustFill: false).$3!;
  if (frame.gapOf(aimFrame) != Q(2) || frame.frame2 - frame.pieces2 != Q(2)) {
    stderr.writeln('THE FRAME LEAVES ${frame.gapOf(aimFrame)}, THE AREAS SAY ${frame.frame2 - frame.pieces2}');
    exit(1);
  }
  final small = Rules(side: 5, width: 8, height: 3);
  final aimSmall = small.sweep(overlapAllowed2: Q(2), mustFill: false).$3!;
  if (small.overlapOf(aimSmall) != Q(2) || small.pieces2 - small.frame2 != Q(2)) {
    stderr.writeln('THE SMALL FRAME SHARES ${small.overlapOf(aimSmall)}, THE AREAS SAY ${small.pieces2 - small.frame2}');
    exit(1);
  }
  // And nothing in the small frame shares less than one square: a hair
  // under one allowed finds no laying at all.
  final (under, _, _) = small.sweep(overlapAllowed2: Q(199, 100), mustFill: false);
  if (under != 0) {
    stderr.writeln('$under LAYINGS OF THE SMALL FRAME SHARE LESS THAN A SQUARE');
    exit(1);
  }
  // The sliver's own area by the shoelace: the parallelogram between the
  // triangle's slant, three in eight, and the trapezium's, two in five,
  // across the frame.
  final sliver = area2([pt(0, 0), pt(8, 3), pt(13, 5), pt(5, 2)]);
  if (sliver != Q(2)) {
    stderr.writeln('THE SLIVER COMES TO $sliver');
    exit(1);
  }
  // The three slants, no two the same, each pair a whisker apart.
  if (3 * 5 - 8 * 2 != -1 || 2 * 13 - 5 * 5 != 1 || 3 * 13 - 8 * 5 != -1) {
    stderr.writeln('THE SLANTS DO NOT DIFFER AS SAID');
    exit(1);
  }

  stdout.writeln(
      'every laying of the four pieces inside every frame swept, turned and '
      'flipped every way, ${_commas(swept)} layings, the area two pieces share '
      'and the square left bare found by exact fractions and never by eye: the '
      'eight-square goes back together 16 ways, its pieces lie in the '
      'thirteen-by-five with no overlap 2 ways and leave one square bare each '
      'time, a sliver along the slant, and fill it never; the five-square goes '
      'back 16 ways, its pieces lie in the eight-by-three overlapping by exactly '
      'one square 2 ways and by less than a square never; and Cassini\'s identity '
      'says why, a '
      'Fibonacci number squared and the product of its neighbours differing by '
      'one, checked to the fortieth: five by thirteen is sixty-four and one, '
      'three by eight is twenty-five less one, and the three slants, three in '
      'eight, two in five and five in thirteen, are no two the same');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.layings)} layings land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.layings)}, and the areas said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
