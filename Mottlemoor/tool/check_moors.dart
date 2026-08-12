import 'dart:io';

import 'package:mottlemoor/herd/moors.dart';
import 'package:mottlemoor/herd/rules.dart';

/// Walks every herding of every moor, sweeps the differences, and
/// refuses the bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The two voices, swept over every moor of fifteen or fewer.
  var moors = 0;
  for (var total = 1; total <= 15; total++) {
    final rules = Rules(total);
    for (var a = 0; a <= total; a++) {
      for (var b = 0; a + b <= total; b++) {
        final herds = (a, b, total - a - b);
        moors++;
        claim(
            (rules.fewest(herds) != null) ==
                rules.differencesAllow(herds),
            'the walk and the differences part at $herds');
      }
    }
  }
  stdout.writeln('every moor of fifteen or fewer, $moors herdings: '
      'the walk settles exactly where the differences allow');
  stdout.writeln('');

  for (var number = 0; number < Moors.count; number++) {
    final moor = Moors.at(number);
    final rules = Rules(moor.total);
    claim(rules.fewest(moor.herds) == moor.fewest,
        '${moor.name}: walk says ${rules.fewest(moor.herds)}, '
        'written ${moor.fewest}');
    claim(rules.differencesAllow(moor.herds) == moor.winnable,
        '${moor.name}: the differences disagree');

    final verdict = moor.winnable
        ? 'settles in ${moor.fewest}, none to spare'
        : 'never settles: no two herds share a remainder by three';
    stdout.writeln(' ${number + 1} ${moor.name.padRight(19)} '
        '${moor.russet}/${moor.olive}/${moor.slate}  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
