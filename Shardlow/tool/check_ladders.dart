// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:shardlow/drop/fewest.dart';
import 'package:shardlow/drop/ladders.dart';

/// Walks every shipped ladder: the fewest drops by the search, what counting
/// alone says, and both held against each other for every ladder up to two
/// hundred rungs and four pots.
void main() {
  for (var number = 0; number < Ladders.count; number++) {
    final ladder = Ladders.at(number);
    final drops = Drops(ladder.pots);
    final searched = drops.fewestFor(ladder.answers, ladder.pots);
    final counted = Drops.countingSays(ladder.answers, ladder.pots);

    print('${(number + 1).toString().padLeft(2)} '
        '${ladder.name.padRight(18)} '
        '${ladder.rungs.toString().padLeft(3)} rungs  '
        '${ladder.pots} pots  '
        'fewest $searched  '
        'written down ${ladder.fewest}  '
        'counting says $counted'
        '${searched == counted ? '' : '  COUNTING IS NOT TIGHT'}'
        '${searched == ladder.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }

  var checked = 0;
  var loose = 0;
  for (var pots = 1; pots <= 4; pots++) {
    final drops = Drops(pots);
    for (var rungs = 1; rungs <= 200; rungs++) {
      final searched = drops.fewestFor(rungs + 1, pots);
      final counted = Drops.countingSays(rungs + 1, pots);
      checked++;
      if (searched != counted) {
        loose++;
        print('  LOOSE at $rungs rungs, $pots pots: '
            'search $searched, counting $counted');
      }
    }
  }
  print('');
  print('$checked ladders checked against the counting; '
      '${loose == 0 ? 'the floor is exactly the answer on every one' : '$loose came loose'}');
}
