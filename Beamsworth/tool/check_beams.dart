import 'dart:io';

import 'package:beamsworth/beam/rules.dart';
import 'package:beamsworth/beam/worths.dart';

/// Sums every parcel, balances every clash, counts the crates,
/// and refuses the bake on any disagreement: this is what
/// `make weights` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final worth in Worths.all) {
    final ways = Rules.waysTo(worth.choose);
    if (ways != worth.ways) {
      stderr.writeln('${worth.name}: sweep finds $ways, '
          'label says ${worth.ways}');
      exit(1);
    }
  }

  // The one six, named.
  final six = Rules.choice(6);
  if ('$six' != '[11, 17, 20, 22, 23, 24]' ||
      Rules.waysTo(6) != 1) {
    stderr.writeln('THE SIX MOVED: $six');
    exit(1);
  }
  // The crate counting for seven: 127 parcels, readings to 125.
  if (Rules.heaviest(7) > 125) {
    stderr.writeln('SEVEN WEIGHTS OUTGREW THE COUNTING');
    exit(1);
  }
  if (Rules.choice(7) != null) {
    stderr.writeln('A CLEAN SEVEN APPEARED');
    exit(1);
  }
  // Every balance the census reports is a true balance.
  Rules.choices(5, (chosen) {
    final clash = Rules.balance(chosen);
    if (clash == null) return;
    final (left, right) = clash;
    final leftSum = left.fold(0, (a, b) => a + b);
    final rightSum = right.fold(0, (a, b) => a + b);
    if (leftSum != rightSum ||
        left.any(right.contains) ||
        left.isEmpty && right.isEmpty) {
      stderr.writeln('A FALSE BALANCE: $left vs $right');
      exit(1);
    }
  });

  stdout.writeln(
      'every choice from the rack swept, threes to sevens: the '
      'clean counts run 206, 331, 142, 1 and none, the one '
      'clean six is 11, 17, 20, 22, 23 and 24, every reported '
      'balance weighs true on both sides, and seven weights '
      'carry 127 parcels into 125 readings at most');
  stdout.writeln('');

  for (var number = 0; number < Worths.count; number++) {
    final worth = Worths.at(number);
    final name = worth.name.padRight(18);
    stdout.writeln(worth.winnable
        ? ' ${number + 1} $name ${worth.task}: ${worth.ways} '
            'choice${worth.ways == 1 ? '' : 's'} of the sweep '
            'land${worth.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${worth.task}: none of the 792, '
            'and the crate counting said so first');
  }
}
