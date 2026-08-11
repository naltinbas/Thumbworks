import 'dart:io';

import 'package:pailsworth/pail/errands.dart';
import 'package:pailsworth/pail/rules.dart';

/// Walks every waterline of every errand and refuses the bake on any
/// disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Errands.count; number++) {
    final errand = Errands.at(number);
    final rules = Rules(errand.caps);

    final fewest = rules.fewestTo(errand.ask);
    claim(fewest == errand.fewest,
        '${errand.name}: walk says $fewest, written ${errand.fewest}');

    // The shared-measure invariant, swept over every reachable
    // waterline: nothing anybody holds escapes the measure.
    final measure = rules.measure;
    for (final held in rules.reachableMeasures()) {
      claim(held % measure == 0,
          '${errand.name}: a pail held $held against measure $measure');
    }
    if (!errand.winnable) {
      claim(errand.ask % measure != 0,
          '${errand.name}: dead but the measure divides the ask');
    }

    final verdict = errand.winnable
        ? 'run in ${errand.fewest} pours, none to spare'
        : 'never runs: the measure is $measure and the ask '
            '${errand.ask}';
    stdout.writeln(' ${number + 1} ${errand.name.padRight(19)} '
        'pails ${errand.caps.join('/')}  ask ${errand.ask}  '
        '${rules.states} waterlines walked  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
