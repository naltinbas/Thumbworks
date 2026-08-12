import 'dart:io';

import 'package:sashmoor/pane/rules.dart';
import 'package:sashmoor/pane/sashes.dart';

/// Counts every window two ways over every placing, and refuses
/// the bake on any disagreement: this is what `make panes` runs,
/// and the README quotes its ledger verbatim.
void main() {
  final small = Rules(3, 3);
  final big = Rules(4, 4);

  // The whole sweep: both counts held together on every placing.
  for (final (rules, counts) in [
    (small, [5, 6, 7]),
    (big, [8, 9, 10]),
  ]) {
    for (final count in counts) {
      if (!rules.countsAgree(count)) {
        stderr.writeln('THE TWO COUNTS PARTED AT $count PANES ON '
            '${rules.across}x${rules.down}');
        exit(1);
      }
    }
  }

  for (final sash in Sashes.all) {
    final rules = Rules(sash.across, sash.down);
    final ways = rules.waysTo(sash.count);
    if (ways != sash.ways) {
      stderr.writeln('${sash.name}: sweep finds $ways, '
          'label says ${sash.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  if (small.waysTo(7) != 0 || small.fewestSpend(7) != 5 ||
      small.rowPairs != 3) {
    stderr.writeln('THE SEVENTH PANE CREPT IN');
    exit(1);
  }
  if (big.fewestSpend(8) != 4 ||
      big.fewestSpend(9) != 6 ||
      big.fewestSpend(10) != 8 ||
      big.rowPairs != 6) {
    stderr.writeln('THE ROW-PAIR ARITHMETIC BROKE');
    exit(1);
  }
  // Every window-free nine spends all six row-pairs exactly.
  var nineSound = true;
  big.placings(9, (panes) {
    if (big.windowFree(panes) && big.rowPairsSpent(panes) != 6) {
      nineSound = false;
    }
  });
  if (!nineSound) {
    stderr.writeln('A NINE WITH SLACK');
    exit(1);
  }

  stdout.writeln(
      'every placing of five, six and seven panes on the little '
      'sash and eight, nine and ten on the big one, all 32,564: '
      'windows counted down the columns and across the rows agree '
      'on every placing, ten panes must spend eight row-pairs '
      'where the sash owns six, and every window-free nine spends '
      'all six exactly');
  stdout.writeln('');

  for (var number = 0; number < Sashes.count; number++) {
    final sash = Sashes.at(number);
    final name = sash.name.padRight(16);
    stdout.writeln(sash.winnable
        ? ' ${number + 1} $name ${sash.task}: '
            '${withComma(sash.ways)} placings of the sweep land it'
        : ' ${number + 1} $name ${sash.task}: no placing does, by '
            'the sweep and by arithmetic both');
  }
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}
