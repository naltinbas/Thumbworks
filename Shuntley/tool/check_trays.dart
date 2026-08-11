import 'dart:io';

import 'package:shuntley/shunt/rules.dart';
import 'package:shuntley/shunt/trays.dart';

/// Walks every shipped tray out and refuses the bake on any
/// disagreement. The suite runs the parity sweeps; this is the ledger.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The two ways of knowing, agreed on every arrangement there is: the
  // walk from home knows nothing of parity, the pair count nothing of
  // walking, and they never part.
  for (final (rows, cols) in const [(2, 3), (3, 3)]) {
    final rules = Rules(rows, cols);
    var parted = false;
    var all = 0;
    for (final board in rules.allBoards()) {
      all++;
      if (rules.solvable(board) != rules.even(board)) parted = true;
    }
    claim(!parted, '$rows by $cols: the walk parted from the parity');
    claim(rules.reached * 2 == all,
        '$rows by $cols: the walk reached ${rules.reached} of $all');
    stdout.writeln(
        'every arrangement of $rows by $cols: the walk reaches a board '
        'exactly when its pairs count even, all $all, half of them '
        'home-comers');
  }

  stdout.writeln('');
  for (var number = 0; number < Trays.count; number++) {
    final tray = Trays.at(number);
    final rules = Rules(tray.rows, tray.cols);

    claim(rules.fewest(tray.tiles) == tray.fewest,
        '${tray.name}: fewest ${rules.fewest(tray.tiles)}, '
        'written ${tray.fewest}');
    if (!tray.winnable) {
      claim(!rules.even(tray.tiles),
          '${tray.name}: dead but its pairs count even');
    }

    final verdict = tray.winnable
        ? 'home in ${tray.fewest}'
        : 'never comes home';
    stdout.writeln(' ${number + 1} ${tray.name.padRight(18)} '
        '${tray.rows} by ${tray.cols}  $verdict');
  }

  // The deep claims, walked fresh.
  final small = Rules(2, 3);
  final big = Rules(3, 3);
  claim(small.deepest == 21, 'the little tray runs deeper than 21');
  claim(big.deepest == 31, 'the eight runs deeper than 31');
  var farthest = 0;
  for (final board in big.allBoards()) {
    if (big.fewest(board) == 31) farthest++;
  }
  claim(farthest == 2, 'boards at 31: $farthest, not two');
  stdout.writeln('\nthe farthest little-tray board lies 21 out; of the '
      'eight\'s 181,440 exactly two lie 31 out and none farther');

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
