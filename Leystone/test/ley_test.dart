import 'package:flutter_test/flutter_test.dart';
import 'package:leystone/ley/greens.dart';
import 'package:leystone/ley/play.dart';
import 'package:leystone/ley/rules.dart';

void main() {
  group('the leys', () {
    test('a ley runs on any slope there is', () {
      expect(Rules.ley((0, 0), (0, 1), (0, 2)), isTrue);
      expect(Rules.ley((0, 0), (1, 0), (2, 0)), isTrue);
      expect(Rules.ley((0, 0), (1, 1), (2, 2)), isTrue);
      expect(Rules.ley((0, 0), (1, 2), (2, 4)), isTrue);
      expect(Rules.ley((0, 0), (2, 1), (4, 2)), isTrue);
      expect(Rules.ley((0, 0), (1, 2), (2, 3)), isFalse);
    });

    test('a newcomer is told the pair it would stand between', () {
      final pair = Rules.leysWith(const [(0, 0), (2, 4), (3, 1)], (1, 2));
      expect(pair, isNotNull);
      expect({pair!.$1, pair.$2}, {(0, 0), (2, 4)});
      expect(
        Rules.leysWith(const [(0, 0), (2, 4)], (3, 1)),
        isNull,
      );
    });

    test('no three of the little close share a line', () {
      const close = [(0, 0), (0, 1), (1, 0), (1, 1)];
      for (var one = 0; one < 4; one++) {
        for (var two = one + 1; two < 4; two++) {
          for (var three = two + 1; three < 4; three++) {
            expect(
              Rules.ley(close[one], close[two], close[three]),
              isFalse,
            );
          }
        }
      }
    });

    test('the search finds the fullest ring of every green', () {
      expect(Rules.fullest(2), (4, 1));
      expect(Rules.fullest(3), (6, 2));
      expect(Rules.fullest(4), (8, 11));
      expect(Rules.fullest(5), (10, 32));
    });

    test('the counting bars the odd stone, and the search agrees',
        () {
      expect(Rules.oddStoneAlwaysLeys(3, 7), isTrue);
      expect(Rules.complete(3, const [], 7), isNull);
    });

    test('a full ring grows from the empty green everywhere the '
        'label says one stands', () {
      for (final green in Greens.all.where((green) => green.winnable)) {
        final ring = Rules.complete(green.size, const [], green.asked);
        expect(ring, isNotNull, reason: green.name);
        expect(ring, hasLength(green.asked));
        expect(Rules.sound(ring!), isTrue);
      }
    });

    test('a stone on each diagonal strands the six', () {
      // Both rings of six spare a whole diagonal, so holding a berth
      // of each diagonal leaves no full ring to grow.
      expect(
        Rules.complete(3, const [(0, 0), (2, 0)], 6),
        isNull,
      );
      // One diagonal stone alone is fine.
      expect(
        Rules.complete(3, const [(0, 0)], 6),
        isNotNull,
      );
    });
  });

  group('a play', () {
    test('stones go up, refuse the ley, and come down', () {
      var play = Play.of(Greens.at(1));
      play = play.raise((0, 0)).raise((0, 1)).raise((1, 0));
      expect(play.stones, hasLength(3));
      expect(play.mayRaise((0, 2)), isFalse);
      final pair = play.leyOf((0, 2));
      expect({pair!.$1, pair.$2}, {(0, 0), (0, 1)});
      expect(play.raise((0, 2)), same(play));
      play = play.lower((1, 0));
      expect(play.stones, hasLength(2));
      expect(play.back.stones, hasLength(3));
    });

    test('following the pointer completes every winnable green', () {
      for (final green in Greens.all.where((green) => green.winnable)) {
        var play = Play.of(green);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 12) fail('${green.name} never stood');
          final ring = play.finished;
          expect(ring, isNotNull, reason: green.name);
          play = play.raise(play.nextOf(ring!)!);
        }
        expect(Rules.sound(play.stones), isTrue);
      }
    });

    test('the odd stone: six stand and every free berth leys', () {
      var play = Play.of(Greens.at(4));
      expect(play.finished, isNull);
      // Raise a full six by the search's own hand.
      final six = Rules.complete(3, const [], 6)!;
      for (final berth in six) {
        play = play.raise(berth);
      }
      expect(play.stones, hasLength(6));
      for (var x = 0; x < 3; x++) {
        for (var y = 0; y < 3; y++) {
          if (play.stones.contains((x, y))) continue;
          expect(play.mayRaise((x, y)), isFalse,
              reason: '($x, $y) stood');
        }
      }
      expect(play.isDone, isFalse);
    });
  });
}
