import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:foldbury/fold/fewest.dart';
import 'package:foldbury/fold/fold.dart';
import 'package:foldbury/fold/folds.dart';
import 'package:foldbury/fold/play.dart';

/// A fold on two banks of gates, every lane running between the banks.
Fold _twoBanks(Random random, {int left = 4, int right = 4, int lanes = 8}) {
  final chosen = <(int, int)>{};
  var guard = 0;
  while (chosen.length < lanes && guard++ < 200) {
    chosen.add((random.nextInt(left), left + random.nextInt(right)));
  }
  return Fold(
    name: 'two banks',
    fewest: 0,
    gates: [
      for (var gate = 0; gate < left + right; gate++)
        Gate('G$gate', random.nextDouble(), random.nextDouble()),
    ],
    lanes: [for (final (one, other) in chosen) Lane(one, other)],
  );
}

void main() {
  group('the fold', () {
    final fold = Folds.at(2);

    test('knows which lanes a gate touches', () {
      expect(fold.lanesAt(1), [1, 3, 6, 7, 8]);
      expect(fold.busiest, 5);
    });

    test('and when a set of gates watches every lane', () {
      expect(fold.watches(0), isFalse);
      expect(fold.watches(Watches.of(fold).posted), isTrue);
    });
  });

  group('the two floors', () {
    test('the matching really is a matching, on every fold', () {
      for (var number = 0; number < Folds.count; number++) {
        final fold = Folds.at(number);
        final matching = Watches.of(fold).matching;
        final used = <int>{};
        for (final lane in matching) {
          expect(used.add(fold[lane].from), isTrue, reason: fold.name);
          expect(used.add(fold[lane].to), isTrue, reason: fold.name);
        }
      }
    });

    test('neither floor ever sits above the answer', () {
      for (var number = 0; number < Folds.count; number++) {
        final watch = Watches.of(Folds.at(number));
        expect(watch.matching.length, lessThanOrEqualTo(watch.fewest));
        expect(watch.byLanes, lessThanOrEqualTo(watch.fewest));
      }
    });

    test('on two banks the matching floor is always exactly the answer', () {
      // Konig's theorem from 1931: when every lane runs between two banks of
      // gates, the biggest matching and the fewest shepherds are the same
      // number. The two searches share nothing but the fold, and they have
      // to agree on every such fold there is.
      final random = Random(1931);
      for (var go = 0; go < 300; go++) {
        final fold = _twoBanks(
          random,
          left: 2 + random.nextInt(3),
          right: 2 + random.nextInt(3),
          lanes: 3 + random.nextInt(6),
        );
        final watch = Watches.of(fold);
        expect(watch.matching.length, watch.fewest,
            reason: fold.lanes
                .map((lane) => '${lane.from}-${lane.to}')
                .join(' '));
      }
    });

    test('and the ring of three is where it comes apart', () {
      final triangle = Folds.at(1);
      final watch = Watches.of(triangle);
      expect(watch.matching.length, 1);
      expect(watch.fewest, 2);
      expect(watch.byLanes, 2);
      expect(watch.floorSaysSo, isTrue);
    });
  });

  group('every fold that ships', () {
    for (var number = 0; number < Folds.count; number++) {
      final fold = Folds.at(number);

      test('${fold.name} says the number the search says', () {
        expect(Watches.of(fold).fewest, fold.fewest);
      });

      test('${fold.name} carries a floor that proves it', () {
        expect(Watches.of(fold).floorSaysSo, isTrue);
      });
    }

    test('past the teaching pair, greed posts a shepherd too many', () {
      for (var number = 2; number < Folds.count; number++) {
        final fold = Folds.at(number);
        expect(Watches.byGreed(fold), greaterThan(fold.fewest),
            reason: fold.name);
      }
    });
  });

  group('a night at the fold', () {
    late Play play;

    setUp(() => play = Play.of(Folds.at(2), Watches.of(Folds.at(2))));

    test('starts with nobody posted and every lane dark', () {
      expect(play.standing, 0);
      expect(play.unwatched, 9);
      expect(play.couldStillBe, 3);
    });

    test('posting a shepherd lights the lanes at the gate', () {
      play = play.touch(1);
      expect(play.isPosted(1), isTrue);
      expect(play.unwatched, 4);
    });

    test('and touching the gate again stands them down', () {
      play = play.touch(1).touch(1);
      expect(play.standing, 0);
    });

    test('the greedy walk costs, and the game says so before the end', () {
      // Posting at whichever gate lights the most dark lanes, over and over,
      // ends at four shepherds on this fold. The busiest gate alone is
      // forgivable; it is the second greedy post that throws the third
      // shepherd away, and couldStillBe says so the moment it happens.
      var sawRise = false;
      var guard = 0;
      while (!play.isDone && guard++ < 8) {
        var best = -1;
        var most = -1;
        for (var gate = 0; gate < play.fold.count; gate++) {
          if (play.isPosted(gate)) continue;
          final lights = play.fold
              .lanesAt(gate)
              .where((lane) => !play.laneWatched(lane))
              .length;
          if (lights > most) {
            most = lights;
            best = gate;
          }
        }
        play = play.touch(best);
        if (!play.isDone && play.couldStillBe > 3) sawRise = true;
      }
      expect(play.standing, 4);
      expect(sawRise, isTrue);
    });

    test('asking posts every fold at its fewest', () {
      for (var number = 0; number < Folds.count; number++) {
        var walk = Play.of(Folds.at(number), Watches.of(Folds.at(number)));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 12) fail('${Folds.at(number).name} never watched');
          walk = walk.touch(walk.next!);
        }
        expect(walk.standing, Folds.at(number).fewest,
            reason: Folds.at(number).name);
        expect(walk.isFewest, isTrue);
      }
    });

    test('and asking after a poor start still finishes as well as it can', () {
      // Post two gates greedily, then ask the rest of the way; the total
      // matches what couldStillBe promised at the moment asking began.
      for (var post = 0; post < 2; post++) {
        var best = -1;
        var most = -1;
        for (var gate = 0; gate < play.fold.count; gate++) {
          if (play.isPosted(gate)) continue;
          final lights = play.fold
              .lanesAt(gate)
              .where((lane) => !play.laneWatched(lane))
              .length;
          if (lights > most) {
            most = lights;
            best = gate;
          }
        }
        play = play.touch(best);
      }
      final could = play.couldStillBe;
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 12) fail('it never watched');
        play = play.touch(play.next!);
      }
      expect(play.standing, could);
    });
  });
}
