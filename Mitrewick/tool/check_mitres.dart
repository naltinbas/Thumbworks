import 'dart:io';

import 'package:mitrewick/board/levels.dart';
import 'package:mitrewick/board/rules.dart';

/// Sweeps every setting of every board, counts the diagonals against
/// the sweep, and refuses the bake on any disagreement: this is what
/// `make mitres` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep.
  for (final level in Levels.all) {
    final rules = Rules(level.side);
    var all = 0, ways = 0;
    rules.settings(level.bishops, (b) {
      if (!level.given.every(b.contains)) return;
      all++;
      if (Rules.peaceful(b)) ways++;
    });
    if (all != level.settings || ways != level.ways) {
      stderr.writeln('${level.name}: sweep finds $ways of $all, label says ${level.ways} of ${level.settings}');
      exit(1);
    }
    if (level.given.isEmpty && ways != rules.peacefulByDiagonals(level.bishops)) {
      stderr.writeln('${level.name}: DIAGONALS SAY ${rules.peacefulByDiagonals(level.bishops)}, SWEEP SAYS $ways');
      exit(1);
    }
  }

  // Every board from two to five: the sweep and the diagonals agree on
  // every count of bishops, the most is 2n - 2 with 2^n peaceful
  // settings, and 2n - 1 never stand; the corners share the long
  // falling diagonal on every board.
  final doubling = <int>[];
  for (var n = 2; n <= 5; n++) {
    final rules = Rules(n);
    for (var k = 1; k <= 2 * n - 1; k++) {
      final byDiagonals = rules.peacefulByDiagonals(k);
      if (n <= 4 || k >= 2 * n - 2) {
        final (peace, all) = rules.sweep(k);
        if (peace != byDiagonals || all != Rules.choose(n * n, k)) {
          stderr.writeln('$n BY $n, $k BISHOPS: sweep $peace of $all, diagonals $byDiagonals');
          exit(1);
        }
      }
    }
    if (rules.peacefulByDiagonals(2 * n - 2) != 1 << n || rules.peacefulByDiagonals(2 * n - 1) != 0) {
      stderr.writeln('$n BY $n: ${rules.peacefulByDiagonals(2 * n - 2)} MOST, ${rules.peacefulByDiagonals(2 * n - 1)} PAST IT');
      exit(1);
    }
    if (!rules.cornersShareFalling) {
      stderr.writeln('$n BY $n: THE CORNERS DO NOT SHARE');
      exit(1);
    }
    doubling.add(rules.peacefulByDiagonals(2 * n - 2));
  }
  for (var n = 6; n <= 7; n++) {
    final rules = Rules(n);
    if (rules.peacefulByDiagonals(2 * n - 2) != 1 << n || rules.peacefulByDiagonals(2 * n - 1) != 0) {
      stderr.writeln('$n BY $n: ${rules.peacefulByDiagonals(2 * n - 2)} MOST');
      exit(1);
    }
    doubling.add(rules.peacefulByDiagonals(2 * n - 2));
  }
  if ('$doubling' != '[4, 8, 16, 32, 64, 128]') {
    stderr.writeln('THE DOUBLING MOVED: $doubling');
    exit(1);
  }

  // The four: every peaceful six uses six rising diagonals and only
  // edge squares, none uses both lonely corners, and a bishop in the
  // middle four kills it.
  {
    const four = Rules(4);
    var edgeOnly = 0, sixRising = 0, bothCorners = 0, middle = 0;
    four.settings(6, (b) {
      if (!Rules.peaceful(b)) return;
      if (b.every((s) => s.$1 == 0 || s.$1 == 3 || s.$2 == 0 || s.$2 == 3)) edgeOnly++;
      if (four.risingUsed(b) == 6) sixRising++;
      if (b.contains((0, 0)) && b.contains((3, 3))) bothCorners++;
      if (b.any((s) => s.$1 >= 1 && s.$1 <= 2 && s.$2 >= 1 && s.$2 <= 2)) middle++;
    });
    if (edgeOnly != 16 || sixRising != 16 || bothCorners != 0 || middle != 0) {
      stderr.writeln('THE FOUR MOVED: $edgeOnly edge, $sixRising six rising, $bothCorners both corners, $middle middle');
      exit(1);
    }
  }

  stdout.writeln(
      'every setting of every board swept and the count read again '
      'diagonal by diagonal, the two agreeing on every count of bishops '
      'on the boards of two, three and four a side and at the most on '
      'five: two less than twice the side stand peaceful in 4, 8, 16, 32, '
      '64 and 128 ways from two to seven a side, one less than twice the '
      'side never, since the corner squares that hold the single-square '
      'rising diagonals share the long falling one on every board; on the '
      'four every peaceful six keeps to the edge, uses six of the seven '
      'rising diagonals and never both lonely corners, and none stands '
      'with a bishop in the middle four');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} settings of the '
            '${_commas(level.settings)} land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.settings)}, and the diagonals said so first');
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
