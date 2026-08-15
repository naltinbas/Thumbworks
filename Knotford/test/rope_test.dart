import 'package:flutter_test/flutter_test.dart';
import 'package:knotford/rope/play.dart';
import 'package:knotford/rope/ropes.dart';
import 'package:knotford/rope/rules.dart';

/// The law of the rope, held to.
void main() {
  group('the rules', () {
    test('sides run round the pegs from home', () {
      const r = Rules(12);
      expect(r.sidesOf(3, 7), (3, 4, 5));
      expect(r.sidesOf(4, 9), (4, 5, 3));
      expect(Rules.longest((4, 5, 3)), 5);
      expect(Rules.sorted((4, 5, 3)), (3, 4, 5));
    });

    test('a corner is square by the squares, and only a triangle can be', () {
      expect(Rules.square((3, 4, 5)), isTrue);
      expect(Rules.square((5, 3, 4)), isTrue);
      expect(Rules.shortfall((3, 4, 5)), 0);
      expect(Rules.shortfall((4, 4, 4)), 16);
      expect(Rules.shortfall((5, 9, 11)), -15);
      expect(Rules.closes((3, 3, 6)), isFalse);
      expect(Rules.closes((2, 5, 5)), isTrue);
      expect(Rules.square((3, 3, 6)), isFalse);
    });

    test('the sweep finds the triangles by perimeter, six markings each', () {
      void sweeps(int knots, int ways, Set<(int, int, int)> triangles) {
        final (found, made) = Rules(knots).sweep();
        expect(found, ways, reason: '$knots');
        expect(made, triangles, reason: '$knots');
      }

      sweeps(12, 6, {(3, 4, 5)});
      sweeps(30, 6, {(5, 12, 13)});
      sweeps(40, 6, {(8, 15, 17)});
      sweeps(60, 12, {(10, 24, 26), (15, 20, 25)});
      sweeps(25, 0, {});
      sweeps(11, 0, {});
      expect(Rules(12).markingCount, 55);
      expect(Rules(60).markingCount, 1711);
    });

    test('Euclid\'s formula gives the sweep\'s triangles on every rope to two hundred', () {
      for (var knots = 3; knots <= 200; knots++) {
        final swept = Rules(knots).sweep().$2;
        final built = Rules.euclid(knots);
        expect(built, swept, reason: '$knots');
        if (knots.isOdd) expect(swept, isEmpty, reason: '$knots');
      }
      expect(Rules.euclid(12), {(3, 4, 5)});
      expect(Rules.euclid(56), {(7, 24, 25)});
    });

    test('the remainders of squares fix the parity', () {
      expect(Rules.oddRopeNeverSquares(), isTrue);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final rope in Ropes.all) {
        final rules = Rules(rope.knots);
        expect(rules.sweep().$1, rope.ways, reason: rope.name);
        expect(rules.markingCount, rope.markings, reason: rope.name);
      }
    });
  });

  group('the play', () {
    test('opens with no pegs', () {
      for (final rope in Ropes.all) {
        final play = Play.of(rope);
        expect(play.marks, isEmpty, reason: rope.name);
        expect(play.sides, isNull);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap stands a peg, a tap lifts it, counted both ways, and back undoes', () {
      var play = Play.of(Ropes.at(0));
      play = play.tap(3);
      expect(play.marks, [3]);
      expect(play.moves, 1);
      play = play.tap(3);
      expect(play.marks, isEmpty);
      expect(play.moves, 2);
      expect(play.back.marks, [3]);
      expect(play.tap(0), same(play));
      expect(play.tap(12), same(play));
    });

    test('no third peg, and the sides read either way round', () {
      final play = Play.of(Ropes.at(0)).tap(7).tap(3);
      expect(play.sides, (3, 4, 5));
      expect(play.isDone, isTrue);
      expect(play.tap(5), same(play));
      final open = Play.of(Ropes.at(0)).tap(2).tap(7);
      expect(open.sides, (2, 5, 5));
      expect(open.closes, isTrue);
      expect(open.shortfall, 4);
      expect(open.isDone, isFalse);
      expect(open.tap(9), same(open));
    });

    test('the ropes by hand', () {
      expect(Play.of(Ropes.at(1)).tap(5).tap(17).isDone, isTrue);
      expect(Play.of(Ropes.at(2)).tap(8).tap(23).isDone, isTrue);
      expect(Play.of(Ropes.at(3)).tap(10).tap(34).isDone, isTrue);
      expect(Play.of(Ropes.at(3)).tap(15).tap(35).isDone, isTrue);
      expect(Play.of(Ropes.at(3)).tap(24).tap(34).sides, (24, 10, 26));
      expect(Play.of(Ropes.at(4)).tap(5).tap(14).shortfall, -15);
    });

    test('the pointer lands every winnable rope', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Ropes.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 8) {
          final (_, knot) = play.next!;
          play = play.tap(knot);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, 2, reason: '$number');
      }
      expect(Play.of(Ropes.at(4)).next, isNull);
    });

    test('the pointer lifts a peg off the aim first', () {
      final play = Play.of(Ropes.at(0)).tap(5);
      expect(play.next!.$1, 'lift');
      expect(play.next!.$2, 5);
    });

    test('the hopeless rope admits it at twelve moves', () {
      var play = Play.of(Ropes.at(4)).tap(5).tap(14);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(14).tap(14);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.full, isTrue);
      expect(play.tap(14), same(play));
    });

    test('a winnable rope never gives up', () {
      var play = Play.of(Ropes.at(0));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap(2).tap(2);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands square', () {
      final mark = Play.standing(Ropes.at(0), const [3, 7]);
      expect(mark.isDone, isTrue);
      expect(mark.sides, (3, 4, 5));
    });
  });
}
