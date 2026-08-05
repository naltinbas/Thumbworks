// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:trodstow/link/cheapest.dart';
import 'package:trodstow/link/parishes.dart';

/// Walks every shipped parish: the cheapest network worked out three ways, the
/// reason each path in it has to be there, and what the shortest way to one
/// place would have cost.
void main() {
  for (var number = 0; number < Rounds.count; number++) {
    final round = Rounds.at(number);
    final parish = round.parish;
    final cheapest = Cheapests.of(parish);
    final growing = Cheapests.byGrowing(parish);
    final trying = Cheapests.byTrying(parish);
    final shortest = Cheapests.byShortestWay(parish);
    final nearest = Cheapests.byNearest(parish);

    // Every path in it has to be the cheapest across the line it crosses.
    var proved = 0;
    for (final trod in cheapest.cut) {
      final why = Cheapests.whyIn(parish, cheapest.cut, trod);
      final dearer = why.crossing.every((other) =>
          other == trod || parish[other].yards > parish[trod].yards);
      if (dearer) proved++;
    }

    print('${(number + 1).toString().padLeft(2)} '
        '${parish.name.padRight(18)} '
        '${parish.count} hamlets  '
        '${parish.many.toString().padLeft(2)} paths  '
        'cheapest ${cheapest.yards}  '
        'written down ${round.yards}  '
        'by growing ${growing.yards}  '
        'by trying every set $trying  '
        'shortest way ${shortest.yards}  '
        '$proved of ${cheapest.cut.length} proved by the line they cross'
        '${cheapest.yards == growing.yards ? '' : '  THE TWO DISAGREE'}'
        '${cheapest.yards == trying ? '' : '  TRYING EVERY SET DISAGREES'}'
        '${proved == cheapest.cut.length ? '' : '  SOME ARE NOT PROVED'}'
        '${nearest.yards == cheapest.yards ? '' : '  NEAREST IS NOT A SUBSET'}'
        '${shortest.yards > cheapest.yards ? '' : '  SHORTEST WAY IS ENOUGH'}'
        '${cheapest.yards == round.yards ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
