import 'package:flutter_test/flutter_test.dart';
import 'package:ringmarsh/ring/play.dart';
import 'package:ringmarsh/ring/rules.dart';
import 'package:ringmarsh/ring/watches.dart';

void main() {
  group('the words', () {
    test('are read clockwise from each place, round the end', () {
      final rules = Rules(3, 8);
      // Ring 0b00000001: lantern 0 lit.
      expect(rules.wordAt(1, 0), 4);
      expect(rules.wordAt(1, 6), 1);
      expect(rules.wordAt(1, 7), 2);
      expect(rules.wordAt(1, 1), 0);
    });

    test('a full ring spells every word exactly once', () {
      final rules = Rules(3, 8);
      // 92 is what the shift-walk built in the probe: check it the
      // long way.
      expect(rules.isFull(92), isTrue);
      expect(rules.allWords(92).toSet(), hasLength(8));
      expect(rules.clashes(92), isEmpty);
    });

    test('a clash names the two places spelling alike', () {
      final rules = Rules(3, 8);
      expect(rules.clashes(0), hasLength(28));
      expect(rules.speltCount(0), 1);
    });
  });

  group('the two ways of knowing', () {
    test('the sweep counts what the books count', () {
      // The anchor: every ring tried, knowing nothing of walks.
      expect(Rules(2, 4).fullCount(), 4);
      expect(Rules(3, 8).fullCount(), 16);
      expect(Rules(4, 16).fullCount(), 256);
      expect(Rules(3, 7).fullCount(), 0);
    });

    test('the shift-walk builds a full ring without counting', () {
      for (final span in [2, 3, 4]) {
        final rules = Rules(span, 1 << span);
        final ring = rules.byShiftWalk();
        expect(rules.isFull(ring), isTrue, reason: 'span $span');
      }
    });

    test('a full eight-ring lights exactly four lanterns', () {
      // Each place begins exactly one word, and half the words begin
      // lit: the note on the level, held against all sixteen.
      final rules = Rules(3, 8);
      for (final ring in rules.allRings()) {
        if (!rules.isFull(ring)) continue;
        var lit = 0;
        for (var place = 0; place < 8; place++) {
          if (ring & (1 << place) != 0) lit++;
        }
        expect(lit, 4, reason: 'ring $ring');
      }
    });

    test('the short ring is short by counting alone', () {
      // Seven places spell at most seven words; the watch asks eight.
      final rules = Rules(3, 7);
      for (final ring in rules.allRings()) {
        expect(rules.speltCount(ring), lessThanOrEqualTo(7));
      }
    });
  });

  group('every watch that ships', () {
    for (var number = 0; number < Watches.count; number++) {
      final watch = Watches.at(number);

      test('${watch.name} is what it says it is', () {
        final rules = Rules(watch.span, watch.length);
        final answers =
            rules.fullRingsUnder(watch.lockedPlaces, watch.lockedBits);
        expect(answers, hasLength(watch.ways));
        for (final ring in answers) {
          expect(rules.isFull(ring), isTrue);
        }
      });
    }

    test('the locked watch honours its locks in its one answer', () {
      final watch = Watches.at(2);
      final play = Play.of(watch);
      expect(play.answers, hasLength(1));
      final answer = play.answers.single;
      expect(answer & watch.lockedPlaces,
          watch.lockedBits & watch.lockedPlaces);
    });
  });

  group('a ring in play', () {
    test('starts with the locks lit as held and nothing else', () {
      final play = Play.of(Watches.at(2));
      expect(play.ring, 1);
      expect(play.turns, 0);
      expect(play.isFull, isFalse);
    });

    test('a turn flips a lantern and counts; locks are refused', () {
      final play = Play.of(Watches.at(2));
      final turned = play.turn(2);
      expect(turned.lit(2), isTrue);
      expect(play.fewestFromHere, 3);
      expect(turned.turns, 1);
      expect(play.mayTurn(0), isFalse);
      expect(identical(play.turn(0), play), isTrue);
    });

    test('take back returns the ring as it stood', () {
      final start = Play.of(Watches.at(0));
      final turned = start.turn(0);
      expect(turned.back.ring, start.ring);
      expect(identical(start.back, start), isTrue);
    });

    test('the live number falls with a good turn and rises with a bad',
        () {
      final play = Play.of(Watches.at(2));
      final away = play.fewestFromHere!;
      final good = play.turn(play.next!);
      expect(good.fewestFromHere, away - 1);
      final bad = good.turn(good.next == 5 ? 6 : 5);
      expect(bad.fewestFromHere, greaterThanOrEqualTo(away - 1));
    });

    test('following next sets every winnable watch full', () {
      for (var number = 0; number < Watches.count; number++) {
        final watch = Watches.at(number);
        if (!watch.winnable) continue;
        var play = Play.of(watch);
        var guard = 0;
        while (!play.isFull) {
          if (guard++ > 20) fail('${watch.name} never came full');
          play = play.turn(play.next!);
        }
        expect(play.clashes, isEmpty, reason: watch.name);
      }
    });

    test('the short ring offers nothing and never fills', () {
      var play = Play.of(Watches.at(4));
      expect(play.fewestFromHere, isNull);
      expect(play.next, isNull);
      for (var place = 0; place < 7; place++) {
        play = play.turn(place);
      }
      expect(play.isFull, isFalse);
      expect(play.clashes, isNotEmpty);
    });
  });
}
