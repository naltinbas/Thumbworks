// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:ellmarsh/cloth/benches.dart';
import 'package:ellmarsh/cloth/rules.dart';

/// Walks every shipped bench and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_benches.dart  (or `make benches`)
void main() {
  // Gap against search on every pair to one hundred and fifty first.
  var pairs = 0;
  for (var long = 1; long <= 150; long++) {
    for (var short = 1; short <= long; short++) {
      if (Rules.isLoss(long, short) != Rules.isLossByGap(long, short)) {
        throw StateError('gap and search part at $long, $short');
      }
      pairs++;
    }
  }
  print('the golden gap and the search agree on all $pairs pairs to a '
      'hundred and fifty ells\n');

  var wrong = 0;
  for (var number = 0; number < Benches.count; number++) {
    final bench = Benches.at(number);
    final winnable = !Rules.isLoss(bench.long, bench.short);

    final agree = winnable == bench.winnable;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${bench.name.padRight(16)} '
        '${bench.long.toString().padLeft(2)} and '
        '${bench.short.toString().padLeft(2)} ells  '
        'quotient ${Rules.quotient(bench.long, bench.short)}  '
        '${winnable ? "the opener holds it" : "the mercer holds it"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong bench${wrong == 1 ? '' : 'es'} wrong');
    throw StateError('the shipped benches are not what they claim');
  }
}
