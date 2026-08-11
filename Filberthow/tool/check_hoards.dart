// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:filberthow/hoard/hoards.dart';
import 'package:filberthow/hoard/rules.dart';

/// Walks every shipped hoard and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_hoards.dart  (or `make hoards`)
void main() {
  // Rule against search on every standing to sixty first.
  var standings = 0;
  for (var nuts = 1; nuts <= 60; nuts++) {
    for (var cap = 1; cap <= nuts; cap++) {
      if (Rules.isLoss(nuts, cap) != Rules.isLossBySplit(nuts, cap)) {
        throw StateError('rule and search part at $nuts, $cap');
      }
      standings++;
    }
  }
  print('the split rule and the search agree on all $standings standings '
      'to sixty nuts\n');

  var wrong = 0;
  for (var number = 0; number < Hoards.count; number++) {
    final hoard = Hoards.at(number);
    final winnable = !Rules.isLoss(hoard.nuts, hoard.nuts - 1);

    final agree = winnable == hoard.winnable;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${hoard.name.padRight(20)} '
        '${hoard.nuts.toString().padLeft(2)} nuts  '
        'split ${Rules.split(hoard.nuts).join(" + ")}  '
        '${winnable ? "the opener wins" : "the opener is lost"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong hoard${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped hoards are not what they claim');
  }
}
