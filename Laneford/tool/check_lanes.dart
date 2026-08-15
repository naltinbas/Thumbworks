import 'dart:io';

import 'package:laneford/green/levels.dart';
import 'package:laneford/green/rules.dart';

/// Sweeps every placing of every green on its grid, holds the counts to
/// Euler's ceiling, and refuses the bake on any disagreement: this is
/// what `make lanes` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and its opening not clear.
  for (final level in Levels.all) {
    final (clear, all, first) = Rules.sweep(level.hamlets, level.lanes, level.size);
    if (clear != level.ways || all != level.settings) {
      stderr.writeln('${level.name}: sweep finds $clear of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (first != null && !Rules.clear(level.lanes, first)) {
      stderr.writeln('${level.name}: THE FIRST PLACING FOUND IS NOT CLEAR');
      exit(1);
    }
    if (Rules.clear(level.lanes, level.start)) {
      stderr.writeln('${level.name}: OPENS CLEAR');
      exit(1);
    }
    if (level.start.toSet().length != level.hamlets) {
      stderr.writeln('${level.name}: TWO HAMLETS OPEN ON ONE POINT');
      exit(1);
    }
    // Euler: a green with more lanes than the ceiling is never clear,
    // and every level's count agrees with that.
    final over = level.lanes.length > level.ceiling;
    if (over != (clear == 0)) {
      stderr.writeln('${level.name}: ${level.lanes.length} LANES, CEILING ${level.ceiling}, YET $clear CLEAR');
      exit(1);
    }
  }

  // The five, every one to every one, ten lanes over Euler's nine: no
  // placing on the four-by-four is clear.
  final k5 = [for (var i = 0; i < 5; i++) for (var j = i + 1; j < 5; j++) (i, j)];
  final (k5clear, k5all, _) = Rules.sweep(5, k5, 4);
  if (k5clear != 0 || k5all != 524160 || Rules.ceiling(5, twoKinds: false) != 9) {
    stderr.writeln('THE FIVE: $k5clear OF $k5all CLEAR');
    exit(1);
  }
  // The three and the three on the five-by-five: none either.
  final k33 = Levels.at(4).lanes;
  final (k33clear, k33all, _) = Rules.sweep(6, k33, 5);
  if (k33clear != 0 || k33all != 127512000) {
    stderr.writeln('THE THREE AND THE THREE ON FIVE BY FIVE: $k33clear OF $k33all');
    exit(1);
  }
  // The geometry: crossing is symmetric, lanes out of one hamlet do not
  // cross unless they run along each other, and a hamlet on a lane is
  // caught.
  if (!Rules.cross((0, 0), (2, 2), (2, 0), (0, 2)) || !Rules.cross((2, 0), (0, 2), (0, 0), (2, 2))) {
    stderr.writeln('THE DIAGONALS DO NOT CROSS');
    exit(1);
  }
  if (Rules.cross((0, 0), (2, 0), (0, 0), (0, 2)) || !Rules.cross((0, 0), (2, 0), (0, 0), (1, 0))) {
    stderr.writeln('LANES OUT OF ONE HAMLET MISJUDGED');
    exit(1);
  }
  if (Rules.throughs([(0, 1)], [(0, 0), (2, 2), (1, 1)]).isEmpty) {
    stderr.writeln('A HAMLET ON A LANE WAS MISSED');
    exit(1);
  }

  stdout.writeln(
      'every placing of the hamlets on the grid swept for every green, the lanes '
      'judged by whole-number cross products, and the counts held to Euler\'s '
      'ceiling, 3v - 6 lanes for a clear green and 2v - 4 for one of two kinds: '
      'four hamlets each to each, six lanes, the ceiling exactly, lie clear in 192 '
      'of 3,024 placings on the three-by-three; two to each of three, six lanes '
      'over five, the ceiling exactly, in 912 of 15,120; five each to each but one '
      'pair, nine lanes, in 1,200 of 524,160 on the four-by-four, and all ten '
      'lanes, one over the ceiling, in none; three to each of three less one lane, '
      'eight, the ceiling exactly, in 26,432 of 5,765,760, and all nine lanes, one '
      'over, in none of the 5,765,760, nor in any of the 127,512,000 on the '
      'five-by-five, as Euler says');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(32);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${_commas(level.ways)} of the ${_commas(level.settings)} placings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${_commas(level.settings)}, and Euler said so first');
  }
}

String _commas(int n) {
  final s = '$n';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}
