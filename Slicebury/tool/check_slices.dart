import 'dart:io';

import 'package:slicebury/slice/cakes.dart';
import 'package:slicebury/slice/rules.dart';

/// Sets every pick of every cake, counts the slices two ways,
/// holds the formula and the ceiling, and refuses the bake on
/// any disagreement: this is what `make slices` runs, and the
/// README quotes its ledger verbatim.
void main() {
  for (final cake in Cakes.all) {
    final ways = Rules.waysTo(cake.candles, cake.slices);
    if (ways != cake.ways) {
      stderr.writeln('${cake.name}: sweep finds $ways, '
          'label says ${cake.ways}');
      exit(1);
    }
  }

  // Both counts, the formula, and the six-candle ceiling over
  // every pick there is.
  if (!Rules.lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The doubling below six, total at every count.
  for (final (candles, slices, picks) in [
    (1, 1, 12),
    (2, 2, 66),
    (3, 4, 220),
    (4, 8, 495),
    (5, 16, 792),
  ]) {
    if (Rules.waysTo(candles, slices) != picks) {
      stderr.writeln('THE DOUBLING BROKE AT $candles');
      exit(1);
    }
  }

  // Six candles split thirty-one and thirty, nothing else.
  if (Rules.waysTo(6, 31) + Rules.waysTo(6, 30) != 924) {
    stderr.writeln('A SIX-CANDLE PICK WENT ASTRAY');
    exit(1);
  }

  stdout.writeln(
      'every pick of every cake set, 12 and 66 and 220 and 495 '
      'and 792 and 924 of them, the slices counted by Euler and '
      'by cuts and never apart: the doubling holds to sixteen at '
      'every single pick, six candles cut thirty-one or, where '
      'three lines clump through a point, thirty, and never '
      'thirty-two');
  stdout.writeln('');

  for (var number = 0; number < Cakes.count; number++) {
    final cake = Cakes.at(number);
    final name = cake.name.padRight(18);
    stdout.writeln(cake.winnable
        ? ' ${number + 1} $name ${cake.task}: ${cake.ways} '
            'pick${cake.ways == 1 ? '' : 's'} of the sweep '
            'land${cake.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${cake.task}: none of the 924, '
            'and the ceiling said so first');
  }
}
