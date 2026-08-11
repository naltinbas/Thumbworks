import 'dart:io';

import 'package:pegbourne/code/riddles.dart';
import 'package:pegbourne/code/rules.dart';

/// Sweeps all 256 codes against every riddle and refuses the bake on
/// any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Riddles.count; number++) {
    final riddle = Riddles.at(number);
    final answers = Rules.answers(riddle.rows);
    claim(answers.length == riddle.ways,
        '${riddle.name}: ${answers.length} agree, written '
        '${riddle.ways}');
    if (!riddle.winnable) {
      claim(Rules.irreconcilable(riddle.rows) != null,
          '${riddle.name}: dead but every pair of rows can hold');
    }

    final verdict = riddle.winnable
        ? '${riddle.ways} code${riddle.ways == 1 ? '' : 's'} '
            'agree${riddle.ways == 1 ? 's' : ''} with every row'
        : 'no code agrees, and two rows cannot even hold together';
    stdout.writeln(' ${number + 1} ${riddle.name.padRight(19)} '
        '${riddle.rows.length} rows  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
