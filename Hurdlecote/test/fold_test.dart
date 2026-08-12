import 'package:flutter_test/flutter_test.dart';
import 'package:hurdlecote/fold/green.dart';
import 'package:hurdlecote/fold/greens.dart';
import 'package:hurdlecote/fold/play.dart';
import 'package:hurdlecote/fold/rules.dart';

void main() {
  const square = [(0, 0), (1, 0), (1, 1), (0, 1)];
  const wholeGreen = [(0, 0), (4, 0), (4, 4), (0, 4)];
  const fullFold = [(0, 0), (0, 2), (3, 1)];

  group('the two reckonings', () {
    test('the shoelace, the walk, and the swallowed, by hand', () {
      expect(Rules.area2(square), 2);
      expect(Rules.walked(square), 4);
      expect(Rules.penned(square), 0);

      expect(Rules.area2(wholeGreen), 32);
      expect(Rules.walked(wholeGreen), 16);
      expect(Rules.penned(wholeGreen), 9);

      expect(Rules.area2(fullFold), 6);
      expect(Rules.walked(fullFold), 4);
      expect(Rules.penned(fullFold), 2);
    });

    test('a standing fence is simple and a broken one is refused',
        () {
      expect(Rules.standsClosed(square), isTrue);
      // Rails crossing.
      expect(
        Rules.standsClosed(const [(0, 0), (2, 2), (2, 0), (0, 2)]),
        isFalse,
      );
      // A hurdle on another's rail.
      expect(
        Rules.standsClosed(const [(0, 0), (0, 1), (1, 0), (0, 2)]),
        isFalse,
      );
      // The same crossing twice.
      expect(
        Rules.standsClosed(const [(0, 0), (1, 0), (0, 0), (0, 1)]),
        isFalse,
      );
      // A flat run pens nothing.
      expect(
        Rules.standsClosed(const [(0, 0), (1, 1), (2, 2)]),
        isFalse,
      );
    });

    test('a hurdle may be set only clear of the standing fence', () {
      const run = [(0, 0), (2, 0)];
      expect(Rules.maySet(run, (2, 2)), isTrue);
      expect(Rules.maySet(run, (0, 0)), isFalse);
      // Doubling straight back over its own rail.
      expect(Rules.maySet(run, (1, 0)), isFalse);
      // A rail through a standing hurdle.
      expect(
        Rules.maySet(const [(0, 0), (2, 1), (4, 0)], (0, 0)),
        isFalse,
      );
      // A rail crossing an earlier one.
      expect(
        Rules.maySet(const [(0, 0), (4, 0), (2, 2)], (2, 0)),
        isFalse,
      );
    });

    test(
        'the sweep of the green counts what the other language '
        'counted', () {
      // 2,148 triangles and 16,786 four-hurdle fences, pinned
      // against an enumeration written separately in Python.
      final fences = Rules.everyFence(5, 4);
      expect(fences.where((fence) => fence.length == 3).length, 2148);
      expect(fences.where((fence) => fence.length == 4).length, 16786);
    });

    test('Pick and the shoelace agree on every fence of the green',
        () {
      for (final fence in Rules.everyFence(5, 4)) {
        expect(
          Rules.area2(fence),
          2 * Rules.penned(fence) + Rules.walked(fence) - 2,
          reason: '$fence',
        );
      }
    });

    test('the acreages march in halves from a half to sixteen', () {
      final seen = <int>{};
      for (final fence in Rules.everyFence(5, 4)) {
        seen.add(Rules.area2(fence));
      }
      expect(seen.reduce((a, b) => a < b ? a : b), 1);
      expect(seen.reduce((a, b) => a > b ? a : b), 32);
      // And no whole-number gap is skipped low down.
      for (var twice = 1; twice <= 16; twice++) {
        expect(seen, contains(twice), reason: 'area2 $twice');
      }
    });
  });

  group('the greens that ship', () {
    for (final green in Greens.all) {
      test(green.name, () {
        var fewest = -1;
        var ways = 0;
        for (final fence in Rules.everyFence(5, 4)) {
          final play = _closed(green, fence);
          if (!play.isDone) continue;
          ways++;
          if (fewest == -1 || fence.length < fewest) {
            fewest = fence.length;
          }
        }
        if (green.winnable) {
          expect(fewest, green.posts);
          expect(ways, green.ways);
        } else {
          expect(fewest, -1);
        }
      });
    }

    test('a third of an acre fails by arithmetic alone', () {
      // 3 * area2 == 2 has no whole answer: area2 is at least 1.
      for (var twice = 1; twice <= 32; twice++) {
        expect(3 * twice == 2, isFalse);
      }
    });
  });

  group('a play', () {
    test('hurdles go up one by one and the fence closes', () {
      var play = Play.of(Greens.at(0));
      for (final spot in const [(0, 0), (0, 1), (1, 0)]) {
        expect(play.maySet(spot), isTrue);
        play = play.set(spot);
      }
      expect(play.mayClose, isTrue);
      play = play.close();
      expect(play.isDone, isTrue);
      expect(play.pens, 1);
      expect(play.swallows, 0);
    });

    test('a wrong fence closes as a miss and back reopens it', () {
      var play = Play.of(Greens.at(0));
      for (final spot in const [(0, 0), (2, 0), (2, 2), (0, 2)]) {
        play = play.set(spot);
      }
      play = play.close();
      expect(play.closed, isTrue);
      expect(play.isDone, isFalse);
      expect(play.pens, 8);
      expect(play.swallows, 1);
      play = play.back;
      expect(play.closed, isFalse);
      expect(play.posts, hasLength(4));
    });

    test('refused hurdles change nothing', () {
      final play = Play.of(Greens.at(0)).set((0, 0)).set((2, 0));
      expect(play.set((1, 0)), same(play));
      expect(play.posts, hasLength(2));
    });

    test('following the pointer settles every winnable green in its '
        'fewest hurdles', () {
      for (final green in Greens.all.where((green) => green.winnable)) {
        var play = Play.of(green);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 8) fail('${green.name} never settled');
          final fence = play.finished;
          expect(fence, isNotNull, reason: green.name);
          final next = play.nextOf(fence!);
          play = next == null ? play.close() : play.set(next);
        }
        expect(play.posts, hasLength(green.posts!),
            reason: green.name);
      }
    });

    test('the third acre offers nothing and never settles', () {
      var play = Play.of(Greens.at(4));
      expect(play.finished, isNull);
      for (final spot in const [(0, 0), (1, 0), (0, 1)]) {
        play = play.set(spot);
      }
      play = play.close();
      expect(play.isDone, isFalse);
      expect(play.pens, 1);
      // And back reopens the miss for another try.
      expect(play.back.closed, isFalse);
      expect(play.back.posts, hasLength(3));
    });
  });
}

Play _closed(Green green, List<(int, int)> fence) {
  var play = Play.of(green);
  for (final spot in fence) {
    play = play.set(spot);
  }
  return play.close();
}
