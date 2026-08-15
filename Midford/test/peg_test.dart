import 'package:flutter_test/flutter_test.dart';
import 'package:midford/peg/cordings.dart';
import 'package:midford/peg/play.dart';
import 'package:midford/peg/rules.dart';

/// The law of the cords, held to.
void main() {
  group('the rules', () {
    test('every four on the board is a parallelogram both ways, and the counts hold', () {
      final rules = Rules();
      var all = 0, rects = 0, rhombs = 0, squares = 0;
      rules.fours((four) {
        all++;
        expect(Rules.parallelogramByMidpoints(four), isTrue, reason: '$four');
        expect(Rules.varignonHolds(four), isTrue, reason: '$four');
        expect(Rules.rectangleByDiagonals(four), Rules.rectangleByMidpoints(four), reason: '$four');
        expect(Rules.rhombusByDiagonals(four), Rules.rhombusByMidpoints(four), reason: '$four');
        if (Rules.rectangleByDiagonals(four)) rects++;
        if (Rules.rhombusByDiagonals(four)) rhombs++;
        if (Rules.squareByDiagonals(four)) squares++;
      });
      expect(all, 303600);
      expect([rects, rhombs, squares], [27952, 18384, 11248]);
    });

    test('every label\'s ways is what the sweep finds', () {
      final rules = Rules();
      for (final cording in Cordings.all) {
        var ways = 0, fours = 0;
        rules.fours((four) {
          for (var i = 0; i < cording.given.length; i++) {
            if (four[i] != cording.given[i]) return;
          }
          fours++;
          if (cording.meets(four)) ways++;
        });
        expect(ways, cording.ways, reason: cording.name);
        expect(fours, cording.fours, reason: cording.name);
      }
    });

    test('the named figures', () {
      const kite = [(2, 0), (4, 2), (2, 4), (0, 2)];
      expect(Rules.rectangleByDiagonals(kite), isTrue);
      expect(Rules.squareByDiagonals(kite), isTrue);
      const square = [(0, 0), (4, 0), (4, 4), (0, 4)];
      expect(Rules.squareByDiagonals(square), isTrue);
      const oblong = [(0, 0), (4, 0), (4, 2), (0, 2)];
      expect(Rules.rhombusByDiagonals(oblong), isTrue);
      expect(Rules.rectangleByDiagonals(oblong), isFalse);
      const flat = [(0, 0), (1, 1), (2, 2), (3, 3)];
      expect(Rules.hasRoom(flat), isFalse);
      expect(Rules.parallelogramByMidpoints(flat), isTrue);
      expect(Rules.midpointsDoubled(square), [(4, 0), (8, 4), (4, 8), (0, 4)]);
    });
  });

  group('the play', () {
    test('opens with the given pegs only', () {
      for (final cording in Cordings.all) {
        final play = Play.of(cording);
        expect(play.pegs, cording.given, reason: cording.name);
        expect(play.isDone, isFalse);
      }
    });

    test('pegs set in order, the last lifts, others do not, back undoes', () {
      var play = Play.of(Cordings.at(0));
      play = play.tap((0, 0)).tap((4, 0));
      expect(play.pegs, [(0, 0), (4, 0)]);
      expect(play.moves, 2);
      expect(play.tap((0, 0)), same(play));
      play = play.tap((4, 0));
      expect(play.pegs, [(0, 0)]);
      expect(play.moves, 3);
      expect(play.back.pegs, [(0, 0), (4, 0)]);
      expect(play.tap((9, 9)), same(play));
    });

    test('a given peg never lifts', () {
      final play = Play.of(Cordings.at(3));
      expect(play.tap((4, 3)), same(play));
      expect(play.tap((0, 0)), same(play));
    });

    test('the figures read as they stand', () {
      var play = Play.of(Cordings.at(0));
      expect(play.figure, 'unfinished');
      play = play.tap((0, 0)).tap((4, 0)).tap((4, 4)).tap((0, 4));
      expect(play.figure, 'a square');
      expect(play.isDone, isTrue);
      final oblong = Play.of(Cordings.at(1)).tap((0, 0)).tap((4, 0)).tap((4, 2)).tap((0, 2));
      expect(oblong.figure, 'a rhombus');
      expect(oblong.isDone, isTrue);
      final any = Play.of(Cordings.at(0)).tap((0, 0)).tap((3, 1)).tap((4, 4)).tap((1, 2));
      expect(any.figure, 'a parallelogram');
      expect(any.isDone, isFalse);
      final flat = Play.of(Cordings.at(0)).tap((0, 0)).tap((1, 1)).tap((2, 2)).tap((3, 3));
      expect(flat.figure, 'flat');
    });

    test('the fourth peg lands at one hole', () {
      final play = Play.of(Cordings.at(3)).tap((1, 4));
      expect(play.isDone, isTrue);
      expect(Play.of(Cordings.at(3)).tap((2, 4)).isDone, isFalse);
      expect(Play.of(Cordings.at(3)).next, ('set', (1, 4)));
    });

    test('the pointer lands the cross cords and the square cords', () {
      for (final number in [0, 2]) {
        var play = Play.of(Cordings.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, peg) = play.next!;
          play = play.tap(peg);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the hopeless cording admits it at twelve moves', () {
      var play = Play.of(Cordings.at(4)).tap((0, 0)).tap((3, 1)).tap((4, 4)).tap((1, 2));
      expect(play.full, isTrue);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap((1, 2)).tap((1, 2));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable cording never gives up', () {
      var play = Play.of(Cordings.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap((1, 1)).tap((1, 1));
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands as a rectangle', () {
      final mark = Play.standing(Cordings.at(0), const [(2, 0), (4, 2), (2, 4), (0, 2)]);
      expect(mark.isDone, isTrue);
      expect(mark.figure, 'a square');
    });
  });
}
