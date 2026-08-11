// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:spanham/row/fewest.dart';
import 'package:spanham/row/levels.dart';

/// Walks every shipped shelf and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_levels.dart  (or `make shelves`)
void main() {
  // The arithmetic against the search on every size to twelve first.
  for (var pairs = 1; pairs <= 12; pairs++) {
    final allowed = Rows.parityAllows(pairs);
    final found = Rows.settings(pairs, most: 1).isNotEmpty;
    if (allowed != found) {
      throw StateError('arithmetic and search part at $pairs pairs');
    }
  }
  print('the arithmetic and the search agree on every shelf to twelve '
      'pairs\n');

  var wrong = 0;
  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final ways = Rows.ways(level.pairs);

    final agree = ways == level.ways && (ways > 0) == level.possible;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${level.name.padRight(16)} '
        '${level.pairs} pairs  '
        '${ways == 0 ? "no setting at all" : "$ways settings"}'
        '  written down ${level.ways}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong shelf${wrong == 1 ? '' : 'es'} wrong');
    throw StateError('the shipped shelves are not what they claim');
  }
}
