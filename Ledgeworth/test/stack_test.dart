import 'package:flutter_test/flutter_test.dart';
import 'package:ledgeworth/stack/levels.dart';
import 'package:ledgeworth/stack/play.dart';
import 'package:ledgeworth/stack/rules.dart';

/// The law of the stack, held to.
void main() {
  group('the rules', () {
    test('edges and overhang add up from the bottom', () {
      expect(Rules.edges([12, 6, 4]), [22, 10, 4]);
      expect(Rules.overhang([12, 6, 4]), 22);
      expect(Rules.edges([0]), [0]);
    });

    test('a stack stands while every pile\'s weight stays over the edge below', () {
      expect(Rules.topples([12]), isNull);
      expect(Rules.topples([13]), 1);
      expect(Rules.topples([12, 6]), isNull);
      expect(Rules.topples([12, 7]), 2);
      expect(Rules.topples([11, 7]), 2);
      expect(Rules.topples([12, 6, 4, 3]), isNull);
      expect(Rules.topples([12, 6, 4, 4]), 4);
      expect(Rules.topples([0, 0, 0]), isNull);
    });

    test('the harmonic stack stands and reaches as the fractions say', () {
      expect(Rules.harmonic(5), [12, 6, 4, 3, 2]);
      for (var n = 1; n <= 5; n++) {
        expect(Rules.stands(Rules.harmonic(n)), isTrue, reason: '$n');
      }
      expect(Rules.harmonicOverhang(1), (1, 2));
      expect(Rules.harmonicOverhang(2), (3, 4));
      expect(Rules.harmonicOverhang(3), (11, 12));
      expect(Rules.harmonicOverhang(4), (25, 24));
      expect(Rules.harmonicOverhang(5), (137, 120));
      expect(Rules.overhang(Rules.harmonic(3)), 22);
      expect(Rules.overhang(Rules.harmonic(4)), 25);
    });

    test('the sweep reads the small stacks', () {
      expect(Rules.sweep(1, 12), (1, 25, 12));
      expect(Rules.sweep(2, 18), (1, 625, 18));
      expect(Rules.sweep(3, 24), (0, 15625, 22));
      expect(Rules.sweep(3, 22), (1, 15625, 22));
      expect(Rules.sweep(4, 24), (16, 390625, 25));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final (ways, all, _) = Rules.sweep(level.books, level.asked);
        expect(ways, level.ways, reason: level.name);
        expect(all, level.stacks, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens flush', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.offsets, List.filled(level.books, 0), reason: level.name);
        expect(play.overhang, 0);
        expect(play.stands, isTrue);
        expect(play.isDone, isFalse);
      }
    });

    test('a nudge moves one book a twenty-fourth, within the book, and back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0, 1);
      expect(play.offsets, [1, 0]);
      expect(play.moves, 1);
      expect(play.tap(0, -1).offsets, [0, 0]);
      expect(play.tap(1, -1), same(play));
      expect(play.tap(2, 1), same(play));
      expect(play.back.offsets, [0, 0]);
      var far = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        far = far.tap(0, 1);
      }
      expect(far.offsets, [24, 0, 0]);
      expect(far.tap(0, 1), same(far));
      expect(far.stands, isFalse);
    });

    test('the stacks by hand', () {
      var one = Play.of(Levels.at(0));
      for (var k = 0; k < 12; k++) {
        one = one.tap(0, 1);
      }
      expect(one.isDone, isTrue);
      expect(one.moves, 12);
      final two = Play.standing(Levels.at(1), [12, 6]);
      expect(two.isDone, isTrue);
      final four = Play.standing(Levels.at(2), [12, 6, 4, 2]);
      expect(four.overhang, 24);
      expect(four.isDone, isTrue);
      final toppled = Play.standing(Levels.at(2), [13, 6, 4, 3]);
      expect(toppled.stands, isFalse);
      expect(toppled.isDone, isFalse);
      expect(toppled.topples, 1);
    });

    test('the pointer lands every winnable stack on the harmonic', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (what, i) = play.next!;
          play = play.tap(i, what == 'right' ? 1 : -1);
        }
        expect(play.isDone, isTrue, reason: '$number');
        // The One, The Two and The Five ask for the harmonic reach itself;
        // The Four lands a twenty-fourth short of it.
        if (number != 2) {
          expect(play.offsets, Rules.harmonic(Levels.at(number).books), reason: '$number');
        } else {
          expect(play.offsets, [12, 6, 4, 2]);
        }
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer eases a book pushed too far', () {
      final play = Play.standing(Levels.at(2), [13, 0, 0, 0]);
      expect(play.next, ('left', 0));
      expect(Play.standing(Levels.at(2), [12, 6, 4, 0]).next, ('right', 3));
    });

    test('the hopeless stack admits it at twenty-six nudges', () {
      var play = Play.of(Levels.at(4));
      for (final (i, times) in [(0, 12), (1, 6), (2, 4)]) {
        for (var k = 0; k < times; k++) {
          play = play.tap(i, 1);
        }
      }
      expect(play.overhang, 22);
      expect(play.stands, isTrue);
      expect(play.moves, 22);
      for (var dither = 0; dither < 2; dither++) {
        play = play.tap(0, 1).tap(0, -1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0, 1), same(play));
    });

    test('a winnable stack never gives up', () {
      var play = Play.of(Levels.at(2));
      for (var dither = 0; dither < 14; dither++) {
        play = play.tap(0, 1).tap(0, -1);
      }
      expect(play.moves, 28);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands a whole book out and a twenty-fourth past', () {
      final mark = Play.standing(Levels.at(2), const [12, 6, 4, 3]);
      expect(mark.isDone, isTrue);
      expect(mark.overhang, 25);
      expect(mark.moves, 25);
    });
  });
}
