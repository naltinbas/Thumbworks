// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:fairhold/hold/consignments.dart';
import 'package:fairhold/hold/rules.dart';

/// Walks every shipped consignment and prints the ledger the README
/// quotes.
///
/// Run with: dart run tool/check_consignments.dart  (or `make holds`)
void main() {
  var wrong = 0;
  for (var number = 0; number < Consignments.count; number++) {
    final consignment = Consignments.at(number);
    final ways = Rules.solutions(consignment.crates).length;
    final ends = Rules.endsInAll(consignment.crates);

    final agree = ways == consignment.ways;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${consignment.name.padRight(22)} '
        '${ways == 0 ? "no stacking at all" : "$ways ways"}'
        '  ends $ends'
        '  written down ${consignment.ways}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong consignment${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped consignments are not what they claim');
  }
}
