import 'dart:io';

import 'package:peckthorne/peck/flocks.dart';
import 'package:peckthorne/peck/rules.dart';

/// Settles every pecking there is, counts every crown twice,
/// holds every law, and refuses the bake on any disagreement:
/// this is what `make pecks` runs, and the README quotes its
/// ledger verbatim.
void main() {
  for (final flock in Flocks.all) {
    final ways = Rules(flock.chickens).waysTo(flock.asked);
    if (ways != flock.ways) {
      stderr.writeln('${flock.name}: sweep finds $ways, '
          'label says ${flock.ways}');
      exit(1);
    }
  }

  // The laws, over every pecking of every yard size shipped:
  // both crown counts agree, the busiest pecker is crowned, a
  // lone king is an emperor and the other way round, and no
  // pecking crowns exactly two.
  for (final size in [3, 4, 5]) {
    if (!Rules(size).lawsHold()) {
      stderr.writeln('A LAW BROKE AT $size CHICKENS');
      exit(1);
    }
  }

  // The spreads, pinned whole.
  if ('${Rules(3).spread()}' != '{1: 6, 3: 2}') {
    stderr.writeln('THE THREES MOVED: ${Rules(3).spread()}');
    exit(1);
  }
  if ('${Rules(4).spread()}' != '{1: 32, 3: 32}') {
    stderr.writeln('THE FOURS MOVED: ${Rules(4).spread()}');
    exit(1);
  }
  final fives = Rules(5).spread();
  if (fives[1] != 320 ||
      fives[3] != 520 ||
      fives[4] != 120 ||
      fives[5] != 64 ||
      fives.length != 4) {
    stderr.writeln('THE FIVES MOVED: $fives');
    exit(1);
  }

  // No pecking of four crowns everybody.
  if (Rules(4).waysTo(4) != 0) {
    stderr.writeln('A FULL COURT OF FOUR APPEARED');
    exit(1);
  }

  // The mark is real: the round pecking of five crowns all.
  final rules = Rules(5);
  final round = [
    for (final (a, b) in rules.pairs) !(b - a == 1 || b - a == 2),
  ];
  if (rules.kings(round).length != 5) {
    stderr.writeln('THE MARK LOST ITS CROWNS');
    exit(1);
  }

  stdout.writeln(
      'every pecking of every yard settled, 8 and 64 and 1,024: '
      'the two crown counts agree on all of them, the busiest '
      'pecker is crowned in each, a lone king is always an '
      'emperor and an emperor always alone, no pecking of four '
      'crowns four, and none anywhere crowns exactly two');
  stdout.writeln('');

  for (var number = 0; number < Flocks.count; number++) {
    final flock = Flocks.at(number);
    final name = flock.name.padRight(18);
    stdout.writeln(flock.winnable
        ? ' ${number + 1} $name ${flock.task}: ${flock.ways} '
            'pecking${flock.ways == 1 ? '' : 's'} of the sweep '
            'land${flock.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${flock.task}: none of the 64, '
            'and the crown count is barred from two everywhere');
  }
}
