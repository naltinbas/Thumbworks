import 'package:flutter_test/flutter_test.dart';
import 'package:wheelford/wheel/cordings.dart';
import 'package:wheelford/wheel/play.dart';
import 'package:wheelford/wheel/rules.dart';

/// The law of the wheel, held to.
void main() {
  group('the rules', () {
    test('the twelve pegs sit on the rim', () {
      expect(Rules.pegs, hasLength(12));
      expect(Rules.pegs.every(Rules.onRim), isTrue);
    });

    test('Thales both ways on every triangle', () {
      var triples = 0, right = 0, sharp = 0;
      Rules.triples((three) {
        triples++;
        expect(Rules.squareCorners(three), Rules.cornersAcrossDiameters(three), reason: '$three');
        if (Rules.squareCorners(three).isNotEmpty) right++;
        if (Rules.sharp(three)) sharp++;
      });
      expect(triples, 220);
      expect(right, 60);
      expect(sharp, 40);
    });

    test('three squares stand on the wheel', () {
      var squares = 0;
      Rules.quads((four) {
        if (Rules.makesSquare(four)) squares++;
      });
      expect(squares, 3);
      expect(Rules.makesSquare(const [(5, 0), (0, 5), (-5, 0), (0, -5)]), isTrue);
      expect(Rules.makesSquare(const [(3, 4), (-4, 3), (-3, -4), (4, -3)]), isTrue);
      expect(Rules.makesSquare(const [(5, 0), (4, 3), (-5, 0), (0, -5)]), isFalse);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final cording in Cordings.all) {
        var sets = 0, ways = 0;
        void consider(List<Peg> set) {
          if (!cording.given.every(set.contains)) return;
          sets++;
          if (cording.meets(set)) ways++;
        }

        if (cording.pegs == 3) {
          Rules.triples(consider);
        } else {
          Rules.quads(consider);
        }
        expect(ways, cording.ways, reason: cording.name);
        expect(sets, cording.sets, reason: cording.name);
      }
    });

    test('corners and diameters read as told', () {
      expect(Rules.squareCorner((3, 4), (5, 0), (-5, 0)), isTrue);
      expect(Rules.isDiameter((5, 0), (-5, 0)), isTrue);
      expect(Rules.isDiameter((5, 0), (0, 5)), isFalse);
      expect(Rules.squareCorners(const [(-5, 0), (5, 0), (3, 4)]), [2]);
      expect(Rules.sharp(const [(5, 0), (-3, 4), (-3, -4)]), isTrue);
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

    test('a tap cords, a tap lifts, counted both ways, and back undoes', () {
      var play = Play.of(Cordings.at(0));
      play = play.tap((5, 0));
      expect(play.pegs, [(5, 0)]);
      expect(play.moves, 1);
      play = play.tap((5, 0));
      expect(play.pegs, isEmpty);
      expect(play.moves, 2);
      expect(play.back.pegs, [(5, 0)]);
      expect(play.tap((1, 1)), same(play));
    });

    test('a given peg never lifts, and no peg past the count', () {
      final play = Play.of(Cordings.at(3));
      expect(play.tap((5, 0)), same(play));
      final full = Play.of(Cordings.at(0)).tap((5, 0)).tap((-5, 0)).tap((3, 4));
      expect(full.isDone, isTrue);
      expect(full.tap((0, 5)), same(full));
    });

    test('the right corner and the sharp three by hand', () {
      final right = Play.of(Cordings.at(0)).tap((-5, 0)).tap((5, 0)).tap((3, 4));
      expect(right.squareCorners, [2]);
      expect(right.isDone, isTrue);
      final sharp = Play.of(Cordings.at(1)).tap((5, 0)).tap((-3, 4)).tap((-3, -4));
      expect(sharp.isDone, isTrue);
      final blunt = Play.of(Cordings.at(1)).tap((5, 0)).tap((4, 3)).tap((3, 4));
      expect(blunt.isDone, isFalse);
    });

    test('the pointer lands the square wheel and the given two', () {
      for (final number in [2, 3]) {
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
      var play = Play.of(Cordings.at(4)).tap((-5, 0)).tap((5, 0)).tap((3, 4));
      expect(play.squareCorners, [2]);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 4; dither++) {
        play = play.tap((3, 4)).tap((3, 4));
      }
      expect(play.moves, 11);
      play = play.tap((3, 4));
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable cording never gives up', () {
      var play = Play.of(Cordings.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap((5, 0)).tap((5, 0));
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands square-cornered', () {
      final mark = Play.standing(Cordings.at(0), const [(-5, 0), (5, 0), (3, 4)]);
      expect(mark.isDone, isTrue);
      expect(mark.squareCorners, [2]);
    });
  });
}
