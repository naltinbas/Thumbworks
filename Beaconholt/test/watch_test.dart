import 'dart:math';

import 'package:beaconholt/watch/countries.dart';
import 'package:beaconholt/watch/fewest.dart';
import 'package:beaconholt/watch/hills.dart';
import 'package:beaconholt/watch/play.dart';
import 'package:flutter_test/flutter_test.dart';

Country _scatter(Random dice, int hills) {
  final lines = <(int, int)>[];
  for (var one = 0; one < hills; one++) {
    for (var other = one + 1; other < hills; other++) {
      if (dice.nextInt(100) < 24) lines.add((one, other));
    }
  }
  return Country(
    hills: [for (var i = 0; i < hills; i++) Hill('$i', 0, 0)],
    sightlines: lines,
  );
}

void main() {
  group('a country', () {
    test('lights the hill a beacon is on and every hill it sees', () {
      final country = Country(
        hills: const [Hill('a', 0, 0), Hill('b', 0, 0), Hill('c', 0, 0)],
        sightlines: const [(0, 1)],
      );
      expect(country.lights(0), 1 | 2);
      expect(country.lights(2), 4, reason: 'a hill that sees nobody');
      expect(country.sees(0, 1), isTrue);
      expect(country.sees(0, 2), isFalse);
    });

    test('and knows when the whole of it is lit', () {
      final country = Country(
        hills: const [Hill('a', 0, 0), Hill('b', 0, 0), Hill('c', 0, 0)],
        sightlines: const [(0, 1), (1, 2)],
      );
      expect(country.isWholeCountryLit([1]), isTrue);
      expect(country.isWholeCountryLit([0]), isFalse);
      expect(country.litBy([0, 2]), country.all);
    });
  });

  group('the fewest beacons', () {
    test('is one on a country where one hill sees everything', () {
      final country = Country(
        hills: const [
          Hill('a', 0, 0),
          Hill('b', 0, 0),
          Hill('c', 0, 0),
          Hill('d', 0, 0),
        ],
        sightlines: const [(0, 1), (0, 2), (0, 3)],
      );
      final watch = Beacons.fewestFor(country);
      expect(watch.fewest, 1);
      expect(watch.where, [0]);
    });

    test('and is as many as there are hills when none of them sees another',
        () {
      final country = Country(
        hills: const [Hill('a', 0, 0), Hill('b', 0, 0), Hill('c', 0, 0)],
        sightlines: const [],
      );
      expect(Beacons.fewestFor(country).fewest, 3);
    });

    test('and nothing smaller lights the country, on a hundred of them', () {
      // What fewest means, said the other way round: every set one smaller
      // is tried and none of them does it. That is what the search is doing
      // and this is the claim it rests on.
      final dice = Random(20260805);
      for (var round = 0; round < 100; round++) {
        final country = _scatter(dice, 5 + dice.nextInt(7));
        final watch = Beacons.fewestFor(country);

        expect(country.isWholeCountryLit(watch.where), isTrue,
            reason: 'the set it gave back leaves a hill dark');
        expect(watch.where, hasLength(watch.fewest));

        if (watch.fewest <= 1) continue;
        var anySmaller = false;
        void walk(List<int> chosen, int from) {
          if (anySmaller) return;
          if (chosen.length == watch.fewest - 1) {
            if (country.isWholeCountryLit(chosen)) anySmaller = true;
            return;
          }
          for (var hill = from; hill < country.count; hill++) {
            walk([...chosen, hill], hill + 1);
          }
        }

        walk(const [], 0);
        expect(anySmaller, isFalse,
            reason: '${watch.fewest - 1} beacons would have done');
      }
    });
  });

  group('every country', () {
    test('takes the number of beacons it says', () {
      for (var i = 0; i < Watchlands.count; i++) {
        final one = Watchlands.at(i);
        expect(Beacons.fewestFor(one.country).fewest, one.fewest,
            reason: one.name);
      }
    });

    test('and lighting the hill that adds the most is not the answer', () {
      // Except on the first, which is there to show what a beacon does.
      for (var i = 1; i < Watchlands.count; i++) {
        final one = Watchlands.at(i);
        final greedy = Beacons.byGreed(one.country);
        expect(one.country.isWholeCountryLit(greedy), isTrue,
            reason: '${one.name}: greed leaves a hill dark');
        expect(greedy.length, greaterThan(one.fewest),
            reason: '${one.name} is solved by always lighting the best hill');
      }
    });

    test('and every hill can see at least one other', () {
      // A hill that sees nobody has to have its own beacon, which is not a
      // decision.
      for (var i = 0; i < Watchlands.count; i++) {
        final one = Watchlands.at(i);
        for (var hill = 0; hill < one.count; hill++) {
          expect(one.country.lights(hill), isNot(1 << hill),
              reason: '${one.name}: ${one.hills[hill].name} sees nobody');
        }
      }
    });
  });

  group('lighting them', () {
    Play start([int which = 1]) => Play.of(Watchlands.at(which));

    test('begins with every hill dark', () {
      final play = start();
      expect(play.beacons, isEmpty);
      expect(play.dark, hasLength(play.count));
      expect(play.isDone, isFalse);
    });

    test('a beacon lights its own hill and everything it sees', () {
      final play = start().turn(0);
      expect(play.hasBeacon(0), isTrue);
      expect(play.isLit(0), isTrue);
      for (var hill = 0; hill < play.count; hill++) {
        if (play.country.sees(0, hill)) {
          expect(play.isLit(hill), isTrue, reason: 'hill $hill');
        }
      }
    });

    test('and tapping it again takes it down', () {
      final play = start().turn(2);
      expect(play.turn(2).beacons, isEmpty);
      expect(play.turn(2).changes, 2);
    });

    test('and the country is watched when nothing is left dark', () {
      for (var which = 0; which < Watchlands.count; which++) {
        final one = Watchlands.at(which);
        var play = Play.of(one);
        for (final hill in Beacons.fewestFor(one.country).where) {
          play = play.turn(hill);
        }
        expect(play.isDone, isTrue, reason: one.name);
        expect(play.isFewest, isTrue, reason: one.name);
        expect(play.over, 0, reason: one.name);
        expect(play.dark, isEmpty, reason: one.name);
      }
    });

    test('and a country lit with too many says how many too many', () {
      final one = Watchlands.at(1);
      var play = Play.of(one);
      for (var hill = 0; hill < one.count; hill++) {
        play = play.turn(hill);
      }
      expect(play.isDone, isTrue);
      expect(play.over, one.count - one.fewest);
      expect(play.isFewest, isFalse);
    });

    test('and a hint names a hill that is in an answer', () {
      final play = start();
      final next = play.next;
      expect(next, isNotNull);
      expect(play.answer.where, contains(next));
      expect(play.turn(next!).next, isNot(next));
    });
  });
}
