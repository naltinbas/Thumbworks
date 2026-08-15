import 'package:flutter_test/flutter_test.dart';
import 'package:foldwick/plank/crossings.dart';
import 'package:foldwick/plank/play.dart';
import 'package:foldwick/plank/rules.dart';

/// The law of the plank, held to.
void main() {
  group('the rules', () {
    test('every label\'s moves and ways are what the walk finds', () {
      for (final crossing in Crossings.all) {
        final rules = Rules(crossing.sheep, crossing.goats, jumps: crossing.jumps);
        final shapes = rules.crossingShapes();
        expect(shapes, hasLength(crossing.ways), reason: crossing.name);
        for (final (moves, jumps, steps) in shapes) {
          expect(moves, crossing.moves);
          expect(jumps, crossing.sheep * crossing.goats);
          expect(steps, crossing.sheep + crossing.goats);
        }
      }
    });

    test('movers, moves and jumps read as told', () {
      final rules = Rules(2, 2);
      expect(rules.start, 'SS_GG');
      expect(rules.goal, 'GG_SS');
      expect(rules.movers('SS_GG'), [1, 3]);
      expect(rules.moved('SS_GG', 1), 'S_SGG');
      expect(rules.movers('S_SGG'), [0, 3]);
      expect(rules.isJump('S_SGG', 3), isTrue);
      expect(rules.moved('S_SGG', 3), 'SGS_G');
      expect(Rules(2, 2, jumps: false).movers('S_SGG'), [0]);
      expect(Rules.order('SGS_G'), 'SGSG');
    });

    test('the arithmetic holds on bigger flocks too', () {
      for (final (m, n) in [(4, 4), (4, 3), (2, 1), (1, 3)]) {
        final rules = Rules(m, n);
        final shapes = rules.crossingShapes();
        expect(shapes, isNotEmpty, reason: '$m $n');
        for (final (moves, jumps, steps) in shapes) {
          expect(moves, m * n + m + n);
          expect(jumps, m * n);
          expect(steps, m + n);
        }
      }
      expect(Rules(2, 1).crossingShapes(), hasLength(3));
    });

    test('the reachable planks, and steps keep the order', () {
      expect(Rules(1, 1).walk().fewest, hasLength(6));
      expect(Rules(2, 2).walk().fewest, hasLength(23));
      expect(Rules(3, 3).walk().fewest, hasLength(72));
      final steps = Rules(2, 2, jumps: false).walk();
      expect(steps.fewest, hasLength(5));
      for (final plank in steps.fewest.keys) {
        expect(Rules.order(plank), 'SSGG');
      }
      expect(steps.fewest.containsKey('GG_SS'), isFalse);
    });
  });

  group('the play', () {
    test('opens at the start', () {
      for (final crossing in Crossings.all) {
        final play = Play.of(crossing);
        expect(play.plank, play.rules.start, reason: crossing.name);
        expect(play.isDone, isFalse);
        expect(play.stuck, isFalse);
      }
    });

    test('a tap moves a mover, counted every one, and back undoes', () {
      var play = Play.of(Crossings.at(1));
      play = play.tap(1);
      expect(play.plank, 'S_SGG');
      expect(play.moves, 1);
      expect(play.tap(2), same(play));
      expect(play.back.plank, 'SS_GG');
    });

    test('the one and one crosses by hand, either way', () {
      final a = Play.of(Crossings.at(0)).tap(0).tap(2).tap(1);
      expect(a.isDone, isTrue);
      expect(a.moves, 3);
      final b = Play.of(Crossings.at(0)).tap(2).tap(0).tap(1);
      expect(b.isDone, isTrue);
    });

    test('a wrong move sticks the fold', () {
      // Two steps in a row block the plank.
      final play = Play.of(Crossings.at(1)).tap(1).tap(0);
      expect(play.plank, '_SSGG');
      expect(play.stuck, isTrue);
      expect(play.gaveUp, isFalse);
      expect(play.next, isNull);
    });

    test('the pointer crosses the two and two and the three and three', () {
      for (final number in [1, 3]) {
        var play = Play.of(Crossings.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          play = play.tap(play.next!);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Crossings.at(number).moves);
      }
    });

    test('the hopeless crossing admits it when it sticks', () {
      var play = Play.of(Crossings.at(4)).tap(1);
      expect(play.stuck, isFalse);
      play = play.tap(0);
      expect(play.stuck, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(3), same(play));
      final other = Play.of(Crossings.at(4)).tap(3).tap(4);
      expect(other.gaveUp, isTrue);
    });

    test('the mark stands on the way across', () {
      final mark = Play.standing(Crossings.at(3), 'GSGSGS_');
      expect(Rules(3, 3).walk().fewest.containsKey('GSGSGS_'), isTrue);
      expect(mark.isDone, isFalse);
      expect(mark.next, isNotNull);
    });
  });
}
