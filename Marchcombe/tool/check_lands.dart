// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:marchcombe/dye/fewest.dart';
import 'package:marchcombe/dye/lands.dart';

/// Whether the only paintings there are, are the one painting with the dyes
/// swapped round every way they can be.
bool _onlyOne(int ways, int dyes) {
  var factorial = 1;
  for (var each = 2; each <= dyes; each++) {
    factorial *= each;
  }
  return ways == factorial;
}

/// Walks every shipped estate: the fewest dyes found by painting, the same
/// number found by splitting the map into sets of fields that keep out of each
/// other's way, the ring of fields that proves it cannot be fewer, and what
/// painting them in the order they come would cost.
void main() {
  for (var number = 0; number < Estates.count; number++) {
    final estate = Estates.at(number);
    final land = estate.land;
    final painting = Dyes.fewestFor(land);
    final covering = Dyes.byCovering(land);
    final byOrder = Dyes.byOrder(land).reduce(max) + 1;
    final ways = Dyes.ways(land, painting.fewest);

    print('${(number + 1).toString().padLeft(2)} '
        '${land.name.padRight(17)} '
        '${land.count} fields  '
        '${land.hedges.length} hedges  '
        'fewest ${painting.fewest}  '
        'written down ${estate.fewest}  '
        'by covering $covering  '
        'the ring is ${painting.ring.length}  '
        'in order $byOrder  '
        '$ways paintings${_onlyOne(ways, painting.fewest) ? ' (ONE, up to swapping the pots)' : ''}  '
        '${painting.tried} tried'
        '${painting.fewest == covering ? '' : '  THE TWO DISAGREE'}'
        '${painting.ringSaysSo ? '' : '  THE RING DOES NOT PROVE IT'}'
        '${byOrder > painting.fewest || number < 2 ? '' : '  IN ORDER IS ENOUGH'}'
        '${painting.fewest == estate.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
