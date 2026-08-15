import 'dart:io';

import 'package:riffleford/deck/riffles.dart';
import 'package:riffleford/deck/rules.dart';

/// Deals every full riffle of every deck, holds the counts to the
/// arithmetic and the tops-differ walk to the sweep, and refuses
/// the bake on any disagreement: this is what `make riffles` runs,
/// and the README quotes its ledger verbatim.
void main() {
  for (final riffle in Riffles.all) {
    final rules = Rules(riffle.deck, cut: riffle.cut, turned: riffle.turned, kinds: riffle.kinds);
    final (all, mixed) = rules.sweep();
    final ways = riffle.wantMixed ? mixed : all - mixed;
    if (all != riffle.riffles || ways != riffle.ways || rules.riffleCount() != all) {
      stderr.writeln('${riffle.name}: sweep finds $ways of $all '
          '(arithmetic ${rules.riffleCount()}), label says ${riffle.ways} of ${riffle.riffles}');
      exit(1);
    }
  }

  // The turned decks: the piles read the pattern in opposite
  // directions and their tops differ at every pair's start, along
  // every riffle; the unturned even cut does neither.
  for (final riffle in Riffles.all) {
    final rules = Rules(riffle.deck, cut: riffle.cut, turned: riffle.turned, kinds: riffle.kinds);
    if (riffle.turned != rules.readOppositeWays()) {
      stderr.writeln('${riffle.name}: reads opposite ways ${rules.readOppositeWays()}');
      exit(1);
    }
    if (riffle.kinds == 2 && riffle.turned != rules.topsDifferAlways()) {
      stderr.writeln('${riffle.name}: tops differ ${rules.topsDifferAlways()}');
      exit(1);
    }
  }
  // The odd cut unturned reads the same as turned, so it lands
  // every riffle as well; the even cut unturned lands six, all of
  // them dealing the deck back as it was.
  final oddUnturned = Rules('RBRBRBRB', cut: 3, turned: false, kinds: 2);
  if (oddUnturned.sweep() != (56, 56)) {
    stderr.writeln('THE ODD CUT UNTURNED MOVED: ${oddUnturned.sweep()}');
    exit(1);
  }
  final evenUnturned = Rules('RBRBRBRB', cut: 4, turned: false, kinds: 2);
  var six = 0;
  evenUnturned.riffles((drops) {
    if (evenUnturned.allMixed(drops)) {
      six++;
      if (evenUnturned.dealt(drops) != 'RBRBRBRB') {
        stderr.writeln('AN UNTURNED LANDING DEALT ${evenUnturned.dealt(drops)}');
        exit(1);
      }
    }
  });
  if (six != 6) {
    stderr.writeln('THE UNTURNED SIX MOVED: $six');
    exit(1);
  }
  // Longer decks and every cut: the principle holds for two kinds
  // on twelve cards at every cut, and for three kinds on nine at
  // every cut, the packet turned.
  for (var cut = 1; cut < 12; cut++) {
    final rules = Rules('RBRBRBRBRBRB', cut: cut, turned: true, kinds: 2);
    final (all, mixed) = rules.sweep();
    if (all != mixed || all != rules.riffleCount() || !rules.topsDifferAlways()) {
      stderr.writeln('TWELVE CARDS CUT $cut: $mixed OF $all');
      exit(1);
    }
  }
  for (var cut = 1; cut < 9; cut++) {
    final rules = Rules('RBGRBGRBG', cut: cut, turned: true, kinds: 3);
    final (all, mixed) = rules.sweep();
    if (all != mixed || !rules.readOppositeWays()) {
      stderr.writeln('THREE KINDS CUT $cut: $mixed OF $all');
      exit(1);
    }
  }

  stdout.writeln(
      'every full riffle of every deck dealt and every block read: with '
      'the packet turned every one of the 56, 70 and 126 riffles deals '
      'every pair or triple mixed, and every cut of a twelve-card deck of '
      'two kinds and a nine-card deck of three besides, since the piles '
      'read the pattern in opposite directions and their tops differ at '
      'every pair\'s start; the even cut with the packet not turned lands '
      '6 riffles of 70, all dealing the deck back as it was, and no '
      'riffle of the turned odd cut ever pairs two reds');
  stdout.writeln('');

  for (var number = 0; number < Riffles.count; number++) {
    final riffle = Riffles.at(number);
    final name = riffle.name.padRight(20);
    stdout.writeln(riffle.winnable
        ? ' ${number + 1} $name ${riffle.task}: ${riffle.ways} riffle${riffle.ways == 1 ? '' : 's'} '
            'of the ${riffle.riffles} land${riffle.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${riffle.task}: none of the ${riffle.riffles}, '
            'and the tops said so first');
  }
}
