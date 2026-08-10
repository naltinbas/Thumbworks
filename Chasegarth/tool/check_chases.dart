// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:chasegarth/forme/chases.dart';
import 'package:chasegarth/forme/fewest.dart';
import 'package:chasegarth/forme/parity.dart';

/// Walks every shipped forme: how many arrangements its chase can reach, how
/// many there are altogether, whether the parity agrees about every one of
/// them, and the distance of the arrangement it starts from.
void main() {
  for (var number = 0; number < Formes.count; number++) {
    final forme = Formes.at(number);
    final chase = forme.chase;
    final started = DateTime.now();
    final slides = Slides(chase);
    final took = DateTime.now().difference(started).inMilliseconds;

    final from = slides.from(forme.start);
    final (_, worst) = slides.furthest;
    final (agreed, disagreed) = slides.againstParity();

    print('${(number + 1).toString().padLeft(2)} '
        '${forme.name.padRight(18)} '
        '${chase.wide}x${chase.tall}  '
        '"${chase.reading}"  '
        'starts ${from ?? 'IMPOSSIBLE'}  '
        'written down ${forme.fewest}  '
        '${slides.reached} of ${slides.everyArrangement} reachable  '
        'furthest $worst  '
        'parity: $agreed agree, $disagreed disagree  '
        '${took}ms'
        '${forme.dropped == (from == null) ? '' : '  DROPPED IS WRONG'}'
        '${!forme.dropped && from != forme.fewest ? '  WRONG NUMBER WRITTEN DOWN' : ''}'
        '${disagreed > 0 ? '  PARITY IS WRONG' : ''}'
        '${slides.reached * 2 == slides.everyArrangement ? '' : '  NOT HALF'}');

    if (forme.dropped) {
      final pair = Parity.swapThatWouldDoIt(chase, forme.start)!;
      final mended = [
        for (final sort in forme.start)
          sort == pair.$1 ? pair.$2 : (sort == pair.$2 ? pair.$1 : sort),
      ];
      final after = slides.from(mended);
      print('    the mend swaps ${chase.letterOf(pair.$1)} and '
          '${chase.letterOf(pair.$2)}, leaving $after slides'
          '${after == forme.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
    }
  }
}
