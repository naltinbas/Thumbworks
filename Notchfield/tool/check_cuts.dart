import 'dart:io';

import 'package:notchfield/ruler/cuts.dart';
import 'package:notchfield/ruler/rules.dart';

/// Sweeps every placing of every ruler and refuses the bake on any
/// disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Cuts.count; number++) {
    final cut = Cuts.at(number);
    final rules = Rules(cut.length);
    final (sound, perfect) = rules.countCuttings(cut.notches);
    final ways = cut.perfect ? perfect : sound;
    claim(ways == cut.ways,
        '${cut.name}: $ways cuttings, written ${cut.ways}');

    final verdict = cut.winnable
        ? '${cut.ways} cutting${cut.ways == 1 ? '' : 's'} '
            '${cut.perfect ? 'perfect' : 'sound'}'
        : 'no sound cutting at all';
    stdout.writeln(' ${number + 1} ${cut.name.padRight(17)} '
        '${cut.notches} notches on ${cut.length}  $verdict');
  }

  // The eleven's edge: a ten cannot hold five notches soundly, so
  // eleven is the shortest field.
  final (tenSound, _) = Rules(10).countCuttings(5);
  claim(tenSound == 0, 'a ten held five notches after all');
  stdout.writeln('\na ten cannot hold five notches soundly, all 462 '
      'placings tried: eleven is the shortest field five notches '
      'can share');

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
