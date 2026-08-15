import 'package:flutter_test/flutter_test.dart';
import 'package:squarebrook/stones/levels.dart';
import 'package:squarebrook/stones/play.dart';
import 'package:squarebrook/stones/rules.dart';

/// The law of the stones, held to.
void main() {
  group('the rules', () {
    test('the stones up to a number, and the pickings swept', () {
      expect(Rules.stones(12), [1, 4, 9]);
      expect(Rules.stones(50), [1, 4, 9, 16, 25, 36, 49]);
      expect(Rules.sweep(12, 3), (1, 10));
      expect(Rules.sweep(50, 2), (2, 28));
      expect(Rules.sweep(7, 3), (0, 4));
      expect(Rules.makings(50, 2), [[1, 49], [25, 25]]);
      expect(Rules.makings(99, 3), [[1, 49, 49], [9, 9, 81], [25, 25, 49]]);
      expect(Rules.makings(23, 4), [[1, 4, 9, 9]]);
    });

    test('the fewest squares, Lagrange and Legendre to three hundred', () {
      expect(Rules.fewest(12), 3);
      expect(Rules.fewest(7), 4);
      expect(Rules.fewest(50), 2);
      expect(Rules.fewest(49), 1);
      expect(Rules.threeSuffice(7), isFalse);
      expect(Rules.threeSuffice(28), isFalse);
      expect(Rules.threeSuffice(12), isTrue);
      for (var n = 1; n <= 300; n++) {
        final fewest = Rules.fewest(n);
        expect(fewest, lessThanOrEqualTo(4), reason: '$n');
        expect(fewest <= 3, Rules.threeSuffice(n), reason: '$n');
      }
    });

    test('by eight, three squares never leave seven', () {
      expect(Rules.leavings(1), {0, 1, 4});
      expect(Rules.leavings(3), isNot(contains(7)));
      expect(Rules.leavings(3), hasLength(7));
      expect(Rules.leavings(4), contains(7));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(Rules.sweep(level.number, level.count), (level.ways, level.pickings), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with nothing picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.picked, isEmpty, reason: level.name);
        expect(play.sum, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a pick adds, a lift takes away, the count caps; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.pick(4);
      expect(play.picked, [4]);
      expect(play.moves, 1);
      expect(play.pick(16), same(play));
      play = play.pick(9);
      expect(play.sum, 13);
      play = play.lift(0);
      expect(play.picked, [9]);
      expect(play.moves, 3);
      expect(play.back.picked, [4, 9]);
      play = play.pick(1).pick(1);
      expect(play.full, isTrue);
      expect(play.pick(1), same(play));
      expect(play.lift(5), same(play));
    });

    test('the numbers by hand', () {
      final twelve = Play.of(Levels.at(0)).pick(4).pick(4).pick(4);
      expect(twelve.isDone, isTrue);
      expect(twelve.moves, 3);
      final fifty = Play.of(Levels.at(1)).pick(49).pick(1);
      expect(fifty.isDone, isTrue);
      final other = Play.of(Levels.at(1)).pick(25).pick(25);
      expect(other.isDone, isTrue);
      final short = Play.of(Levels.at(0)).pick(1).pick(1).pick(1);
      expect(short.full, isTrue);
      expect(short.isDone, isFalse);
    });

    test('the pointer makes every winnable number', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (what, x) = play.next!;
          play = what == 'pick' ? play.pick(x) : play.lift(x);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says lift when a stone is off the making', () {
      final play = Play.of(Levels.at(3)).pick(81);
      expect(play.next, ('lift', 0));
      expect(Play.of(Levels.at(3)).next, ('pick', 1));
      expect(Play.of(Levels.at(3)).pick(49).next, ('pick', 1));
    });

    test('the hopeless number admits it at twelve taps', () {
      var play = Play.of(Levels.at(4)).pick(4).pick(1).pick(1);
      expect(play.full, isTrue);
      expect(play.sum, 6);
      for (var k = 0; k < 9; k++) {
        play = k.isEven ? play.lift(0) : play.pick(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.pick(1), same(play));
    });

    test('a winnable number never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 7; k++) {
        play = play.pick(1).lift(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands made', () {
      final mark = Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);
      expect(mark.isDone, isTrue);
      expect(mark.picked, [1, 49, 49]);
    });
  });
}
