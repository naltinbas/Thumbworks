import 'package:flutter_test/flutter_test.dart';
import 'package:sevenby/turn/levels.dart';
import 'package:sevenby/turn/play.dart';
import 'package:sevenby/turn/rules.dart';

/// The divisions, the clock, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the decimals', () {
    test('a seventh the long way, and by the clock', () {
      expect(Rules.divide(1, 7).$1, [1, 4, 2, 8, 5, 7]);
      expect(Rules.divide(1, 7).$2, [1, 3, 2, 6, 4, 5]);
      expect(Rules.divide(2, 7).$1, [2, 8, 5, 7, 1, 4]);
      expect(Rules.divide(1, 13).$1, [0, 7, 6, 9, 2, 3]);
      expect(Rules.divide(1, 37).$1, [0, 2, 7]);
      expect(Rules.divide(1, 3).$1, [3]);
      expect(Rules.divide(1, 3).$2, [1]);
      expect(Rules.divide(1, 11).$1, [0, 9]);
      expect(Rules.periodByDivision(1, 7), 6);
      expect(Rules.periodByClock(7), 6);
      expect(Rules.periodByClock(13), 6);
      expect(Rules.periodByClock(37), 3);
      expect(Rules.periodByClock(47), 46);
      expect(Rules.isFullTurn(7), isTrue);
      expect(Rules.isFullTurn(13), isFalse);
      expect(Rules.blockValue([1, 4, 2, 8, 5, 7]), BigInt.from(142857));
      expect(Rules.blockValue([1, 4, 2, 8, 5, 7]) * BigInt.from(7), Rules.nines(6));
      expect(Rules.isRotation([2, 8, 5, 7, 1, 4], [1, 4, 2, 8, 5, 7]), isTrue);
      expect(Rules.isRotation([1, 5, 3, 8, 4, 6], [0, 7, 6, 9, 2, 3]), isFalse);
      expect(Rules.tellDigits([0, 2, 7]), '027');
      expect(Rules.commas(BigInt.from(999999)), '999,999');
      expect(Rules.settings, 308);
      expect(Rules.primes, [3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]);
    });

    test('division and the clock agree on every fraction, the period divides p - 1, and Midy holds', () {
      for (final p in Rules.primes) {
        final byClock = Rules.periodByClock(p);
        expect((p - 1) % byClock, 0, reason: '$p');
        for (var k = 1; k < p; k++) {
          final (digits, remainders) = Rules.divide(k, p);
          expect(digits.length, byClock, reason: '$k/$p');
          expect(remainders.first, k);
          expect(Rules.blockValue(digits) * BigInt.from(p), Rules.nines(digits.length) * BigInt.from(k), reason: '$k/$p');
          if (digits.length.isEven) {
            final h = digits.length ~/ 2;
            expect(Rules.blockValue(digits.sublist(0, h)) + Rules.blockValue(digits.sublist(h)), Rules.nines(h), reason: 'Midy $k/$p');
          }
        }
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Long Turn']);
      for (final level in Levels.all) {
        var n = 0;
        for (final p in Rules.primes) {
          for (var k = 1; k < p; k++) {
            if (level.meets(p, k)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (7, 1));
      expect(Levels.at(1).aim, (7, 1));
      expect(Levels.at(2).aim, (7, 2));
      expect(Levels.at(3).aim, (37, 1));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial a fraction whose decimal comes round every six places');
      expect(Levels.at(1).task, 'dial a fraction whose decimal takes the whole turn to come round, p - 1 places');
      expect(Levels.at(2).task, 'dial a fraction over seven, not a seventh itself, and read the digits of a seventh from another start');
      expect(Levels.at(4).task, 'dial a fraction whose decimal takes more than p - 1 places to come round');
    });

    test('an ask is met by the fraction', () {
      expect(Levels.at(0).meets(7, 3), isTrue);
      expect(Levels.at(0).meets(13, 5), isTrue);
      expect(Levels.at(0).meets(11, 1), isFalse);
      expect(Levels.at(1).meets(17, 4), isTrue);
      expect(Levels.at(1).meets(13, 1), isFalse);
      expect(Levels.at(2).meets(7, 6), isTrue);
      expect(Levels.at(2).meets(7, 1), isFalse);
      expect(Levels.at(2).meets(13, 2), isFalse);
      expect(Levels.at(3).meets(37, 36), isTrue);
      expect(Levels.at(3).meets(3, 1), isFalse);
      expect(Levels.at(4).meets(47, 1), isFalse);
      expect(Levels.at(0).meets(9, 1), isFalse);
      expect(Levels.at(0).meets(7, 7), isFalse);
    });
  });

  group('the play', () {
    test('opens at one over eleven', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.prime, play.top, play.moves), (11, 1, 0));
        expect(play.period, 2);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the dials turn a step a tap, prime to prime, and stop at their ends', () {
      var play = Play.of(Levels.at(3)).set(1, 1);
      expect((play.prime, play.top, play.moves), (11, 2, 1));
      expect(play.digits, [1, 8]);
      play = play.set(0, 1);
      expect((play.prime, play.top), (13, 2));
      // A seventh lands nothing on the three, so the prime can run down.
      var low = Play.of(Levels.at(3));
      while (low.prime > 3) {
        low = low.set(0, -1);
      }
      expect(low.set(0, -1), same(low));
      expect((low.prime, low.top), (3, 1));
      var high = Play.of(Levels.at(4));
      while (high.prime < 47 && !high.isOver) {
        high = high.set(0, 1);
      }
      expect(high.isOver, isTrue);
      final one = play.set(1, -1);
      expect(one.set(1, -1), same(one));
    });

    test('a prime turned down past the top drags the top down', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 9; k++) {
        play = play.set(1, 1);
      }
      expect((play.prime, play.top), (11, 10));
      expect(play.set(1, 1), same(play));
      play = play.set(0, -1);
      expect((play.prime, play.top), (7, 6));
      expect(play.isDone, isTrue);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(3)).set(1, 1).set(1, 1);
      expect(play.top, 3);
      expect(play.back.top, 2);
      expect(play.back.back.top, 1);
    });

    test('the pointer turns the prime first, then the top', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (0, -1));
      play = play.set(0, -1);
      expect((play.prime, play.top), (7, 1));
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, -1)), 'Turn the prime down.');
      expect(Play.pointed((1, 1)), 'Turn the top up.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the long turn admits it at a full turn, or after twelve taps', () {
      var play = Play.of(Levels.at(4)).set(0, 1);
      expect((play.prime, play.period), (13, 6));
      expect(play.gaveUp, isFalse);
      play = play.set(0, 1);
      expect((play.prime, play.period), (17, 16));
      expect(play.isFullTurn, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.set(1, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the clock, Midy and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Midy\'s theorem'));
      expect(words, contains('308 fractions'));
      expect(words, contains('This is ask 5, The Long Turn.'));
      expect(words, contains('divided out in full'));
    });
  });
}
