// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:shroveham/griddle/batches.dart';
import 'package:shroveham/griddle/fewest.dart';

/// Walks every shipped batch and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_batches.dart  (or `make batches`)
void main() {
  var wrong = 0;

  for (var number = 0; number < Batches.count; number++) {
    final batch = Batches.at(number);
    final walk = Flips.byWalk(batch.cakes);
    final floor = Flips.gaps(batch.cakes);
    final hand = Flips.byHand(batch.cakes);

    final agree = walk == batch.fewest;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${batch.name.padRight(15)} '
        '${batch.many} cakes  '
        'fewest $walk  written down ${batch.fewest}  '
        'gaps $floor  the hand $hand'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong batch${wrong == 1 ? '' : 'es'} wrong');
    throw StateError('the shipped batches are not what they claim');
  }
}
