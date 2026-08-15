import 'package:flutter_test/flutter_test.dart';
import 'package:setwick/set/dances.dart';
import 'package:setwick/set/play.dart';
import 'package:setwick/set/rules.dart';

/// The law of the set, held to.
void main() {
  group('the rules', () {
    test('every label\'s counts are what the sweep finds', () {
      for (final dance in Dances.all) {
        final (all, landed) = Rules(dance.caller).sweep();
        expect(all, dance.pairings, reason: dance.name);
        expect(landed, dance.ways, reason: dance.name);
      }
    });

    test('Bezout finds each partner, and none over nine for 3 and 6', () {
      final eleven = Rules(11);
      expect(eleven.partnerOf(2), 6);
      expect(eleven.partnerOf(3), 4);
      expect(eleven.partnerOf(5), 9);
      expect(eleven.partnerOf(7), 8);
      expect(eleven.partnerOf(1), 1);
      expect(eleven.partnerOf(10), 10);
      final nine = Rules(9);
      expect(nine.partnerOf(3), isNull);
      expect(nine.partnerOf(6), isNull);
      expect(nine.partnerOf(2), 5);
      expect(nine.partnerOf(4), 7);
      expect(nine.row(3), [3, 6, 0, 3, 6, 0, 3, 6]);
    });

    test('Bezout\'s pairing is the sweep\'s, pair for pair', () {
      for (final dance in Dances.all) {
        final rules = Rules(dance.caller);
        final bezout = rules.landing();
        expect(bezout != null, dance.winnable, reason: dance.name);
        if (bezout == null) continue;
        Map<int, int>? swept;
        rules.pairings((pairs) {
          if (rules.lands(pairs)) swept = Map.of(pairs);
        });
        expect(swept, bezout, reason: dance.name);
      }
    });

    test('Wilson both ways, to thirty', () {
      for (var n = 2; n <= 30; n++) {
        final over = Rules.factorialOver(n);
        expect(over, Rules.isPrime(n) ? n - 1 : (n == 4 ? 2 : 0),
            reason: '$n');
      }
      expect(Rules.factorial(11), BigInt.from(3628800));
      expect(Rules.factorial(17), BigInt.parse('20922789888000'));
    });

    test('a pairing lands only whole and sound', () {
      final rules = Rules(7);
      expect(rules.lands({2: 4, 4: 2, 3: 5, 5: 3}), isTrue);
      expect(rules.lands({2: 4, 4: 2}), isFalse);
      expect(rules.lands({2: 3, 3: 2, 4: 5, 5: 4}), isFalse);
      expect(rules.comesToOne(2, 4), isTrue);
      expect(rules.comesToOne(2, 3), isFalse);
    });
  });

  group('the play', () {
    test('opens loose, nothing picked', () {
      for (final dance in Dances.all) {
        final play = Play.of(dance);
        expect(play.couples, isEmpty, reason: dance.name);
        expect(play.loose, hasLength(dance.caller - 3));
        expect(play.isDone, isFalse);
      }
    });

    test('a pick, an unpick, a pair and a lift', () {
      var play = Play.of(Dances.at(0));
      play = play.tap(2);
      expect(play.picked, 2);
      expect(play.moves, 0);
      play = play.tap(2);
      expect(play.picked, isNull);
      play = play.tap(2).tap(3);
      expect(play.couples, [(2, 3)]);
      expect(play.sour, [(2, 3)]);
      expect(play.moves, 1);
      play = play.tap(3);
      expect(play.couples, isEmpty);
      expect(play.moves, 2);
      expect(play.back.couples, [(2, 3)]);
    });

    test('1 and n - 1 keep to themselves', () {
      final play = Play.of(Dances.at(0));
      expect(play.touches(1), isFalse);
      expect(play.touches(6), isFalse);
      expect(play.tap(1), same(play));
      expect(play.tap(6), same(play));
    });

    test('the set of seven pairs off by hand', () {
      final play = Play.of(Dances.at(0)).tap(2).tap(4).tap(3).tap(5);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
      expect(play.sound, [(2, 4), (3, 5)]);
      expect(play.tap(2), same(play));
    });

    test('the pointer pairs off the seventeen', () {
      var play = Play.of(Dances.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final (what, a, b) = play.next!;
        play = what == 'lift' ? play.tap(a) : play.tap(a).tap(b);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 7);
    });

    test('the pointer lifts a sour pair first, then a taken partner', () {
      var play = Play.of(Dances.at(1)).tap(2).tap(3);
      expect(play.next, ('lift', 2, 3));
      play = play.tap(2);
      // 6 taken by 5 (5 x 6 = 30, 8 over 11): a sour pair, lifted
      // before anything else.
      play = play.tap(5).tap(6);
      expect(play.next, ('lift', 5, 6));
      play = play.tap(5);
      expect(play.next, ('pair', 2, 6));
    });

    test('the hopeless set admits it at nine moves', () {
      var play = Play.of(Dances.at(4)).tap(2).tap(5).tap(4).tap(7).tap(3).tap(6);
      expect(play.moves, 3);
      expect(play.sound, [(2, 5), (4, 7)]);
      expect(play.sour, [(3, 6)]);
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap(3);
        play = play.tap(3).tap(6);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      expect(play.couples, hasLength(3));
    });

    test('a winnable set never gives up', () {
      var play = Play.of(Dances.at(1));
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(2).tap(3).tap(2);
      }
      expect(play.moves, 10);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands paired off', () {
      final mark = Play.standing(Dances.at(1), Rules(11).landing()!);
      expect(mark.isDone, isTrue);
      expect(mark.couples, [(2, 6), (3, 4), (5, 9), (7, 8)]);
    });
  });
}
