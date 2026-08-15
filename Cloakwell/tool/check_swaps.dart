import 'dart:io';

import 'package:cloakwell/rail/levels.dart';
import 'package:cloakwell/rail/rules.dart';

/// Sweeps every sequence of swaps for every rail, holds the pairs out
/// of order to the search and to the parity, and refuses the bake on
/// any disagreement: this is what `make swaps` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep of sequences.
  for (final level in Levels.all) {
    final (sorting, all) = Rules.sequences(level.row, level.swaps);
    if (sorting != level.ways || all != level.sequences) {
      stderr.writeln('${level.name}: sweep finds $sorting of $all, label says ${level.ways} of ${level.sequences}');
      exit(1);
    }
    if (level.winnable && level.swaps != Rules.inversions(level.row)) {
      stderr.writeln('${level.name}: asks ${level.swaps} swaps for ${Rules.inversions(level.row)} pairs');
      exit(1);
    }
  }

  // Every row of up to six coats: the fewest swaps by search is the
  // count of pairs out of order, and the sign by cycles is the parity
  // of that count.
  var rows = 0;
  for (var n = 1; n <= 6; n++) {
    Rules.rows(n, (r) {
      rows++;
      final inv = Rules.inversions(r);
      if (Rules.fewestBySearch(r) != inv) {
        stderr.writeln('$r: fewest ${Rules.fewestBySearch(r)}, pairs $inv');
        exit(1);
      }
      if (Rules.signByCycles(r) != (inv.isEven ? 1 : -1)) {
        stderr.writeln('$r: SIGN AND PAIRS DISAGREE');
        exit(1);
      }
    });
  }
  if (rows != 873) {
    stderr.writeln('$rows ROWS');
    exit(1);
  }
  // Every swap of neighbours changes the count of pairs by exactly one:
  // every row of up to five coats, every swap.
  Rules.rows(5, (r) {
    for (var i = 0; i + 1 < r.length; i++) {
      final d = Rules.inversions(Rules.swapped(r, i)) - Rules.inversions(r);
      if (d != 1 && d != -1) {
        stderr.writeln('$r SWAP $i CHANGES THE PAIRS BY $d');
        exit(1);
      }
    }
  });
  // The reverse of four in five, and in seven: never in five, and in
  // seven never either, since seven is odd and six is even.
  final (five, _) = Rules.sequences([4, 3, 2, 1], 5);
  final (seven, sevens) = Rules.sequences([4, 3, 2, 1], 7);
  final (eight, _) = Rules.sequences([4, 3, 2, 1], 8);
  if (five != 0 || seven != 0 || eight == 0 || sevens != 2187) {
    stderr.writeln('THE REVERSE OF FOUR: five $five, seven $seven, eight $eight');
    exit(1);
  }
  // The middle out in six: some do, six being even like four.
  final (six, _) = Rules.sequences([2, 4, 1, 5, 3], 6);
  if (six == 0) {
    stderr.writeln('THE MIDDLE OUT NEVER SORTS IN SIX');
    exit(1);
  }

  stdout.writeln(
      'every sequence of swaps swept for every rail, and every row of up '
      'to six coats searched, 873 rows: the fewest swaps of neighbours '
      'that sort a row is its count of pairs out of order in every case, '
      'the sign by cycles is the parity of that count in every case, and '
      'every swap of every row of five changes the count by exactly one; '
      'the reverse of four sorts in six swaps 16 ways of 729, in five '
      'never and in seven never, and in eight it does, the middle out '
      'sorting in four 5 ways of 256 and in six besides');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(19);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.sequences)} sequences land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.sequences)}, and one pair a swap said so first');
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
