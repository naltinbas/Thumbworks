import 'dart:io';

import 'package:cutmere/cellar/levels.dart';
import 'package:cutmere/cellar/rules.dart';

/// Walks the game tree for every row up to two hundred casks, holds the
/// bound to it, sweeps every first cut, and refuses the bake on any
/// disagreement: this is what `make cuts` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the sweep and the tree.
  for (final level in Levels.all) {
    final (winning, all) = Rules.sweep(level.casks, level.questions);
    if (winning != level.ways || all != level.cuts) {
      stderr.writeln('${level.name}: sweep finds $winning of $all, label says ${level.ways} of ${level.cuts}');
      exit(1);
    }
    if ((Rules.questions(level.casks) <= level.questions) != level.winnable) {
      stderr.writeln('${level.name}: the tree wants ${Rules.questions(level.casks)}, allowed ${level.questions}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
    if (level.winnable) {
      final (bigger, _) = Rules.kept(level.casks, Rules.middle(level.casks));
      if (Rules.questions(bigger) > level.questions - 1) {
        stderr.writeln('${level.name}: THE MIDDLE CUT FAILS');
        exit(1);
      }
    }
  }

  // Every row up to two hundred: the tree's fewest questions is the
  // bound, the least k with 2 to the k at least the casks; the middle
  // cut is always a best cut; and 2 to the k casks want k while one
  // more wants k plus one.
  var rows = 0;
  for (var n = 1; n <= 200; n++) {
    rows++;
    if (Rules.questions(n) != Rules.bound(n)) {
      stderr.writeln('$n CASKS: the tree wants ${Rules.questions(n)}, the bound says ${Rules.bound(n)}');
      exit(1);
    }
    if (n > 1) {
      final (bigger, _) = Rules.kept(n, Rules.middle(n));
      if (1 + Rules.questions(bigger) != Rules.questions(n)) {
        stderr.writeln('$n CASKS: THE MIDDLE CUT IS NOT BEST');
        exit(1);
      }
    }
  }
  for (var k = 0; k <= 7; k++) {
    final n = 1 << k;
    if (Rules.questions(n) != k || Rules.questions(n + 1) != k + 1) {
      stderr.writeln('$n CASKS WANT ${Rules.questions(n)}, $n + 1 WANT ${Rules.questions(n + 1)}');
      exit(1);
    }
  }

  stdout.writeln(
      'the game tree walked for every row from one to two hundred casks, the '
      'cellarman keeping the bigger part at every cut, $rows rows: the fewest '
      'questions that serve is the least k with 2 to the k at least the casks, '
      'the bound, on every row, since k questions have 2 to the k answers; the '
      'middle cut is a best first cut every time; 1, 2, 4, 8, 16, 32, 64 and 128 '
      'casks want 0, 1, 2, 3, 4, 5, 6 and 7 questions and one more cask wants one '
      'more; and every first cut swept for the cellars on the sham, eight in '
      'three by 1 cut of 7, sixteen in four by 1 of 15, twenty in five by 13 of '
      '19, a hundred in seven by 29 of 99, and nine in three by none of 8');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(12);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} first cut${level.ways == 1 ? '' : 's'} of the ${level.cuts} serve${level.ways == 1 ? 's' : ''}'
        : ' ${number + 1} $name ${level.task}: none of the ${level.cuts}, and the answers said so first');
  }
}
