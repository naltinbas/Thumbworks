import 'package:flutter_test/flutter_test.dart';
import 'package:evenholme/split/levels.dart';
import 'package:evenholme/split/play.dart';
import 'package:evenholme/split/rules.dart';

/// The primes, the splits, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the primes and the splits', () {
    test('the sieve and trial division agree to 2,000', () {
      for (var n = 0; n <= 2000; n++) {
        expect(Rules.isPrime(n), Rules.isPrimeByTrial(n), reason: '$n');
      }
      expect(Rules.primesTo(20), [2, 3, 5, 7, 11, 13, 17, 19]);
      expect(Rules.primesTo(2000), hasLength(303));
      expect(Rules.isPrime(1), isFalse);
      expect(Rules.isPrime(2001), isFalse);
    });

    test('the splits', () {
      expect(Rules.splits(20), [(3, 17), (7, 13)]);
      expect(Rules.splits(100), hasLength(6));
      expect(Rules.splits(4), [(2, 2)]);
      expect(Rules.splits(12), [(5, 7)]);
      expect(Rules.splits(51), isEmpty);
      expect(Rules.splits(5), [(2, 3)]);
      expect(Rules.told((3, 17)), '3 + 17');
      for (var n = 4; n <= 2000; n += 2) {
        expect(Rules.splits(n), isNotEmpty, reason: '$n');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Odd']);
      for (final level in Levels.all) {
        var met = 0;
        for (var a = 2; a <= level.number ~/ 2; a++) {
          if (level.meets(a)) met++;
        }
        expect(met, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).picks, 9);
      expect(Levels.at(4).picks, 24);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'split 20 into two primes');
      expect(Levels.at(1).task, 'split 60 into two primes two apart');
      expect(Levels.at(2).task, 'split 98 into two primes both over thirty');
      expect(Levels.at(4).task, 'split 51 into two primes');
    });

    test('an ask is met by a pick and its partner', () {
      expect(Levels.at(0).meets(3), isTrue);
      expect(Levels.at(0).meets(17), isTrue);
      expect(Levels.at(0).meets(9), isFalse);
      expect(Levels.at(1).meets(29), isTrue);
      expect(Levels.at(1).meets(7), isFalse);
      expect(Levels.at(2).meets(31), isTrue);
      expect(Levels.at(2).meets(19), isFalse);
      expect(Levels.at(4).meets(2), isFalse);
      expect(Levels.at(0).aim, 3);
      expect(Levels.at(1).aim, 29);
    });
  });

  group('the play', () {
    test('opens with nothing picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.picked, play.moves), (null, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap picks, the partner follows, and a tap on either lets go', () {
      var play = Play.of(Levels.at(0)).tap(9);
      expect((play.picked, play.partner, play.moves), (9, 11, 1));
      expect(play.pickedPrime, isFalse);
      expect(play.partnerPrime, isTrue);
      play = play.tap(11);
      expect(play.picked, isNull);
      play = play.tap(7);
      expect(play.isDone, isTrue);
      expect(play.tap(3), same(play));
    });

    test('taps out of range do nothing', () {
      final play = Play.of(Levels.at(0));
      expect(play.tap(1), same(play));
      expect(play.tap(19), same(play));
      expect(play.tap(0), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(9).tap(5);
      expect(play.back.picked, 9);
      expect(play.back.back.picked, isNull);
    });

    test('the pointer names the aim, and goes quiet once it is picked', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 3);
      play = play.tap(97);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed(3), 'Tap 3.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer splits every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        play = play.tap(play.next!);
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the odd admits it at 2, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).tap(3);
      expect(play.gaveUp, isFalse);
      play = play.tap(2);
      expect((play.picked, play.partner), (2, 49));
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap(k.isEven ? 5 : 7);
      }
      expect((wander.moves, wander.gaveUp), (20, true));
    });

    test('the why tells Goldbach and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Goldbach wrote to Euler in 1742'));
      expect(words, contains('This is ask 5, The Odd.'));
      expect(words, contains('tried in full'));
    });
  });
}
