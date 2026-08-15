import 'dart:io';

import 'package:pursebury/duel/levels.dart';
import 'package:pursebury/duel/play.dart';
import 'package:pursebury/duel/rules.dart';

/// Sweeps every setting of the purses and the coin, solves every duel
/// as a chain against the formula, and refuses the bake on any
/// disagreement: this is what `make duels` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the sweep, the aim landing it, and no
  // level landed at the opening setting.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != Rules.settings || Rules.settings != 108) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2, aim.$3)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The two voices on every setting: the chain solved against the
  // formula, chance and length; with the fair coin the chance is the
  // share and the length the purses multiplied; the two chances of a
  // duel add to one; and Ash's chance grows with his purse.
  for (var ash = 1; ash <= Rules.most; ash++) {
    for (var birch = 1; birch <= Rules.most; birch++) {
      for (var coin = 0; coin < 3; coin++) {
        final byFormula = Rules.chanceByFormula(ash, birch, coin), byChain = Rules.chainSolved(ash, birch, coin);
        final lastsByFormula = Rules.lastsByFormula(ash, birch, coin), lastsByChain = Rules.chainSolved(ash, birch, coin, tosses: true);
        if (byFormula != byChain || lastsByFormula != lastsByChain) {
          stderr.writeln('$ash V $birch, COIN $coin: FORMULA $byFormula LASTING $lastsByFormula, CHAIN $byChain LASTING $lastsByChain');
          exit(1);
        }
        if (coin == 1 && (byFormula != Frac.of(ash, ash + birch) || lastsByFormula != Frac.of(ash * birch))) {
          stderr.writeln('$ash V $birch FAIR: $byFormula LASTING $lastsByFormula');
          exit(1);
        }
        // Birch's chance is Ash's with the purses swapped and the coin
        // turned, and the two add to one.
        if (byFormula + Rules.chanceByFormula(birch, ash, 2 - coin) != Frac.one) {
          stderr.writeln('$ash V $birch, COIN $coin: THE TWO CHANCES DO NOT ADD TO ONE');
          exit(1);
        }
        if (ash > 1 && byFormula.compareTo(Rules.chanceByFormula(ash - 1, birch, coin)) <= 0) {
          stderr.writeln('$ash V $birch, COIN $coin: A COIN MORE DOES NOT HELP');
          exit(1);
        }
      }
    }
  }

  // The named facts: against the coin, one coin to one is a third and
  // six to one 63/127, the nearest to a half of the 108 and under it;
  // for the coin, one coin each is two thirds; and no chance against the
  // coin is a half, since 2 to the pot less 1 is odd.
  final against = [for (var a = 1; a <= 6; a++) Rules.chanceByFormula(a, 1, 0).toString()];
  if (against.join(', ') != '1/3, 3/7, 7/15, 15/31, 31/63, 63/127') {
    stderr.writeln('AGAINST THE COIN, ONE COIN TO ONE AND UP: $against');
    exit(1);
  }
  Frac? nearest;
  for (var ash = 1; ash <= Rules.most; ash++) {
    for (var birch = 1; birch <= Rules.most; birch++) {
      final c = Rules.chanceByFormula(ash, birch, 0);
      if (c.compareTo(Frac.of(1, 2)) >= 0) {
        stderr.writeln('$ash V $birch AGAINST THE COIN: $c, A HALF OR MORE');
        exit(1);
      }
      if (nearest == null || c.compareTo(nearest) > 0) nearest = c;
      // 2^(a+b) - 1 is odd, and the chance is (2^a - 1) over it; for the
      // coin it is 2^b (2^a - 1) over the same odd number.
      final pot = BigInt.two.pow(ash + birch) - BigInt.one, purse = BigInt.two.pow(ash) - BigInt.one;
      if (pot.isEven || Frac(purse, pot) != c || Frac(BigInt.two.pow(birch) * purse, pot) != Rules.chanceByFormula(ash, birch, 2)) {
        stderr.writeln('$ash V $birch, CROOKED COINS: NOT $purse OVER $pot');
        exit(1);
      }
    }
  }
  if (nearest != Frac.of(63, 127) || Rules.chanceByFormula(1, 1, 2) != Frac.of(2, 3) || Rules.lastsByFormula(2, 2, 2) != Frac.of(18, 5) || Rules.lastsByFormula(3, 1, 0) != Frac.of(17, 5)) {
    stderr.writeln('THE NAMED FACTS ARE OFF: NEAREST $nearest');
    exit(1);
  }

  stdout.writeln(
      'every setting of the two purses and the coin swept, one to six coins each '
      'and the coin against Ash, fair or for him, 108 settings, every duel solved '
      'as a chain of purses in exact fractions and held to the formula, chance '
      'and length both, and the two agree on all 108: with the fair coin Ash '
      'takes the pot as often as his share of it and the duel lasts the purses '
      'multiplied; the two players\' chances add to one and a coin more never '
      'hurts, on all 108; against the coin, one coin to Birch\'s one is 1/3, then '
      '3/7, 7/15, 15/31, 31/63 and 63/127 at six to one, the nearest to a half '
      'of the 108 and under it, every one being 2 to Ash\'s purse less 1 over 2 '
      'to the pot less 1, an odd number under; for the coin, one coin each is '
      '2/3, and two each last 18/5 tosses; and a quarter comes 2 ways, two to '
      'one 4, nine tosses 1, nine in twenty against the coin 4, and the even '
      'duel against the coin never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(31);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${Rules.settings} settings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${Rules.settings}, and the odd number said so first');
  }
}
