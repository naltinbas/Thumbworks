import 'dart:io';

import 'package:pigeonwick/post/rounds.dart';
import 'package:pigeonwick/post/rules.dart';

/// Posts every round, runs the recurrence, divides by e, and
/// refuses the bake on any disagreement: this is what
/// `make letters` runs, and the README quotes its ledger verbatim.
void main() {
  // Three voices on the deranged counts, every size shipped.
  for (final letters in [3, 4, 5]) {
    final swept = Rules(letters).waysTo(0);
    if (swept != Rules.deranged(letters) ||
        swept != Rules.byE(letters)) {
      stderr.writeln('THE VOICES PARTED AT $letters: sweep '
          '$swept, recurrence ${Rules.deranged(letters)}, '
          'by e ${Rules.byE(letters)}');
      exit(1);
    }
  }

  for (final round in Rounds.all) {
    final ways = Rules(round.letters).waysTo(round.home);
    if (ways != round.ways) {
      stderr.writeln('${round.name}: sweep finds $ways, '
          'label says ${round.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final four = Rules(4);
  if (four.waysTo(0) != 9 ||
      four.waysTo(1) != 8 ||
      four.waysTo(2) != 6 ||
      four.waysTo(3) != 0 ||
      four.waysTo(4) != 1) {
    stderr.writeln('THE SPREAD OF FOUR MOVED');
    exit(1);
  }
  if (four.waysTo(1) != 4 * Rules.deranged(3)) {
    stderr.writeln('THE ONE HOME LOST ITS ARITHMETIC');
    exit(1);
  }
  // Exactly letters-less-one home is nobody's round, every size.
  for (final letters in [3, 4, 5]) {
    if (Rules(letters).waysTo(letters - 1) != 0) {
      stderr.writeln('A ROUND WITH ${letters - 1} HOME '
          'OF $letters');
      exit(1);
    }
  }

  stdout.writeln(
      'every round of the post swept, 6 and 24 and 120 by size: '
      'the deranged counts 2, 9 and 44 come out of the sweep, '
      'the recurrence and the figure by e alike, the spread of '
      'four runs 9, 8, 6, none, 1, and one shy of all home is '
      'nobody\'s round at any size');
  stdout.writeln('');

  for (var number = 0; number < Rounds.count; number++) {
    final round = Rounds.at(number);
    final name = round.name.padRight(18);
    stdout.writeln(round.winnable
        ? ' ${number + 1} $name ${round.task}: ${round.ways} '
            'round${round.ways == 1 ? '' : 's'} of the sweep '
            'land${round.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${round.task}: none of the 24, '
            'since three home leaves the fourth only its own '
            'hole');
  }
}
