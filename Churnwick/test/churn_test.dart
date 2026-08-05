import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:churnwick/churn/dairies.dart';
import 'package:churnwick/churn/dairy.dart';
import 'package:churnwick/churn/fewest.dart';
import 'package:churnwick/churn/play.dart';

void main() {
  group('the dairy', () {
    final dairy = Dairy(name: 'three and five', churns: const [3, 5], want: 4);

    test('filling a churn puts it to the brim', () {
      expect(const Pour.fill(1).on(dairy, [0, 0]), [0, 5]);
    });

    test('emptying one puts it to nothing', () {
      expect(const Pour.empty(1).on(dairy, [0, 5]), [0, 0]);
    });

    test('pouring stops when the first is empty', () {
      expect(const Pour.tip(0, 1).on(dairy, [3, 0]), [0, 3]);
    });

    test('and when the second is full', () {
      expect(const Pour.tip(1, 0).on(dairy, [0, 5]), [3, 2]);
    });

    test('a pour that changes nothing is not a pour', () {
      expect(const Pour.fill(0).doesAnything(dairy, [3, 0]), isFalse);
      expect(const Pour.empty(0).doesAnything(dairy, [0, 0]), isFalse);
      expect(const Pour.tip(0, 1).doesAnything(dairy, [0, 3]), isFalse);
      expect(const Pour.tip(0, 1).doesAnything(dairy, [3, 5]), isFalse);
      expect(const Pour.tip(0, 1).doesAnything(dairy, [3, 0]), isTrue);
    });

    test('and neither is one from a churn into itself', () {
      expect(const Pour.tip(0, 0).doesAnything(dairy, [3, 0]), isFalse);
    });
  });

  group('the step', () {
    test('is the biggest number every churn is a whole number of', () {
      expect(Pouring.stepOf(const [3, 5]), 1);
      expect(Pouring.stepOf(const [6, 10]), 2);
      expect(Pouring.stepOf(const [9, 15]), 3);
      expect(Pouring.stepOf(const [5, 6, 11]), 1);
    });

    test('and what can stand is the multiples of it', () {
      final dairy = Dairy(name: 'x', churns: const [6, 10], want: 8);
      expect(Pouring.whatCanStand(dairy), [2, 4, 6, 8, 10]);
    });

    test('which is exactly what walking the whole dairy finds', () {
      // The one that matters. The step is arithmetic and says what can be
      // measured without looking at anything; walking the dairy looks at
      // everything. They have to agree, on every dairy there is.
      final random = Random(1848);
      for (var go = 0; go < 120; go++) {
        final churns = [
          for (var churn = 0; churn < 2 + random.nextInt(2); churn++)
            2 + random.nextInt(12),
        ];
        final dairy = Dairy(name: 'x', churns: churns, want: -1);
        expect(
          Pouring.reachedByWalking(churns),
          Pouring.whatCanStand(dairy).toSet(),
          reason: 'on churns of $churns',
        );
      }
    });

    test('and nothing that is not a multiple of it can be wanted', () {
      final dairy = Dairy(name: 'x', churns: const [6, 10], want: 5);
      expect(Pouring.canBeDone(dairy), isFalse);
      expect(Pouring.fewestFor(dairy), isNull);
    });

    test('nor anything bigger than the biggest churn', () {
      final dairy = Dairy(name: 'x', churns: const [3, 5], want: 8);
      expect(Pouring.canBeDone(dairy), isFalse);
      expect(Pouring.fewestFor(dairy), isNull);
    });
  });

  group('the fewest goes', () {
    test('three and five make four in six', () {
      final dairy = Dairy(name: 'x', churns: const [3, 5], want: 4);
      final measure = Pouring.fewestFor(dairy)!;
      expect(measure.pours, 6);

      // And doing what it says really does leave four standing.
      var standing = dairy.empty;
      for (final pour in measure.how) {
        expect(pour.doesAnything(dairy, standing), isTrue);
        standing = pour.on(dairy, standing);
      }
      expect(standing, contains(4));
    });

    test('nothing at all when the churn is already the size wanted', () {
      final dairy = Dairy(name: 'x', churns: const [4, 9], want: 4);
      expect(Pouring.fewestFor(dairy)!.pours, 1);
    });

    test('walking it and working it out agree, on every two churn dairy '
        'up to thirteen', () {
      // Two churns leave only two things worth doing, so the answer can be
      // counted without any search at all. That is a different piece of code
      // from the walk, and it has to give the same number every time.
      for (var one = 2; one <= 13; one++) {
        for (var other = 2; other <= 13; other++) {
          if (one == other) continue;
          for (var want = 1; want <= (one > other ? one : other); want++) {
            final dairy = Dairy(name: 'x', churns: [one, other], want: want);
            final walked = Pouring.fewestFor(dairy);
            final tipped = Pouring.byTipping(dairy);
            if (!Pouring.canBeDone(dairy)) {
              expect(walked, isNull, reason: '$one and $other want $want');
              expect(tipped, isNull, reason: '$one and $other want $want');
              continue;
            }
            expect(walked!.pours, tipped,
                reason: 'walking says ${walked.pours} and tipping says '
                    '$tipped on $one and $other wanting $want');
          }
        }
      }
    });

    test('and the way it gives back is a real way, on every morning', () {
      for (var number = 0; number < Mornings.count; number++) {
        final dairy = Mornings.at(number).dairy;
        final measure = Pouring.fewestFor(dairy)!;
        var standing = dairy.empty;
        for (final pour in measure.how) {
          expect(pour.doesAnything(dairy, standing), isTrue,
              reason: dairy.name);
          standing = pour.on(dairy, standing);
        }
        expect(dairy.isDone(standing), isTrue, reason: dairy.name);
        expect(measure.how, hasLength(measure.pours), reason: dairy.name);
      }
    });
  });

  group('every morning that ships', () {
    for (var number = 0; number < Mornings.count; number++) {
      final morning = Mornings.at(number);

      test('${morning.name} says the number the walk says', () {
        expect(Pouring.fewestFor(morning.dairy)!.pours, morning.fewest);
      });

      test('${morning.name} can be done and is worth doing', () {
        expect(Pouring.canBeDone(morning.dairy), isTrue);
        expect(morning.fewest, greaterThan(3));
        expect(morning.dairy.churns.toSet(),
            hasLength(morning.dairy.count));
      });
    }

    test('and two of them have churns that share a factor', () {
      final sharing = [
        for (var number = 0; number < Mornings.count; number++)
          if (Pouring.stepOf(Mornings.at(number).dairy.churns) > 1) number,
      ];
      expect(sharing, hasLength(greaterThanOrEqualTo(2)));
    });
  });

  group('a morning at the churns', () {
    late Play play;

    setUp(() => play = Play.of(Mornings.at(0).dairy, Mornings.answerFor(0)));

    test('starts with empty churns and nothing picked up', () {
      expect(play.standing, [0, 0]);
      expect(play.goes, 0);
      expect(play.holding, -1);
      expect(play.couldFinishIn, play.fewest);
    });

    test('picking a churn up and putting it down again', () {
      expect(play.hold(1).holding, 1);
      expect(play.hold(1).hold(1).holding, -1);
    });

    test('filling and pouring', () {
      play = play.doIt(const Pour.fill(1)).doIt(const Pour.tip(1, 0));
      expect(play.standing, [3, 2]);
      expect(play.goes, 2);
      expect(play.holding, -1);
    });

    test('a pour that would change nothing does not count as a go', () {
      play = play.doIt(const Pour.empty(0));
      expect(play.goes, 0);
    });

    test('take back undoes the last one', () {
      play = play.doIt(const Pour.fill(1)).doIt(const Pour.tip(1, 0));
      expect(play.back.standing, [0, 5]);
      expect(play.back.goes, 1);
      expect(play.back.back.goes, 0);
    });

    test('again empties everything', () {
      play = play.doIt(const Pour.fill(1)).again;
      expect(play.goes, 0);
      expect(play.standing, [0, 0]);
    });

    test('it says when the fewest has been thrown away', () {
      // Filling the small churn first is the wrong way round here, and it
      // costs two goes.
      play = play.doIt(const Pour.fill(0));
      expect(play.couldFinishIn, greaterThan(play.fewest));
    });

    test('and show me finishes every morning in the fewest there is', () {
      for (var number = 0; number < Mornings.count; number++) {
        var walk = Play.of(
          Mornings.at(number).dairy,
          Mornings.answerFor(number),
        );
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 40) fail('it never finished');
          final next = walk.next;
          expect(next, isNotNull, reason: Mornings.at(number).name);
          walk = walk.doIt(next!);
        }
        expect(walk.isFewest, isTrue, reason: Mornings.at(number).name);
        expect(walk.goes, Mornings.at(number).fewest,
            reason: Mornings.at(number).name);
      }
    });

    test('and still finishes in the fewest after a wrong turn', () {
      play = play.doIt(const Pour.fill(0)).doIt(const Pour.tip(0, 1));
      final could = play.couldFinishIn!;
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 40) fail('it never finished');
        play = play.doIt(play.next!);
      }
      expect(play.goes, could);
    });
  });
}
