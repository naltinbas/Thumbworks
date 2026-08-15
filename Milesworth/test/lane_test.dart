import 'package:flutter_test/flutter_test.dart';
import 'package:milesworth/lane/levels.dart';
import 'package:milesworth/lane/play.dart';
import 'package:milesworth/lane/rules.dart';

/// The law of the lane, held to.
void main() {
  group('the rules', () {
    test('a run adds up as its stones times its average', () {
      expect(Rules.sum((4, 6)), 15);
      expect(Rules.sum((1, 5)), 15);
      expect(Rules.sum((7, 8)), 15);
      expect(Rules.sum((6, 7)), 13);
      expect(Rules.length((4, 6)), 3);
      const fifteen = Rules(15);
      expect(fifteen.lands((4, 6)), isTrue);
      expect(fifteen.lands((15, 15)), isFalse);
      expect(fifteen.lands((7, 9)), isFalse);
    });

    test('the sweep finds the runs, and the odd divisors build the same', () {
      expect(Rules(15).sweep(), (3, 105));
      expect(Rules(15).landings(), [(1, 5), (4, 6), (7, 8)]);
      expect(Rules.byOddDivisors(15), [(1, 5), (4, 6), (7, 8)]);
      expect(Rules(13).landings(), [(6, 7)]);
      expect(Rules(45).landings(), [(1, 9), (5, 10), (7, 11), (14, 16), (22, 23)]);
      expect(Rules(16).sweep(), (0, 120));
      expect(Rules.oddDivisors(45), [3, 5, 9, 15, 45]);
      expect(Rules.runFor(15, 15), (7, 8));
      expect(Rules.runFor(21, 7), (1, 6));
      expect(Rules.runFor(45, 3), (14, 16));
    });

    test('sweep and odd divisors agree on every lane to a hundred, powers of two aside', () {
      for (var n = 1; n <= 100; n++) {
        expect(Rules(n).landings(), Rules.byOddDivisors(n), reason: '$n');
        expect(Rules(n).landings().isEmpty, Rules.isPowerOfTwo(n), reason: '$n');
      }
      expect(Rules.isPowerOfTwo(64), isTrue);
      expect(Rules.isPowerOfTwo(48), isFalse);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final (ways, all) = Rules(level.count).sweep();
        expect(ways, level.ways, reason: level.name);
        expect(all, level.runs, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with no marks', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.marks, isEmpty, reason: level.name);
        expect(play.run, isNull);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap marks, a tap lifts, counted both ways, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(4);
      expect(play.marks, [4]);
      expect(play.moves, 1);
      play = play.tap(4);
      expect(play.marks, isEmpty);
      expect(play.moves, 2);
      expect(play.back.marks, [4]);
      expect(play.tap(0), same(play));
      expect(play.tap(16), same(play));
    });

    test('no third mark, and the run reads either way round', () {
      final play = Play.of(Levels.at(0)).tap(6).tap(4);
      expect(play.run, (4, 6));
      expect(play.sum, 15);
      expect(play.isDone, isTrue);
      expect(play.tap(9), same(play));
      final short = Play.of(Levels.at(0)).tap(2).tap(5);
      expect(short.sum, 14);
      expect(short.isDone, isFalse);
      expect(short.tap(9), same(short));
    });

    test('the lanes by hand', () {
      expect(Play.of(Levels.at(1)).tap(10).tap(11).isDone, isTrue);
      expect(Play.of(Levels.at(2)).tap(6).tap(7).isDone, isTrue);
      expect(Play.of(Levels.at(3)).tap(1).tap(9).isDone, isTrue);
      expect(Play.of(Levels.at(3)).tap(22).tap(23).isDone, isTrue);
      expect(Play.of(Levels.at(4)).tap(1).tap(5).sum, 15);
      expect(Play.of(Levels.at(4)).tap(7).tap(9).sum, 24);
    });

    test('the pointer lands every winnable lane', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 8) {
          final (_, stone) = play.next!;
          play = play.tap(stone);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, 2, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer lifts a mark off the aim first', () {
      final play = Play.of(Levels.at(0)).tap(9);
      expect(play.next!.$1, 'lift');
      expect(play.next!.$2, 9);
    });

    test('the hopeless lane admits it at twelve moves', () {
      var play = Play.of(Levels.at(4)).tap(1).tap(5);
      expect(play.isDone, isFalse);
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(5).tap(5);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.full, isTrue);
      expect(play.tap(5), same(play));
    });

    test('a winnable lane never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap(2).tap(2);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands landed', () {
      final mark = Play.standing(Levels.at(0), const [4, 6]);
      expect(mark.isDone, isTrue);
      expect(mark.run, (4, 6));
    });
  });
}
