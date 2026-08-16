import 'package:flutter_test/flutter_test.dart';
import 'package:onesby/ones/levels.dart';
import 'package:onesby/ones/play.dart';
import 'package:onesby/ones/rules.dart';

/// The rows, the two tellings, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the rows', () {
    test('a row of p ones is 2 to the p less 1, prime or not both ways', () {
      expect(Rules.row(7), BigInt.from(127));
      expect(Rules.row(11), BigInt.from(2047));
      expect(Rules.row(31), BigInt.from(2147483647));
      expect(Rules.row(5).toRadixString(2), '11111');
      expect(Rules.rowIsPrimeByDivision(7), isTrue);
      expect(Rules.rowIsPrimeByLucasLehmer(7), isTrue);
      expect(Rules.rowIsPrimeByDivision(11), isFalse);
      expect(Rules.rowIsPrimeByLucasLehmer(11), isFalse);
      expect(Rules.rowIsPrimeByDivision(2), isTrue);
      expect(Rules.rowIsPrimeByLucasLehmer(2), isTrue);
      expect(Rules.chain(7), [4, 14, 67, 42, 111, 0].map(BigInt.from).toList());
      expect(Rules.chain(5), [4, 14, 8, 0].map(BigInt.from).toList());
      expect(Rules.smallestFactor(BigInt.from(2047)), BigInt.from(23));
      expect(Rules.smallestFactor(BigInt.from(127)), BigInt.from(127));
      expect(Rules.smallestExponentFactor(9), 3);
      expect(Rules.smallestExponentFactor(25), 5);
      expect(Rules.smallestExponentFactor(11), 11);
      expect(Rules.isPrime(31), isTrue);
      expect(Rules.isPrime(1), isFalse);
      expect(Rules.commas(BigInt.from(2147483647)), '2,147,483,647');
      expect(Rules.settings, 30);
    });

    test('division and the chain agree on every exponent, and composite lengths divide', () {
      final primeRows = <int>[];
      for (var p = 2; p <= 31; p++) {
        expect(Rules.rowIsPrimeByLucasLehmer(p), Rules.rowIsPrimeByDivision(p), reason: '$p');
        if (Rules.rowIsPrimeByDivision(p)) primeRows.add(p);
        if (!Rules.isPrime(p)) {
          final a = Rules.smallestExponentFactor(p);
          expect(Rules.row(p) % Rules.row(a), BigInt.zero, reason: '$p');
          expect(Rules.smallestFactor(Rules.row(p)), Rules.row(a), reason: '$p');
        }
      }
      expect(primeRows, [2, 3, 5, 7, 13, 17, 19, 31]);
    });

    test('the perfect numbers add back', () {
      expect(Rules.perfect(2), BigInt.from(6));
      expect(Rules.perfect(7), BigInt.from(8128));
      expect(Rules.aliquot(BigInt.from(8128)), BigInt.from(8128));
      expect(Rules.aliquot(BigInt.from(496)), BigInt.from(496));
      expect(Rules.aliquot(BigInt.from(12)), BigInt.from(16));
      expect(Rules.perfect(13), BigInt.from(33550336));
      expect(Rules.aliquot(BigInt.from(33550336)), BigInt.from(33550336));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Composite Row']);
      for (final level in Levels.all) {
        var n = 0;
        for (var p = 2; p <= 31; p++) {
          if (level.meets(p)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, 11);
      expect(Levels.at(1).aim, 11);
      expect(Levels.at(2).aim, 7);
      expect(Levels.at(3).aim, 31);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial a prime exponent whose row of ones is not prime');
      expect(Levels.at(1).task, 'dial an exponent whose row of ones 23 divides');
      expect(Levels.at(2).task, 'dial the exponent whose prime row makes the perfect number 8,128');
      expect(Levels.at(3).task, 'dial the longest row of ones the dial holds that is prime');
      expect(Levels.at(4).task, 'dial a composite exponent whose row of ones is prime');
    });

    test('an ask is met by the exponent alone', () {
      expect(Levels.at(0).meets(11), isTrue);
      expect(Levels.at(0).meets(23), isTrue);
      expect(Levels.at(0).meets(13), isFalse);
      expect(Levels.at(0).meets(9), isFalse);
      expect(Levels.at(1).meets(22), isTrue);
      expect(Levels.at(1).meets(23), isFalse);
      expect(Levels.at(2).meets(7), isTrue);
      expect(Levels.at(2).meets(5), isFalse);
      expect(Levels.at(3).meets(31), isTrue);
      expect(Levels.at(3).meets(19), isFalse);
      expect(Levels.at(4).meets(4), isFalse);
      expect(Levels.at(4).meets(7), isFalse);
      expect(Levels.at(0).meets(1), isFalse);
      expect(Levels.at(0).meets(32), isFalse);
    });
  });

  group('the play', () {
    test('opens at two ones', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.exponent, play.moves), (2, 0));
        expect(play.row, BigInt.from(3));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('winds by one or ten, stopping at the ends', () {
      var play = Play.of(Levels.at(3)).wind(10);
      expect((play.exponent, play.moves), (12, 1));
      play = play.wind(10).wind(10);
      expect(play.exponent, 31);
      expect(play.moves, 3);
      expect(play.isDone, isTrue);
      final low = Play.of(Levels.at(3));
      expect(low.wind(-1), same(low));
      expect(low.wind(-10), same(low));
      final near = Play.of(Levels.at(0)).wind(10).wind(10).wind(10);
      expect(near.exponent, 31);
      final top = near.wind(1);
      expect(top, same(near));
      expect(near.wind(10), same(near));
    });

    test('back undoes one wind', () {
      final play = Play.of(Levels.at(0)).wind(1).wind(1);
      expect(play.exponent, 4);
      expect(play.back.exponent, 3);
      expect(play.back.back.exponent, 2);
    });

    test('the pointer winds towards the aim, ten while it can', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 10);
      play = play.wind(10).wind(10);
      expect(play.exponent, 22);
      expect(play.next, 1);
      expect(Play.pointed(10), 'Wind up by 10.');
      expect(Play.pointed(-1), 'Wind down by 1.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          play = play.wind(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the composite row admits it after four composite lengths, or twelve taps', () {
      var play = Play.of(Levels.at(4));
      for (final e in [4, 6, 8]) {
        play = play.wind(e - play.exponent);
      }
      expect(play.seen, {4, 6, 8});
      expect(play.gaveUp, isFalse);
      play = play.wind(1);
      expect(play.exponent, 9);
      expect(play.seen, {4, 6, 8, 9});
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.wind(k.isEven ? 1 : -1);
      }
      expect(wander.exponent, 2);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Mersenne, Euclid and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Mersenne\'s numbers'));
      expect(words, contains('Lucas-Lehmer chain'));
      expect(words, contains('This is ask 5, The Composite Row.'));
      expect(words, contains('told prime or not both ways'));
    });
  });
}
