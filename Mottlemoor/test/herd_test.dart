import 'package:flutter_test/flutter_test.dart';
import 'package:mottlemoor/herd/moors.dart';
import 'package:mottlemoor/herd/play.dart';
import 'package:mottlemoor/herd/rules.dart';

void main() {
  group('the meeting', () {
    test('shrinks two herds and grows the third by two', () {
      final rules = Rules(6);
      expect(rules.met((2, 2, 2), 0, 1), (1, 1, 4));
      expect(rules.met((1, 1, 4), 0, 1), (0, 0, 6));
      expect(rules.met((2, 2, 2), 1, 2), (4, 1, 1));
    });

    test('only standing herds can meet', () {
      final rules = Rules(6);
      expect(rules.meetings((6, 0, 0)), isEmpty);
      expect(rules.meetings((5, 1, 0)), [(0, 1)]);
      expect(rules.meetings((2, 2, 2)), hasLength(3));
    });
  });

  group('the two ways of knowing', () {
    test('the walk settles exactly where the differences allow', () {
      // The anchor: 815 herdings, the walk knowing nothing of
      // remainders, the differences knowing nothing of walking.
      var moors = 0;
      for (var total = 1; total <= 15; total++) {
        final rules = Rules(total);
        for (var a = 0; a <= total; a++) {
          for (var b = 0; a + b <= total; b++) {
            final herds = (a, b, total - a - b);
            moors++;
            expect(rules.fewest(herds) != null,
                rules.differencesAllow(herds),
                reason: '$herds');
          }
        }
      }
      expect(moors, 815);
    });

    test('a meeting never changes a difference\'s remainder', () {
      final rules = Rules(12);
      const herds = (3, 4, 5);
      for (final (one, other) in rules.meetings(herds)) {
        final after = rules.met(herds, one, other);
        expect((after.$1 - after.$2) % 3, (herds.$1 - herds.$2) % 3);
        expect((after.$2 - after.$3) % 3, (herds.$2 - herds.$3) % 3);
      }
    });

    test('the famous herd is dead both ways', () {
      final rules = Rules(45);
      expect(rules.differencesAllow((13, 15, 17)), isFalse);
      expect(rules.fewest((13, 15, 17)), isNull);
    });
  });

  group('every moor that ships', () {
    for (var number = 0; number < Moors.count; number++) {
      final moor = Moors.at(number);

      test('${moor.name} is what it says it is', () {
        final rules = Rules(moor.total);
        expect(rules.fewest(moor.herds), moor.fewest);
      });
    }
  });

  group('a moor in play', () {
    test('starts as dealt', () {
      final play = Play.of(Moors.at(0));
      expect(play.herds, (2, 2, 2));
      expect(play.meetingsMade, 0);
      expect(play.isSettled, isFalse);
      expect(play.fewestFromHere, 2);
    });

    test('a meeting moves the herds and counts; empties are refused',
        () {
      var play = Play.of(Moors.at(0)).meet(0, 1);
      expect(play.herds, (1, 1, 4));
      expect(play.meetingsMade, 1);
      play = play.meet(0, 1);
      expect(play.herds, (0, 0, 6));
      expect(play.isSettled, isTrue);
      expect(identical(play.meet(0, 1), play), isTrue);
    });

    test('take back returns the moor as it grazed', () {
      final start = Play.of(Moors.at(0));
      final met = start.meet(0, 2);
      expect(met.back.herds, (2, 2, 2));
      expect(identical(start.back, start), isTrue);
    });

    test('a wandering meeting shows in the live number at once', () {
      // Somewhere on the fifteen a live meeting fails to step
      // nearer: find it rather than guess it.
      final play = Play.of(Moors.at(2));
      final before = play.fewestFromHere!;
      Play? wandered;
      for (final (one, other) in play.rules.meetings(play.herds)) {
        final after = play.meet(one, other);
        if (after.fewestFromHere! >= before) {
          wandered = after;
          break;
        }
      }
      expect(wandered, isNotNull,
          reason: 'every first meeting stepped nearer');
      expect(wandered!.fewestFromHere, greaterThanOrEqualTo(before));
    });

    test('following next settles every winnable moor at its fewest',
        () {
      for (var number = 0; number < Moors.count; number++) {
        final moor = Moors.at(number);
        if (!moor.winnable) continue;
        var play = Play.of(moor);
        var guard = 0;
        while (!play.isSettled) {
          if (guard++ > 12) fail('${moor.name} never settled');
          final (one, other) = play.next!;
          play = play.meet(one, other);
        }
        expect(play.meetingsMade, moor.fewest, reason: moor.name);
      }
    });

    test('the mismatches offer nothing however the herds meet', () {
      for (final number in const [4, 5]) {
        var play = Play.of(Moors.at(number));
        expect(play.fewestFromHere, isNull);
        expect(play.next, isNull);
        for (var round = 0; round < 6; round++) {
          final meetings = play.rules.meetings(play.herds);
          if (meetings.isEmpty) break;
          play = play.meet(meetings.first.$1, meetings.first.$2);
          expect(play.isSettled, isFalse);
        }
      }
    });
  });
}
