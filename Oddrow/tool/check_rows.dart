import 'dart:io';

import 'package:oddrow/row/askings.dart';
import 'package:oddrow/row/rules.dart';

/// Reads every row of the wall three ways, holds the tally
/// whole, and refuses the bake on any disagreement: this is
/// what `make rows` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final asking in Askings.all) {
    final ways = Rules.waysTo(asking.odds);
    if (ways != asking.ways) {
      stderr.writeln('${asking.name}: sweep finds $ways, '
          'label says ${asking.ways}');
      exit(1);
    }
  }

  // The three counts and the tally, over every row.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The rows behind the notes, pinned.
  if ('${Rules.rowsWith(2)}' != '[1, 2, 4, 8]' ||
      '${Rules.rowsWith(4)}' != '[3, 5, 6, 9, 10, 12]' ||
      '${Rules.rowsWith(8)}' != '[7, 11, 13, 14]' ||
      '${Rules.rowsWith(16)}' != '[15]') {
    stderr.writeln('THE ROWS MOVED');
    exit(1);
  }

  // The two odds sit at the ends on every two-odd row.
  for (final at in Rules.rowsWith(2)) {
    if ('${Rules.oddPlaces(at)}' != '[0, $at]') {
      stderr.writeln('A TWO-ODD ROW LIT THE MIDDLE: $at');
      exit(1);
    }
  }

  stdout.writeln(
      'every row of the wall read three ways, the addition, the '
      'bit rule and the doubling, and never apart: the odd '
      'counts run one, two, four, eight and sixteen over rows '
      'nought to fifteen, tallying 1, 4, 6, 4 and 1 rows '
      'apiece, and no power of two means no row: three odds '
      'belong to nobody');
  stdout.writeln('');

  for (var number = 0; number < Askings.count; number++) {
    final asking = Askings.at(number);
    final name = asking.name.padRight(18);
    stdout.writeln(asking.winnable
        ? ' ${number + 1} $name ${asking.task}: ${asking.ways} '
            'row${asking.ways == 1 ? '' : 's'} of the wall '
            'hold${asking.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${asking.task}: none of the '
            'sixteen, and the doubling said so first');
  }
}
