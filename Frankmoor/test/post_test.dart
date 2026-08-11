import 'package:flutter_test/flutter_test.dart';
import 'package:frankmoor/post/letters.dart';
import 'package:frankmoor/post/play.dart';
import 'package:frankmoor/post/rules.dart';

void main() {
  group('the walk and the sweep', () {
    test('payable agrees with brute force on every amount to a hundred',
        () {
      for (final (cheap, dear) in const [(5, 7), (3, 8), (5, 8), (4, 9)]) {
        for (var amount = 1; amount <= 100; amount++) {
          var brute = false;
          for (var c = 0; c * cheap <= amount && !brute; c++) {
            for (var d = 0; c * cheap + d * dear <= amount && !brute; d++) {
              if (c * cheap + d * dear == amount) brute = true;
            }
          }
          expect(Rules.payable(amount, cheap, dear), brute,
              reason: '$amount with $cheap, $dear');
        }
      }
    });

    test('the largest gap is ab less a less b, swept true', () {
      for (final (cheap, dear) in const [(5, 7), (3, 8), (5, 8), (4, 9)]) {
        expect(Rules.frobenius(cheap, dear),
            Rules.frobeniusBySweep(cheap, dear),
            reason: '$cheap, $dear');
        // And everything above it is payable, well past the bound.
        for (var amount = Rules.frobenius(cheap, dear) + 1;
            amount <= Rules.frobenius(cheap, dear) + 40;
            amount++) {
          expect(Rules.payable(amount, cheap, dear), isTrue,
              reason: '$amount with $cheap, $dear');
        }
      }
    });

    test('the gap count is half of (a-1)(b-1), swept true', () {
      for (final (cheap, dear) in const [(5, 7), (3, 8), (5, 8), (4, 9)]) {
        expect(
            Rules.gaps(cheap, dear), Rules.gapsBySweep(cheap, dear),
            reason: '$cheap, $dear');
      }
    });

    test('the twenty three walk is the counter-top proof', () {
      expect(Rules.walk(23, 5, 7), [23, 16, 9, 2]);
      for (final left in Rules.walk(23, 5, 7)) {
        expect(left % 5, isNot(0));
      }
    });

    test('paying finds real ways, fewest dear stamps first', () {
      expect(Rules.paying(24, 5, 7), (2, 2));
      expect(Rules.paying(33, 5, 7), (1, 4));
      expect(Rules.paying(14, 3, 8), (2, 1));
      expect(Rules.paying(23, 5, 7), isNull);
    });
  });

  group('every letter that ships', () {
    for (var number = 0; number < Letters.count; number++) {
      final letter = Letters.at(number);

      test('${letter.name} says what the walk says', () {
        expect(Rules.payable(letter.amount, letter.cheap, letter.dear),
            letter.payable);
      });
    }

    test('the unpayable letters are their stamps\' largest gaps', () {
      expect(Letters.at(2).amount,
          Rules.frobenius(Letters.at(2).cheap, Letters.at(2).dear));
      expect(Letters.at(4).amount,
          Rules.frobenius(Letters.at(4).cheap, Letters.at(4).dear));
    });
  });

  group('a letter at the counter', () {
    test('opens bare and payable when it is', () {
      final play = Play.of(Letters.at(0));
      expect(play.total, 0);
      expect(play.owed, 24);
      expect(play.canStill, isTrue);
    });

    test('stamps go on and come off', () {
      var play = Play.of(Letters.at(0)).affix(true).affix(false);
      expect(play.total, 12);
      expect(play.back.total, 5);
      expect(identical(Play.of(Letters.at(0)).back,
          Play.of(Letters.at(0)).back.back), isFalse);
    });

    test('following next pays every payable letter exactly', () {
      for (var number = 0; number < Letters.count; number++) {
        final letter = Letters.at(number);
        if (!letter.payable) continue;
        var play = Play.of(letter);
        var guard = 0;
        while (!play.isPaid) {
          if (guard++ > 12) fail('${letter.name} never paid');
          expect(play.canStill, isTrue, reason: letter.name);
          play = play.affix(play.next!);
        }
        expect(play.total, letter.amount, reason: letter.name);
      }
    });

    test('a wrong stamp is known at once', () {
      // On the odd parcel, a second five strands the letter.
      var play = Play.of(Letters.at(1)).affix(true).affix(true);
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('the unpayable letter can never even start', () {
      final play = Play.of(Letters.at(2));
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('overshooting is unreachable too', () {
      var play = Play.of(Letters.at(0));
      for (var stamps = 0; stamps < 5; stamps++) {
        play = play.affix(false);
      }
      expect(play.total, greaterThan(play.letter.amount));
      expect(play.canStill, isFalse);
    });
  });
}
