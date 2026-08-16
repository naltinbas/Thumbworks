import 'package:flutter_test/flutter_test.dart';
import 'package:feintley/feint/levels.dart';
import 'package:feintley/feint/play.dart';
import 'package:feintley/feint/rules.dart';

/// The test, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the test', () {
    test('the powers, the passes, the liars and the squares', () {
      expect(Rules.powMod(2, 340, 341), 1);
      expect(Rules.powWhole(2, 340, 341), 1);
      expect(Rules.powMod(3, 340, 341), 56);
      expect(Rules.powMod(2, 90, 91), 64);
      expect(Rules.passes(2, 341), isTrue);
      expect(Rules.passes(3, 341), isFalse);
      expect(Rules.passes(2, 91), isFalse);
      expect(Rules.passes(3, 91), isTrue);
      expect(Rules.passes(2, 7), isTrue);
      expect(Rules.passes(7, 7), isFalse);
      expect(Rules.isPrime(1009), isTrue);
      expect(Rules.isPrime(561), isFalse);
      expect(Rules.factor(341), 11);
      expect(Rules.factor(1009), isNull);
      expect(Rules.liar(2, 341), isTrue);
      expect(Rules.liar(2, 7), isFalse);
      expect(Rules.carmichael(561), isTrue);
      expect(Rules.carmichael(341), isFalse);
      expect(Rules.carmichael(1105), isTrue);
      expect(Rules.gcd(11, 561), 11);
      expect(Rules.squares(2, 341).length, 9);
      expect(Rules.squares(2, 341).first, (0, 2, false));
      expect(Rules.squares(2, 341).where((s) => s.$3).length, 4);
      expect(Rules.tell(1200), '1,200');
    });

    test('the sweep: the two powers agree everywhere, every prime passes, and the liars are the sweep\'s', () {
      final sieve = Rules.sieve;
      var settings = 0, primePasses = 0, liars = 0;
      final byBase = <int, int>{};
      for (var n = 2; n <= Rules.most; n++) {
        expect(Rules.isPrime(n), sieve[n], reason: '$n');
        for (var a = 2; a <= 12; a++) {
          settings++;
          expect(Rules.powWhole(a, n - 1, n), Rules.powMod(a, n - 1, n), reason: '$n on $a');
          final passes = Rules.passes(a, n);
          if (Rules.isPrime(n)) {
            expect(passes, Rules.gcd(a, n) == 1, reason: '$n on $a');
            if (passes) primePasses++;
          } else if (passes) {
            liars++;
            byBase[a] = (byBase[a] ?? 0) + 1;
          }
        }
      }
      expect((settings, primePasses, liars), (13189, 2142, 116));
      expect(byBase[2], 4);
      expect(byBase[3], 7);
      expect(byBase[8], 22);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Failing Prime']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var n = 2; n <= Rules.most; n++) {
          for (var a = 2; a <= 12; a++) {
            if (level.meets(n, a)) ways++;
          }
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (1009, 2));
      expect(Levels.at(1).aim, (341, 2));
      expect(Levels.at(2).aim, (91, 3));
      expect(Levels.at(3).aim, (561, 2));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set a prime above a thousand and a base, and have it pass');
      expect(Levels.at(1).task, 'set a composite that passes on base two');
      expect(Levels.at(2).task, 'set a composite that passes on base three');
      expect(Levels.at(3).task, 'set a composite that passes on every base it shares no factor with, and such a base');
      expect(Levels.at(4).task, 'set a prime and a base it does not divide, and have it fail');
    });

    test('an ask is met by the setting', () {
      expect(Levels.at(0).meets(1009, 2), isTrue);
      expect(Levels.at(0).meets(997, 2), isFalse);
      expect(Levels.at(0).meets(1000, 2), isFalse);
      expect(Levels.at(1).meets(341, 2), isTrue);
      expect(Levels.at(1).meets(341, 3), isFalse);
      expect(Levels.at(1).meets(7, 2), isFalse);
      expect(Levels.at(2).meets(91, 3), isTrue);
      expect(Levels.at(2).meets(91, 2), isFalse);
      expect(Levels.at(3).meets(561, 2), isTrue);
      expect(Levels.at(3).meets(561, 11), isFalse);
      expect(Levels.at(3).meets(1105, 2), isTrue);
      expect(Levels.at(3).meets(341, 2), isFalse);
      expect(Levels.at(4).meets(7, 2), isFalse);
      expect(Levels.at(0).meets(1201, 2), isFalse);
    });
  });

  group('the play', () {
    test('opens at 91 on base two', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.number, play.base, play.moves), (91, 2, 0));
        expect(play.prime, isFalse);
        expect(play.passes, isFalse);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step moves a dial and stops at the ends', () {
      final play = Play.of(Levels.at(4));
      expect(play.step('n', 10).number, 101);
      expect(play.step('a', 1).base, 3);
      expect(play.step('a', -1), same(play));
      expect(Play.standing(Levels.at(4), 1195, 2).step('n', 10).number, 1200);
      expect(Play.standing(Levels.at(4), 3, 2).step('n', -10).number, 2);
      final atTheTop = Play.standing(Levels.at(4), 91, 12);
      expect(atTheTop.step('a', 1), same(atTheTop));
      expect(play.step('n', 10).moves, 1);
      expect(play.step('n', 10).seen, {101});
      expect(play.step('a', 1).seen, isEmpty);
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(0)).step('n', 10).step('a', 1);
      expect((play.back.number, play.back.base), (101, 2));
      expect((play.back.back.number, play.back.back.base), (91, 2));
    });

    test('the pointer steps the number by tens, then ones, then the base', () {
      expect(Play.of(Levels.at(1)).next, ('n', 10));
      expect(Play.pointed(('n', 10)), 'Step the number up by 10.');
      expect(Play.standing(Levels.at(1), 339, 2).next, ('n', 1));
      expect(Play.pointed(('n', 1)), 'Step the number up by 1.');
      expect(Play.standing(Levels.at(2), 91, 2).next, ('a', 1));
      expect(Play.pointed(('a', 1)), 'Step the base up.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 200) {
          final (which, by) = play.next!;
          play = play.step(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var liar = Play.of(Levels.at(1));
      while (!liar.isDone) {
        final (which, by) = liar.next!;
        liar = liar.step(which, by);
      }
      expect((liar.number, liar.base, liar.moves), (341, 2, 25));
    });

    test('the failing prime admits it after three primes, or twenty taps', () {
      var play = Play.of(Levels.at(4)).step('n', 10);
      expect(play.number, 101);
      expect(play.seen, {101});
      expect(play.gaveUp, isFalse);
      play = play.step('n', 1).step('n', 1);
      expect(play.seen, {101, 103});
      play = play.step('n', 1).step('n', 1).step('n', 1).step('n', 1);
      expect(play.number, 107);
      expect(play.seen, {101, 103, 107});
      expect(play.gaveUp, isTrue);
      expect(play.moves, 7);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.step('a', k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 20);
    });

    test('the why tells Fermat and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('as Fermat wrote in 1640'));
      expect(words, contains('13,189 settings'));
      expect(words, contains('This is ask 5, The Failing Prime.'));
      expect(words, contains('tested in full'));
    });
  });
}
