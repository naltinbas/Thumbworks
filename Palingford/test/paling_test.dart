import 'package:flutter_test/flutter_test.dart';
import 'package:palingford/paling/levels.dart';
import 'package:palingford/paling/play.dart';
import 'package:palingford/paling/rules.dart';

/// The fence itself, with no screen anywhere near it.
void main() {
  group('a run', () {
    test('reads left to right and takes any palings in that order', () {
      // 3 1 4 2 5: the longest climb is 1, 2, 5 and the longest drop is
      // either 3, 1 or 4, 2.
      const fence = [3, 1, 4, 2, 5];
      expect(Rules.longestClimb(fence), 3);
      expect(Rules.longestDrop(fence), 2);
      expect(Rules.climbs(fence), [1, 1, 2, 2, 3]);
      expect(Rules.drops(fence), [1, 2, 1, 2, 1]);
    });

    test('is the whole fence when the palings stand in order', () {
      expect(Rules.longestClimb(Rules.opening), 10);
      expect(Rules.longestDrop(Rules.opening), 1);
    });

    test('names the places it runs through', () {
      const fence = [3, 1, 4, 2, 5];
      final climb = Rules.climbLine(fence);
      expect(climb.length, 3);
      for (var i = 1; i < climb.length; i++) {
        expect(climb[i], greaterThan(climb[i - 1]));
        expect(fence[climb[i]], greaterThan(fence[climb[i - 1]]));
      }
      final drop = Rules.dropLine(fence);
      expect(drop.length, 2);
      expect(fence[drop[0]], greaterThan(fence[drop[1]]));
    });
  });

  group('the tags', () {
    test('are all different on every fence of eight', () {
      var swept = 0;
      void walk(List<int> so, List<bool> used) {
        if (so.length == 8) {
          swept++;
          final up = Rules.climbs(so);
          final down = Rules.drops(so);
          final tags = {for (var i = 0; i < 8; i++) '${up[i]},${down[i]}'};
          expect(tags.length, 8, reason: so.join());
          return;
        }
        for (var h = 1; h <= 8; h++) {
          if (used[h - 1]) continue;
          used[h - 1] = true;
          walk([...so, h], used);
          used[h - 1] = false;
        }
      }

      walk(const [], List.filled(8, false));
      expect(swept, 40320);
    });

    test('give the two runs their meaning', () {
      const fence = [4, 3, 2, 1, 7, 6, 5, 9, 8, 10];
      expect(Rules.badge(fence, 0), (1, 1));
      expect(Rules.badge(fence, 3), (1, 4));
      expect(Rules.badge(fence, 9), (4, 1));
    });
  });

  group('the move', () {
    test('lifts a paling out and slides it in, the rest closing up', () {
      expect(Rules.lift([1, 2, 3, 4], 0, 3), [2, 3, 4, 1]);
      expect(Rules.lift([1, 2, 3, 4], 3, 0), [4, 1, 2, 3]);
    });

    test('back into its own gap changes nothing', () {
      for (var at = 0; at < 4; at++) {
        expect(Rules.lift([1, 2, 3, 4], at, at), [1, 2, 3, 4]);
      }
    });

    test('counts as ten less the palings that keep their order', () {
      expect(Rules.between(Rules.opening, Rules.opening), 0);
      expect(Rules.shared([1, 2, 3, 4], [2, 1, 3, 4]), 3);
      // From the opening, which climbs the whole way, that is ten less the
      // longest climb.
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(Rules.between(Rules.opening, level.aim),
            Rules.palings - Rules.longestClimb(level.aim),
            reason: level.name);
      }
    });
  });

  group('the second voice', () {
    test('lays a heap of ten in 42 shapes', () {
      final shapes = Rules.shapes();
      expect(shapes.length, 42);
      for (final shape in shapes) {
        expect(shape.fold<int>(0, (a, b) => a + b), 10);
        for (var i = 1; i < shape.length; i++) {
          expect(shape[i], lessThanOrEqualTo(shape[i - 1]));
        }
      }
    });

    test('counts fillings by the hook lengths', () {
      expect(Rules.tableaux(const [1]), 1);
      expect(Rules.tableaux(const [2, 1]), 2);
      expect(Rules.tableaux(const [3, 3, 3]), 42);
      expect(Rules.tableaux(const [10]), 1);
    });

    test('agrees with a sweep of seven palings on every box of limits', () {
      const few = 7;
      final count = List.generate(few + 1, (_) => List.filled(few + 1, 0));
      void walk(List<int> so, List<bool> used) {
        if (so.length == few) {
          count[Rules.longestClimb(so)][Rules.longestDrop(so)]++;
          return;
        }
        for (var h = 1; h <= few; h++) {
          if (used[h - 1]) continue;
          used[h - 1] = true;
          walk([...so, h], used);
          used[h - 1] = false;
        }
      }

      walk(const [], List.filled(few, false));
      for (var climbCap = 1; climbCap <= few; climbCap++) {
        for (var dropCap = 1; dropCap <= few; dropCap++) {
          var swept = 0;
          for (var c = 1; c <= climbCap; c++) {
            for (var d = 1; d <= dropCap; d++) {
              swept += count[c][d];
            }
          }
          expect(Rules.byShapes(climbCap, dropCap, few), swept,
              reason: '$climbCap by $dropCap');
        }
      }
      expect(Rules.byShapes(few, few, few), 5040);
    });

    test('says ten palings cannot keep both runs under four, and nine can',
        () {
      expect(Rules.byShapes(3, 3), 0);
      expect(Rules.byShapes(3, 3, 9), 1764);
      expect(Rules.byShapes(4, 3), 107604);
      expect(Rules.byShapes(3, 4), 107604);
      expect(Rules.byShapes(10, 10), 3628800);
    });
  });

  group('every ask', () {
    test('is not landed by the opening', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });

    test('is landed by the fence it points at, in the moves it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(level.meets(level.aim), isTrue, reason: level.name);
        expect(Rules.between(Rules.opening, level.aim), level.fewest,
            reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways).toList(),
          [985032, 970528, 586590, 107604, 0]);
      expect(Levels.all.map((l) => l.fewest).toList(), [6, 5, 7, 6, null]);
    });

    test('is landed by the pointer in the moves it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final aim = play.next!;
          play = play.take(aim.$1).slide(aim.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('lifts a paling, which leaves nine standing', () {
      final one = Play.of(Levels.at(0)).take(3);
      expect(one.inHand, 4);
      expect(one.standing, [1, 2, 3, 5, 6, 7, 8, 9, 10]);
      expect(one.moves, 0);
    });

    test('slides it in and counts one move', () {
      final one = Play.of(Levels.at(0)).take(0).slide(9);
      expect(one.moves, 1);
      expect(one.fence, [2, 3, 4, 5, 6, 7, 8, 9, 10, 1]);
      expect(one.held, isNull);
    });

    test('will not count a move that puts it back where it was', () {
      final play = Play.of(Levels.at(0)).take(4).slide(4);
      expect(play.moves, 0);
      expect(play.fence, Rules.opening);
      expect(play.held, isNull);
    });

    test('takes a move back', () {
      final one = Play.of(Levels.at(0)).take(0).slide(9);
      expect(one.back.moves, 0);
      expect(one.back.fence, Rules.opening);
    });

    test('reads the runs off the palings still standing', () {
      final held = Play.of(Levels.at(0)).take(9);
      expect(held.standing.length, 9);
      expect(held.climb, 9);
      expect(held.tags.length, 9);
    });

    test('points at a paling and a gap', () {
      final play = Play.of(Levels.at(0));
      final aim = play.next!;
      expect(play.pointed(aim), contains('Lift the paling at place'));
      expect(play.take(aim.$1).pointed(aim), contains('slide it into gap'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('wants both runs under four and keeps no fence to point at', () {
      expect(dead.climbCap, 3);
      expect(dead.dropCap, 3);
      expect(dead.ways, 0);
      expect(dead.aim, isEmpty);
      expect(Play.of(dead).next, isNull);
    });

    test('admits it after six fences', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final step in const [(0, 9), (0, 5), (3, 0), (8, 2), (1, 7),
        (4, 0)]) {
        play = play.take(step.$1).slide(step.$2);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });

  group('the why', () {
    test('names the tags, the theorem and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(1)));
      expect(words, contains('Erdos'));
      expect(words, contains('3,628,800'));
      expect(words, contains('The Matched Fence'));
    });
  });
}
