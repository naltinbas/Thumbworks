// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:lockhithe/quay/berths.dart';
import 'package:lockhithe/quay/odds.dart';

/// Prints the ledger the README quotes: every berth's chances, by every
/// reckoning that can reach it.
///
/// Run with: dart run tool/check_berths.dart  (or `make berths`)
void main() {
  for (var number = 0; number < Berths.count; number++) {
    final berth = Berths.at(number);
    final counting = Odds.byCounting(berth.lockers, berth.looks);
    final luck = Odds.byLuck(berth.lockers, berth.looks);

    var line = '${(number + 1).toString().padLeft(2)} '
        '${berth.name.padRight(17)} '
        '${berth.lockers} sailors, ${berth.looks} looks  '
        'following ${counting.$1} in ${counting.$2}  '
        'guessing ${luck.$1} in ${luck.$2}';

    if (berth.lockers <= 8) {
      final sweep = Odds.bySweep(berth.lockers, berth.looks);
      if (sweep != counting) {
        throw StateError('the reckonings part at ${berth.name}');
      }
      line += '  (sweep agrees)';
    }
    print(line);
  }
}
