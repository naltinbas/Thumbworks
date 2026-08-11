import 'package:flutter_test/flutter_test.dart';
import 'package:shroveham/griddle/batches.dart';
import 'package:shroveham/griddle/fewest.dart';
import 'package:shroveham/griddle/play.dart';

/// Every ordering of the sizes 1..n, biggest first to start.
Iterable<List<int>> _orderings(int n) sync* {
  yield* _permuted([for (var size = n; size >= 1; size--) size], 0);
}

Iterable<List<int>> _permuted(List<int> cakes, int from) sync* {
  if (from == cakes.length) {
    yield [...cakes];
    return;
  }
  for (var at = from; at < cakes.length; at++) {
    var swap = cakes[from]; cakes[from] = cakes[at]; cakes[at] = swap;
    yield* _permuted(cakes, from + 1);
    swap = cakes[from]; cakes[from] = cakes[at]; cakes[at] = swap;
  }
}

void main() {
  group('the flip', () {
    test('turns everything above the slice over, and undoes itself', () {
      expect(Flips.flipped(const [4, 2, 5, 3, 1], 2), [4, 2, 1, 3, 5]);
      expect(Flips.flipped(const [4, 2, 5, 3, 1], 0), [1, 3, 5, 2, 4]);
      final batch = [6, 4, 7, 3, 1, 5, 2];
      expect(Flips.flipped(Flips.flipped(batch, 3), 3), batch);
    });
  });

  group('the walk', () {
    test('reaches every arrangement there is', () {
      expect(Flips.walk(5).length, 120);
      expect(Flips.walk(6).length, 720);
    });

    test('and the served batch is nought flips from itself', () {
      expect(Flips.byWalk(const [5, 4, 3, 2, 1]), 0);
      expect(Flips.byWalk(const [4, 3, 2, 1]), 0);
    });
  });

  group('the floor', () {
    test('a served batch has no gaps, and the worst have many', () {
      expect(Flips.gaps(const [5, 4, 3, 2, 1]), 0);
      expect(Flips.gaps(const [4, 2, 5, 3, 1]), 5);
    });

    test('no flip ever mends more than one gap, over every batch of five '
        'and every slice', () {
      // The whole of the floor argument, swept rather than trusted: 119
      // batches, four slices each, and the gap count never falls by two.
      for (final cakes in _orderings(5)) {
        final gaps = Flips.gaps(cakes);
        for (var under = 0; under <= 3; under++) {
          expect(gaps - Flips.gaps(Flips.flipped(cakes, under)),
              lessThanOrEqualTo(1),
              reason: '$cakes under $under');
        }
      }
    });

    test('so the walk never beats the gaps, on every batch of five and six',
        () {
      for (final n in const [5, 6]) {
        for (final cakes in _orderings(n)) {
          expect(Flips.byWalk(cakes),
              greaterThanOrEqualTo(Flips.gaps(cakes)),
              reason: '$cakes');
        }
      }
    });

    test('and the slack is real: some batches need more than their gaps', () {
      var slack = 0;
      for (final cakes in _orderings(5)) {
        if (Flips.byWalk(cakes) > Flips.gaps(cakes)) slack++;
      }
      expect(slack, greaterThan(0));
      expect(Flips.byWalk(const [4, 5, 3, 1, 2]), 4);
      expect(Flips.gaps(const [4, 5, 3, 1, 2]), 3);
    });
  });

  group('the hand', () {
    test('serves every batch of five and six, never under the walk, never '
        'over two flips a cake', () {
      for (final n in const [5, 6]) {
        for (final cakes in _orderings(n)) {
          final hand = Flips.byHand(cakes);
          expect(hand, greaterThanOrEqualTo(Flips.byWalk(cakes)),
              reason: '$cakes');
          expect(hand, lessThanOrEqualTo(2 * n - 3), reason: '$cakes');
        }
      }
    });

    test('and pays two over the fewest on the batch named for it', () {
      final batch = Batches.at(3);
      expect(Flips.byHand(batch.cakes), batch.fewest + 2);
    });
  });

  group('every batch that ships', () {
    for (var number = 0; number < Batches.count; number++) {
      final batch = Batches.at(number);

      test('${batch.name} is what it says it is', () {
        expect(batch.cakes.toSet().length, batch.many);
        expect(Flips.byWalk(batch.cakes), batch.fewest);
      });
    }

    test('the floor carries the first, second and last, and falls short on '
        'the slack batch', () {
      expect(Flips.gaps(Batches.at(0).cakes), Batches.at(0).fewest);
      expect(Flips.gaps(Batches.at(1).cakes), Batches.at(1).fewest);
      expect(Flips.gaps(Batches.at(4).cakes), Batches.at(4).fewest);
      expect(Flips.gaps(Batches.at(2).cakes), Batches.at(2).fewest - 1);
    });

    test('the tall order wants a flip for every cake', () {
      expect(Batches.at(4).fewest, Batches.at(4).many);
    });
  });

  group('a batch in play', () {
    test('starts as dealt, with the fewest still to be had', () {
      final play = Play.of(Batches.at(0));
      expect(play.made, 0);
      expect(play.isServed, isFalse);
      expect(play.couldStillBe, Batches.at(0).fewest);
    });

    test('the slice goes anywhere but under the top cake alone', () {
      final play = Play.of(Batches.at(0));
      expect(play.mayFlip(0), isTrue);
      expect(play.mayFlip(2), isTrue);
      expect(play.mayFlip(3), isFalse);
      expect(play.mayFlip(-1), isFalse);
      expect(identical(play.flip(3), play), isTrue);
    });

    test('following next serves every batch at its fewest', () {
      for (var number = 0; number < Batches.count; number++) {
        final batch = Batches.at(number);
        var play = Play.of(batch);
        var guard = 0;
        while (!play.isServed) {
          if (guard++ > 10) fail('${batch.name} never served');
          expect(play.couldStillBe, batch.fewest, reason: batch.name);
          play = play.flip(play.next!);
        }
        expect(play.made, batch.fewest, reason: batch.name);
        expect(play.isFewest, isTrue, reason: batch.name);
      }
    });

    test('a wasted flip shows in the live number at once', () {
      final play = Play.of(Batches.at(1));
      var wasted = -1;
      for (var under = 0; under <= 3; under++) {
        if (play.flip(under).couldStillBe > play.batch.fewest) {
          wasted = under;
          break;
        }
      }
      expect(wasted, isNot(-1));
      // A flip can lose one going nowhere, or two going backwards; either
      // way the live number rises past the par the moment it happens.
      expect(
        play.flip(wasted).couldStillBe,
        inInclusiveRange(play.batch.fewest + 1, play.batch.fewest + 2),
      );
    });

    test('take back returns the batch as it lay', () {
      final start = Play.of(Batches.at(0));
      final flipped = start.flip(start.next!);
      expect(flipped.made, 1);
      expect(flipped.back.cakes, Batches.at(0).cakes);
      expect(identical(start.back, start), isTrue);
    });

    test('gaps are counted live', () {
      var play = Play.of(Batches.at(0));
      expect(play.gapsNow, 3);
      while (!play.isServed) {
        play = play.flip(play.next!);
      }
      expect(play.gapsNow, 0);
    });
  });
}
