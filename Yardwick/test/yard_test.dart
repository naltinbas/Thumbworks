import 'package:flutter_test/flutter_test.dart';
import 'package:yardwick/yard/levels.dart';
import 'package:yardwick/yard/play.dart';
import 'package:yardwick/yard/rules.dart';

/// The hedges, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the hedges', () {
    test('the Fibonacci numbers, the two yardsticks, the measuring and Euclid on the counts', () {
      expect([for (var i = 1; i <= 10; i++) Rules.fib(i).toInt()], [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
      expect(Rules.fib(30), BigInt.from(832040));
      expect(Rules.gcd(30, 12), 6);
      expect(Rules.measureByHedges(30, 12), BigInt.from(8));
      expect(Rules.measureByCounts(30, 12), BigInt.from(8));
      expect(Rules.measureByHedges(4, 6), BigInt.one);
      expect(Rules.measureByHedges(30, 15), BigInt.from(610));
      expect(Rules.euclidOnCounts(30, 12), [(30, 12), (12, 6), (6, 0)]);
      expect(Rules.euclidOnCounts(6, 9), [(6, 9), (9, 6), (6, 3), (3, 0)]);
      expect(Rules.divides(3, 9), isTrue);
      expect(Rules.divides(4, 6), isFalse);
      expect(Rules.divides(2, 7), isTrue);
      expect(Rules.dividesByCounts(3, 9), isTrue);
      expect(Rules.dividesByCounts(4, 6), isFalse);
      expect(Rules.isPrime(BigInt.from(89)), isTrue);
      expect(Rules.isPrime(BigInt.from(4181)), isFalse);
      expect(Rules.isPrimeInt(19), isTrue);
      expect(Rules.tell(BigInt.from(832040)), '832,040');
    });

    test('the sweep: the two yardsticks agree on every pair of counts, and the measuring too', () {
      var coprime = 0, sly = 0, whole = 0;
      for (var m = 1; m <= 30; m++) {
        for (var n = 1; n <= 30; n++) {
          final byHedges = Rules.measureByHedges(m, n);
          expect(Rules.measureByCounts(m, n), byHedges, reason: '$m, $n');
          expect(Rules.dividesByCounts(m, n), Rules.divides(m, n), reason: '$m, $n');
          expect(byHedges == BigInt.one, Rules.gcd(m, n) <= 2, reason: '$m, $n');
          if (byHedges == BigInt.one) coprime++;
          if (byHedges == BigInt.one && Rules.gcd(m, n) > 1 && m >= 3 && n >= 3) sly++;
          if (m >= 3 && m < n && Rules.divides(m, n)) whole++;
        }
      }
      expect((coprime, sly, whole), (698, 114, 38));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Odd Share']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var m = 1; m <= 30; m++) {
          for (var n = 1; n <= 30; n++) {
            if (level.meets(m, n)) ways++;
          }
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (5, 5));
      expect(Levels.at(1).aim, (4, 6));
      expect(Levels.at(2).aim, (3, 6));
      expect(Levels.at(3).aim, (10, 10));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the two counts so that the yardstick is five');
      expect(Levels.at(1).task, 'set two counts above two that share a factor while their hedges share none');
      expect(Levels.at(2).task, 'set the counts so that the first hedge, three or more, measures the longer second hedge exactly');
      expect(Levels.at(3).task, 'set the two counts so that the yardstick is 55 or longer');
      expect(Levels.at(4).task, 'set two counts that share no factor while their hedges share one');
    });

    test('an ask is met by the counts', () {
      expect(Levels.at(0).meets(5, 5), isTrue);
      expect(Levels.at(0).meets(30, 25), isTrue);
      expect(Levels.at(0).meets(6, 9), isFalse);
      expect(Levels.at(1).meets(4, 6), isTrue);
      expect(Levels.at(1).meets(2, 4), isFalse);
      expect(Levels.at(1).meets(6, 9), isFalse);
      expect(Levels.at(2).meets(3, 9), isTrue);
      expect(Levels.at(2).meets(6, 3), isFalse);
      expect(Levels.at(2).meets(2, 8), isFalse);
      expect(Levels.at(3).meets(10, 10), isTrue);
      expect(Levels.at(3).meets(30, 15), isTrue);
      expect(Levels.at(3).meets(9, 9), isFalse);
      expect(Levels.at(4).meets(7, 9), isFalse);
      expect(Levels.at(0).meets(0, 5), isFalse);
    });
  });

  group('the play', () {
    test('opens at 6 and 9', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.first, play.second, play.moves), (6, 9, 0));
        expect(play.measure, BigInt.from(2));
        expect(play.commonCount, 3);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step moves one count within one and thirty', () {
      final play = Play.of(Levels.at(4));
      expect((play.step('m', 1).first, play.step('m', 1).second), (7, 9));
      expect(play.step('n', -1).second, 8);
      expect(Play.standing(Levels.at(4), 30, 9).step('m', 1), isNotNull);
      expect(Play.standing(Levels.at(4), 30, 9).step('m', 1).first, 30);
      expect(Play.standing(Levels.at(4), 1, 9).step('m', -1).first, 1);
      expect(play.step('m', 1).moves, 1);
      expect(play.step('m', 1).seen, {'7,9'});
      expect(play.step('n', -1).seen, isEmpty);
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(0)).step('m', 1).step('n', 1);
      expect((play.back.first, play.back.second), (7, 9));
      expect((play.back.back.first, play.back.back.second), (6, 9));
    });

    test('the pointer steps the first count first, then the second', () {
      expect(Play.of(Levels.at(0)).next, ('m', -1));
      expect(Play.pointed(('m', -1)), 'Step the first count down.');
      expect(Play.of(Levels.at(3)).next, ('m', 1));
      expect(Play.standing(Levels.at(3), 10, 9).next, ('n', 1));
      expect(Play.pointed(('n', 1)), 'Step the second count up.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          final (which, by) = play.next!;
          play = play.step(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var long = Play.of(Levels.at(3));
      while (!long.isDone) {
        final (which, by) = long.next!;
        long = long.step(which, by);
      }
      expect((long.first, long.second, long.moves), (10, 10, 5));
    });

    test('the odd share admits it after three coprime settings, or sixteen taps', () {
      var play = Play.of(Levels.at(4)).step('m', 1).step('m', 1);
      expect(play.seen, {'7,9', '8,9'});
      expect(play.gaveUp, isFalse);
      play = play.step('m', 1);
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      play = play.step('n', 1);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 4);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 16; k++) {
        wander = wander.step('n', k.isEven ? 3 : -3);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 16);
    });

    test('the why tells Lucas and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('as Lucas set down in 1876'));
      expect(words, contains('900 settings'));
      expect(words, contains('This is ask 5, The Odd Share.'));
      expect(words, contains('measured in full'));
    });
  });
}
