import 'package:flutter_test/flutter_test.dart';
import 'package:ellmarsh/cloth/benches.dart';
import 'package:ellmarsh/cloth/play.dart';
import 'package:ellmarsh/cloth/rules.dart';

void main() {
  group('the gap and the search', () {
    test('agree on every pair to a hundred and fifty ells', () {
      // The anchor. The search knows cuts; the gap knows one whole-number
      // inequality. 11,325 pairs, no parting.
      for (var long = 1; long <= 150; long++) {
        for (var short = 1; short <= long; short++) {
          expect(Rules.isLoss(long, short), Rules.isLossByGap(long, short),
              reason: '$long, $short');
        }
      }
    });

    test('choice appears exactly where the quotient is two or more, and '
        'choice is winning', () {
      for (var long = 2; long <= 120; long++) {
        for (var short = 1; short < long; short++) {
          if (long % short == 0) continue;
          if (Rules.quotient(long, short) >= 2) {
            expect(Rules.isLoss(long, short), isFalse,
                reason: '$long, $short has choice');
          }
        }
      }
    });

    test('consecutive Fibonacci pairs alternate across the edge', () {
      expect(Rules.isLoss(13, 8), isFalse);
      expect(Rules.isLoss(21, 13), isTrue);
      expect(Rules.isLoss(34, 21), isFalse);
      expect(Rules.isLoss(55, 34), isTrue);
      expect(Rules.isLoss(89, 55), isFalse);
    });

    test('the near run wins by a single ell of margin', () {
      expect(34 * 34, 1156);
      expect(34 * 21 + 21 * 21, 1155);
      expect(55 * 55, 3025);
      expect(55 * 34 + 34 * 34, 3026);
    });

    test('the winning cut hands over a lost pair, everywhere it exists', () {
      for (var long = 2; long <= 100; long++) {
        for (var short = 1; short < long; short++) {
          if (Rules.isLoss(long, short)) continue;
          final times = Rules.winningTimes(long, short);
          expect(times, greaterThan(0), reason: '$long, $short');
          expect(Rules.isLoss(long - times * short, short), isTrue,
              reason: '$long, $short times $times');
        }
      }
    });
  });

  group('every bench that ships', () {
    for (var number = 0; number < Benches.count; number++) {
      final bench = Benches.at(number);

      test('${bench.name} says what the search says', () {
        expect(!Rules.isLoss(bench.long, bench.short), bench.winnable);
      });
    }
  });

  group('a bench in play', () {
    test('opens as the mercer left it', () {
      final play = Play.of(Benches.at(0));
      expect(play.long, 25);
      expect(play.short, 7);
      expect(play.quotient, 3);
      expect(play.winnable, isTrue);
      expect(play.next, 2);
    });

    test('a cut brings the mercer\'s answer on its heels', () {
      final play = Play.of(Benches.at(0)).cut(2);
      expect(play.made, 1);
      expect(play.theirLast, greaterThan(0));
      expect(play.winnable, isTrue);
    });

    test('the wrong cut hands the bench over at once', () {
      final play = Play.of(Benches.at(0)).cut(1);
      expect(play.winnable, isFalse);
      expect(play.next, isNull);
    });

    test('following the gap holds every winnable bench', () {
      for (var number = 0; number < Benches.count; number++) {
        final bench = Benches.at(number);
        if (!bench.winnable) continue;
        var play = Play.of(bench);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 30) fail('${bench.name} never ended');
          expect(play.winnable, isTrue, reason: bench.name);
          play = play.cut(play.next!);
        }
        expect(play.won, isTrue, reason: bench.name);
      }
    });

    test('the golden bench is forced the whole way down, and lost', () {
      var play = Play.of(Benches.at(3));
      expect(play.winnable, isFalse);
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 30) fail('the golden bench never ended');
        expect(play.quotient, 1, reason: 'a choice appeared');
        play = play.cut(1);
      }
      expect(play.won, isFalse);
    });

    test('take back returns the whole exchange', () {
      final start = Play.of(Benches.at(0));
      final cutOnce = start.cut(2);
      expect(cutOnce.back.long, 25);
      expect(identical(start.back, start), isTrue);
    });

    test('no cut lands past the quotient', () {
      final play = Play.of(Benches.at(0));
      expect(identical(play.cut(4), play), isTrue);
      expect(identical(play.cut(0), play), isTrue);
    });
  });
}
