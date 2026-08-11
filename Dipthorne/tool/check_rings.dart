// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:dipthorne/ring/fewest.dart';
import 'package:dipthorne/ring/rings.dart';

/// Walks every shipped ring and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_rings.dart  (or `make dips`)
void main() {
  // The reckoning against the count, everywhere, before the ledger.
  var swept = 0;
  for (var children = 1; children <= 120; children++) {
    for (var beats = 1; beats <= 12; beats++) {
      if (Dips.byCount(children, beats) != Dips.byReckoning(children, beats)) {
        throw StateError('count and reckoning part at $children, $beats');
      }
      swept++;
    }
  }
  var turned = 0;
  for (var children = 1; children <= 500; children++) {
    if (Dips.byBinaryTurn(children) != Dips.byReckoning(children, 2)) {
      throw StateError('the binary turn parts at $children');
    }
    turned++;
  }
  print('count and reckoning agree on $swept rings; '
      'the binary turn agrees on $turned two-beat rings\n');

  var wrong = 0;
  for (var number = 0; number < Rings.count; number++) {
    final ring = Rings.at(number);
    final count = Dips.byCount(ring.children, ring.beats);
    final reckon = Dips.byReckoning(ring.children, ring.beats);

    final agree = count == ring.safe && reckon == ring.safe;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${ring.name.padRight(15)} '
        '${ring.children.toString().padLeft(2)} in the ring  '
        '${ring.beats} beats  '
        'safe seat $count  written down ${ring.safe}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong ring${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped rings are not what they claim');
  }
}
