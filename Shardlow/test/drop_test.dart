import 'package:flutter_test/flutter_test.dart';
import 'package:shardlow/drop/fewest.dart';
import 'package:shardlow/drop/ladder.dart';
import 'package:shardlow/drop/ladders.dart';
import 'package:shardlow/drop/play.dart';

void main() {
  group('the counting', () {
    test('says how many answers a run of drops can tell apart', () {
      // Three drops with one pot: break now, or now, or now, or never.
      expect(Drops.tellsApart(3, 1), 4);
      // Three drops with two pots add the two-break words.
      expect(Drops.tellsApart(3, 2), 7);
      // With as many pots as drops, every word is allowed.
      expect(Drops.tellsApart(3, 3), 8);
    });

    test('and the floor it gives is exactly the answer, everywhere', () {
      // The famous fact about this puzzle, checked rather than cited: for
      // every ladder up to 120 rungs and every hand up to four pots, the
      // search and the counting come out the same.
      for (var pots = 1; pots <= 4; pots++) {
        final drops = Drops(pots);
        for (var rungs = 1; rungs <= 120; rungs++) {
          expect(
            drops.fewestFor(rungs + 1, pots),
            Drops.countingSays(rungs + 1, pots),
            reason: '$rungs rungs, $pots pots',
          );
        }
      }
    });

    test('one pot is a rung at a time', () {
      final drops = Drops(1);
      for (var rungs = 1; rungs <= 30; rungs++) {
        expect(drops.fewestFor(rungs + 1, 1), rungs);
      }
    });

    test('and the second pot is worth almost everything', () {
      final one = Drops(1).fewestFor(101, 1);
      final two = Drops(2).fewestFor(101, 2);
      expect(one, 100);
      expect(two, 14);
    });
  });

  group('the referee', () {
    test('keeps whichever half needs more drops', () {
      final drops = Drops(2);
      const standing = Standing(lowest: 0, highest: 10);
      // Dropping from rung 1 splits 11 answers into 1 below and 10 above:
      // breaking settles it, surviving leaves nearly everything, so it
      // survives.
      expect(drops.breaksAt(standing, 1, 2), isFalse);
      // Dropping from rung 10 splits into 10 below with one pot fewer and 1
      // above: it breaks.
      expect(drops.breaksAt(standing, 10, 2), isTrue);
    });
  });

  group('every ladder that ships', () {
    for (var number = 0; number < Ladders.count; number++) {
      final ladder = Ladders.at(number);

      test('${ladder.name} says the number the search says', () {
        expect(
          Drops(ladder.pots).fewestFor(ladder.answers, ladder.pots),
          ladder.fewest,
        );
      });

      test('${ladder.name} sits exactly on the counting floor', () {
        expect(
          Drops.countingSays(ladder.answers, ladder.pots),
          ladder.fewest,
        );
      });
    }
  });

  group('a morning at the ladder', () {
    late Play play;

    setUp(() => play = Play.of(Ladders.at(1), Drops(Ladders.at(1).pots)));

    test('starts with everything possible and both pots whole', () {
      expect(play.standing.lowest, 0);
      expect(play.standing.highest, 10);
      expect(play.hand, 2);
      expect(play.couldFinishIn, 4);
    });

    test('a drop narrows what is possible', () {
      play = play.drop(4);
      expect(play.made, 1);
      expect(play.standing.answers, lessThan(11));
    });

    test('a rung outside what is possible is not worth dropping from', () {
      play = play.drop(4);
      final standing = play.standing;
      expect(play.worthDropping(standing.lowest), isFalse);
      expect(identical(play.drop(standing.lowest), play), isTrue);
    });

    test('the referee never lets the last pot leave anything unsettled', () {
      // Play to the end with sound moves; the last answer is exact.
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 10) fail('it never settled');
        play = play.drop(play.next!);
      }
      expect(play.answer, isNotNull);
      expect(play.hand, greaterThanOrEqualTo(0));
    });

    test('a greedy first drop from the top costs, and the game knows at once',
        () {
      play = play.drop(10);
      expect(play.couldFinishIn, greaterThan(4));
    });

    test('take back and again put the morning back', () {
      play = play.drop(4);
      expect(play.back.made, 0);
      play = play.drop(4).again;
      expect(play.made, 0);
      expect(play.hand, 2);
    });

    test('following the table settles every ladder at par', () {
      for (var number = 0; number < Ladders.count; number++) {
        final ladder = Ladders.at(number);
        var walk = Play.of(ladder, Drops(ladder.pots));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 20) fail('${ladder.name} never settled');
          walk = walk.drop(walk.next!);
        }
        expect(walk.made, ladder.fewest, reason: ladder.name);
        expect(walk.isFewest, isTrue, reason: ladder.name);
      }
    });

    test('one pot walks the rungs from the bottom', () {
      var walk = Play.of(Ladders.at(0), Drops(1));
      final asked = <int>[];
      var guard = 0;
      while (!walk.isDone) {
        if (guard++ > 10) fail('it never settled');
        final rung = walk.next!;
        asked.add(rung);
        walk = walk.drop(rung);
      }
      expect(asked, [1, 2, 3, 4, 5, 6]);
    });
  });
}
