import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/play.dart';
import 'package:hazardwell/game/review.dart';
import 'package:hazardwell/game/rules.dart';

void main() {
  group('the rules', () {
    test('two dice pay the total, and double it on a pair', () {
      expect(Rules.paidFor(3, 5), 8);
      expect(Rules.paidFor(4, 4), 16, reason: 'a pair pays twice the total');
      expect(Rules.paidFor(6, 6), 24);
    });

    test('and the payouts the solver is written round add up', () {
      // The solver has the same nine payouts written out in its inner loop,
      // where a list would cost a bounds check fifty million times a sweep.
      // This is what says the two agree.
      final counted = <int, int>{};
      for (var first = 2; first <= Rules.faces; first++) {
        for (var second = 2; second <= Rules.faces; second++) {
          final paid = Rules.paidFor(first, second);
          counted[paid] = (counted[paid] ?? 0) + 1;
        }
      }

      final written = <int, int>{};
      for (var i = 0; i < Rules.boldPays.length; i += 2) {
        written[Rules.boldPays[i]] = Rules.boldPays[i + 1];
      }
      expect(written, counted);
      expect(counted.values.reduce((a, b) => a + b), 25,
          reason: 'twenty five of the thirty six rolls have no one on them');
    });
  });

  group('a throw', () {
    test('pays what it shows', () {
      expect(const Rolled([4]).paid, 4);
      expect(const Rolled([3, 5]).paid, 8);
      expect(const Rolled([5, 5]).paid, 20);
    });

    test('pays nothing at all if a one came up', () {
      expect(const Rolled([1]).bust, isTrue);
      expect(const Rolled([1]).paid, 0);
      expect(const Rolled([1, 6]).bust, isTrue);
      expect(const Rolled([6, 1]).paid, 0);
    });

    test('and two ones take the score with them', () {
      expect(const Rolled([1, 1]).wipes, isTrue);
      expect(const Rolled([1, 6]).wipes, isFalse);
      expect(const Rolled([1]).wipes, isFalse, reason: 'one die cannot wipe');
    });
  });

  group('a game', () {
    test('adds what a throw pays to the turn, and keeps it there', () {
      final play = const Play.start().took(Move.one, const Rolled([5]));
      expect(play.turn, 5);
      expect(play.yours, 0, reason: 'nothing is banked until it is banked');
      expect(play.toMove, Who.you);
    });

    test('hands over on a one, and the turn is lost', () {
      final play = const Play.start()
          .took(Move.one, const Rolled([5]))
          .took(Move.one, const Rolled([1]));
      expect(play.turn, 0);
      expect(play.yours, 0);
      expect(play.toMove, Who.them);
    });

    test('takes the score away on two ones', () {
      var play = const Play.start().took(Move.one, const Rolled([6])).bank();
      play = play.bank();
      expect(play.yours, 6);
      expect(play.toMove, Who.you, reason: 'they banked nothing and handed on');

      play = play.took(Move.two, const Rolled([1, 1]));
      expect(play.yours, 0, reason: 'two ones take everything');
      expect(play.toMove, Who.them);
    });

    test('banks the turn and hands over', () {
      final play = const Play.start()
          .took(Move.two, const Rolled([4, 4]))
          .bank();
      expect(play.yours, 16);
      expect(play.turn, 0);
      expect(play.toMove, Who.them);
    });

    test('is won by banking to the target, and stops there', () {
      var play = const Play(yours: 96, theirs: 40, turn: 0, toMove: Who.you);
      play = play.took(Move.one, const Rolled([5])).bank();

      expect(play.yours, 101);
      expect(play.isOver, isTrue);
      expect(play.won, Who.you);
      expect(play.toMove, Who.you, reason: 'nobody moves after that');
      expect(play.took(Move.one, const Rolled([6])).yours, 101);
    });

    test('and is not won by a turn that has not been banked', () {
      final play = const Play(yours: 96, theirs: 40, turn: 0, toMove: Who.you)
          .took(Move.one, const Rolled([5]));
      expect(play.isOver, isFalse, reason: 'it is still on the table');
      expect(play.won, isNull);
    });
  });

  group('the odds', () {
    late Odds odds;

    setUpAll(() => odds = Odds.reckon());

    test('settle, and say how far they moved last', () {
      expect(odds.drift, lessThan(1e-9));
      expect(odds.sweeps, lessThan(200));
    });

    test('are a fixed point of the rule that made them', () {
      // The proof that the table is right, and the only one there is. Every
      // number in it should be exactly the best its three moves are worth
      // according to the rest of the table. If that holds everywhere, the
      // table is the answer; the sweeps were only a way of finding it.
      final dice = Random(7);
      var worst = 0.0;
      for (var i = 0; i < 20000; i++) {
        final mine = dice.nextInt(Rules.target);
        final theirs = dice.nextInt(Rules.target);
        final turn = dice.nextInt(Rules.target - mine);
        final moved =
            (odds.winning(mine, theirs, turn) -
                    odds.chanceAt(mine, theirs, turn).bestChance)
                .abs();
        if (moved > worst) worst = moved;
      }
      expect(worst, lessThan(1e-9));
    });

    test('give the first player a little the best of it', () {
      // A known number, and one this had better agree with: the player who
      // goes first in a race like this wins about fifty three times in a
      // hundred.
      expect(odds.winning(0, 0, 0), greaterThan(0.5));
      expect(odds.winning(0, 0, 0), lessThan(0.56));
    });

    test('rise with the score and with the turn, and fall with theirs', () {
      for (final turn in [0, 7, 19]) {
        for (var score = 0; score < 80; score += 7) {
          expect(odds.winning(score + 5, 40, turn),
              greaterThan(odds.winning(score, 40, turn)));
          expect(odds.winning(40, score + 5, turn),
              lessThan(odds.winning(40, score, turn)));
        }
      }
      for (var turn = 0; turn < 40; turn++) {
        expect(odds.winning(30, 30, turn + 1),
            greaterThanOrEqualTo(odds.winning(30, 30, turn)));
      }
    });

    test('say the game is over when it is', () {
      expect(odds.winning(80, 10, 20), 1, reason: 'that turn wins by banking');
      expect(odds.winning(10, 100, 0), 0);
    });

    test('never say bank when there is nothing to bank', () {
      // Banking nothing hands the turn over for no gain, and a throw at least
      // might pay. There should not be one position in the whole game where
      // that is the best thing to do.
      for (var mine = 0; mine < Rules.target; mine++) {
        for (var theirs = 0; theirs < Rules.target; theirs++) {
          expect(odds.bestAt(mine, theirs, 0), isNot(Move.bank),
              reason: 'at $mine against $theirs');
        }
      }
    });

    test('use all three moves, and not by a hair', () {
      final used = <Move, int>{};
      for (var mine = 0; mine < Rules.target; mine += 3) {
        for (var theirs = 0; theirs < Rules.target; theirs += 3) {
          for (var turn = 0; turn < Rules.target - mine; turn += 3) {
            final chance = odds.chanceAt(mine, theirs, turn);
            if (chance.gap < 0.001) continue;
            used[chance.best] = (used[chance.best] ?? 0) + 1;
          }
        }
      }
      for (final move in Move.values) {
        expect(used[move], greaterThan(200),
            reason: '${move.name} is barely ever clearly right');
      }
    });

    test('and two dice are not just one die twice', () {
      // They would be, without the pair paying double: two dice where either
      // one ends the turn is exactly one die rolled twice with no choice in
      // between, which can never be better than rolling one and then
      // deciding. The double is what makes it a different gamble — and this
      // is what says so.
      final square = Rules.paidFor(4, 4);
      expect(square, greaterThan(4 + 4));

      var boldIsBest = 0;
      for (var mine = 0; mine < 60; mine += 5) {
        for (var turn = 0; turn < 30; turn += 5) {
          final chance = odds.chanceAt(mine, 30, turn);
          if (chance.best == Move.two && chance.gap > 0.002) boldIsBest++;
        }
      }
      expect(boldIsBest, greaterThan(5));
    });
  });

  group('a review', () {
    late Odds odds;

    setUpAll(() => odds = Odds.reckon());

    test('costs nothing when every move was the best one', () {
      final review = Review(odds);
      var play = const Play.start();
      for (var i = 0; i < 6; i++) {
        final best = odds.bestAt(play.mine, play.others, play.turn);
        review.note(play, best);
        play = best == Move.bank
            ? play.bank()
            : play.took(best, const Rolled([5, 4]));
        if (play.toMove == Who.them) play = play.bank();
      }
      expect(review.mistakes, 0);
      expect(review.given, lessThan(1e-9));
      expect(review.sharpness, 1);
    });

    test('and puts a number on it when they were not', () {
      final review = Review(odds);
      // Banking nothing is the one move that is never right anywhere.
      review.note(const Play.start(), Move.bank);

      expect(review.mistakes, 1);
      expect(review.given, greaterThan(0.02));
      expect(review.worst, hasLength(1));
      expect(review.worst.single.best, isNot(Move.bank));
      expect(review.sharpness, 0);
    });
  });
}
