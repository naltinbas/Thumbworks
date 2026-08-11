import 'dart:io';

import 'package:wickfield/wick/rules.dart';
import 'package:wickfield/wick/wicks.dart';

/// Works every shipped number out from the crosses and refuses the bake
/// on any disagreement. The suite runs deeper sweeps; this is the ledger.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The two ways of knowing, agreed on every small board there is: the
  // walk from dark knows nothing of algebra, the elimination nothing of
  // walking, and they never part.
  for (final (rows, cols) in const [(3, 3), (4, 4)]) {
    final rules = Rules(rows, cols);
    final walk = rules.byWalk();
    var parted = false;
    for (final board in rules.allBoards()) {
      if (walk[board] != rules.fewest(board)) parted = true;
    }
    claim(!parted, '$rows by $cols: the walk parted from the algebra');
    stdout.writeln(
        'every board of $rows by $cols: the walk from dark and the '
        'elimination name the same fewest, all ${1 << rules.cells}');
  }

  stdout.writeln('');
  for (var number = 0; number < Wicks.count; number++) {
    final wick = Wicks.at(number);
    final rules = Rules(wick.rows, wick.cols);
    final answers = rules.answers(wick.lit);

    claim(answers.length == wick.ways,
        '${wick.name}: ${answers.length} ways, written ${wick.ways}');
    claim(rules.fewest(wick.lit) == wick.fewest,
        '${wick.name}: fewest ${rules.fewest(wick.lit)}, '
        'written ${wick.fewest}');
    for (final presses in answers) {
      claim(rules.pressAll(wick.lit, presses) == 0,
          '${wick.name}: an answer left a lamp lit');
    }
    if (!wick.winnable) {
      claim(rules.oddAgainst(wick.lit) != null,
          '${wick.name}: dead but odd against no quiet pattern');
    }

    final verdict = wick.winnable
        ? 'dark in ${wick.fewest}, ${wick.ways} way${wick.ways == 1 ? '' : 's'}'
        : 'never goes dark';
    stdout.writeln(
        ' ${number + 1} ${wick.name.padRight(18)} ${wick.rows} by '
        '${wick.cols}  ${wick.lamps} lit  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
