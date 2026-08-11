// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:foldbury/fold/fewest.dart';
import 'package:foldbury/fold/folds.dart';

/// Walks every shipped fold: the fewest shepherds, the matching floor, the
/// lanes floor, and what posting greedily at the busiest gate would cost.
void main() {
  for (var number = 0; number < Folds.count; number++) {
    final fold = Folds.at(number);
    final watch = Watches.of(fold);
    final greed = Watches.byGreed(fold);

    print('${(number + 1).toString().padLeft(2)} '
        '${fold.name.padRight(18)} '
        '${fold.count.toString().padLeft(2)} gates  '
        '${fold.many.toString().padLeft(2)} lanes  '
        'fewest ${watch.fewest}  '
        'written down ${fold.fewest}  '
        'matching ${watch.matching.length}  '
        'by lanes ${watch.byLanes}  '
        'greed $greed'
        '${watch.floorSaysSo ? '' : '  NEITHER FLOOR PROVES IT'}'
        '${watch.fewest == fold.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
