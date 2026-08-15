import 'package:flutter_test/flutter_test.dart';
import 'package:cloakwell/rail/levels.dart';
import 'package:cloakwell/rail/play.dart';
import 'package:cloakwell/rail/rules.dart';

/// The law of the rail, held to.
void main() {
  group('the rules', () {
    test('pairs out of order are counted', () {
      expect(Rules.inversions([1, 2, 3, 4]), 0);
      expect(Rules.inversions([2, 1, 4, 3]), 2);
      expect(Rules.inversions([4, 3, 2, 1]), 6);
      expect(Rules.inversions([2, 4, 1, 5, 3]), 4);
      expect(Rules.sorted([1, 2, 3]), isTrue);
      expect(Rules.swapped([4, 3, 2, 1], 0), [3, 4, 2, 1]);
      expect(Rules.firstDescent([1, 3, 2]), 1);
      expect(Rules.firstDescent([1, 2, 3]), isNull);
    });

    test('the fewest swaps by search is the count of pairs, and the sign agrees', () {
      for (var n = 1; n <= 5; n++) {
        Rules.rows(n, (r) {
          final inv = Rules.inversions(r);
          expect(Rules.fewestBySearch(r), inv, reason: '$r');
          expect(Rules.signByCycles(r), inv.isEven ? 1 : -1, reason: '$r');
        });
      }
    });

    test('a swap changes the count by exactly one', () {
      Rules.rows(4, (r) {
        for (var i = 0; i + 1 < r.length; i++) {
          final d = Rules.inversions(Rules.swapped(r, i)) - Rules.inversions(r);
          expect(d.abs(), 1, reason: '$r $i');
        }
      });
    });

    test('the sequences count as told', () {
      expect(Rules.sequences([2, 1, 4, 3], 2), (2, 9));
      expect(Rules.sequences([4, 3, 2, 1], 6), (16, 729));
      expect(Rules.sequences([4, 3, 2, 1], 5), (0, 243));
      expect(Rules.sequences([4, 3, 2, 1], 7), (0, 2187));
      expect(Rules.sequences([2, 4, 1, 5, 3], 4), (5, 256));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final (sorting, all) = Rules.sequences(level.row, level.swaps);
        expect(sorting, level.ways, reason: level.name);
        expect(all, level.sequences, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens as the coats hang', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.row, level.row, reason: level.name);
        expect(play.moves, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap swaps two neighbours, counted, and back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0);
      expect(play.row, [3, 4, 2, 1]);
      expect(play.moves, 1);
      expect(play.inversions, 5);
      expect(play.tap(3), same(play));
      expect(play.back.row, [4, 3, 2, 1]);
    });

    test('the rails by hand', () {
      final two = Play.of(Levels.at(0)).tap(0).tap(2);
      expect(two.isDone, isTrue);
      final other = Play.of(Levels.at(0)).tap(2).tap(0);
      expect(other.isDone, isTrue);
      final wasted = Play.of(Levels.at(0)).tap(1).tap(1);
      expect(wasted.missed, isTrue);
      expect(wasted.isDone, isFalse);
      expect(wasted.gaveUp, isFalse);
      expect(wasted.tap(0), same(wasted));
      final four = Play.of(Levels.at(1)).tap(0).tap(1).tap(2).tap(0).tap(1).tap(0);
      expect(four.isDone, isTrue);
    });

    test('the pointer lands every winnable rail', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, i) = play.next!;
          play = play.tap(i);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).swaps, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer keeps quiet once a swap is wasted', () {
      final play = Play.of(Levels.at(1)).tap(0).tap(0);
      expect(play.inversions, 6);
      expect(play.left, 4);
      expect(play.next, isNull);
    });

    test('the hopeless rail cracks at five swaps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 5; k++) {
        play = play.tap(Rules.firstDescent(play.row)!);
      }
      expect(play.moves, 5);
      expect(play.inversions, 1);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the mark stands as the reverse of four', () {
      final mark = Play.of(Levels.at(1));
      expect(mark.inversions, 6);
    });
  });
}
