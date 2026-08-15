import 'dart:io';

import 'package:loafham/loaf/fraction.dart';
import 'package:loafham/loaf/loaves.dart';
import 'package:loafham/loaf/rules.dart';

/// Tries every set of cuts on the board for every share, runs the
/// greedy cut, and refuses the bake on any disagreement: this is
/// what `make loaves` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final loaf in Loaves.all) {
    final ways = Rules(loaf.share).waysBySweep(loaf.cuts);
    if (ways != loaf.ways) {
      stderr.writeln('${loaf.name}: sweep finds $ways, label says ${loaf.ways}');
      exit(1);
    }
  }

  // The named cuts, and the greedy cut against the sweep.
  const named = {
    '2/3:2': '[[2, 6]]',
    '4/5:3': '[[2, 4, 20], [2, 5, 10]]',
    '9/10:3': '[[2, 3, 15]]',
    '5/7:3': '[[2, 6, 21], [2, 7, 14]]',
  };
  for (final entry in named.entries) {
    final parts = entry.key.split(':');
    final share = Fraction(int.parse(parts[0].split('/')[0]), int.parse(parts[0].split('/')[1]));
    final found = Rules(share).waysWith(int.parse(parts[1]));
    if ('$found' != entry.value) {
      stderr.writeln('THE CUTS OF ${entry.key} MOVED: $found');
      exit(1);
    }
  }
  const greedyWant = {
    '2/3': '[2, 6]',
    '4/5': '[2, 4, 20]',
    '9/10': '[2, 3, 15]',
    '5/7': '[2, 5, 70]',
  };
  for (final entry in greedyWant.entries) {
    final p = entry.key.split('/');
    final got = Rules.greedy(Fraction(int.parse(p[0]), int.parse(p[1])));
    if ('$got' != entry.value) {
      stderr.writeln('THE GREEDY CUT OF ${entry.key} MOVED: $got');
      exit(1);
    }
    if (Rules.sumOf(got) != Fraction(int.parse(p[0]), int.parse(p[1]))) {
      stderr.writeln('THE GREEDY CUT OF ${entry.key} DOES NOT ADD UP');
      exit(1);
    }
  }

  // Fibonacci's method ends on every share with a bottom of twelve
  // or less, in four cuts at most, and its cuts are always distinct
  // and add up.
  var longest = 0;
  for (var den = 2; den <= 12; den++) {
    for (var num = 1; num < den; num++) {
      final share = Fraction(num, den);
      final cuts = Rules.greedy(share);
      if (cuts.toSet().length != cuts.length || Rules.sumOf(cuts) != share) {
        stderr.writeln('THE GREEDY CUT FAILED ON $share: $cuts');
        exit(1);
      }
      if (cuts.length > longest) longest = cuts.length;
      // Where every greedy cut sits on the board, the sweep holds it.
      if (cuts.every((d) => d <= 24)) {
        final found = Rules(share).waysWith(cuts.length);
        if (!found.any((f) => '$f' == '$cuts')) {
          stderr.writeln('THE SWEEP MISSED THE GREEDY CUT OF $share');
          exit(1);
        }
      }
    }
  }
  if (longest != 4) {
    stderr.writeln('THE LONGEST GREEDY CUT IS $longest');
    exit(1);
  }

  // The two cuts: with a half, three tenths are left and no cut is
  // three tenths; without, a third and a quarter are the most, and
  // that is seven twelfths.
  final fourFifths = Fraction(4, 5);
  if (fourFifths - Fraction(1, 2) != Fraction(3, 10) ||
      Fraction(3, 10).isUnit ||
      Fraction(1, 3) + Fraction(1, 4) != Fraction(7, 12) ||
      !(Fraction(7, 12) < fourFifths) ||
      Rules(fourFifths).waysWith(2).isNotEmpty ||
      Rules(fourFifths, largest: 200).waysWith(2).isNotEmpty) {
    stderr.writeln('THE TWO CUTS MOVED');
    exit(1);
  }

  stdout.writeln(
      'every set of cuts from a half to a twenty-fourth tried on every '
      'share: two of three comes only as a half and a sixth, four of '
      'five two ways in three cuts and never in two, since a half leaves '
      'three tenths and no half leaves seven twelfths at the most, nine '
      'of ten one way, five of seven two ways though the greedy cut '
      'wants a seventieth, and Fibonacci\'s method ends in four cuts at '
      'most on every share with a bottom of twelve or less');
  stdout.writeln('');

  for (var number = 0; number < Loaves.count; number++) {
    final loaf = Loaves.at(number);
    final name = loaf.name.padRight(18);
    stdout.writeln(loaf.winnable
        ? ' ${number + 1} $name ${loaf.task}: ${loaf.ways} '
            'set${loaf.ways == 1 ? '' : 's'} of cuts of the sweep '
            'make${loaf.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${loaf.task}: none on the board nor '
            'off it, and the three tenths said so first');
  }
}
