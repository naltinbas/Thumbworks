// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:rimeworth/round/parishes.dart';
import 'package:rimeworth/round/runs.dart';

/// Walks every shipped parish: the runs the counting gives, the runs a search
/// over every way the lorry could drive gives, and whether the routes the
/// game can lay out actually salt everything.
void main() {
  for (var number = 0; number < Grittings.count; number++) {
    final gritting = Grittings.at(number);
    final parish = gritting.parish;
    final round = Runs.fewestFor(parish);
    final routes = Runs.routes(parish);
    final driving = parish.laneCount <= 16 ? Runs.byDriving(parish) : -1;

    final salted = <int>{};
    for (final route in routes) {
      for (var step = 1; step < route.length; step++) {
        salted.add(parish.laneBetween(route[step - 1], route[step]));
      }
    }
    final covers = salted.length == parish.laneCount && !salted.contains(-1);

    final agrees = driving < 0 || driving == round.runs;
    print('${(number + 1).toString().padLeft(2)} '
        '${gritting.name.padRight(17)} '
        '${parish.count} junctions  '
        '${parish.laneCount} lanes  '
        '${round.odd.length} odd  '
        'runs ${round.runs}  '
        'written down ${gritting.runs}  '
        'by driving ${driving < 0 ? 'skipped' : driving}  '
        '${routes.length} routes  '
        '${covers ? 'they salt everything' : 'ROUTES DO NOT COVER IT'}'
        '${agrees ? '' : '  DISAGREES'}'
        '${round.runs == gritting.runs ? '' : '  WRONG NUMBER WRITTEN DOWN'}'
        '${parish.isJoinedUp ? '' : '  NOT JOINED UP'}');
  }
}
