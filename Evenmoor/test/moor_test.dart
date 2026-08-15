import 'package:flutter_test/flutter_test.dart';
import 'package:evenmoor/moor/peggings.dart';
import 'package:evenmoor/moor/play.dart';
import 'package:evenmoor/moor/rules.dart';

/// The law of the moor, held to.
void main() {
  group('the rules', () {
    test('the moor has twenty-five holes in four kinds, 9, 6, 6 and 4', () {
      final rules = Rules();
      expect(rules.holes, hasLength(25));
      final byKind = List.filled(4, 0);
      for (final hole in rules.holes) {
        byKind[Rules.kindOf(hole)]++;
      }
      expect(byKind, [9, 6, 6, 4]);
    });

    test('a halfway post lands exactly when both sums are even', () {
      expect(Rules.halfwayOnHole((0, 0), (2, 2)), isTrue);
      expect(Rules.halfwayOnHole((0, 0), (1, 1)), isFalse);
      expect(Rules.halfwayOnHole((1, 0), (3, 4)), isTrue);
      expect(Rules.halfwayOnHole((1, 0), (3, 3)), isFalse);
      expect(Rules.postDoubled((1, 0), (3, 4)), (4, 4));
    });

    test('the census and the kinds agree on every placing of three, four and five', () {
      final rules = Rules();
      for (final count in [3, 4, 5]) {
        var placings = 0;
        rules.placings(count, (pegs) {
          placings++;
          expect(Rules.halfwayPairs(pegs).length, Rules.landedByKinds(pegs), reason: '$pegs');
        });
        expect(placings, {3: 2300, 4: 12650, 5: 53130}[count]);
      }
    });

    test('the spread of posts over every placing is pinned', () {
      final rules = Rules();
      const pinned = {
        3: {0: 900, 1: 1272, 3: 128},
        4: {0: 1296, 1: 7308, 2: 1701, 3: 2188, 6: 157},
        5: {1: 13608, 2: 19017, 3: 12192, 4: 5568, 6: 2607, 10: 138},
      };
      for (final count in pinned.keys) {
        final spread = <int, int>{};
        rules.placings(count, (pegs) {
          final landed = Rules.halfwayPairs(pegs).length;
          spread[landed] = (spread[landed] ?? 0) + 1;
        });
        expect(spread, pinned[count], reason: '$count');
      }
    });

    test('five pegs never keep every post off', () {
      final rules = Rules();
      expect(rules.sweep(5, 0), (0, 53130));
      expect(rules.landing(5, 0), isNull);
    });

    test('every label\'s ways is what the sweep finds', () {
      final rules = Rules();
      for (final pegging in Peggings.all) {
        final (ways, all) = rules.sweep(pegging.pegs, pegging.asked);
        expect(ways, pegging.ways, reason: pegging.name);
        expect(all, pegging.placings, reason: pegging.name);
      }
    });

    test('the four-apart count is the product of the kinds', () {
      expect(9 * 6 * 6 * 4, 1296);
      expect(Peggings.at(0).ways, 1296);
    });
  });

  group('the play', () {
    test('opens empty', () {
      for (final pegging in Peggings.all) {
        final play = Play.of(pegging);
        expect(play.pegs, isEmpty, reason: pegging.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap sets, a tap lifts, counted both ways, and back undoes', () {
      var play = Play.of(Peggings.at(0));
      play = play.tap((0, 0));
      expect(play.pegs, [(0, 0)]);
      expect(play.moves, 1);
      play = play.tap((0, 0));
      expect(play.pegs, isEmpty);
      expect(play.moves, 2);
      expect(play.back.pegs, [(0, 0)]);
      expect(play.tap((7, 7)), same(play));
    });

    test('no peg past the count', () {
      final full = Play.of(Peggings.at(1)).tap((0, 0)).tap((2, 0)).tap((0, 2));
      expect(full.isDone, isTrue);
      expect(full.tap((4, 4)), same(full));
      expect(full.tap((0, 0)), same(full));
    });

    test('the peggings by hand', () {
      final apart = Play.of(Peggings.at(0)).tap((0, 0)).tap((1, 0)).tap((0, 1)).tap((1, 1));
      expect(apart.landed, isEmpty);
      expect(apart.kindsUsed, 4);
      expect(apart.isDone, isTrue);
      final together = Play.of(Peggings.at(1)).tap((0, 0)).tap((2, 0)).tap((0, 2));
      expect(together.landed, hasLength(3));
      expect(together.isDone, isTrue);
      final one = Play.of(Peggings.at(2)).tap((0, 0)).tap((1, 0)).tap((0, 1)).tap((1, 1)).tap((4, 4));
      expect(one.landed, [(0, 4)]);
      expect(one.isDone, isTrue);
      final ten = Play.of(Peggings.at(3)).tap((0, 0)).tap((2, 0)).tap((4, 0)).tap((0, 2)).tap((2, 2));
      expect(ten.landed, hasLength(10));
      expect(ten.isDone, isTrue);
      final nine = Play.of(Peggings.at(3)).tap((0, 0)).tap((2, 0)).tap((4, 0)).tap((0, 2)).tap((1, 2));
      expect(nine.landed, hasLength(6));
      expect(nine.isDone, isFalse);
    });

    test('the pointer lands every winnable pegging', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Peggings.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, peg) = play.next!;
          play = play.tap(peg);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Peggings.at(4)).next, isNull);
    });

    test('the pointer lifts a peg off the aim first', () {
      final play = Play.of(Peggings.at(3)).tap((3, 3));
      expect(play.next!.$1, 'lift');
      expect(play.next!.$2, (3, 3));
    });

    test('the hopeless pegging admits it at thirteen moves', () {
      var play = Play.of(Peggings.at(4)).tap((0, 0)).tap((1, 0)).tap((0, 1)).tap((1, 1)).tap((4, 4));
      expect(play.landed, [(0, 4)]);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap((4, 4)).tap((4, 4));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.full, isTrue);
      expect(play.tap((4, 4)), same(play));
    });

    test('a winnable pegging never gives up', () {
      var play = Play.of(Peggings.at(0));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap((0, 0)).tap((0, 0));
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands with one post landed', () {
      final mark = Play.standing(Peggings.at(2), const [(0, 0), (3, 0), (0, 3), (3, 3), (4, 4)]);
      expect(mark.isDone, isTrue);
      expect(mark.landed, [(0, 4)]);
      expect(mark.kindsUsed, 4);
    });
  });
}
