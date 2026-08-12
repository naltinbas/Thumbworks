import 'dart:io';

import 'package:greetley/shake/lawns.dart';
import 'package:greetley/shake/rules.dart';

/// Counts every hand, doubles every shake, sweeps every lawn, and
/// refuses the bake on any disagreement: this is what
/// `make shakes` runs, and the README quotes its ledger verbatim.
void main() {
  // The doubling and the even law over every lawn shipped.
  for (final guests in [4, 5]) {
    if (!Rules(guests).lawHolds()) {
      stderr.writeln('THE LAW BROKE AT $guests GUESTS');
      exit(1);
    }
  }

  for (final fete in Lawns.all) {
    final ways = Rules(fete.guests).waysTo(fete.asked);
    if (ways != fete.ways) {
      stderr.writeln('${fete.name}: sweep finds $ways, '
          'label says ${fete.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final four = Rules(4);
  if ([for (final odd in [0, 1, 2, 3, 4]) four.waysTo(odd)]
          .join(',') !=
      '8,0,48,0,8') {
    stderr.writeln('THE SPREAD OF FOUR MOVED');
    exit(1);
  }
  // The all-even lawns come to two to the spare shakes.
  for (final guests in [4, 5]) {
    final spare =
        guests * (guests - 1) ~/ 2 - (guests - 1);
    if (Rules(guests).waysTo(0) != (1 << spare)) {
      stderr.writeln('THE POWER OF TWO FAILED AT $guests');
      exit(1);
    }
  }
  final five = Rules(5);
  if (five.waysTo(4) != 5 * five.waysTo(0)) {
    stderr.writeln('THE FOUR ODD LOST ITS FIVES');
    exit(1);
  }

  stdout.writeln(
      'every lawn of four and five guests swept, 64 and 1,024 of '
      'them: the hand total doubles the shakes on every one, the '
      'odd-handed never number odd, the all-even lawns come to '
      'two to the spare shakes, 8 and 64, and the spread of four '
      'runs 8, none, 48, none, 8');
  stdout.writeln('');

  for (var number = 0; number < Lawns.count; number++) {
    final fete = Lawns.at(number);
    final name = fete.name.padRight(20);
    stdout.writeln(fete.winnable
        ? ' ${number + 1} $name ${fete.task}: ${fete.ways} '
            'lawn${fete.ways == 1 ? '' : 's'} of the sweep '
            'land${fete.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${fete.task}: none of the 64, '
            'since every shake hands out two');
  }
}
