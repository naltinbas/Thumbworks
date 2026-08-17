import 'package:flutter_test/flutter_test.dart';
import 'package:hookmere/shape/levels.dart';
import 'package:hookmere/shape/play.dart';
import 'package:hookmere/shape/rules.dart';

/// The staircase itself: the hooks, the fillings, and the moves.
void main() {
  group('the staircases', () {
    test('eight boxes lie 22 ways', () {
      final all = Rules.staircases();
      expect(all.length, 22);
      for (final rows in all) {
        expect(Rules.valid(rows), isTrue, reason: '$rows');
        expect(rows.fold(0, (a, b) => a + b), 8);
      }
      expect(all.map((r) => r.join(',')).toSet().length, 22);
    });

    test('a staircase never widens as it goes down', () {
      expect(Rules.valid([3, 3, 2]), isTrue);
      expect(Rules.valid([2, 3, 3]), isFalse);
      expect(Rules.valid([3, 3, 3]), isFalse);
      expect(Rules.valid([8]), isTrue);
      expect(Rules.valid([3, 0, 5]), isFalse);
    });

    test('the hooks of the ones the asks name', () {
      expect(Rules.hooks([8]), [8, 7, 6, 5, 4, 3, 2, 1]);
      expect(Rules.hooks([4, 2, 1, 1]), [7, 4, 2, 1, 4, 1, 2, 1]);
      expect(Rules.hookProduct([4, 2, 1, 1]), 448);
      expect(Rules.hookProduct([8]), 40320);
      expect(Rules.hooks([3, 3, 2]), [5, 4, 2, 4, 3, 1, 2, 1]);
    });

    test('turning one on its side swaps rows for columns', () {
      expect(Rules.turned([4, 2, 1, 1]), [4, 2, 1, 1]);
      expect(Rules.turned([3, 3, 2]), [3, 3, 2]);
      expect(Rules.turned([4, 4]), [2, 2, 2, 2]);
      expect(Rules.turned([8]), [1, 1, 1, 1, 1, 1, 1, 1]);
    });
  });

  group('the two voices', () {
    test('agree on every staircase of eight boxes', () {
      for (final rows in Rules.staircases()) {
        expect(Rules.byHooks(rows), Rules.byCounting(rows),
            reason: Rules.tellShape(rows));
      }
    });

    test('and the counts squared add to eight factorial', () {
      var squares = 0;
      for (final rows in Rules.staircases()) {
        squares += Rules.byHooks(rows) * Rules.byHooks(rows);
      }
      expect(squares, Rules.factorial(8));
      expect(squares, 40320);
    });

    test('a staircase and its turning count the same', () {
      for (final rows in Rules.staircases()) {
        expect(Rules.byCounting(Rules.turned(rows)), Rules.byCounting(rows),
            reason: Rules.tellShape(rows));
      }
    });

    test('the counts the asks name', () {
      expect(Rules.byHooks([4, 2, 1, 1]), 90);
      expect(Rules.byHooks([4, 3, 1]), 70);
      expect(Rules.byHooks([3, 2, 2, 1]), 70);
      expect(Rules.byHooks([4, 4]), 14);
      expect(Rules.byHooks([2, 2, 2, 2]), 14);
      expect(Rules.byHooks([8]), 1);
      expect(Rules.byHooks([3, 3, 2]), 42);
    });

    test('no staircase has more fillings than ninety', () {
      for (final rows in Rules.staircases()) {
        expect(Rules.byHooks(rows), lessThanOrEqualTo(90));
      }
    });
  });

  group('the moves', () {
    test('lift off a corner only', () {
      expect(Rules.corners([3, 3, 2]), [1, 2]);
      expect(Rules.corners([8]), [0]);
      expect(Rules.corners([2, 2, 2, 2]), [3]);
    });

    test('a move keeps the staircase a staircase', () {
      expect(Rules.move([3, 3, 2], 2, 3), [3, 3, 1, 1]);
      expect(Rules.move([3, 3, 2], 0, 0), isNull);
      expect(Rules.move([3, 3, 2], 2, 0), [4, 3, 1]);
      expect(Rules.move([3, 3, 2], 1, 0), [4, 2, 2]);
    });

    test('every staircase is reachable from the opening', () {
      final away = <String, int>{Rules.opening.join(','): 0};
      final queue = <List<int>>[Rules.opening];
      for (var head = 0; head < queue.length; head++) {
        final at = queue[head];
        for (final from in Rules.corners(at)) {
          for (var to = 0; to <= at.length; to++) {
            final next = Rules.move(at, from, to);
            if (next == null) continue;
            final key = next.join(',');
            if (away.containsKey(key)) continue;
            away[key] = away[at.join(',')]! + 1;
            queue.add(next);
          }
        }
      }
      expect(away.length, 22);
      expect(away.values.reduce((a, b) => a > b ? a : b), 5);
    });
  });

  group('the asks', () {
    test('are landed by as many staircases as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final rows in Rules.staircases()) {
          if (level.meets(rows)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('the fewest moves each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [1, 2, 2, 5, null]);
    });

    test('none of them is landed before a move is made', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens on three, three and two', () {
      final play = Play.of(Levels.at(0));
      expect(play.rows, [3, 3, 2]);
      expect(play.byHooks, 42);
      expect(play.counted, 42);
      expect(play.hookProduct, 960);
      expect(play.holding, isNull);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a lift and a drop make one move', () {
      var play = Play.of(Levels.at(0)).tap(2);
      expect(play.holding, 2);
      expect(play.moves, 0);
      play = play.tap(0);
      expect(play.rows, [4, 3, 1]);
      expect(play.holding, isNull);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
    });

    test('a lift can be put back where it came from', () {
      final play = Play.of(Levels.at(1)).tap(2).tap(2);
      expect(play.holding, isNull);
      expect(play.rows, [3, 3, 2]);
      expect(play.moves, 0);
    });

    test('a row with one as long under it has no corner', () {
      final play = Play.of(Levels.at(1));
      expect(play.isCorner(0), isFalse);
      expect(identical(play.tap(0), play), isTrue);
      expect(play.isCorner(1), isTrue);
    });

    test('a drop that would widen a row below is refused', () {
      final play = Play.of(Levels.at(1)).tap(1);
      expect(play.holding, 1);
      expect(play.canDrop(2), isFalse);
      expect(identical(play.tap(2), play), isTrue);
      expect(play.canDrop(0), isTrue);
    });

    test('back undoes the last move', () {
      final play = Play.of(Levels.at(3)).tap(2).tap(3).tap(3).tap(0);
      expect(play.moves, 2);
      expect(play.back.rows, [3, 3, 1, 1]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest moves', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        expect(play.toGo!.$1, level.fewest, reason: level.name);
        while (!play.isDone) {
          final was = play.toGo!.$1;
          final aim = play.next!;
          play = play.tap(aim.$1).tap(aim.$2);
          expect(play.isDone || play.toGo!.$1 == was - 1, isTrue,
              reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says what to do with the hand it has', () {
      expect(Play.pointed((2, 0), null, 3), 'Lift a box off row 3.');
      expect(Play.pointed((2, 0), 2, 3), 'Put it on row 1.');
      expect(Play.pointed((2, 3), 2, 3), 'Start a new row with it.');
      expect(Play.pointed((2, 0), 1, 3), 'Put the box back on row 2.');
    });

    test('the hopeless ask admits it after four staircases', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final move in [(1, 0), (0, 1), (1, 3), (0, 3)]) {
        play = play.tap(move.$1).tap(move.$2);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.byHooks, play.counted);
      expect(identical(play.tap(3), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final move in [(1, 0), (0, 1), (1, 3)]) {
        play = play.tap(move.$1).tap(move.$2);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names the three who published it', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Frame, Robinson and Thrall published it in 1954'));
      expect(words, contains('the same multiset'));
      expect(words, contains('Against the Hooks'));
    });
  });
}
