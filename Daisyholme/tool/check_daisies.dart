import 'dart:io';

import 'package:daisyholme/daisy/circles.dart';
import 'package:daisyholme/daisy/rules.dart';

/// Wires every circle there is, holds the daisy count and the
/// pairing lemma against the sweep, and refuses the bake on any
/// disagreement: this is what `make daisies` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final circle in Circles.all) {
    final rules = Rules(circle.people);
    final given = {
      for (final pair in circle.given) rules.pairs.indexOf(pair),
    };
    final ways = rules.waysBySweep(given: given.isEmpty ? null : given);
    if (ways != circle.ways) {
      stderr.writeln('${circle.name}: sweep finds $ways, '
          'label says ${circle.ways}');
      exit(1);
    }
  }

  // The two counts, held together where both speak.
  for (final people in [3, 4, 5, 7]) {
    final rules = Rules(people);
    if (rules.waysBySweep() != rules.waysByDaisies()) {
      stderr.writeln('THE COUNTS PARTED AT $people');
      exit(1);
    }
  }

  // The laws on every landing: a heart, even friend counts,
  // and the friends pairing off.
  for (final people in [3, 4, 5, 7]) {
    if (!Rules(people).lawsHold()) {
      stderr.writeln('A LAW BROKE AT $people');
      exit(1);
    }
  }

  stdout.writeln(
      'every wiring of every circle swept, 8 and 64 and 1,024 '
      'and 2,097,152: the landings match hearts times pairings '
      'exactly, 1 and 15 and 105 with none at all for four, '
      'every landing keeps a heart befriended to everyone, and '
      'round every person of every landing the friends pair '
      'off, which is why the crowd must come odd');
  stdout.writeln('');

  for (var number = 0; number < Circles.count; number++) {
    final circle = Circles.at(number);
    final name = circle.name.padRight(18);
    stdout.writeln(circle.winnable
        ? ' ${number + 1} $name ${circle.task}: ${circle.ways} '
            'wiring${circle.ways == 1 ? '' : 's'} of the sweep '
            'land${circle.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${circle.task}: none of the 64, '
            'and the pairing lemma said so first');
  }
}
