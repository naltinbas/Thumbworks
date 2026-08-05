// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:packwold/fit/boxes.dart';
import 'package:packwold/fit/cover.dart';

/// Walks every shipped box and counts the ways of packing it.
///
/// Run with: dart run tool/check_boxes.dart
void main() {
  for (var i = 0; i < Puzzles.count; i++) {
    final puzzle = Puzzles.at(i);
    final box = puzzle.box;
    final began = DateTime.now();
    final found = Cover(box, letters: puzzle.letters).solve(enough: 3);
    final took = DateTime.now().difference(began).inMicroseconds / 1000;

    final number = '${i + 1}'.padLeft(2);
    final steps = '${found.looked}'.padLeft(6);
    final ways = found.count == 1 ? '1 packing ' : '${found.count} packings';
    print('$number ${puzzle.name.padRight(18)}${puzzle.wide}x${puzzle.deep}  '
        '${puzzle.pieces} pieces  ${box.cells} cells  $ways  '
        '$steps steps  ${took.toStringAsFixed(1)}ms');
  }
}
