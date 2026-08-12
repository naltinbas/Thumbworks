import 'dart:io';

import 'package:marrowden/show/rules.dart';
import 'package:marrowden/show/shows.dart';

/// Walks every sitting of every bench, sweeps every rule where the
/// bench is short enough to hold them all, and refuses the bake on
/// any disagreement: this is what `make shows` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // The fork that puts certainty off the bench: two sittings that
  // open identically, the best in different seats.
  const forkA = [3, 2, 1, 0];
  const forkB = [2, 3, 1, 0];
  if (forkA.indexOf(3) != 0 || forkB.indexOf(3) != 1) {
    stderr.writeln('THE FORK IS BENT');
    exit(1);
  }

  // The note-claims, each recomputed.
  final firstBlind = Rules.allSittings(4)
      .where((sitting) => sitting.first == 3)
      .length;
  if (firstBlind != 6 ||
      Rules.winsOfCutoff(5, 1) != 50 ||
      Rules.winsOfCutoff(6, 3) != 282 ||
      Rules.winsOfCutoff(7, 3) != 2052) {
    stderr.writeln('A NOTE-CLAIM BROKE');
    exit(1);
  }

  stdout.writeln(
      'the wave-them-by rule against every sitting of the bench, '
      'and against every rank-based rule where the sweep can hold '
      'them all; two sittings open alike with the best in '
      'different seats, so no rule of any kind lands it every '
      'time');
  stdout.writeln('');

  for (var number = 0; number < Shows.count; number++) {
    final show = Shows.at(number);

    if (Rules.factorial(show.marrows) != show.of ||
        Rules.bestSkip(show.marrows) != show.skip ||
        Rules.winsOfCutoff(show.marrows, show.skip) != show.wins) {
      stderr.writeln('${show.name}: the rule disagrees');
      exit(1);
    }
    final swept = show.swept;
    if (swept != null) {
      if (Rules.rulesOf(show.marrows) != swept ||
          Rules.ceiling(show.marrows) != show.wins) {
        stderr.writeln('${show.name}: the sweep disagrees');
        exit(1);
      }
    }

    final name = show.name.padRight(16);
    final line = show.sure
        ? 'land the best every sitting: no rule does, '
            '${show.wins} of ${show.of} being the ceiling of all '
            '${show.swept}'
        : 'wave ${show.skip} by: the best lands ${show.wins} of '
            '${show.of} sittings'
            '${swept != null ? ', and none of the $swept rules beats it' : ''}';
    stdout.writeln(
        ' ${number + 1} $name ${show.marrows} marrows  $line');
  }
}
