import 'dart:io';

import 'package:noughtsmill/mill/grinds.dart';
import 'package:noughtsmill/mill/rules.dart';

/// Grinds every factorial, sums the fives, finds the skips, and
/// refuses the bake on any disagreement: this is what
/// `make noughts` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // The ledger against the grinding, runs and skips included.
  if (!Rules.lawHolds()) {
    stderr.writeln('THE LEDGER AND THE GRINDSTONE PARTED');
    exit(1);
  }

  for (final grind in Grinds.all) {
    final landings = Rules.windings(grind.asked);
    if (landings.length != grind.ways) {
      stderr.writeln('${grind.name}: sweep finds '
          '${landings.length}, label says ${grind.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  if ('${Rules.windings(1)}' != '[5, 6, 7, 8, 9]' ||
      '${Rules.windings(4)}' != '[20, 21, 22, 23, 24]' ||
      '${Rules.windings(6)}' != '[25, 26, 27, 28, 29]' ||
      '${Rules.windings(24)}' != '[100, 101, 102, 103, 104]') {
    stderr.writeln('A RUN MOVED');
    exit(1);
  }
  if (Rules.noughts(100) != 24 ||
      Rules.ledger(100).join('+') != '20+4') {
    stderr.writeln('THE HUNDRED MISCOUNTED');
    exit(1);
  }
  if ('${Rules.skipped(29)}' != '[5, 11, 17, 23, 29]') {
    stderr.writeln('THE SKIPS WANDERED');
    exit(1);
  }

  stdout.writeln(
      'every winding to two hundred ground twice, the whole '
      'factorial against Legendre\'s ledger, and never a '
      'disagreement: the counts run five windings each, skip 5, '
      '11, 17, 23 and 29 where the twenty-fives land, and a '
      'hundred factorial ends in twenty-four noughts, twenty '
      'from the fives and four from the twenty-fives');
  stdout.writeln('');

  for (var number = 0; number < Grinds.count; number++) {
    final grind = Grinds.at(number);
    final name = grind.name.padRight(20);
    stdout.writeln(grind.winnable
        ? ' ${number + 1} $name ${grind.task}: ${grind.ways} '
            'windings of the sweep land it'
        : ' ${number + 1} $name ${grind.task}: none to two '
            'hundred, and twenty-five is the reason');
  }
}
