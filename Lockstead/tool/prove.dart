// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:lockstead/lock/boards.dart';
import 'package:lockstead/lock/marks.dart';
import 'package:lockstead/lock/solver.dart';

/// Walks the whole strategy tree of every lock and says how deep it goes.
///
/// Run with: dart run tool/prove.dart
///
/// This is where the number on a board comes from. Every code in the lock is
/// a leaf of the tree, so the deepest leaf is not an average, a sample or a
/// hope — it is what the lock costs at worst.
void main() {
  final clock = Stopwatch()..start();
  for (final board in Boards.all) {
    final began = clock.elapsedMilliseconds;
    final marks = Marks.of(board.lock);
    final built = clock.elapsedMilliseconds;
    final depths = Solver(marks).deepest();
    final done = clock.elapsedMilliseconds;

    print('${board.name.padRight(16)} '
        '${board.lock.pegs}x${board.lock.colours}  '
        '${board.codes.toString().padLeft(5)} codes  '
        'worst ${depths.deepest} (says ${board.inside})  '
        'average ${depths.average.toStringAsFixed(3)}  '
        '[$depths]  '
        'table ${built - began}ms, tree ${done - built}ms');
  }
}
