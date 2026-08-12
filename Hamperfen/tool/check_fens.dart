import 'dart:io';

import 'package:hamperfen/basket/fens.dart';
import 'package:hamperfen/basket/rules.dart';

/// Weighs every pair, sweeps every family, shelves the middle,
/// and refuses the bake on any disagreement: this is what
/// `make baskets` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final fen in Fens.all) {
    final ways = Rules.waysTo(fen.take);
    if (ways != fen.ways) {
      stderr.writeln('${fen.name}: sweep finds $ways, '
          'label says ${fen.ways}');
      exit(1);
    }
  }

  // The shelf weighing, over every family to seven.
  if (!Rules.lymHolds()) {
    stderr.writeln('THE WEIGHING BROKE');
    exit(1);
  }
  // The six is the middle shelf and nothing else.
  final six = Rules.family(6)!;
  if (six.any((basket) => Rules.herbs(basket) != 2) ||
      Rules.waysTo(6) != 1) {
    stderr.writeln('THE SIX LEFT THE MIDDLE SHELF');
    exit(1);
  }
  // Every free five is the middle shelf less one.
  var fives = true;
  Rules.families(5, (family) {
    if (!Rules.free(family)) return;
    if (family.any((basket) => Rules.herbs(basket) != 2)) {
      fives = false;
    }
  });
  if (!fives) {
    stderr.writeln('A FIVE OFF THE MIDDLE SHELF');
    exit(1);
  }

  stdout.writeln(
      'every family on the shelf swept, pairs to sevens: the '
      'free counts run 55, 64, 25, 6, 1 and none, the one '
      'family of six is the middle shelf entire, every free '
      'five is that shelf less a basket, and the weighing holds '
      'at twelve twelfths with twelve only ever a whole shelf');
  stdout.writeln('');

  for (var number = 0; number < Fens.count; number++) {
    final fen = Fens.at(number);
    final name = fen.name.padRight(14);
    stdout.writeln(fen.winnable
        ? ' ${number + 1} $name ${fen.task}: ${fen.ways} '
            'famil${fen.ways == 1 ? 'y' : 'ies'} of the sweep '
            'land${fen.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${fen.task}: none of the '
            '11,440, and the weighing said so first');
  }
}
