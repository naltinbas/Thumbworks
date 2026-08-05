// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:winnowmere/sift/fewest.dart';
import 'package:winnowmere/sift/noughts.dart';
import 'package:winnowmere/sift/puzzles.dart';

/// Walks every shipped puzzle: whether what it starts with can still be
/// finished in the number it promises.
///
/// Run with: dart run tool/check_siftings.dart
void main() {
  for (var i = 0; i < Siftings.count; i++) {
    final one = Siftings.at(i);
    final began = DateTime.now();
    final found = Fewest.fromHere(one.start, giveUpAfter: one.toFind + 1);
    final took = DateTime.now().difference(began).inMilliseconds;

    print('${'${i + 1}'.padLeft(2)} ${one.name.padRight(14)}'
        '${one.lines} lines  '
        '${one.given.length} given  '
        'fewest ${one.fewest}  '
        '${found == null ? 'CANNOT BE FINISHED' : 'finishes in ${found.$1} more'}'
        '  ${found != null && found.$1 == one.toFind ? 'agrees' : 'DOES NOT AGREE'}'
        '  ${took}ms  ${Noughts.right(one.start)} of '
        '${1 << one.lines} rows already right');
  }
}
