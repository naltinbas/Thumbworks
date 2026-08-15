import 'dart:io';

import 'package:ledgeworth/stack/levels.dart';
import 'package:ledgeworth/stack/rules.dart';

/// Sweeps every stack on the grid, holds the harmonic stack to the
/// sweep, and refuses the bake on any disagreement: this is what
/// `make stacks` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and the harmonic stack
  // standing with the reach the arithmetic says.
  final bests = <int>[];
  for (final level in Levels.all) {
    final (ways, all, best) = Rules.sweep(level.books, level.asked);
    if (ways != level.ways || all != level.stacks) {
      stderr.writeln('${level.name}: sweep finds $ways of $all, label says ${level.ways} of ${level.stacks}');
      exit(1);
    }
    final harmonic = Rules.harmonic(level.books);
    if (!Rules.stands(harmonic)) {
      stderr.writeln('${level.name}: THE HARMONIC STACK TOPPLES');
      exit(1);
    }
    // On the grid the harmonic stack reaches the sweep's best.
    if (Rules.overhang(harmonic) != best) {
      stderr.writeln('${level.name}: harmonic reaches ${Rules.overhang(harmonic)}, the sweep\'s best is $best');
      exit(1);
    }
    bests.add(best);
  }
  if ('$bests' != '[12, 18, 25, 27, 22]') {
    stderr.writeln('THE BESTS MOVED: $bests');
    exit(1);
  }

  // The harmonic overhang exactly, for one to eight books, and its
  // twenty-fourths rounded down are the grid stack's reach for one to
  // five; three books never reach a whole book, four do.
  const exact = [(1, 2), (3, 4), (11, 12), (25, 24), (137, 120), (49, 40), (363, 280), (761, 560)];
  for (var n = 1; n <= 8; n++) {
    final (num, den) = Rules.harmonicOverhang(n);
    if ((num, den) != exact[n - 1]) {
      stderr.writeln('$n BOOKS: harmonic overhang $num/$den, expected ${exact[n - 1]}');
      exit(1);
    }
    if (n <= 5 && Rules.overhang(Rules.harmonic(n)) != (num * Rules.grain) ~/ den) {
      stderr.writeln('$n BOOKS: grid harmonic ${Rules.overhang(Rules.harmonic(n))}, exact floor ${(num * Rules.grain) ~/ den}');
      exit(1);
    }
  }
  if (Rules.harmonicOverhang(3).$1 >= Rules.harmonicOverhang(3).$2 ||
      Rules.harmonicOverhang(4).$1 < Rules.harmonicOverhang(4).$2) {
    stderr.writeln('THREE REACH OR FOUR FALL SHORT');
    exit(1);
  }

  // The topple reads level by level: nudge any book of the harmonic
  // stack of five one twenty-fourth further and it topples at that
  // book's level.
  final five = Rules.harmonic(5);
  for (var i = 0; i < 5; i++) {
    final pushed = List.of(five)..[i] += 1;
    if (Rules.topples(pushed) != i + 1) {
      stderr.writeln('PUSHING BOOK ${i + 1} TOPPLES AT ${Rules.topples(pushed)}');
      exit(1);
    }
  }
  // Nudged one back, it stands, and reaches one less.
  for (var i = 0; i < 5; i++) {
    final eased = List.of(five)..[i] -= 1;
    if (!Rules.stands(eased) || Rules.overhang(eased) != 26) {
      stderr.writeln('EASING BOOK ${i + 1} FAILS');
      exit(1);
    }
  }

  stdout.writeln(
      'every stack of one to five books on the twenty-fourths swept, '
      '25 and 625 and 15,625 and 390,625 and 9,765,625 of them, each read '
      'for standing level by level and for reach: the best standing stack '
      'hangs out 12, 18, 22, 25 and 27 twenty-fourths, which is the '
      'harmonic stack every time, half plus a quarter plus a sixth and on, '
      'rounded down to the grid, and the harmonic overhang exact is 1/2, '
      '3/4, 11/12, 25/24, 137/120 of a book for one to five, so three '
      'books never reach a whole book and four do; and every book of the '
      'harmonic five topples the stack at its own level when pushed one '
      'twenty-fourth further');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(9);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.stacks)} stacks on the grid land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.stacks)}, and eleven twelfths said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
