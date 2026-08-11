import 'dart:io';

import 'package:ferrydale/ferry/ferries.dart';

/// Walks every arrangement of every ferry and refuses the bake on any
/// disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Ferries.count; number++) {
    final ferry = Ferries.at(number);
    final rules = ferry.rules();

    claim(rules.fewest == ferry.fewest,
        '${ferry.name}: walk says ${rules.fewest}, written '
        '${ferry.fewest}');
    claim(rules.reachableFromStart == ferry.reach,
        '${ferry.name}: reaches ${rules.reachableFromStart}, written '
        '${ferry.reach}');

    final verdict = ferry.winnable
        ? 'across in ${ferry.fewest}, ${ferry.reach} arrangements '
            'walked'
        : 'never across: all ${ferry.reach} arrangements walked, the '
            'far bank never full';
    stdout.writeln(' ${number + 1} ${ferry.name.padRight(21)} '
        'boat of ${ferry.capacity}  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
