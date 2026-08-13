import 'dart:io';

import 'package:clinkfield/clink/feasts.dart';
import 'package:clinkfield/clink/rules.dart';

/// Raises every feast there is, holds the wallflower law and
/// the spreads, and refuses the bake on any disagreement: this
/// is what `make clinks` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final feast in Feasts.all) {
    final ways = Rules(feast.guests).waysTo(feast.asked);
    if (ways != feast.ways) {
      stderr.writeln('${feast.name}: sweep finds $ways, '
          'label says ${feast.ways}');
      exit(1);
    }
  }


  // The laws over both tables.
  if (!Rules(4).lawsHold() || !Rules(5).lawsHold()) {
    stderr.writeln('A LAW BROKE');
    exit(1);
  }

  // The spreads, pinned whole.
  if ('${Rules(4).spread()}' != '{1: 8, 2: 32, 3: 24}') {
    stderr.writeln('THE FOURS MOVED: ${Rules(4).spread()}');
    exit(1);
  }
  if ('${Rules(5).spread()}' != '{1: 14, 2: 310, 3: 580, 4: 120}') {
    stderr.writeln('THE FIVES MOVED: ${Rules(5).spread()}');
    exit(1);
  }

  // The fourteen level feasts of five: silent, full, and the
  // twelve rings.
  final five = Rules(5);
  var rings = 0;
  var silent = 0;
  var full = 0;
  five.feasts((clinked) {
    if (five.distinct(clinked) != 1) return;
    final count = five.counts(clinked).first;
    if (count == 0) silent++;
    if (count == 4) full++;
    if (count == 2) rings++;
  });
  if (silent != 1 || full != 1 || rings != 12) {
    stderr.writeln('THE LEVEL FEASTS MOVED: $silent $full $rings');
    exit(1);
  }

  stdout.writeln(
      'every feast raised, the 64 of four guests and the 1,024 '
      'of five: the counts never all differ at either table, '
      'the wallflower and the toast of the table never share a '
      'feast, and the fourteen level feasts of five are the '
      'silent one, the full one and the twelve rings');
  stdout.writeln('');

  for (var number = 0; number < Feasts.count; number++) {
    final feast = Feasts.at(number);
    final name = feast.name.padRight(18);
    stdout.writeln(feast.winnable
        ? ' ${number + 1} $name ${feast.task}: ${feast.ways} '
            'feast${feast.ways == 1 ? '' : 's'} of the sweep '
            'land${feast.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${feast.task}: none of the '
            '1,024, and the wallflower said so first');
  }
}
