import 'package:flutter_test/flutter_test.dart';
import 'package:filberthow/hoard/hoards.dart';
import 'package:filberthow/hoard/play.dart';
import 'package:filberthow/hoard/rules.dart';

void main() {
  group('the split', () {
    test('is Fibonacci clusters, no two neighbours, and unique by being '
        'greedy', () {
      final fibs = Rules.fibsTo(200).toSet();
      for (var nuts = 1; nuts <= 120; nuts++) {
        final split = Rules.split(nuts);
        expect(split.fold(0, (sum, part) => sum + part), nuts);
        for (final part in split) {
          expect(fibs, contains(part), reason: '$nuts: $part');
        }
        // No two neighbours in the run: each part at least twice-ish the
        // next, the Fibonacci way.
        final run = Rules.fibsTo(200);
        for (var at = 1; at < split.length; at++) {
          final hi = run.indexOf(split[at - 1]);
          final lo = run.indexOf(split[at]);
          expect(hi - lo, greaterThanOrEqualTo(2),
              reason: '$nuts: ${split[at - 1]} next to ${split[at]}');
        }
      }
    });
  });

  group('the rule and the search', () {
    test('agree on every standing to sixty nuts', () {
      // The anchor. The search knows takes and caps; the split knows a
      // greedy sum. They never part.
      for (var nuts = 1; nuts <= 60; nuts++) {
        for (var cap = 1; cap <= nuts; cap++) {
          expect(Rules.isLoss(nuts, cap), Rules.isLossBySplit(nuts, cap),
              reason: '$nuts nuts, cap $cap');
        }
      }
    });

    test('the opener is lost exactly on the Fibonacci hoards', () {
      final fibs = Rules.fibsTo(100).toSet();
      for (var nuts = 3; nuts <= 60; nuts++) {
        expect(Rules.isLoss(nuts, nuts - 1), fibs.contains(nuts),
            reason: '$nuts nuts');
      }
    });

    test('the winning take is the smallest cluster, and it works', () {
      for (var nuts = 4; nuts <= 60; nuts++) {
        if (Rules.isLoss(nuts, nuts - 1)) continue;
        final take = Rules.winningTake(nuts, nuts - 1);
        expect(take, Rules.split(nuts).last, reason: '$nuts nuts');
        expect(Rules.isLoss(nuts - take, 2 * take), isTrue,
            reason: '$nuts nuts take $take');
      }
    });
  });

  group('every hoard that ships', () {
    for (var number = 0; number < Hoards.count; number++) {
      final hoard = Hoards.at(number);

      test('${hoard.name} says what the search says', () {
        expect(!Rules.isLoss(hoard.nuts, hoard.nuts - 1), hoard.winnable);
      });
    }

    test('the fibonacci hoard is one whole cluster', () {
      expect(Rules.split(Hoards.at(2).nuts), [34]);
    });

    test('the long hoard splits four deep', () {
      expect(Rules.split(Hoards.at(4).nuts), [34, 13, 5, 2]);
    });
  });

  group('a hoard in play', () {
    test('opens with the whole hoard and a cap one short', () {
      final play = Play.of(Hoards.at(0));
      expect(play.nuts, 20);
      expect(play.cap, 19);
      expect(play.winnable, isTrue);
      expect(play.next, 2);
    });

    test('a take brings the grey squirrel\'s answer on its heels', () {
      final play = Play.of(Hoards.at(0)).take(2);
      expect(play.made, 1);
      expect(play.theirLast, greaterThan(0));
      expect(play.winnable, isTrue);
      expect(play.cap, 2 * play.theirLast <= play.nuts
          ? 2 * play.theirLast
          : play.nuts);
    });

    test('the wrong take hands the hoard over, and the game knows at once',
        () {
      final play = Play.of(Hoards.at(0)).take(5);
      expect(play.winnable, isFalse);
      expect(play.next, isNull);
    });

    test('following the split wins every winnable hoard', () {
      for (var number = 0; number < Hoards.count; number++) {
        final hoard = Hoards.at(number);
        if (!hoard.winnable) continue;
        var play = Play.of(hoard);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 40) fail('${hoard.name} never ended');
          expect(play.winnable, isTrue, reason: hoard.name);
          play = play.take(play.next!);
        }
        expect(play.won, isTrue, reason: hoard.name);
      }
    });

    test('the grey squirrel never loses the fibonacci hoard to a smallest-'
        'cluster shadow', () {
      // Play every opening take on 34: the machine answers and the player
      // follows any winning take they ever get; they never get one.
      for (var opening = 1; opening <= 20; opening++) {
        var play = Play.of(Hoards.at(2)).take(opening);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 60) fail('the hoard never emptied');
          expect(play.next, isNull, reason: 'opening $opening');
          play = play.take(1);
        }
        expect(play.won, isFalse, reason: 'opening $opening');
      }
    });

    test('take back returns the whole exchange', () {
      final start = Play.of(Hoards.at(0));
      final taken = start.take(2);
      expect(taken.back.nuts, 20);
      expect(identical(start.back, start), isTrue);
    });

    test('no take lands out of cap or past the hoard', () {
      final play = Play.of(Hoards.at(0)).take(2);
      expect(identical(play.take(play.cap + 1), play), isTrue);
      expect(identical(play.take(0), play), isTrue);
    });
  });
}
