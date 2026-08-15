import 'package:flutter_test/flutter_test.dart';
import 'package:loafham/loaf/fraction.dart';
import 'package:loafham/loaf/loaves.dart';
import 'package:loafham/loaf/play.dart';
import 'package:loafham/loaf/rules.dart';

/// The law of the loaf, held to.
void main() {
  group('the fractions', () {
    test('add, take away, and stay in lowest terms', () {
      expect(Fraction(2, 4), Fraction(1, 2));
      expect(Fraction(1, 2) + Fraction(1, 6), Fraction(2, 3));
      expect(Fraction(4, 5) - Fraction(1, 2), Fraction(3, 10));
      expect(Fraction(1, 3) + Fraction(1, 4), Fraction(7, 12));
      expect(Fraction(7, 12) < Fraction(4, 5), isTrue);
      expect(Fraction(3, 10).isUnit, isFalse);
      expect('${Fraction(4, 5)}', '4/5');
      expect('${Fraction(3, 3)}', '1');
    });
  });

  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final loaf in Loaves.all) {
        expect(Rules(loaf.share).waysBySweep(loaf.cuts), loaf.ways, reason: loaf.name);
      }
    });

    test('the named cuts', () {
      expect(Rules(Fraction(2, 3)).waysWith(2), [[2, 6]]);
      expect(Rules(Fraction(4, 5)).waysWith(3), [[2, 4, 20], [2, 5, 10]]);
      expect(Rules(Fraction(9, 10)).waysWith(3), [[2, 3, 15]]);
      expect(Rules(Fraction(5, 7)).waysWith(3), [[2, 6, 21], [2, 7, 14]]);
      expect(Rules(Fraction(4, 5)).waysWith(2), isEmpty);
      expect(Rules(Fraction(4, 5), largest: 100).waysWith(2), isEmpty);
      expect(Rules(Fraction(9, 10)).fewest(), 3);
      expect(Rules(Fraction(3, 7)).fewest(), 4);
    });

    test('the greedy cut ends and adds up, on every share to twelfths', () {
      var longest = 0;
      for (var den = 2; den <= 12; den++) {
        for (var num = 1; num < den; num++) {
          final share = Fraction(num, den);
          final cuts = Rules.greedy(share);
          expect(Rules.sumOf(cuts), share, reason: '$share');
          expect(cuts.toSet(), hasLength(cuts.length), reason: '$share');
          if (cuts.length > longest) longest = cuts.length;
        }
      }
      expect(longest, 4);
      expect(Rules.greedy(Fraction(4, 5)), [2, 4, 20]);
      expect(Rules.greedy(Fraction(5, 7)), [2, 5, 70]);
    });
  });

  group('the play', () {
    test('opens uncut', () {
      for (final loaf in Loaves.all) {
        final play = Play.of(loaf);
        expect(play.cuts, isEmpty, reason: loaf.name);
        expect(play.isDone, isFalse);
        expect(play.left, loaf.share);
      }
    });

    test('a tap takes a cut, a tap puts it back, counted both ways', () {
      var play = Play.of(Loaves.at(1));
      play = play.tap(4);
      expect(play.cuts, [4]);
      expect(play.moves, 1);
      play = play.tap(2);
      expect(play.cuts, [2, 4]);
      expect(play.sum, Fraction(3, 4));
      expect(play.left, Fraction(1, 20));
      play = play.tap(4);
      expect(play.cuts, [2]);
      expect(play.moves, 3);
      expect(play.back.cuts, [2, 4]);
    });

    test('no more cuts than allowed, and none off the board', () {
      final play = Play.of(Loaves.at(0)).tap(2).tap(6);
      expect(play.isDone, isTrue);
      expect(play.tap(3), same(play));
      final bare = Play.of(Loaves.at(0));
      expect(bare.tap(1), same(bare));
      expect(bare.tap(25), same(bare));
    });

    test('over the share reads as over', () {
      final play = Play.of(Loaves.at(0)).tap(2).tap(3);
      expect(play.over, isTrue);
      expect(play.left, Fraction.zero);
      expect(play.isDone, isFalse);
    });

    test('the two of three by hand, the four of five two ways', () {
      expect(Play.of(Loaves.at(0)).tap(6).tap(2).isDone, isTrue);
      expect(Play.of(Loaves.at(1)).tap(2).tap(4).tap(20).isDone, isTrue);
      expect(Play.of(Loaves.at(1)).tap(10).tap(5).tap(2).isDone, isTrue);
    });

    test('the pointer cuts the nine of ten and the five of seven', () {
      for (final number in [2, 3]) {
        var play = Play.of(Loaves.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, den) = play.next!;
          play = play.tap(den);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the pointer puts a stray cut back first', () {
      final play = Play.of(Loaves.at(2)).tap(7);
      expect(play.next, ('back', 7));
      expect(play.tap(7).next, ('take', 2));
    });

    test('the hopeless share admits it at ten moves', () {
      var play = Play.of(Loaves.at(4)).tap(2).tap(4);
      expect(play.sum, Fraction(3, 4));
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap(4).tap(4);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.cuts, [2, 4]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable share never gives up', () {
      var play = Play.of(Loaves.at(1));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap(3).tap(3);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands cut', () {
      final mark = Play.standing(Loaves.at(1), const [2, 4, 20]);
      expect(mark.isDone, isTrue);
      expect(mark.sum, Fraction(4, 5));
    });
  });
}
