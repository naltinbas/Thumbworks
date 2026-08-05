import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:handfast/hire/fair.dart';
import 'package:handfast/hire/fairs.dart';
import 'package:handfast/hire/most.dart';
import 'package:handfast/hire/play.dart';

/// A fair made up at random, the same way the tool that found the shipped
/// ones does it.
Fair _madeUp(Random random, {int jobs = 6, int people = 6, int chance = 35}) =>
    Fair(
      name: 'made up',
      work: [for (var job = 0; job < jobs; job++) 'W$job'],
      hands: [for (var hand = 0; hand < people; hand++) 'H$hand'],
      whoCan: [
        for (var job = 0; job < jobs; job++)
          {
            for (var hand = 0; hand < people; hand++)
              if (random.nextInt(100) < chance) hand,
          },
      ],
    );

void main() {
  group('the fair', () {
    final fair = Days.at(0).fair;

    test('knows who can take on what', () {
      expect(fair.can(0, 1), isTrue);
      expect(fair.can(0, 0), isFalse);
      expect(fair.whoCan[1], {3});
    });

    test('and how many hands a set of jobs has between it', () {
      expect(fair.reachedBy([1, 3]), {3, 1});
      expect(fair.reachedBy([2, 5]), {0, 5});
    });
  });

  group('the walk', () {
    test('covers everything when everything can be covered', () {
      final hiring = Hirings.most(Days.at(0).fair);
      expect(hiring.most, 6);
      expect(hiring.undone, 0);
      expect(hiring.short, isEmpty);
    });

    test('and hands nobody two jobs', () {
      for (var number = 0; number < Days.count; number++) {
        final hiring = Hirings.most(Days.at(number).fair);
        final given = hiring.took.where((hand) => hand >= 0).toList();
        expect(given.toSet(), hasLength(given.length),
            reason: Days.at(number).name);
      }
    });

    test('and never gives a job to somebody who cannot do it', () {
      for (var number = 0; number < Days.count; number++) {
        final fair = Days.at(number).fair;
        final hiring = Hirings.most(fair);
        for (var job = 0; job < fair.jobs; job++) {
          if (hiring.took[job] < 0) continue;
          expect(fair.can(job, hiring.took[job]), isTrue, reason: fair.name);
        }
      }
    });

    test('two jobs that only one hand can do leaves one undone', () {
      final fair = Fair(
        name: 'two and one',
        work: const ['a', 'b'],
        hands: const ['only'],
        whoCan: const [
          {0},
          {0},
        ],
      );
      final hiring = Hirings.most(fair);
      expect(hiring.most, 1);
      expect(hiring.undone, 1);
      expect(hiring.short, [0, 1]);
      expect(hiring.onlyThese, [0]);
      expect(hiring.shortSaysSo, isTrue);
    });
  });

  group('the walk against trying every way', () {
    test('agree on four hundred fairs made up at random', () {
      final random = Random(1935);
      for (var go = 0; go < 400; go++) {
        final fair = _madeUp(
          random,
          jobs: 3 + random.nextInt(6),
          people: 3 + random.nextInt(6),
          chance: 15 + random.nextInt(50),
        );
        final walked = Hirings.most(fair).most;
        final tried = Hirings.byTrying(fair);
        expect(walked, tried,
            reason: 'the walk says $walked and trying every way says $tried '
                'on ${fair.whoCan}');
      }
    });

    test('and the set of jobs it hands back really is short of hands', () {
      // The part that matters. Whatever the fair, the jobs it names have
      // fewer hands between them than there are jobs in the list, and the
      // difference is exactly the number that go undone.
      final random = Random(2024);
      for (var go = 0; go < 400; go++) {
        final fair = _madeUp(
          random,
          jobs: 3 + random.nextInt(6),
          people: 3 + random.nextInt(6),
          chance: 15 + random.nextInt(50),
        );
        final hiring = Hirings.most(fair);
        if (hiring.undone == 0) continue;

        expect(fair.reachedBy(hiring.short).toSet(), hiring.onlyThese.toSet(),
            reason: '${fair.whoCan}');
        expect(hiring.short.length - hiring.onlyThese.length, hiring.undone,
            reason: '${fair.whoCan}');
        expect(hiring.shortSaysSo, isTrue);
      }
    });

    test('and no set of jobs anywhere is shorter of hands than that one', () {
      // Hall's condition the long way round: every set of jobs there is,
      // counted against the hands it can reach.
      final random = Random(1066);
      for (var go = 0; go < 250; go++) {
        final fair = _madeUp(
          random,
          jobs: 3 + random.nextInt(6),
          people: 3 + random.nextInt(5),
          chance: 15 + random.nextInt(45),
        );
        expect(Hirings.shortfallByTrying(fair), Hirings.most(fair).undone,
            reason: '${fair.whoCan}');
      }
    });

    test('and working down the board is never better, and often worse', () {
      final random = Random(1381);
      var worse = 0;
      for (var go = 0; go < 300; go++) {
        final fair = _madeUp(random, jobs: 6, people: 6, chance: 30);
        final most = Hirings.most(fair).most;
        final down =
            Hirings.byWorkingDown(fair).where((hand) => hand >= 0).length;
        expect(down, lessThanOrEqualTo(most));
        if (down < most) worse++;
      }
      expect(worse, greaterThan(30));
    });
  });

  group('every day that ships', () {
    for (var number = 0; number < Days.count; number++) {
      final day = Days.at(number);

      test('${day.name} says the number both ways say', () {
        expect(Hirings.most(day.fair).most, day.most);
        expect(Hirings.byTrying(day.fair), day.most);
      });

      test('${day.name} carries a set of jobs that proves it', () {
        final hiring = Hirings.most(day.fair);
        expect(hiring.shortSaysSo, isTrue);
        expect(Hirings.shortfallByTrying(day.fair), hiring.undone);
      });

      test('${day.name} is written down properly', () {
        final fair = day.fair;
        expect(fair.work.toSet(), hasLength(fair.jobs));
        expect(fair.hands.toSet(), hasLength(fair.people));
        for (final can in fair.whoCan) {
          expect(can, isNotEmpty);
          for (final hand in can) {
            expect(hand, lessThan(fair.people));
          }
        }
        // Nobody stands about at this fair who can do nothing at all.
        for (var hand = 0; hand < fair.people; hand++) {
          expect(fair.whoCan.any((can) => can.contains(hand)), isTrue,
              reason: '${fair.hands[hand]} on ${fair.name}');
        }
      });
    }

    test('and past the first, working down the board comes out short', () {
      for (var number = 1; number < Days.count; number++) {
        final day = Days.at(number);
        final down =
            Hirings.byWorkingDown(day.fair).where((hand) => hand >= 0).length;
        expect(down, lessThan(day.most), reason: day.name);
      }
    });
  });

  group('a day at the fair', () {
    late Play play;

    setUp(() => play = Play.of(Days.at(0).fair, Days.answerFor(0)));

    test('starts with nothing given out', () {
      expect(play.covered, 0);
      expect(play.isDone, isFalse);
      expect(play.couldStillGet, play.most);
    });

    test('giving a job to a hand who can do it', () {
      play = play.take(0, 1);
      expect(play.handOn(0), 1);
      expect(play.covered, 1);
      expect(play.isFree(1), isFalse);
    });

    test('and to one who cannot does nothing', () {
      expect(identical(play.take(0, 0), play), isTrue);
    });

    test('giving the same job to the same hand again takes it back', () {
      play = play.take(0, 1).take(0, 1);
      expect(play.covered, 0);
    });

    test('a hand cannot be in two places', () {
      play = play.take(0, 3);
      expect(play.canTake(1, 3), isFalse);
      expect(identical(play.take(1, 3), play), isTrue);
    });

    test('the day is over when nothing else can be given out', () {
      // Ditching and Carting can only be done by Wray, so taking Wray for
      // Hedging strands both of them.
      play = play.take(0, 3);
      var guard = 0;
      while (!play.isDone) {
        if (guard++ > 20) fail('it never ended');
        final next = play.next!;
        play = play.take(next.$1, next.$2);
      }
      expect(play.isMost, isFalse);
      expect(play.covered, lessThan(play.most));
    });

    test('and it says so as soon as the mistake is made', () {
      play = play.take(0, 3);
      expect(play.couldStillGet, lessThan(play.most));
      play = play.let(0);
      expect(play.couldStillGet, play.most);
    });

    test('show me works every day up to the most there is', () {
      for (var number = 0; number < Days.count; number++) {
        var walk = Play.of(Days.at(number).fair, Days.answerFor(number));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 40) fail('it never finished');
          final next = walk.next;
          expect(next, isNotNull, reason: Days.at(number).name);
          walk = walk.take(next!.$1, next.$2);
        }
        expect(walk.isMost, isTrue, reason: Days.at(number).name);
        expect(walk.covered, Days.at(number).most,
            reason: Days.at(number).name);
      }
    });
  });
}
