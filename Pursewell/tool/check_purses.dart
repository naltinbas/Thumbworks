import 'dart:io';

import 'package:pursewell/purse/purses.dart';
import 'package:pursewell/purse/rules.dart';

/// Sweeps every purse, walks the greedy, bans the neighbours,
/// and refuses the bake on any disagreement: this is what
/// `make coins` runs, and the README quotes its ledger verbatim.
void main() {
  // Uniqueness and the greedy over every purse to a hundred.
  if (!Rules.lawHolds()) {
    stderr.writeln('A PURSE PAID TWICE, OR THE GREEDY MISSED');
    exit(1);
  }

  for (final purse in Purses.all) {
    final payments = Rules.payments(purse.price);
    if (purse.secondWay) {
      if (payments.length != 1 || purse.ways != 0) {
        stderr.writeln('${purse.name}: a second way exists');
        exit(1);
      }
    } else if (payments.length != purse.ways) {
      stderr.writeln('${purse.name}: sweep finds '
          '${payments.length}, label says ${purse.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  if ('${Rules.payments(11).single}' != '[3, 8]' ||
      '${Rules.payments(19).single}' != '[1, 5, 13]' ||
      '${Rules.payments(30).single}' != '[1, 8, 21]' ||
      '${Rules.payments(47).single}' != '[13, 34]' ||
      '${Rules.payments(12).single}' != '[1, 3, 8]') {
    stderr.writeln('A PAYMENT MOVED');
    exit(1);
  }
  // Thirty's stranding: 17 has no lawful payment avoiding 13's
  // reach once 13 is spent.
  final seventeen = Rules.payments(17).single;
  if (!seventeen.contains(13)) {
    stderr.writeln('SEVENTEEN PAYS WITHOUT THIRTEEN');
    exit(1);
  }

  stdout.writeln(
      'every purse from one to a hundred swept through every '
      'lawful handful: each pays exactly one way, the greedy '
      'walk lands on that way every time, and the five prices '
      'shipped pay 3 and 8, 1 and 5 and 13, 1 and 8 and 21, 13 '
      'and 34, and 1 and 3 and 8 with no second way anywhere');
  stdout.writeln('');

  for (var number = 0; number < Purses.count; number++) {
    final purse = Purses.at(number);
    final name = purse.name.padRight(16);
    stdout.writeln(purse.winnable
        ? ' ${number + 1} $name ${purse.task}: 1 payment, and '
            'the sweep proves it alone'
        : ' ${number + 1} $name ${purse.task}: none, by '
            'Zeckendorf\'s uniqueness swept to a hundred');
  }
}
