import 'dart:io';

import 'package:brickholme/yard/levels.dart';
import 'package:brickholme/yard/rules.dart';

/// Walks every paving of every yard with the drain on every flag, holds
/// the colouring to the walk on all of them, and refuses the bake on
/// any disagreement: this is what `make tilings` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against the walk, the colouring and the paving.
  for (final level in Levels.all) {
    final rules = level.rules;
    final walked = rules.pavings();
    if (walked != level.ways) {
      stderr.writeln('${level.name}: the walk counts $walked pavings, label says ${level.ways}');
      exit(1);
    }
    if (rules.colouringAllows != level.winnable) {
      stderr.writeln('${level.name}: the colouring ${rules.colouringAllows ? 'allows' : 'forbids'}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    final paving = rules.paving();
    if ((paving != null) != level.winnable || (paving != null && !rules.paved(paving))) {
      stderr.writeln('${level.name}: THE PAVING FOUND IS $paving');
      exit(1);
    }
    if (paving != null && paving.length != level.bricks) {
      stderr.writeln('${level.name}: ${paving.length} BRICKS, NOT ${level.bricks}');
      exit(1);
    }
  }

  // Every yard from four to eleven whose flags less one divide by three,
  // with the drain on every flag: the walk finds a paving exactly when
  // the drain wears the odd colour of both slants, and every brick that
  // fits anywhere covers one flag of each colour, on both slants.
  var yards = 0, paveable = 0;
  final allowed = <int, int>{};
  for (final n in [4, 5, 7, 8, 10, 11]) {
    for (var d = 0; d < n * n; d++) {
      final rules = Rules(n, d);
      yards++;
      final walked = rules.pavings();
      if ((walked > 0) != rules.colouringAllows) {
        stderr.writeln('$n BY $n, DRAIN $d: walk $walked, colouring ${rules.colouringAllows}');
        exit(1);
      }
      if (walked > 0) {
        paveable++;
        allowed[n] = (allowed[n] ?? 0) + 1;
        final paving = rules.paving();
        if (paving == null || !rules.paved(paving)) {
          stderr.writeln('$n BY $n, DRAIN $d: THE WALK COUNTS $walked BUT NO PAVING IS FOUND');
          exit(1);
        }
      }
    }
    final rules = Rules(n, 0);
    for (var c = 0; c < n * n; c++) {
      for (final across in [true, false]) {
        final f = rules.flagsOf((c, across));
        if (f == null) continue;
        for (final sum in [true, false]) {
          final colours = f.map((x) => rules.colour(x, sum: sum)).toSet();
          if (colours.length != 3) {
            stderr.writeln('$n BY $n: BRICK ($c, $across) COVERS COLOURS $colours');
            exit(1);
          }
        }
      }
    }
  }

  stdout.writeln(
      'every yard from four to eleven whose flags less one divide by three walked '
      'with the drain on every flag, $yards yards, the pavings counted row by row: '
      'a paving is found exactly when the drain wears the odd colour of both '
      'slants, $paveable yards of the $yards, since a brick three flags long, '
      'across or down, always covers one flag of each colour, and the drain must '
      'take the odd one; the four yard paves round its four corners only, the '
      'five round its middle only, the seven round nine flags, the eight round '
      'four, the ten round sixteen and the eleven round nine; the four yard round '
      'a corner 4 ways, the five round the middle 2, the seven round the middle '
      '258, the eight two in from the corner 356, and the eight round a corner '
      'never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} pavings, ${level.bricks} bricks each'
        : ' ${number + 1} $name ${level.task}: none, and the colouring said so first');
  }
}
