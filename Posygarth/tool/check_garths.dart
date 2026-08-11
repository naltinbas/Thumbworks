// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:posygarth/garden/garths.dart';
import 'package:posygarth/garden/rules.dart';

/// Walks every shipped garth and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_garths.dart  (or `make garths`)
void main() {
  // The plantings first, size by size.
  for (final size in const [3, 4, 5, 7, 9]) {
    final planting = Rules.planted(size)!;
    if (!Rules.sound(size, planting)) {
      throw StateError('the planting fails at $size');
    }
  }
  print('the plantings hold at three, four, five, seven and nine\n');

  var wrong = 0;
  for (var number = 0; number < Garths.count; number++) {
    final garth = Garths.at(number);
    final exists = Rules.anyExists(garth.size);

    final agree = exists == garth.possible;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${garth.name.padRight(17)} '
        '${garth.size} beds a side  '
        '${exists ? "the garth blooms" : "no planting at all"}'
        '${garth.seeded.isEmpty ? "" : "  (${garth.seeded.length} seeded)"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong garth${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped garths are not what they claim');
  }
}
