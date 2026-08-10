// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:treblesway/ring/extent.dart';
import 'package:treblesway/ring/peals.dart';

/// Walks every shipped peal: how many rows its tower can reach, how many ways
/// its goal can be rung, and whether the labels are right.
void main() {
  for (var number = 0; number < Peals.count; number++) {
    final peal = Peals.at(number);
    final tower = peal.tower;

    final seen = <int>{tower.keyOf(tower.rounds)};
    final waiting = [tower.rounds];
    while (waiting.isNotEmpty) {
      final row = waiting.removeLast();
      for (final change in tower.changes) {
        final next = change.apply(row);
        if (seen.add(tower.keyOf(next))) waiting.add(next);
      }
    }

    final started = DateTime.now();
    final extents = Extent(tower, goalRows: peal.goalRows).countExtents();
    final took = DateTime.now().difference(started).inMilliseconds;

    print('${(number + 1).toString().padLeft(2)} '
        '${peal.name.padRight(18)} '
        '${tower.bells} bells  '
        '${tower.changes.length} changes  '
        'reaches ${seen.length.toString().padLeft(2)} of ${tower.rows}  '
        'goal ${peal.goalRows}  '
        'ways ${extents.toString().padLeft(5)}  '
        'written down ${peal.extents.toString().padLeft(5)}  '
        '${took}ms'
        '${extents == peal.extents ? '' : '  WRONG NUMBER WRITTEN DOWN'}'
        '${(extents == 0) == peal.hopeless ? '' : '  THE LABEL IS WRONG'}');
  }
}
