// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:colthorpe/tour/fewest.dart';
import 'package:colthorpe/tour/yards.dart';

/// Walks every shipped yard and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_yards.dart  (or `make yards`)
void main() {
  var wrong = 0;

  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final found = Rounds.exists(yard);

    final agree = found == yard.possible;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${yard.name.padRight(19)} '
        '${yard.width}x${yard.height}  '
        '${yard.closed ? "closed" : "open  "}  '
        'dark ${yard.darks}  light ${yard.lights}  '
        '${found ? "a round exists" : "no round at all"}'
        '  written down ${yard.possible ? "possible" : "impossible"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong yard${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped yards are not what they claim');
  }
}
