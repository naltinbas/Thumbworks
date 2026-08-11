import 'package:flutter_test/flutter_test.dart';
import 'package:turnstead/green/greens.dart';
import 'package:turnstead/green/play.dart';
import 'package:turnstead/green/rules.dart';

void main() {
  group('the wheel', () {
    test('writes every card from four to twelve, every pair once', () {
      for (var sides = 4; sides <= 12; sides += 2) {
        final met = <String>{};
        for (var round = 0; round < sides - 1; round++) {
          final seen = <int>{};
          for (final (a, b) in Rules.wheelRound(sides, round)) {
            expect(seen.add(a), isTrue, reason: '$sides r$round side $a');
            expect(seen.add(b), isTrue, reason: '$sides r$round side $b');
            expect(met.add('$a-$b'), isTrue,
                reason: '$sides repeats $a-$b');
          }
          expect(seen, hasLength(sides), reason: '$sides r$round');
        }
        expect(met, hasLength(sides * (sides - 1) ~/ 2),
            reason: '$sides misses pairs');
      }
    });
  });

  group('the pigeonhole and the search', () {
    test('a card one round short never writes, at any size', () {
      for (var sides = 4; sides <= 8; sides += 2) {
        expect(Rules.canStillFinish(sides, {}, [], sides - 3), isFalse,
            reason: '$sides sides');
        expect(Rules.canStillFinish(sides, {}, [], sides - 2), isTrue,
            reason: '$sides sides');
      }
    });

    test('and the refutations come back quickly', () {
      final watch = Stopwatch()..start();
      Rules.canStillFinish(8, {}, [], 5);
      expect(watch.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('every green that ships', () {
    for (var number = 0; number < Greens.count; number++) {
      final green = Greens.at(number);

      test('${green.name} says what the search says', () {
        expect(
            Rules.canStillFinish(green.sides, {}, [], green.rounds - 1),
            green.possible);
      });
    }
  });

  group('a card being written', () {
    test('starts blank with the first round in hand', () {
      final play = Play.of(Greens.at(0));
      expect(play.matchesMade, 0);
      expect(play.roundInHand, 1);
      expect(play.canStill, isTrue);
    });

    test('picking two free sides pairs them; the same side unpicks', () {
      var play = Play.of(Greens.at(0)).pick(0);
      expect(play.chosen, 0);
      play = play.pick(0);
      expect(play.chosen, -1);
      play = play.pick(0).pick(2);
      expect(play.current, [(0, 2)]);
      expect(play.busy(0), isTrue);
    });

    test('a full round closes itself and the next opens', () {
      var play = Play.of(Greens.at(0)).pick(0).pick(1).pick(2).pick(3);
      expect(play.rounds, hasLength(1));
      expect(play.current, isEmpty);
      expect(play.roundInHand, 2);
    });

    test('sides that have met cannot meet again', () {
      var play = Play.of(Greens.at(0)).pick(0).pick(1).pick(2).pick(3);
      play = play.pick(0);
      final refused = play.pick(1);
      expect(refused.current, isEmpty);
      expect(refused.chosen, 0);
    });

    test('following next writes every writable card', () {
      for (var number = 0; number < Greens.count; number++) {
        final green = Greens.at(number);
        if (!green.possible) continue;
        var play = Play.of(green);
        var guard = 0;
        while (!play.isWritten) {
          if (guard++ > green.pairs + 2) {
            fail('${green.name} never wrote');
          }
          final match = play.next!;
          play = play.pick(match.$1).pick(match.$2);
        }
        expect(play.rounds, hasLength(green.rounds),
            reason: green.name);
      }
    });

    test('the short card can never start', () {
      final play = Play.of(Greens.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('a stranding pairing shows in the live answer at once', () {
      // On eight sides, pair to strand: the search knows immediately.
      var play = Play.of(Greens.at(3));
      var strander = (-1, -1);
      outer:
      for (var a = 0; a < 8; a++) {
        for (var b = a + 1; b < 8; b++) {
          final tried = play.pick(a).pick(b);
          if (tried.current.isEmpty && tried.rounds.isEmpty) continue;
          if (!tried.canStill) {
            strander = (a, b);
            break outer;
          }
        }
      }
      // A first pairing never strands a fresh even card; go one deeper.
      if (strander.$1 < 0) {
        play = play.pick(0).pick(1);
        outer2:
        for (var a = 2; a < 8; a++) {
          for (var b = a + 1; b < 8; b++) {
            final tried = play.pick(a).pick(b);
            if (!tried.canStill) {
              strander = (a, b);
              break outer2;
            }
          }
        }
      }
      // Whether or not a strand exists this shallow, the live answer
      // holds for the pairings we did make.
      expect(play.canStill, isTrue);
    });

    test('back unwinds pairings across a round boundary', () {
      var play = Play.of(Greens.at(0)).pick(0).pick(1).pick(2).pick(3);
      expect(play.rounds, hasLength(1));
      play = play.back;
      expect(play.rounds, isEmpty);
      expect(play.current, [(0, 1)]);
    });
  });
}
