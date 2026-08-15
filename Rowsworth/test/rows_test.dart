import 'package:flutter_test/flutter_test.dart';
import 'package:rowsworth/pebble/askings.dart';
import 'package:rowsworth/pebble/play.dart';
import 'package:rowsworth/pebble/rules.dart';

/// The law of the rows, held to.
void main() {
  group('the rules', () {
    test('every label\'s heaps are what the sweep finds', () {
      final rules = Rules();
      for (final asking in Askings.all) {
        expect(rules.heapsWith(asking.rows), asking.heaps, reason: asking.name);
      }
    });

    test('divisors, factors and the two counts', () {
      expect(Rules.divisors(12), [1, 2, 3, 4, 6, 12]);
      expect(Rules.factors(60), [(2, 2), (3, 1), (5, 1)]);
      expect(Rules.factors(64), [(2, 6)]);
      expect(Rules.factors(1), isEmpty);
      expect(Rules.rowsByPowers(60), 12);
      expect(Rules.rowsByTrial(60), 12);
      for (var n = 1; n <= 1000; n++) {
        expect(Rules.rowsByTrial(n), Rules.rowsByPowers(n), reason: '$n');
      }
    });

    test('the smallest heaps and the records', () {
      expect(Rules.smallestWith(7), 64);
      expect(Rules.smallestWith(12), 60);
      expect(Rules.smallestWith(13), 4096);
      expect(Rules().records(), [1, 2, 4, 6, 12, 24, 36, 48, 60]);
    });

    test('a prime count of rows is one prime raised', () {
      for (var n = 2; n <= 1000; n++) {
        final rows = Rules.rowsByPowers(n);
        var prime = rows > 1;
        for (var d = 2; d * d <= rows; d++) {
          if (rows % d == 0) prime = false;
        }
        if (prime) expect(Rules.factors(n), hasLength(1), reason: '$n');
      }
    });
  });

  group('the play', () {
    test('opens with no heap', () {
      for (final asking in Askings.all) {
        final play = Play.of(asking);
        expect(play.heap, isNull, reason: asking.name);
        expect(play.rows, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a pick sets the heap, counted every one, and back undoes', () {
      var play = Play.of(Askings.at(3));
      play = play.pick(24);
      expect(play.heap, 24);
      expect(play.rows, 8);
      expect(play.moves, 1);
      play = play.pick(60);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
      expect(play.back.heap, 24);
      expect(play.pick(60), same(play));
    });

    test('a pick off the board does nothing', () {
      final play = Play.of(Askings.at(0));
      expect(play.pick(0), same(play));
      expect(play.pick(101), same(play));
    });

    test('the seven rows meet at sixty-four alone', () {
      final play = Play.of(Askings.at(0)).pick(64);
      expect(play.isDone, isTrue);
      expect(Play.of(Askings.at(0)).pick(63).isDone, isFalse);
      expect(Play.of(Askings.at(0)).next, 64);
    });

    test('the pointer meets the nine and the twelve', () {
      for (final number in [1, 3]) {
        final play = Play.of(Askings.at(number));
        expect(play.pick(play.next!).isDone, isTrue, reason: '$number');
      }
    });

    test('the hopeless asking admits it at twelve picks', () {
      var play = Play.of(Askings.at(4));
      for (var n = 1; n <= 12; n++) {
        play = play.pick(n * 8);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      expect(play.pick(3), same(play));
    });

    test('a winnable asking never gives up', () {
      var play = Play.of(Askings.at(3));
      for (var n = 1; n <= 13; n++) {
        play = play.pick(n);
      }
      expect(play.moves, 13);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands met', () {
      final mark = Play.standing(Askings.at(3), 60);
      expect(mark.isDone, isTrue);
      expect(mark.rows, 12);
    });
  });
}
