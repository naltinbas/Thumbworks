// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:pyxholm/assay/boxes.dart';
import 'package:pyxholm/assay/fewest.dart';

/// Walks every shipped box: the fewest weighings the searching finds, and what
/// counting alone says it could possibly be.
void main() {
  for (var number = 0; number < Boxes.count; number++) {
    final pyx = Boxes.at(number);
    final started = DateTime.now();
    final fewest = Assay.of(pyx.coins).fewestFor(pyx.everything);
    final took = DateTime.now().difference(started).inMilliseconds;

    print('${(number + 1).toString().padLeft(2)} '
        '${pyx.name.padRight(14)} '
        '${pyx.coins.toString().padLeft(2)} coins  '
        '${pyx.knownLight ? 'the light one' : 'either way   '}  '
        '${pyx.verdicts.toString().padLeft(2)} to tell apart  '
        'fewest ${fewest ?? '-'}  '
        'written down ${pyx.fewest}  '
        'counting says ${pyx.countingSays}  '
        '${took}ms'
        '${fewest == pyx.countingSays ? '' : '  COUNTING IS NOT ENOUGH'}'
        '${fewest == pyx.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
