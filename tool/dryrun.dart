// This is a command line tool whose whole job is to print a table.
// ignore_for_file: avoid_print

import 'package:emberlane/sim/field.dart';
import 'package:emberlane/sim/kinds.dart';
import 'package:emberlane/sim/plan.dart';
import 'package:emberlane/sim/waves.dart';

/// Plays the whole game with nobody at the controls and reports how it went.
///
/// Run with: dart run tool/dryrun.dart
///
/// This is how the waves and the tower numbers were settled. A defence game is
/// twenty minutes long and its difficulty is an emergent property of about
/// forty numbers, so playing it by hand after every change is not a thing
/// anybody does often enough. The simulation has no randomness in it, so a
/// plan plus the wave table is a whole run, and a run takes a few hundred
/// milliseconds.
///
/// Three plans are played. What is wanted is for the good one to get through,
/// the thin one to die somewhere in the middle, and the silly one to die
/// early — a game the careless player also wins is a game with nothing in it.
void main() {
  print('plan                 waves held  keep left  embers  spent  steps');
  print('-' * 66);

  for (final plan in Plan.all) {
    final watch = Stopwatch()..start();
    final run = plan.play();
    watch.stop();

    final held = run.wave;
    print('${plan.name.padRight(20)}'
        '${'$held/${Waves.count}'.padLeft(11)}'
        '${run.keep.toString().padLeft(11)}'
        '${run.embers.toString().padLeft(8)}'
        '${plan.spent(run).toString().padLeft(7)}'
        '${run.steps.toString().padLeft(7)}'
        '   ${watch.elapsedMilliseconds}ms');
  }

  print('');
  print('${Waves.count} waves, ${Waves.everyWalker} walkers in all');
  print('field ${Field.columns}x${Field.rows}, '
      'path ${Field.only.length} cells');
  print('towers: ${[
    for (final tower in Tower.values)
      '${tower.name} ${tower.cost}'
  ].join(', ')}');
}
