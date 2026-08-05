import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rimeworth/round/parish.dart';
import 'package:rimeworth/round/parishes.dart';
import 'package:rimeworth/round/play.dart';
import 'package:rimeworth/round/rest.dart';
import 'package:rimeworth/round/runs.dart';

/// A connected parish made up at random: a spanning tree first, so it always
/// hangs together, and then some more lanes on top of it.
Parish _madeUp(Random random, {int junctions = 7, int extra = 4}) {
  final lanes = <Lane>[];
  final taken = <String>{};

  void join(int one, int other) {
    final key = one < other ? '$one-$other' : '$other-$one';
    if (one == other || !taken.add(key)) return;
    lanes.add(Lane(one, other));
  }

  for (var junction = 1; junction < junctions; junction++) {
    join(random.nextInt(junction), junction);
  }
  for (var more = 0; more < extra; more++) {
    join(random.nextInt(junctions), random.nextInt(junctions));
  }

  return Parish(
    junctions: [
      for (var junction = 0; junction < junctions; junction++)
        Junction('J$junction', random.nextDouble(), random.nextDouble()),
    ],
    lanes: lanes,
  );
}

/// Drives a parish by asking the game where to go next, and gives back how
/// many runs that took.
int _drivenByAsking(Parish parish) {
  var play = Play.of(parish);
  var guard = 0;

  while (!play.isDone) {
    if (guard++ > 500) fail('it never finished');
    final next = play.next;
    if (next == null) fail('it had nowhere to go and was not finished');
    final before = play;
    play = play.touch(next);
    if (identical(play, before)) fail('it pointed somewhere it cannot go');
  }
  return play.runs;
}

void main() {
  group('the parish', () {
    final parish = Grittings.at(1).parish;

    test('knows how many lanes meet at a junction', () {
      expect(parish.lanesOn(0), 3);
      expect(parish.lanesOn(2), 4);
      expect(parish.lanesOn(4), 2);
    });

    test('the odd junctions are the ones with an odd number of lanes', () {
      expect(parish.oddJunctions, [0, 1]);
    });

    test('hangs together', () {
      expect(parish.isJoinedUp, isTrue);
    });

    test('a parish in two halves does not', () {
      final split = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 0, 1),
          Junction('c', 1, 0),
          Junction('d', 1, 1),
        ],
        lanes: const [Lane(0, 1), Lane(2, 3)],
      );
      expect(split.isJoinedUp, isFalse);
    });
  });

  group('the counting', () {
    test('a ring is one run, and it comes back to where it set off', () {
      final ring = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 1, 0),
          Junction('c', 1, 1),
          Junction('d', 0, 1),
        ],
        lanes: const [Lane(0, 1), Lane(1, 2), Lane(2, 3), Lane(3, 0)],
      );
      final round = Runs.fewestFor(ring);
      expect(round.runs, 1);
      expect(round.odd, isEmpty);

      final routes = Runs.routes(ring);
      expect(routes, hasLength(1));
      expect(routes.first.first, routes.first.last);
    });

    test('two odd junctions is one run between the two of them', () {
      // A line of three: the two ends have one lane each.
      final line = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 1, 0),
          Junction('c', 2, 0),
        ],
        lanes: const [Lane(0, 1), Lane(1, 2)],
      );
      final round = Runs.fewestFor(line);
      expect(round.runs, 1);
      expect(round.odd, [0, 2]);
      expect(round.starts, [0, 2]);
    });

    test('six odd junctions is three runs', () {
      // A triangle with a dead end hanging off each corner.
      final comb = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 1, 0),
          Junction('c', 0, 1),
          Junction('d', 2, 0),
          Junction('e', 2, 1),
          Junction('f', 2, 2),
        ],
        lanes: const [
          Lane(0, 1),
          Lane(1, 2),
          Lane(2, 0),
          Lane(0, 3),
          Lane(1, 4),
          Lane(2, 5),
        ],
      );
      expect(Runs.fewestFor(comb).runs, 3);
    });
  });

  group('the routes it lays out', () {
    for (var number = 0; number < Grittings.count; number++) {
      final gritting = Grittings.at(number);

      test('${gritting.name}: every lane once, and no more runs than it '
          'takes', () {
        final parish = gritting.parish;
        final routes = Runs.routes(parish);
        expect(routes, hasLength(gritting.runs));

        final salted = <int>[];
        for (final route in routes) {
          for (var step = 1; step < route.length; step++) {
            final lane = parish.laneBetween(route[step - 1], route[step]);
            expect(lane, isNot(-1),
                reason: 'it drove between two junctions with no lane there');
            salted.add(lane);
          }
        }
        expect(salted.toSet(), hasLength(parish.laneCount));
        expect(salted, hasLength(parish.laneCount));
      });
    }
  });

  group('the counting against driving it', () {
    test('two hundred parishes made up at random agree', () {
      final random = Random(24601);
      for (var go = 0; go < 200; go++) {
        final parish = _madeUp(
          random,
          junctions: 4 + random.nextInt(4),
          extra: random.nextInt(5),
        );
        final counted = Runs.fewestFor(parish).runs;
        final driven = Runs.byDriving(parish);
        expect(counted, driven,
            reason: 'the counting says $counted and driving it says $driven '
                'on ${parish.lanes.map((lane) => '${lane.from}-${lane.to}')}');
      }
    });

    test('and the routes it lays out are that many, and salt everything', () {
      final random = Random(31337);
      for (var go = 0; go < 200; go++) {
        final parish = _madeUp(
          random,
          junctions: 4 + random.nextInt(5),
          extra: random.nextInt(6),
        );
        final routes = Runs.routes(parish);
        expect(routes, hasLength(Runs.fewestFor(parish).runs));

        final salted = <int>[];
        for (final route in routes) {
          for (var step = 1; step < route.length; step++) {
            salted.add(parish.laneBetween(route[step - 1], route[step]));
          }
        }
        expect(salted, hasLength(parish.laneCount));
        expect(salted.toSet(), hasLength(parish.laneCount));
      }
    });
  });

  group('what is left', () {
    test('nothing salted is the whole parish', () {
      final parish = Grittings.at(2).parish;
      final rest = Rests.from(parish, <int>{}, -1);
      expect(rest.runsLeft, Runs.fewestFor(parish).runs);
    });

    test('everything salted is nothing left', () {
      final parish = Grittings.at(0).parish;
      final all = {for (var lane = 0; lane < parish.laneCount; lane++) lane};
      expect(Rests.from(parish, all, 0).runsLeft, 0);
    });

    test('standing where there is nothing left costs another run', () {
      // A line of three. Salt the left lane driving from the middle, and the
      // lorry is at the far left with the right lane still to do.
      final line = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 1, 0),
          Junction('c', 2, 0),
        ],
        lanes: const [Lane(0, 1), Lane(1, 2)],
      );
      expect(Rests.from(line, {0}, 0).runsLeft, 1);
      expect(Rests.from(line, {0}, 1).runsLeft, 0);
    });
  });

  group('driving it by asking the game where to go', () {
    for (var number = 0; number < Grittings.count; number++) {
      final gritting = Grittings.at(number);
      test('${gritting.name} comes out in ${gritting.runs}', () {
        expect(_drivenByAsking(gritting.parish), gritting.runs);
      });
    }

    test('a hundred parishes made up at random come out in the fewest', () {
      final random = Random(8675309);
      for (var go = 0; go < 100; go++) {
        final parish = _madeUp(
          random,
          junctions: 4 + random.nextInt(5),
          extra: random.nextInt(6),
        );
        expect(_drivenByAsking(parish), Runs.fewestFor(parish).runs);
      }
    });
  });

  group('the lorry', () {
    late Play play;

    setUp(() => play = Play.of(Grittings.at(0).parish));

    test('starts off the map with nothing salted', () {
      expect(play.at, -1);
      expect(play.runs, 0);
      expect(play.done, 0);
      expect(play.isDone, isFalse);
    });

    test('the first tap sets it down and costs a run', () {
      play = play.touch(0);
      expect(play.at, 0);
      expect(play.runs, 1);
      expect(play.done, 0);
    });

    test('a tap on a junction it can reach drives there', () {
      play = play.touch(0).touch(1);
      expect(play.at, 1);
      expect(play.done, 1);
      expect(play.salted, [0]);
    });

    test('a tap on a junction with no lane to it does nothing', () {
      play = play.touch(0);
      final again = play.touch(3);
      expect(again.at, 0);
      expect(again.done, 0);
    });

    test('a lane cannot be salted twice', () {
      play = play.touch(0).touch(1);
      final again = play.touch(0);
      expect(again.done, 1);
      expect(again.at, 1);
    });

    test('a tap far away while there is still a lane here does nothing', () {
      play = play.touch(0).touch(1);
      final again = play.touch(4);
      expect(identical(again, play), isTrue);
    });

    test('take back undoes the last thing, whatever it was', () {
      play = play.touch(0).touch(1);
      expect(play.back.at, 0);
      expect(play.back.done, 0);
      expect(play.back.back.at, -1);
      expect(play.back.back.runs, 0);
    });

    test('again starts over', () {
      play = play.touch(0).touch(1).touch(2).again;
      expect(play.done, 0);
      expect(play.runs, 0);
      expect(play.at, -1);
    });

    test('it is stuck when nothing is left where it stands', () {
      final line = Parish(
        junctions: const [
          Junction('a', 0, 0),
          Junction('b', 1, 0),
          Junction('c', 2, 0),
        ],
        lanes: const [Lane(0, 1), Lane(1, 2)],
      );
      var walk = Play.of(line).touch(1).touch(0);
      expect(walk.isStuck, isTrue);
      expect(walk.isDone, isFalse);
      expect(walk.couldFinishIn, 2);

      // Stuck at one end, so a tap somewhere else is a new run.
      walk = walk.touch(1).touch(2);
      expect(walk.isDone, isTrue);
      expect(walk.runs, 2);
    });
  });

  group('every parish that ships', () {
    for (var number = 0; number < Grittings.count; number++) {
      final gritting = Grittings.at(number);
      final parish = gritting.parish;

      test('${gritting.name} says the number the counting says', () {
        expect(gritting.runs, Runs.fewestFor(parish).runs);
      });

      test('${gritting.name} hangs together and has no lane twice', () {
        expect(parish.isJoinedUp, isTrue);
        final pairs = parish.lanes
            .map((lane) => lane.from < lane.to
                ? '${lane.from}-${lane.to}'
                : '${lane.to}-${lane.from}')
            .toSet();
        expect(pairs, hasLength(parish.laneCount));
        expect(parish.junctions.map((junction) => junction.name).toSet(),
            hasLength(parish.count));
      });

      test('${gritting.name} agrees with a search over every way to drive it',
          () {
        expect(Runs.byDriving(parish), gritting.runs);
      });

      test('${gritting.name} has every junction on the map', () {
        for (var junction = 0; junction < parish.count; junction++) {
          expect(parish.lanesOn(junction), greaterThan(0));
          expect(parish.junctions[junction].x, inInclusiveRange(0.05, 0.95));
          expect(parish.junctions[junction].y, inInclusiveRange(0.05, 0.95));
        }
      });
    }
  });
}
