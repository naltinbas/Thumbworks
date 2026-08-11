import 'dart:io';

import 'package:charmstead/charm/charms.dart';
import 'package:charmstead/charm/rules.dart';

/// Sweeps every filling of the bed against every shipped claim, and
/// refuses the bake on any disagreement.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  final all = Rules.allCharms();
  claim(all.length == 8, 'the sweep found ${all.length} charms');
  for (final charm in all) {
    claim(charm[4] == 5, 'a charm holds ${charm[4]} at the heart');
  }
  final orbit = {
    for (final turning in Rules.turnings)
      Rules.turned(all.first, turning).join(','),
  };
  claim(
      orbit.length == 8 &&
          orbit.containsAll({for (final charm in all) charm.join(',')}),
      'the eight are not one square eight ways round');
  stdout.writeln('the sweep of all 362,880 fillings finds 8 charms, '
      'every heart a five, and all eight one square eight ways round');
  stdout.writeln('');

  for (var number = 0; number < Charms.count; number++) {
    final charm = Charms.at(number);
    final honoured = Rules.charmsUnder(charm.pins);
    claim(honoured.length == charm.ways,
        '${charm.name}: ${honoured.length} hold, written ${charm.ways}');

    final verdict = charm.winnable
        ? '${charm.ways} charm${charm.ways == 1 ? '' : 's'} '
            'honour${charm.ways == 1 ? 's' : ''} the pins'
        : 'no charm honours the pins';
    stdout.writeln(' ${number + 1} ${charm.name.padRight(16)} '
        '${charm.pins.length} pinned  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
