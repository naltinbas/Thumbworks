import 'dart:io';

import 'package:foursworth/window/houses.dart';
import 'package:foursworth/window/rules.dart';

/// Dials every house every way, holds the all-even law and the
/// circling law, and refuses the bake on any disagreement:
/// this is what `make windows` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final house in Houses.all) {
    final ways = Rules.waysTo(house.count, house.asked);
    if (ways != house.ways) {
      stderr.writeln('${house.name}: sweep finds $ways, '
          'label says ${house.ways}');
      exit(1);
    }
  }

  // The laws over every dialling of three and four.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The four-window spread, pinned whole.
  final spread = <int, int>{};
  Rules.diallings(4, (windows) {
    final turns = Rules.turnsToDark(windows);
    spread[turns] = (spread[turns] ?? 0) + 1;
  });
  final told =
      Map.fromEntries(spread.entries.toList()..sort((a, b) => a.key - b.key));
  if ('$told' !=
      '{0: 1, 1: 7, 2: 104, 3: 560, 4: 2384, 5: 400, 6: 512, 7: 128}') {
    stderr.writeln('THE SPREAD MOVED: $told');
    exit(1);
  }

  // The classic seven-turn dialling walks its full road.
  if (Rules.turnsToDark([0, 1, 3, 7]) != 7) {
    stderr.writeln('THE CLASSIC ROAD MOVED');
    exit(1);
  }

  stdout.writeln(
      'every dialling of every house walked, 4,096 of four '
      'windows and 512 of three: four windows always go dark by '
      'the seventh turn with every face even after the fourth, '
      'the spread pinned whole, while of the threes only the '
      'eight all-alike ever rest, the other 504 circling for '
      'ever on the parity ring');
  stdout.writeln('');

  for (var number = 0; number < Houses.count; number++) {
    final house = Houses.at(number);
    final name = house.name.padRight(18);
    stdout.writeln(house.winnable
        ? ' ${number + 1} $name ${house.task}: ${house.ways} '
            'dialling${house.ways == 1 ? '' : 's'} of the sweep '
            'land${house.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${house.task}: none of the 512, '
            'and the parity ring said so first');
  }
}
