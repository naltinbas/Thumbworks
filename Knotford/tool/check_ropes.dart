import 'dart:io';

import 'package:knotford/rope/ropes.dart';
import 'package:knotford/rope/rules.dart';

/// Sweeps every marking of every rope, holds Euclid's formula and the
/// parity of squares to the sweep, and refuses the bake on any
/// disagreement: this is what `make ropes` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final rope in Ropes.all) {
    final rules = Rules(rope.knots);
    final (ways, _) = rules.sweep();
    if (ways != rope.ways || rules.markingCount != rope.markings) {
      stderr.writeln('${rope.name}: sweep finds $ways of ${rules.markingCount}, '
          'label says ${rope.ways} of ${rope.markings}');
      exit(1);
    }
    var counted = 0;
    rules.markings((i, j) => counted++);
    if (counted != rules.markingCount) {
      stderr.writeln('${rope.name}: $counted markings walked, arithmetic says ${rules.markingCount}');
      exit(1);
    }
  }

  // Every rope to two hundred knots: the sweep's triangles are exactly
  // Euclid's, and no odd rope squares.
  var ropesThatSquare = 0, triangles = 0;
  final perimeters = <int>[];
  for (var knots = 3; knots <= 200; knots++) {
    final (ways, swept) = Rules(knots).sweep();
    final built = Rules.euclid(knots);
    if (swept.length != built.length || !swept.containsAll(built)) {
      stderr.writeln('$knots KNOTS: sweep $swept, Euclid $built');
      exit(1);
    }
    for (final t in swept) {
      // Six markings run each triangle, three sides in every order.
      final (a, b, c) = t;
      if (a * a + b * b != c * c || a + b + c != knots) {
        stderr.writeln('$knots KNOTS: $t IS NOT RIGHT');
        exit(1);
      }
    }
    if (ways != 6 * swept.length) {
      stderr.writeln('$knots KNOTS: $ways markings for ${swept.length} triangles');
      exit(1);
    }
    if (knots.isOdd && ways != 0) {
      stderr.writeln('$knots KNOTS: AN ODD ROPE SQUARED');
      exit(1);
    }
    if (ways > 0) {
      ropesThatSquare++;
      triangles += swept.length;
      if (knots <= 60) perimeters.add(knots);
    }
  }
  if (!Rules.oddRopeNeverSquares()) {
    stderr.writeln('THE REMAINDERS DO NOT FIX THE PARITY');
    exit(1);
  }
  if ('$perimeters' != '[12, 24, 30, 36, 40, 48, 56, 60]') {
    stderr.writeln('THE ROPES TO SIXTY MOVED: $perimeters');
    exit(1);
  }
  if (Rules(12).sweep().$2.first != (3, 4, 5) ||
      '${Rules(60).sweep().$2.toList()..sort((a, b) => a.$1 - b.$1)}' != '[(10, 24, 26), (15, 20, 25)]') {
    stderr.writeln('THE NAMED TRIANGLES MOVED');
    exit(1);
  }
  // Nothing shorter than twelve squares.
  for (var knots = 3; knots < 12; knots++) {
    if (Rules(knots).sweep().$1 != 0) {
      stderr.writeln('$knots KNOTS SQUARED');
      exit(1);
    }
  }
  stdout.writeln(
      'every marking of every rope to two hundred knots swept, and the '
      'right triangles it finds are Euclid\'s exactly, k times m squared '
      'less n squared, twice mn and m squared plus n squared, on every '
      'rope: $ropesThatSquare ropes square, $triangles triangles among '
      'them, six markings to a triangle, none shorter than twelve knots, '
      'twelve, twenty-four, thirty, thirty-six, forty, forty-eight, '
      'fifty-six and sixty up to sixty, and never an odd rope, since the '
      'remainders of squares by four fix the sides even in sum');
  stdout.writeln('');

  for (var number = 0; number < Ropes.count; number++) {
    final rope = Ropes.at(number);
    final name = rope.name.padRight(12);
    stdout.writeln(rope.winnable
        ? ' ${number + 1} $name ${rope.task}: ${rope.ways} markings of the '
            '${_commas(rope.markings)} land it'
        : ' ${number + 1} $name ${rope.task}: none of the '
            '${_commas(rope.markings)}, and the remainders said so first');
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
