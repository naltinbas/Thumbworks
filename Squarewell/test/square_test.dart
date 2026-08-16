import 'package:flutter_test/flutter_test.dart';
import 'package:squarewell/square/levels.dart';
import 'package:squarewell/square/play.dart';
import 'package:squarewell/square/rules.dart';

/// The squares, Euler's test, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the squares', () {
    test('the squares on seven and eleven, by bases and by Euler', () {
      expect(Rules.squaresByBases(7), {1, 2, 4});
      expect(Rules.squaresByEuler(7), {1, 2, 4});
      expect(Rules.squaresByBases(11), {1, 3, 4, 5, 9});
      expect(Rules.rootsOf(2, 7), [3, 4]);
      expect(Rules.rootsOf(2, 11), isEmpty);
      expect(Rules.rootsOf(12, 13), [5, 8]);
      expect(Rules.isSquareByEuler(2, 7), isTrue);
      expect(Rules.isSquareByEuler(3, 7), isFalse);
      expect(Rules.powMod(2, 3, 7), 1);
      expect(Rules.powMod(3, 3, 7), 6);
      expect(Rules.powMod(2, 5, 11), 10);
      expect(Rules.told({1, 2, 4}), '1, 2 and 4');
      expect(Rules.told({1}), '1');
      expect(Rules.settings, 90);
      expect(Rules.clocks, [3, 5, 7, 11, 13, 17, 19, 23]);
      expect(Rules.isPrime(97), isTrue);
      expect(Rules.isPrime(91), isFalse);
    });

    test('the two voices agree on every prime clock to a hundred, half the hours squares', () {
      var primes = 0;
      for (var p = 3; p <= 100; p++) {
        if (!Rules.isPrime(p)) continue;
        primes++;
        final byBases = Rules.squaresByBases(p), byEuler = Rules.squaresByEuler(p);
        expect(byEuler, byBases, reason: '$p');
        expect(byBases, hasLength((p - 1) ~/ 2), reason: '$p');
        expect(byBases.contains(p - 1), p % 4 == 1, reason: 'minus one on $p');
        expect(byBases.contains(2 % p), p % 8 == 1 || p % 8 == 7, reason: 'two on $p');
        for (var h = 1; h < p; h++) {
          final roots = Rules.rootsOf(h, p);
          expect(roots.isEmpty || (roots.length == 2 && roots[0] + roots[1] == p), isTrue, reason: '$h on $p');
        }
      }
      expect(primes, 24);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Two of Eleven']);
      for (final level in Levels.all) {
        var n = 0;
        for (final p in Rules.clocks) {
          for (var b = 1; b < p; b++) {
            if (level.meets(p, b)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (7, 3));
      expect(Levels.at(1).aim, (7, 3));
      expect(Levels.at(2).aim, (5, 2));
      expect(Levels.at(3).aim, (7, 3));
      expect(Levels.at(0).settings, 6);
      expect(Levels.at(2).settings, 90);
      expect(Levels.at(4).settings, 10);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial a base on the seven-hour clock whose square is 2');
      expect(Levels.at(1).task, 'dial a base on the seven-hour clock standing on an hour that no base squares to');
      expect(Levels.at(2).task, 'dial a base and a clock so that the square is one short of the clock');
      expect(Levels.at(4).task, 'dial a base on the eleven-hour clock whose square is 2');
    });

    test('an ask is met on its clock', () {
      expect(Levels.at(0).meets(7, 3), isTrue);
      expect(Levels.at(0).meets(7, 4), isTrue);
      expect(Levels.at(0).meets(7, 2), isFalse);
      expect(Levels.at(0).meets(17, 6), isFalse);
      expect(Levels.at(1).meets(7, 5), isTrue);
      expect(Levels.at(1).meets(7, 4), isFalse);
      expect(Levels.at(2).meets(13, 5), isTrue);
      expect(Levels.at(2).meets(7, 6), isFalse);
      expect(Levels.at(3).meets(23, 18), isTrue);
      expect(Levels.at(3).meets(11, 3), isFalse);
      expect(Levels.at(4).meets(11, 3), isFalse);
    });
  });

  group('the play', () {
    test('opens at base 1, the clock locked or at eleven', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.base, 1);
        expect(play.clock, level.clock ?? 11);
        expect((play.moves, play.square), (0, 1));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap, prime to prime, and stop at their ends', () {
      var play = Play.of(Levels.at(2)).set(1, 1);
      expect((play.clock, play.base, play.moves), (11, 2, 1));
      expect(play.square, 4);
      play = play.set(0, 1);
      expect((play.clock, play.base), (13, 2));
      // Base 1 lands nothing, so the clock can run to either end.
      var low = Play.of(Levels.at(2));
      while (low.clock > 3) {
        low = low.set(0, -1);
      }
      expect(low.set(0, -1), same(low));
      expect((low.clock, low.base, low.moves), (3, 1, 3));
      var high = Play.of(Levels.at(2));
      while (high.clock < 23) {
        high = high.set(0, 1);
      }
      expect(high.set(0, 1), same(high));
      expect(high.clock, 23);
      final one = play.set(1, -1);
      expect(one.set(1, -1), same(one));
    });

    test('a clock turned down past the base drags the base down', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 9; k++) {
        play = play.set(1, 1);
      }
      expect((play.clock, play.base), (11, 10));
      expect(play.set(1, 1), same(play));
      play = play.set(0, -1);
      expect((play.clock, play.base), (7, 6));
    });

    test('a locked clock does not turn, and back undoes one tap', () {
      final play = Play.of(Levels.at(0));
      expect(play.set(0, 1), same(play));
      final two = play.set(1, 1).set(1, 1);
      expect(two.base, 3);
      expect(two.back.base, 2);
      expect(two.back.back.base, 1);
    });

    test('the pointer turns the clock first, then the base', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (0, -1));
      while (play.clock > 5) {
        play = play.set(0, -1);
      }
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, -1)), 'Turn the clock down.');
      expect(Play.pointed((1, 1)), 'Turn the base up.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the two of eleven admits it once every base is tried, or after twelve taps', () {
      var play = Play.of(Levels.at(4));
      for (var b = 2; b <= 10; b++) {
        play = play.set(1, 1);
        expect(play.gaveUp, b == 10, reason: 'base $b');
      }
      expect(play.tried, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.set(1, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Euler and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Euler found in 1748'));
      expect(words, contains('90 settings'));
      expect(words, contains('This is ask 5, The Two of Eleven.'));
      expect(words, contains('squared in full'));
    });
  });
}
