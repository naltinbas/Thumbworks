import 'dart:io';

import 'package:bridgeholm/walk/rules.dart';
import 'package:bridgeholm/walk/towns.dart';

/// Counts the odd landings and searches every trail of every town, and
/// refuses the bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Towns.count; number++) {
    final town = Towns.at(number);
    final rules = Rules(town);

    final odd = rules.oddGrounds;
    claim(odd.toString() == town.oddGrounds.toString(),
        '${town.name}: odd landings $odd, written ${town.oddGrounds}');
    claim(rules.walkable == town.walkable,
        '${town.name}: search says walkable=${rules.walkable}');

    // The theorem, met in both directions on this town: walks exist
    // exactly when the odd landings number nought or two, and they
    // leave exactly the odd pair, or anywhere when none are odd.
    final counts = [
      for (var ground = 0; ground < town.grounds.length; ground++)
        rules.walksFrom(ground),
    ];
    if (odd.length == 2) {
      for (var ground = 0; ground < town.grounds.length; ground++) {
        claim((counts[ground] > 0) == odd.contains(ground),
            '${town.name}: walks from ${town.grounds[ground]}');
      }
    } else if (odd.isEmpty && town.walkable) {
      for (var ground = 0; ground < town.grounds.length; ground++) {
        claim(counts[ground] > 0,
            '${town.name}: no walk from ${town.grounds[ground]}');
      }
    } else {
      claim(counts.every((count) => count == 0),
          '${town.name}: a walk exists after all');
    }

    final verdict = town.walkable
        ? 'walkable, ${odd.isEmpty ? 'from every landing' : 'from its '
            'two odd landings only'}'
        : 'no walk at all, ${odd.length} odd landings';
    stdout.writeln(' ${number + 1} ${town.name.padRight(17)} '
        '${town.grounds.length} landings, ${town.bridges.length} '
        'bridges  $verdict  walks ${counts.join('/')}');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
