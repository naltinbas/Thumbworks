import 'dart:io';

import 'package:evenmoor/moor/peggings.dart';
import 'package:evenmoor/moor/rules.dart';

/// Sweeps every placing of three, four and five pegs on the moor,
/// holds the pigeonhole count to the census on each, and refuses the
/// bake on any disagreement: this is what `make halfways` runs, and
/// the README quotes its ledger verbatim.
void main() {
  final rules = Rules();
  for (final pegging in Peggings.all) {
    final (ways, all) = rules.sweep(pegging.pegs, pegging.asked);
    if (ways != pegging.ways || all != pegging.placings) {
      stderr.writeln('${pegging.name}: sweep finds $ways of $all, label says ${pegging.ways} of ${pegging.placings}');
      exit(1);
    }
  }

  // The kinds: nine, six, six and four holes.
  final kinds = [0, 0, 0, 0];
  for (final hole in rules.holes) {
    kinds[Rules.kindOf(hole)]++;
  }
  if ('$kinds' != '[9, 6, 6, 4]') {
    stderr.writeln('THE KINDS MOVED: $kinds');
    exit(1);
  }
  // On every placing of three, four and five, the census of landed
  // posts is the pigeonhole count, and five pegs never land none;
  // the spreads pinned.
  const spreads = {
    3: {0: 900, 1: 1272, 3: 128},
    4: {0: 1296, 1: 7308, 2: 1701, 3: 2188, 6: 157},
    5: {1: 13608, 2: 19017, 3: 12192, 4: 5568, 6: 2607, 10: 138},
  };
  for (final entry in spreads.entries) {
    final spread = <int, int>{};
    rules.placings(entry.key, (pegs) {
      final landed = Rules.halfwayPairs(pegs).length;
      if (landed != Rules.landedByKinds(pegs)) {
        stderr.writeln('THE CENSUS AND THE KINDS PART AT $pegs');
        exit(1);
      }
      spread[landed] = (spread[landed] ?? 0) + 1;
    });
    for (final k in entry.value.keys) {
      if (spread[k] != entry.value[k]) {
        stderr.writeln('THE SPREAD OF ${entry.key} MOVED AT $k: ${spread[k]}');
        exit(1);
      }
    }
    if (spread.length != entry.value.length) {
      stderr.writeln('THE SPREAD OF ${entry.key} HAS EXTRA COUNTS: $spread');
      exit(1);
    }
  }
  // 9 x 6 x 6 x 4 is 1,296; 84 + 20 + 20 + 4 is 128; 126 + 6 + 6 is 138.
  if (9 * 6 * 6 * 4 != 1296 || 84 + 20 + 20 + 4 != 128 || 126 + 6 + 6 != 138) {
    stderr.writeln('THE ARITHMETIC MOVED');
    exit(1);
  }

  stdout.writeln(
      'every placing of three, four and five pegs on the moor swept, 2,300 '
      'and 12,650 and 53,130 of them, and every halfway post read two ways, '
      'by whether it lands on a hole and by the kinds of its two pegs, the '
      'two agreeing on every placing: four pegs keep every post off 1,296 '
      'ways, one to a kind, three pegs land all three 128 ways, five pegs '
      'land one post 13,608 ways and all ten 138 ways, and never none, '
      'since four kinds cannot hold five pegs one apiece');
  stdout.writeln('');

  for (var number = 0; number < Peggings.count; number++) {
    final pegging = Peggings.at(number);
    final name = pegging.name.padRight(19);
    stdout.writeln(pegging.winnable
        ? ' ${number + 1} $name ${pegging.task}: ${_commas(pegging.ways)} placings of the '
            '${_commas(pegging.placings)} land it'
        : ' ${number + 1} $name ${pegging.task}: none of the ${_commas(pegging.placings)}, '
            'and the four kinds said so first');
  }
}

/// 53130 as 53,130.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
