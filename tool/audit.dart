// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:cinderplot/game/maker.dart';
import 'package:cinderplot/game/plots.dart';
import 'package:cinderplot/game/solve.dart';

/// Lays out boards until it has a hundred of each size that need no guessing,
/// and says what that cost.
///
/// Run with: dart run tool/audit.dart [how many]
///
/// The numbers to watch are how many seeds were thrown away for each one kept
/// — which decides how long a phone waits for a board — and the hardest rule
/// each kept board actually needed, which is what says whether a size is the
/// difficulty it claims to be.
void main(List<String> args) {
  final wanted = args.isEmpty ? 100 : int.parse(args.first);
  final clock = Stopwatch()..start();

  for (final size in Plots.all) {
    var kept = 0;
    var tried = 0;
    var steps = 0;
    final needed = <String, int>{};
    final began = clock.elapsedMilliseconds;

    for (var seed = 1; kept < wanted && seed < 400000; seed++) {
      tried++;
      final field = Maker.from(
        across: size.across,
        down: size.down,
        mines: size.mines,
        seed: seed,
        needs: size.needs,
      );
      if (field == null) continue;
      kept++;
      final solved = reasonThrough(field, upTo: size.needs);
      steps += solved.steps;
      needed[solved.hardest.name] = (needed[solved.hardest.name] ?? 0) + 1;
    }

    final took = clock.elapsedMilliseconds - began;
    print('${size.name.padRight(13)} '
        '${size.across}x${size.down} ${size.mines} mines '
        '(${(size.density * 100).round()}%)  '
        'kept $kept of $tried  '
        '${(took / kept).toStringAsFixed(0)}ms a board  '
        '${(steps / kept).toStringAsFixed(0)} steps  '
        '$needed');
  }
}
