import 'package:flutter_test/flutter_test.dart';
import 'package:trestlemere/table/levels.dart';
import 'package:trestlemere/table/play.dart';
import 'package:trestlemere/table/rules.dart';

/// The hall itself, with no screen anywhere near it.
void main() {
  group('a seating', () {
    test('is only who shares a table, written one way', () {
      expect(Rules.write(Rules.tidy([
        [2, 0],
        [1]
      ])), 'AC B');
      // The trestles have no names, so these are the same seating.
      final one = Rules.fromSeats([0, 0, 1, 1, 2, 2]);
      final two = Rules.fromSeats([2, 2, 0, 0, 1, 1]);
      expect(Rules.write(one), Rules.write(two));
    });

    test('drops a trestle nobody sits at', () {
      expect(Rules.fromSeats([0, 0, 0, 0, 0, 0]).length, 1);
      expect(Rules.fromSeats([0, 0, 0, 0, 0, 3]).length, 2);
    });

    test('reads its sizes smallest first', () {
      expect(Rules.sizes(Rules.fromSeats([0, 1, 1, 2, 2, 2])), [1, 2, 3]);
    });
  });

  group('the walk', () {
    test('writes every seating of six guests once', () {
      final all = Rules.seatings();
      expect(all.length, 203);
      final marks = all.map(Rules.write).toSet();
      expect(marks.length, 203);
      for (final s in all) {
        var seated = 0;
        for (final table in Rules.tidy(s)) {
          expect(table, isNotEmpty);
          seated += table.length;
        }
        expect(seated, Rules.guests);
      }
    });

    test('splits them 1, 31, 90, 65, 15 and 1 by table count', () {
      final byK = <int, int>{};
      for (final s in Rules.seatings()) {
        final k = Rules.tidy(s).length;
        byK[k] = (byK[k] ?? 0) + 1;
      }
      expect([for (var k = 1; k <= 6; k++) byK[k]], [1, 31, 90, 65, 15, 1]);
    });
  });

  group('the counting', () {
    test('gets the same row without writing a seating down', () {
      expect([for (var k = 1; k <= 6; k++) Rules.byRecurrence(6, k)],
          [1, 31, 90, 65, 15, 1]);
    });

    test('agrees with the walk at every smaller supper too', () {
      for (var n = 0; n <= Rules.guests; n++) {
        final here = Rules.seatings(n);
        expect(Rules.allWays(n), here.length, reason: '$n guests');
        final byK = <int, int>{};
        for (final s in here) {
          final k = Rules.tidy(s).length;
          byK[k] = (byK[k] ?? 0) + 1;
        }
        for (var k = 1; k <= n; k++) {
          expect(Rules.byRecurrence(n, k), byK[k], reason: '$n guests, $k');
        }
      }
    });

    test('adds its row to the whole count', () {
      expect(Rules.allWays(6), 203);
      expect(Rules.allWays(5), 52);
      expect(Rules.allWays(1), 1);
    });
  });

  group('the shapes the asks turn on', () {
    test('force one, two and three when three tables differ', () {
      for (final s in Rules.seatings()) {
        final t = Rules.tidy(s);
        if (t.length != 3 || !Rules.allDifferent(t)) continue;
        expect(Rules.sizes(t), [1, 2, 3]);
      }
    });

    test('force two, two and two when nobody is alone at three tables', () {
      for (final s in Rules.seatings()) {
        final t = Rules.tidy(s);
        if (t.length != 3 || !Rules.nobodyAlone(t)) continue;
        expect(Rules.sizes(t), [2, 2, 2]);
      }
    });

    test('want ten guests for four tables of different sizes', () {
      expect(Rules.fewestFor(4), 10);
      expect(Rules.fewestFor(3), 6);
      expect(Rules.fewestFor(2), 3);
      expect(Rules.fewestFor(4), greaterThan(Rules.guests));
    });
  });

  group('every ask', () {
    test('lands as many seatings as it claims', () {
      for (final level in Levels.all) {
        final n = Rules.seatings().where(level.meets).length;
        expect(n, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways).toList(), [90, 60, 15, 10, 0]);
    });

    test('opens with everybody at one trestle, which lands nothing', () {
      final open = Play.of(Levels.at(0));
      expect(open.laid, 1);
      for (final level in Levels.all) {
        expect(level.meets(open.tables), isFalse, reason: level.name);
      }
    });

    test('is seated by the pointer in the moves it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.moves < 12) {
          final aim = play.next!;
          play = play.sit(aim.$1, aim.$2);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('moves a guest and counts one move', () {
      final one = Play.of(Levels.at(0)).sit(0, 1);
      expect(one.moves, 1);
      expect(one.laid, 2);
      expect(one.sizes, [1, 5]);
    });

    test('will not count a move that seats nobody anew', () {
      final play = Play.of(Levels.at(0));
      expect(identical(play.sit(0, 0), play), isTrue);
    });

    test('takes a move back', () {
      final one = Play.of(Levels.at(0)).sit(0, 1);
      expect(one.back.laid, 1);
      expect(one.back.moves, 0);
    });

    test('counts the moves between two seatings without minding names', () {
      // The same seating written with the trestles swapped is no moves
      // away at all.
      expect(Play.between([0, 0, 1, 1, 2, 2], [2, 2, 0, 0, 1, 1]), 0);
      expect(Play.between([0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1]), 1);
    });

    test('points at a guest and a trestle', () {
      final play = Play.of(Levels.at(0));
      final aim = play.next!;
      expect(play.pointed(aim), contains('Move '));
      expect(play.pointed(aim), contains('trestle'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('is landed by none of the 203', () {
      expect(Rules.seatings().where(dead.meets), isEmpty);
      expect(dead.tables, 4);
    });

    test('keeps no pointer at all', () {
      expect(Play.of(dead).next, isNull);
    });

    test('admits it after six seatings', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final step in const [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
        (1, 0)]) {
        play = play.sit(step.$1, step.$2);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });

  group('the why', () {
    test('names the counting, the walk and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(1)));
      expect(words, contains('Stirling'));
      expect(words, contains('203'));
      expect(words, contains('The Three Sizes'));
    });
  });
}
