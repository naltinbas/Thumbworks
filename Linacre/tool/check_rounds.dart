// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:linacre/wire/game.dart';
import 'package:linacre/wire/rounds.dart';
import 'package:linacre/wire/webs.dart';

/// Walks every shipped round: who wins it with the player moving first, in
/// how many of the player's moves, and whether two webs settle it.
void main() {
  for (var number = 0; number < Rounds.count; number++) {
    final round = Rounds.at(number);
    final game = Game(round.net);
    final settled = game.settle(0, 0, round.part);
    final playerWins = settled.cutterWins == (round.part == Part.cutter);
    final inMine = (settled.inMoves + 1) ~/ 2;
    final webs = Webs.findTwoWebs(round.net);

    print('${(number + 1).toString().padLeft(2)} '
        '${round.name.padRight(18)} '
        '${round.net.count} posts ${round.net.many.toString().padLeft(2)} wires  '
        'player ${round.part == Part.cutter ? 'cuts  ' : 'braces'}  '
        '${playerWins ? 'wins in $inMine' : 'cannot win'}  '
        'written down ${round.fewest ?? 'no number'}  '
        'two webs ${webs == null ? 'no' : 'yes'}'
        '${playerWins == !round.hopeless ? '' : '  WRONG WAY ROUND'}'
        '${playerWins && inMine != round.fewest ? '  WRONG NUMBER WRITTEN DOWN' : ''}'
        '${round.hopeless && webs == null ? '  HOPELESS WITHOUT WEBS' : ''}');
  }
}
