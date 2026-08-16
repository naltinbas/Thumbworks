import 'package:flutter_test/flutter_test.dart';
import 'package:roundhithe/road/levels.dart';
import 'package:roundhithe/road/play.dart';
import 'package:roundhithe/road/rules.dart';

/// The roads, the round trips, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the roads', () {
    test('six villages, fifteen roads, and a plan told and read back', () {
      expect(Rules.villages, 6);
      expect(Rules.pairs, hasLength(15));
      expect(Rules.plans, 32768);
      expect(Rules.roadOf(0, 1), 0);
      expect(Rules.roadOf(5, 4), 14);
      expect(Rules.roadOf(2, 0), 1);
      final ring = Rules.planOf('AB, BC, CD, DE, EF, FA');
      expect(Rules.tell(ring), 'AB, AF, BC, CD, DE, EF');
      expect(Rules.roads(ring), 6);
      expect(Rules.joined(ring, 0, 1), isTrue);
      expect(Rules.joined(ring, 0, 2), isFalse);
      expect(Rules.joined(ring, 0, 0), isFalse);
      expect(Rules.tell(Rules.toggled(ring, 0, 2)), 'AB, AC, AF, BC, CD, DE, EF');
      expect(Rules.tell(Rules.toggled(ring, 1, 0)), 'AF, BC, CD, DE, EF');
      expect(Rules.degrees(ring), [2, 2, 2, 2, 2, 2]);
      expect(Rules.minDegree(ring), 2);
      expect(Rules.dirac(ring), isFalse);
      expect(Rules.ore(ring), isFalse);
      final threes = Rules.planOf('AD, AE, AF, BD, BE, BF, CD, CE, CF');
      expect(Rules.degrees(threes), [3, 3, 3, 3, 3, 3]);
      expect(Rules.dirac(threes), isTrue);
      expect(Rules.ore(threes), isTrue);
    });

    test('a round trip found by the walk and by the table', () {
      expect(Rules.tripByWalk(Rules.planOf('AB, BC, CD, DE, EF, FA')), [0, 1, 2, 3, 4, 5]);
      expect(Rules.tripByTable(Rules.planOf('AB, BC, CD, DE, EF, FA')), isTrue);
      expect(Rules.tripByWalk(Rules.planOf('AB, BC, CA, DE, EF, FD')), isNull);
      expect(Rules.tripByTable(Rules.planOf('AB, BC, CA, DE, EF, FD')), isFalse);
      expect(Rules.tripByWalk(Rules.planOf('AD, AE, AF, BD, BE, BF, CD, CE, CF')), [0, 3, 1, 4, 2, 5]);
      final hung = Rules.planOf('AB, AC, AD, AE, BC, BD, BE, CD, CE, DE, EF');
      expect(Rules.roads(hung), 11);
      expect(Rules.tripByWalk(hung), isNull);
      expect(Rules.tripByTable(hung), isFalse);
      expect(Rules.tripByWalk(0), isNull);
      expect(Rules.tripByWalk(Rules.plans - 1), [0, 1, 2, 3, 4, 5]);
    });

    test('the sweep: the two voices agree on every plan, and Dirac and Ore hold on every plan they cover', () {
      var trips = 0, dirac = 0, ore = 0, twoEach = 0, twoEachTrips = 0, threeEach = 0, threeEachTrips = 0, elevenNoTrip = 0;
      for (var mask = 0; mask < Rules.plans; mask++) {
        final walk = Rules.tripByWalk(mask);
        expect(Rules.tripByTable(mask), walk != null, reason: Rules.tell(mask));
        if (walk != null) trips++;
        if (Rules.dirac(mask)) {
          dirac++;
          expect(walk, isNotNull, reason: Rules.tell(mask));
        }
        if (Rules.ore(mask)) {
          ore++;
          expect(walk, isNotNull, reason: Rules.tell(mask));
        }
        final d = Rules.degrees(mask);
        if (d.every((x) => x == 2)) {
          twoEach++;
          if (walk != null) twoEachTrips++;
        }
        if (d.every((x) => x == 3)) {
          threeEach++;
          if (walk != null) threeEachTrips++;
        }
        if (Rules.roads(mask) == 11 && walk == null) elevenNoTrip++;
        if (Rules.roads(mask) >= 12) expect(walk, isNotNull, reason: Rules.tell(mask));
      }
      expect(trips, 10078);
      expect(dirac, 1858);
      expect(ore, 1978);
      expect((twoEach, twoEachTrips), (70, 60));
      expect((threeEach, threeEachTrips), (70, 70));
      expect(elevenNoTrip, 30);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Three Each']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var mask = 0; mask < Rules.plans; mask++) {
          if (level.meets(mask)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Rules.tell(Levels.at(0).aim!), 'AE, AF, BD, BF, CD, CE');
      expect(Rules.tell(Levels.at(1).aim!), 'AB, AF, BF, CD, CE, DE');
      expect(Rules.tell(Levels.at(2).aim!), 'AD, AE, AF, BD, BE, BF, CD, CE, CF');
      expect(Rules.tell(Levels.at(3).aim!), 'AB, AC, AD, AE, AF, BC, BD, BE, CD, CE, DE');
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'lay six roads with a round trip through all six villages');
      expect(Levels.at(1).task, 'give every village two roads and no round trip');
      expect(Levels.at(2).task, 'give every village three roads exactly');
      expect(Levels.at(3).task, 'lay eleven roads and no round trip');
      expect(Levels.at(4).task, 'give every village three roads or more and no round trip');
    });

    test('an ask is met by the plan', () {
      final ring = Rules.planOf('AB, BC, CD, DE, EF, FA');
      final trios = Rules.planOf('AB, BC, CA, DE, EF, FD');
      final threes = Rules.planOf('AD, AE, AF, BD, BE, BF, CD, CE, CF');
      final hung = Rules.planOf('AB, AC, AD, AE, BC, BD, BE, CD, CE, DE, EF');
      expect(Levels.at(0).meets(ring), isTrue);
      expect(Levels.at(0).meets(trios), isFalse);
      expect(Levels.at(0).meets(threes), isFalse);
      expect(Levels.at(1).meets(trios), isTrue);
      expect(Levels.at(1).meets(ring), isFalse);
      expect(Levels.at(2).meets(threes), isTrue);
      expect(Levels.at(2).meets(hung), isFalse);
      expect(Levels.at(3).meets(hung), isTrue);
      expect(Levels.at(3).meets(Rules.toggled(hung, 3, 5)), isFalse);
      expect(Levels.at(4).meets(threes), isFalse);
      expect(Levels.at(4).meets(trios), isFalse);
    });
  });

  group('the play', () {
    test('opens with no roads and nothing held', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.roads, play.held, play.moves), (0, null, 0));
        expect(play.trip, isNull);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap holds a village, a second lays the road, the same again lets go, and a laid road lifts', () {
      var play = Play.of(Levels.at(4)).tap(0);
      expect(play.held, 0);
      expect(play.roads, 0);
      play = play.tap(1);
      expect(play.held, isNull);
      expect(Rules.tell(play.roads), 'AB');
      expect(play.moves, 2);
      play = play.tap(2).tap(2);
      expect(play.held, isNull);
      expect(play.moves, 4);
      play = play.tap(1).tap(0);
      expect(play.roads, 0);
      expect(play.tap(6), same(play));
      expect(play.tap(-1), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(play.back.held, 0);
      expect(play.back.back.held, isNull);
      expect(play.back.back.roads, 0);
    });

    test('the pointer names the road, lifts a stray road first, and speaks to a held village', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (0, 4, false));
      expect(Play.pointed((0, 4, false)), 'Tap A, then E, to lay the road AE.');
      play = play.tap(0);
      expect(play.next, (0, 4, false));
      expect(Play.pointed(play.next!, held: play.held), 'Now tap E to lay the road AE.');
      play = play.tap(1);
      expect(play.next, (0, 1, true));
      expect(Play.pointed(play.next!, held: play.held), 'Tap A, then B, to lift the road AB.');
      play = play.tap(2);
      expect(play.next, (2, 3, false));
      expect(Play.pointed(play.next!, held: play.held), 'Now tap D to lay the road CD.');
      expect(Play.pointed((2, 2, false)), 'Tap C again to let it go.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in two taps a road', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (a, b, _) = play.next!;
          play = play.tap(a == b ? a : (play.held == a ? b : a));
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 2 * Rules.roads(level.aim!), reason: level.name);
      }
    });

    test('the three each admits it after three plans with three roads each, or forty taps', () {
      var play = Play.of(Levels.at(4));
      for (final r in ['AD', 'AE', 'AF', 'BD', 'BE', 'BF', 'CD', 'CE', 'CF']) {
        play = play.tap(Rules.names.indexOf(r[0])).tap(Rules.names.indexOf(r[1]));
      }
      expect(play.dirac, isTrue);
      expect(play.trip, [0, 3, 1, 4, 2, 5]);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.tap(0).tap(1);
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      play = play.tap(0).tap(2);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 22);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        wander = wander.tap(k % 2);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 40);
    });

    test('the why tells Dirac and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Dirac proved in 1952'));
      expect(words, contains('32,768'));
      expect(words, contains('This is ask 5, The Three Each.'));
      expect(words, contains('walked in full'));
    });
  });
}
