// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:frankmoor/post/letters.dart';
import 'package:frankmoor/post/rules.dart';

/// Walks every shipped letter and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_letters.dart  (or `make letters`)
void main() {
  // The rules against the sweeps on every stamp pair in use, first.
  for (final (cheap, dear) in const [(5, 7), (3, 8), (5, 8)]) {
    if (Rules.frobenius(cheap, dear) !=
        Rules.frobeniusBySweep(cheap, dear)) {
      throw StateError('the frobenius rule parts at $cheap, $dear');
    }
    if (Rules.gaps(cheap, dear) != Rules.gapsBySweep(cheap, dear)) {
      throw StateError('the gap count parts at $cheap, $dear');
    }
    print('stamps $cheap and $dear: last gap '
        '${Rules.frobenius(cheap, dear)}, '
        '${Rules.gaps(cheap, dear)} gaps in all, both swept true');
  }
  print('');

  var wrong = 0;
  for (var number = 0; number < Letters.count; number++) {
    final letter = Letters.at(number);
    final payable =
        Rules.payable(letter.amount, letter.cheap, letter.dear);

    final agree = payable == letter.payable;
    if (!agree) wrong++;

    final way = Rules.paying(letter.amount, letter.cheap, letter.dear);
    print('${(number + 1).toString().padLeft(2)} '
        '${letter.name.padRight(22)} '
        '${letter.amount}d with ${letter.cheap}s and ${letter.dear}s  '
        '${way == null ? "cannot be paid" : "${way.$1} and ${way.$2}"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong letter${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped letters are not what they claim');
  }
}
