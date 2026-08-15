import 'package:flutter_test/flutter_test.dart';
import 'package:tithebury/tithe/levels.dart';
import 'package:tithebury/tithe/play.dart';
import 'package:tithebury/tithe/rules.dart';

/// The tithes, the asks and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the tithes', () {
    test('divisors and their sum, by the count and by the formula', () {
      expect(Rules.divisors(28), [1, 2, 4, 7, 14]);
      expect(Rules.divisors(1), isEmpty);
      expect(Rules.divisors(7), [1]);
      expect(Rules.tithe(28), 28);
      expect(Rules.tithe(10), 8);
      expect(Rules.tithe(220), 284);
      expect(Rules.tithe(284), 220);
      expect(Rules.tithe(120), 240);
      expect(Rules.tithe(256), 255);
      expect(Rules.tithe(1), 0);
      for (var n = 1; n <= 500; n++) {
        expect(Rules.titheByFormula(n), Rules.tithe(n), reason: '$n');
      }
      expect(Rules.factors(360), [(2, 3), (3, 2), (5, 1)]);
      expect(Rules.factors(97), [(97, 1)]);
      expect(Rules.settings, 500);
    });

    test('perfect, prime, powers of two, and Euclid', () {
      expect([for (var n = 1; n <= 500; n++) if (Rules.isPerfect(n)) n], [6, 28, 496]);
      expect(Rules.euclidPerfect, [6, 28, 496]);
      expect(Rules.isPrime(31), isTrue);
      expect(Rules.isPrime(1), isFalse);
      expect(Rules.isPrime(91), isFalse);
      expect(Rules.isPowerOfTwo(256), isTrue);
      expect(Rules.isPowerOfTwo(1), isTrue);
      expect(Rules.isPowerOfTwo(96), isFalse);
      expect(Rules.told([1, 2, 4, 7, 14]), '1, 2, 4, 7 and 14');
      expect(Rules.told([1]), '1');
      expect(Rules.told([]), 'nothing');
    });

    test('the sweep', () {
      expect(Rules.sweep(Rules.isPerfect), (3, 500, 6));
      expect(Rules.sweep((n) => Rules.tithe(n) == n - 1), (9, 500, 1));
      expect(Rules.sweep((n) => Rules.isPowerOfTwo(n) && Rules.tithe(n) == n), (0, 500, null));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Power of Two']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 500), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the number so its proper divisors add up to it exactly');
      expect(Levels.at(1).task, 'set the number so its proper divisors add up to a different number whose proper divisors add up to it');
      expect(Levels.at(4).task, 'set the number, a power of two, so its proper divisors add up to it exactly');
    });

    test('an ask is met by the tithe', () {
      expect(Levels.at(0).meets(496), isTrue);
      expect(Levels.at(0).meets(12), isFalse);
      expect(Levels.at(1).meets(284), isTrue);
      expect(Levels.at(1).meets(6), isFalse);
      expect(Levels.at(2).meets(18), isTrue);
      expect(Levels.at(2).meets(20), isFalse);
      expect(Levels.at(3).meets(120), isTrue);
      expect(Levels.at(4).meets(64), isFalse);
    });
  });

  group('the play', () {
    test('opens on ten, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.number, play.moves), (10, 0));
        expect(play.tithe, 8);
        expect(play.tithesTithe, 7);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a wind moves the dial, and it stops at the ends', () {
      var play = Play.of(Levels.at(0)).wind(10);
      expect((play.number, play.moves), (20, 1));
      play = play.wind(-1);
      expect((play.number, play.moves), (19, 2));
      final low = Play.standing(Levels.at(0), 1);
      expect(low.wind(-1), same(low));
      expect(low.wind(-10), same(low));
      final high = Play.standing(Levels.at(0), 495);
      final top = high.wind(10);
      expect(top.number, 500);
      expect(top.wind(1), same(top));
      expect(play.wind(0), same(play));
    });

    test('back undoes one wind', () {
      final play = Play.of(Levels.at(0)).wind(10).wind(1);
      expect(play.back.number, 20);
      expect(play.back.back.moves, 0);
    });

    test('the perfect lands at six, and it takes no more winds', () {
      final play = Play.of(Levels.at(0)).wind(-1).wind(-1).wind(-1).wind(-1);
      expect(play.number, 6);
      expect(play.isDone, isTrue);
      expect(play.wind(1), same(play));
    });

    test('the pointer winds tens then ones towards the aim', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, 10);
      for (var k = 0; k < 21; k++) {
        play = play.wind(10);
      }
      expect(play.number, 220);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      final near = Play.standing(Levels.at(0), 25);
      expect(near.next, 1);
      final over = Play.standing(Levels.at(0), 30);
      expect(over.next, -1);
      expect(Play.pointed(10), 'Wind up by 10.');
      expect(Play.pointed(-1), 'Wind down by 1.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer tallies every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          play = play.wind(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the power of two admits it at 256, or after forty winds', () {
      var play = Play.standing(Levels.at(4), 246);
      expect(play.gaveUp, isFalse);
      play = play.wind(10);
      expect(play.number, 256);
      expect(play.gaveUp, isTrue);
      expect(play.tithe, 255);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        wander = wander.wind(k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (40, true));
    });

    test('the why tells the one short and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('a power of two always comes one short'));
      expect(words, contains('This is ask 5, The Power of Two.'));
      expect(words, contains('every number from one to 500, tried in full'));
    });
  });
}
