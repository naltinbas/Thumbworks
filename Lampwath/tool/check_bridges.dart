// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:lampwath/wath/bridge.dart';
import 'package:lampwath/wath/bridges.dart';
import 'package:lampwath/wath/fewest.dart';

/// Walks every shipped night: the fewest minutes by the settling, what
/// ferrying with the fastest walker costs, and a brute force over every way
/// the night could go.
int byTrying(Bridge bridge) {
  // Ferrying is a real plan, so its figure is a ceiling to prune against,
  // and no plan worth having crosses more than twice per walker.
  var best = Crossings(bridge).byFerrying();

  void go(int over, bool lampFar, int spent, int crossings) {
    if (spent >= best) return;
    if (over == bridge.everyone) {
      best = spent;
      return;
    }
    if (crossings > bridge.count * 2 + 1) return;
    for (var one = 0; one < bridge.count; one++) {
      if (((over >> one) & 1 != 0) != lampFar) continue;
      for (var other = one; other < bridge.count; other++) {
        if (((over >> other) & 1 != 0) != lampFar) continue;
        final party = (1 << one) | (1 << other);
        final slower =
            bridge.walkers[one].minutes > bridge.walkers[other].minutes
                ? bridge.walkers[one].minutes
                : bridge.walkers[other].minutes;
        final landed = lampFar ? over & ~party : over | party;
        go(landed, !lampFar, spent + slower, crossings + 1);
      }
    }
  }

  go(0, false, 0, 0);
  return best;
}

void main() {
  for (var number = 0; number < Bridges.count; number++) {
    final bridge = Bridges.at(number);
    final crossings = Crossings(bridge);
    final settled = crossings.from(0, false);
    final tried = byTrying(bridge);
    final ferried = crossings.byFerrying();

    print('${(number + 1).toString().padLeft(2)} '
        '${bridge.name.padRight(20)} '
        '${bridge.count} walkers '
        '(${bridge.walkers.map((walker) => walker.minutes).join(', ')})  '
        'fewest $settled  '
        'written down ${bridge.fewest}  '
        'by trying $tried  '
        'ferrying $ferried'
        '${settled == tried ? '' : '  THE TWO DISAGREE'}'
        '${settled == bridge.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}'
        '${(ferried == settled) == bridge.ferryDoes ? '' : '  FERRY LABEL IS WRONG'}');
  }
}
