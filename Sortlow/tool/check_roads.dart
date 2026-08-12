import 'dart:io';

import 'package:sortlow/mill/loads.dart';
import 'package:sortlow/mill/rules.dart';

/// Grinds every load there is, holds the walk to the backwards
/// table, and refuses the bake on any disagreement: this is
/// what `make roads` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final load in Loads.all) {
    final ways = Rules.waysTo(load.asked);
    if (ways != load.ways) {
      stderr.writeln('${load.name}: sweep finds $ways, '
          'label says ${load.ways}');
      exit(1);
    }
    // No load opens landed.
    if (!Rules.repdigit(load.opens) &&
        Rules.stepsByWalk(load.opens) == load.asked) {
      stderr.writeln('${load.name} OPENS LANDED');
      exit(1);
    }
  }

  // The walk, the table, the reach of seven, the lone
  // standstill and the barred repdigits, over every load.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The spread, pinned whole.
  final spread = <int, int>{};
  Rules.numbers((n) {
    final steps = Rules.stepsByWalk(n);
    spread[steps] = (spread[steps] ?? 0) + 1;
  });
  if (spread[0] != 1 ||
      spread[1] != 383 ||
      spread[2] != 576 ||
      spread[3] != 2400 ||
      spread[4] != 1272 ||
      spread[5] != 1518 ||
      spread[6] != 1656 ||
      spread[7] != 2184 ||
      spread.length != 8) {
    stderr.writeln('THE SPREAD MOVED: $spread');
    exit(1);
  }

  // The smallest one-turn load wears leading noughts: 0026,
  // one grind of 6200 less 26.
  var smallest = 1 << 30;
  Rules.numbers((n) {
    if (Rules.stepsByWalk(n) == 1 && n < smallest) smallest = n;
  });
  if (smallest != 26 || Rules.turn(26) != Rules.stone) {
    stderr.writeln('THE SMALLEST ONE-TURN MOVED: $smallest');
    exit(1);
  }

  stdout.writeln(
      'every load ground, all 9,990 four-digit numbers whose '
      'digits vary: the forward walk and the table built '
      'backwards from the stone agree on every one, every road '
      'ends by the seventh turn, 6174 alone stands still, and '
      'the ten repdigits collapse to nought at one grind');
  stdout.writeln('');

  for (var number = 0; number < Loads.count; number++) {
    final load = Loads.at(number);
    final name = load.name.padRight(18);
    stdout.writeln(load.winnable
        ? ' ${number + 1} $name ${load.task}: ${load.ways} '
            'load${load.ways == 1 ? '' : 's'} of the sweep '
            'land${load.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${load.task}: none of the '
            '9,990, and the seventh turn said so first');
  }
}
