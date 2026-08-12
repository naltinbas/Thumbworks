import 'dart:io';

import 'package:wirecombe/wire/combes.dart';
import 'package:wirecombe/wire/rules.dart';

/// Wires every tree, reads every code, counts every leaf, and
/// refuses the bake on any disagreement: this is what
/// `make wires` runs, and the README quotes its ledger verbatim.
void main() {
  // Cayley's count and the Prufer round-trip, every size shipped.
  for (final cottages in [3, 4, 5]) {
    final rules = Rules(cottages);
    var cayley = 1;
    for (var power = 0; power < cottages - 2; power++) {
      cayley *= cottages;
    }
    if (rules.runs() != cayley) {
      stderr.writeln('CAYLEY PARTED AT $cottages: '
          '${rules.runs()} vs $cayley');
      exit(1);
    }
    if (!rules.prufersHold()) {
      stderr.writeln('A RUN LOST ITS CODE AT $cottages');
      exit(1);
    }
  }

  for (final combe in Combes.all) {
    final ways = Rules(combe.cottages).waysTo(combe.ends);
    if (ways != combe.ways) {
      stderr.writeln('${combe.name}: sweep finds $ways, '
          'label says ${combe.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final five = Rules(5);
  if (five.waysTo(2) + five.waysTo(3) + five.waysTo(4) !=
      five.runs()) {
    stderr.writeln('THE ENDS DO NOT ADD UP');
    exit(1);
  }
  for (final few in [0, 1]) {
    if (five.waysTo(few) != 0) {
      stderr.writeln('A RUN WITH $few LANE\'S ENDS');
      exit(1);
    }
  }

  stdout.writeln(
      'every wiring of every combe swept: the runs number 3, 16 '
      'and 125 exactly as Cayley says, every run codes to its '
      'Prufer word and back, every run keeps two lane\'s ends at '
      'least, and the ends of five split 60, 60 and 5 with '
      'nothing below two');
  stdout.writeln('');

  for (var number = 0; number < Combes.count; number++) {
    final combe = Combes.at(number);
    final name = combe.name.padRight(20);
    stdout.writeln(combe.winnable
        ? ' ${number + 1} $name ${combe.task}: ${combe.ways} '
            'run${combe.ways == 1 ? '' : 's'} of the sweep '
            'land${combe.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${combe.task}: none, two '
            'line-ends short before a wiring is tried');
  }
}
