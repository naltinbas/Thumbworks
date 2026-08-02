// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:haulyard/yard/haul.dart';
import 'package:haulyard/yard/levels.dart';

/// Searches every yard for the shortest way through it, and prints what it
/// found.
///
/// Run with: dart run tool/pars.dart
///
/// This is where the par on a level comes from. A designer's guess at how few
/// shoves a yard takes is worth nothing — the point of a target is that it is
/// reachable and that nothing beats it, and only a search knows that.
void main() {
  final clock = Stopwatch()..start();
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final began = clock.elapsedMicroseconds;
    final haul = Hauler(level.ground).from(level.start);
    final took = (clock.elapsedMicroseconds - began) / 1000;

    print('${(i + 1).toString().padLeft(2)} ${level.name.padRight(18)} '
        '${level.start.crates.length} crates  '
        'par ${haul.pushes?.toString().padLeft(3) ?? ' — '}  '
        '(says ${level.par})  '
        '${haul.looked.toString().padLeft(6)} positions  '
        '${took.toStringAsFixed(1)}ms');
  }
}
