// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:packwold/fit/cover.dart';
import 'package:packwold/fit/pieces.dart';

/// Counts the ways of packing every rectangle the twelve pentominoes fit in.
///
/// Run with: dart run tool/counts.dart
///
/// These four numbers were worked out by other people, decades ago, and are
/// the one thing here checked against somebody else's work rather than
/// against itself. Each solution has three more like it — turned round and
/// flipped over — so the count the search gives is four times the published
/// figure.
void main() {
  print('rect   cells  packings  and up to turning and flipping'.padRight(60));
  for (final size in const [(3, 20), (4, 15), (5, 12), (6, 10)]) {
    final box = Box.plain(size.$2, size.$1);
    final began = DateTime.now();
    final found = Cover(box).solve(enough: 1 << 30);
    final took = DateTime.now().difference(began).inMilliseconds;

    final rect = '${size.$1}x${size.$2}'.padRight(7);
    final cells = '${box.cells}'.padLeft(4);
    final raw = '${found.count}'.padLeft(10);
    final upTo = '${found.count ~/ 4}'.padLeft(10);
    print('$rect$cells$raw$upTo   ${found.looked} steps, ${took}ms');
  }
}
