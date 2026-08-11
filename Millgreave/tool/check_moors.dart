// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:millgreave/moor/moors.dart';
import 'package:millgreave/moor/rules.dart';

/// Walks every shipped moor and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_moors.dart  (or `make moors`)
void main() {
  // The built rows against the wind, size by size, before the ledger.
  for (var size = 4; size <= 12; size++) {
    final built = Rules.built(size)!;
    for (var a = 0; a < size; a++) {
      for (var b = a + 1; b < size; b++) {
        if (Rules.steals(a, built[a], b, built[b])) {
          throw StateError('the built rows steal at size $size');
        }
      }
    }
  }
  print('the built rows keep the wind on every moor from four to twelve\n');

  var wrong = 0;
  for (var number = 0; number < Moors.count; number++) {
    final moor = Moors.at(number);
    final ways = Rules.ways(moor.size);

    final agree = ways == moor.ways && (ways > 0) == moor.possible;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${moor.name.padRight(16)} '
        '${moor.size} plots a side  '
        '${ways == 0 ? "no setting at all" : "$ways settings"}'
        '  written down ${moor.ways}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong moor${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped moors are not what they claim');
  }
}
