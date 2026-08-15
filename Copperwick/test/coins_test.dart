import 'package:flutter_test/flutter_test.dart';
import 'package:copperwick/coins/levels.dart';
import 'package:copperwick/coins/play.dart';
import 'package:copperwick/coins/rules.dart';

/// The law of the pennies, held to.
void main() {
  group('the rules', () {
    test('the upright and the turned triangles', () {
      const r = Rules(3);
      expect(r.coins, 6);
      expect(r.upright, [(0, 0), (0, 1), (1, 1), (0, 2), (1, 2), (2, 2)]);
      expect(r.turned((1, 3)), [(1, 3), (0, 2), (1, 2), (-1, 1), (0, 1), (1, 1)]);
      expect(r.isTurned(r.turned((1, 3)).toSet()), isTrue);
      expect(r.pointOf(r.turned((2, 5)).toSet()), (2, 5));
      expect(r.isTurned(r.upright.toSet()), isFalse);
      expect(r.isTurned({(0, 0), (0, 1), (1, 1)}), isFalse);
      expect(r.table, hasLength(27));
    });

    test('shares, placements and the fewest', () {
      const r = Rules(4);
      final lying = r.upright.toSet();
      expect(r.shared(lying, (2, 4)), 7);
      expect(r.shared(lying, (0, 0)), 1);
      expect(r.placements, hasLength(28));
      expect(r.bestShare, 7);
      expect(r.fewest, 3);
      expect(r.rowsBound, 7);
      expect(r.third, 3);
      expect(r.within(3), [(2, 4)]);
      expect(r.within(2), isEmpty);
      expect(r.aim, (2, 4));
    });

    test('every triangle to eight rows: the sweep, the rows and the third agree', () {
      for (var n = 1; n <= 8; n++) {
        final r = Rules(n);
        expect(r.bestShare, r.rowsBound, reason: '$n rows');
        expect(r.fewest, r.third, reason: '$n rows');
        expect(r.within(r.fewest), isNotEmpty, reason: '$n rows');
        expect(r.within(r.fewest - 1), isEmpty, reason: '$n rows');
        if (n <= 5) expect(r.turned(r.aim).every(r.table.contains), isTrue, reason: '$n rows');
      }
    });

    test('every sequence of moves on the small tables', () {
      expect(const Rules(2).sequences(1), (3, 51));
      expect(const Rules(3).sequences(2), (12, 15876));
      expect(const Rules(3).sequences(1).$1, 0);
      expect(const Rules(4).sequences(2).$1, 0);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final r = level.rules;
        expect(r.within(level.moves), hasLength(level.ways), reason: level.name);
        expect(r.placements, hasLength(level.placements), reason: level.name);
        expect(r.fewest <= level.moves, level.winnable, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens upright with nothing in hand', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.lying, unorderedEquals(level.rules.upright), reason: level.name);
        expect(play.held, isNull);
        expect(play.moves, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap takes up, a tap puts down, a slide counts; back undoes the slide', () {
      var play = Play.of(Levels.at(2));
      play = play.tap((0, 0));
      expect(play.held, (0, 0));
      expect(play.moves, 0);
      play = play.tap((0, 0));
      expect(play.held, isNull);
      play = play.tap((2, 4));
      expect(play.moves, 0);
      play = play.tap((0, 0)).tap((2, 4));
      expect(play.moves, 1);
      expect(play.lying, contains((2, 4)));
      expect(play.lying, isNot(contains((0, 0))));
      final back = play.tap((0, 3)).back;
      expect(back.moves, 0);
      expect(back.held, isNull);
      expect(back.lying, contains((0, 0)));
      expect(play.tap((9, 9)), same(play));
    });

    test('the triangles by hand', () {
      final three = Play.of(Levels.at(0)).tap((0, 0)).tap((1, 2));
      expect(three.turned, isTrue);
      expect(three.moves, 1);
      expect(three.tap((1, 1)), same(three));
      final six = Play.of(Levels.at(1)).tap((0, 0)).tap((-1, 1)).tap((2, 2)).tap((1, 3));
      expect(six.turned, isTrue);
      final ten = Play.of(Levels.at(2)).tap((0, 0)).tap((2, 4)).tap((0, 3)).tap((-1, 1)).tap((3, 3)).tap((2, 1));
      expect(ten.turned, isTrue);
      expect(ten.moves, 3);
      expect(ten.bestFit, 10);
    });

    test('the best fit follows the pennies', () {
      final play = Play.of(Levels.at(2));
      expect(play.bestFit, 7);
      expect(play.tap((0, 0)).tap((2, 4)).bestFit, 8);
    });

    test('the pointer turns every winnable triangle', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 30) {
          final (_, s) = play.next!;
          play = play.tap(s);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).moves, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says take, then to', () {
      final play = Play.of(Levels.at(2));
      expect(play.next, ('take', (0, 0)));
      expect(play.tap((0, 0)).next, ('to', (2, 4)));
      expect(play.tap((1, 1)).next, ('take', (0, 0)));
    });

    test('the hopeless triangle admits it at two moves', () {
      final play = Play.of(Levels.at(4)).tap((0, 0)).tap((2, 4)).tap((0, 3)).tap((-1, 1));
      expect(play.moves, 2);
      expect(play.spent, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.missed, isFalse);
      expect(play.isOver, isTrue);
      expect(play.tap((3, 3)), same(play));
    });

    test('a winnable triangle can miss, and back takes it back', () {
      final play = Play.of(Levels.at(0)).tap((0, 0)).tap((-1, -1));
      expect(play.missed, isTrue);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isTrue);
      expect(play.back.moves, 0);
      expect(play.back.isOver, isFalse);
    });

    test('the mark stands turned', () {
      final mark = Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)), moves: 3);
      expect(mark.turned, isTrue);
      expect(mark.moves, 3);
    });
  });
}
