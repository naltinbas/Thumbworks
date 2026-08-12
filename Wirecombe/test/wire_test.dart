import 'package:flutter_test/flutter_test.dart';
import 'package:wirecombe/wire/combes.dart';
import 'package:wirecombe/wire/play.dart';
import 'package:wirecombe/wire/rules.dart';

/// The law of the combe, held to.
void main() {
  group('the rules', () {
    test('a run joins all with no loop and no spare line', () {
      final rules = Rules(4);
      expect(rules.isRun(const [(0, 1), (1, 2), (2, 3)]), isTrue);
      expect(rules.isRun(const [(0, 1), (1, 2), (0, 2)]), isFalse);
      expect(rules.loops(const [(0, 1), (1, 2), (0, 2)]), isTrue);
      expect(rules.pieces(const [(0, 1), (2, 3)]), 2);
    });

    test('lane\'s ends are the cottages on one line', () {
      final rules = Rules(5);
      expect(
        rules.lanesEnds(const [(0, 1), (1, 2), (2, 3), (3, 4)]),
        [0, 4],
      );
      expect(
        rules.lanesEnds(const [(0, 1), (0, 2), (0, 3), (0, 4)]),
        [1, 2, 3, 4],
      );
    });

    test('Cayley\'s count holds at every size', () {
      expect(Rules(3).runs(), 3);
      expect(Rules(4).runs(), 16);
      expect(Rules(5).runs(), 125);
    });

    test('every run codes to its Prufer word and back', () {
      for (final cottages in [3, 4, 5]) {
        expect(Rules(cottages).prufersHold(), isTrue,
            reason: '$cottages');
      }
    });

    test('a known code round-trips by hand', () {
      final rules = Rules(5);
      const path = [(0, 1), (1, 2), (2, 3), (3, 4)];
      expect(rules.code(path), [1, 2, 3]);
      expect(rules.decode([1, 2, 3]).toSet(), path.toSet());
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final combe in Combes.all) {
        expect(Rules(combe.cottages).waysTo(combe.ends), combe.ways,
            reason: combe.name);
      }
    });

    test('the ends of five add up and never dip below two', () {
      final five = Rules(5);
      expect(five.waysTo(2) + five.waysTo(3) + five.waysTo(4), 125);
      expect(five.waysTo(0), 0);
      expect(five.waysTo(1), 0);
    });
  });

  group('the play', () {
    test('two picks wire a line', () {
      var play = Play.of(Combes.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      play = play.tapAt(1);
      expect(play.lines, [(0, 1)]);
      expect(play.moves, 1);
    });

    test('the same two cottages unwire their line', () {
      var play = Play.of(Combes.at(0)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(0);
      expect(play.lines, isEmpty);
      expect(play.moves, 2);
    });

    test('a loop shows itself and blocks the landing', () {
      var play = Play.of(Combes.at(1));
      for (final line in const [(0, 1), (1, 2), (0, 2)]) {
        play = play.tapAt(line.$1).tapAt(line.$2);
      }
      expect(play.looped, isTrue);
      expect(play.isDone, isFalse);
    });

    test('a lane lands the three cottages', () {
      var play = Play.of(Combes.at(0));
      play = play.tapAt(0).tapAt(1).tapAt(1).tapAt(2);
      expect(play.isDone, isTrue);
      expect(play.lanesEnds, [0, 2]);
      expect(play.tapAt(0), same(play));
    });

    test('the long lane needs its two ends exactly', () {
      var play = Play.of(Combes.at(2));
      for (final line in const [(0, 1), (0, 2), (0, 3), (0, 4)]) {
        play = play.tapAt(line.$1).tapAt(line.$2);
      }
      // A star stands: one run, but four ends where two are asked.
      expect(play.pieces, 1);
      expect(play.lanesEnds, hasLength(4));
      expect(play.isDone, isFalse);
    });

    test('back takes back the last wiring', () {
      var play = Play.of(Combes.at(0)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(2);
      expect(play.moves, 2);
      expect(play.back.lines, [(0, 1)]);
      expect(play.back.moves, 1);
    });

    test('show me wires a real run home', () {
      var play = Play.of(Combes.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final ((a, b), wire) = aim!;
        expect(wire, isTrue);
        play = play.tapAt(a).tapAt(b);
      }
      expect(play.isDone, isTrue);
      expect(play.lanesEnds, hasLength(4));
    });

    test('the hopeless combe has nothing to point at', () {
      expect(Play.of(Combes.at(4)).next, isNull);
    });

    test('the hopeless combe admits it after twelve wirings', () {
      var play = Play.of(Combes.at(4));
      for (var round = 0; round < 6; round++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable combe never gives up', () {
      var play = Play.of(Combes.at(1));
      for (var round = 0; round < 6; round++) {
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
