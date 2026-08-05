// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:skeinmoor/thread/boards.dart';
import 'package:skeinmoor/thread/solve.dart';

/// Hands every board that ships to the solver and says what it found.
///
/// Run with: dart run tool/check_boards.dart
void main() {
  final clock = Stopwatch()..start();
  for (var i = 0; i < Boards.count; i++) {
    final board = Boards.at(i);
    final began = clock.elapsedMicroseconds;
    final found = Threader(board.field).ways(enough: 3);
    final took = (clock.elapsedMicroseconds - began) / 1000;

    print('${(i + 1).toString().padLeft(2)} ${board.name.padRight(16)} '
        '${board.side}x${board.side}  '
        '${board.threads} threads  '
        '${found.count} way${found.count == 1 ? '' : 's'}  '
        '${found.looked.toString().padLeft(6)} steps  '
        '${took.toStringAsFixed(1)}ms');
  }
}
