import 'package:flutter_test/flutter_test.dart';
import 'package:flagstead/hall/levels.dart';
import 'package:flagstead/hall/play.dart';
import 'package:flagstead/hall/rules.dart';

/// The hall, the peg and the two sums, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the hall', () {
    test('the two sums agree wherever the peg stands', () {
      var settings = 0;
      for (final (wide, tall, px, py) in Rules.settings()) {
        settings++;
        if (settings % 5 != 0) continue;
        expect(Rules.acrossOne(wide, tall, 0, px, py),
            Rules.acrossTwo(wide, tall, 0, px, py),
            reason: '$wide by $tall at ($px, $py)');
        final (one, two) = Rules.sumsByAlgebra(wide, tall, 0, px, py);
        expect(one, Rules.acrossOne(wide, tall, 0, px, py));
        expect(two, Rules.acrossTwo(wide, tall, 0, px, py));
      }
      expect(settings, 11025);
      expect(Rules.howMany, 11025);
    });

    test('a leaning hall parts the sums by twice the lean times the width',
        () {
      for (var lean = 1; lean <= 3; lean++) {
        for (final (wide, tall, px, py) in Rules.settings()) {
          if ((px + py) % 7 != 0) continue;
          expect(Rules.apart(wide, tall, lean, px, py), 2 * lean * wide,
              reason: '$wide by $tall leaned $lean at ($px, $py)');
        }
      }
      expect(Rules.apart(5, 4, 2, 3, 3), 20);
      expect(Rules.apart(5, 4, 0, 3, 3), 0);
    });

    test('the squares, the posts and what counts as inside', () {
      expect(Rules.posts(6, 8, 0), [(0, 0), (6, 0), (6, 8), (0, 8)]);
      expect(Rules.posts(5, 4, 2), [(0, 0), (5, 0), (7, 4), (2, 4)]);
      expect(Rules.squares(6, 8, 0, 3, 4), [25, 25, 25, 25]);
      expect(Rules.acrossOne(6, 8, 0, 3, 4), 50);
      expect(Rules.allWhole(6, 8, 0, 3, 4), isTrue);
      expect(Rules.allSame(6, 8, 0, 3, 4), isTrue);
      expect(Rules.inside(6, 8, 0, 3, 4), isTrue);
      expect(Rules.inside(6, 8, 0, 0, 0), isFalse);
      // The left wall of a leaning hall runs from (0, 0) to (2, 4), so
      // at one pace up it is half a pace along.
      expect(Rules.inside(5, 4, 2, 0, 1), isFalse);
      expect(Rules.inside(5, 4, 2, 1, 1), isTrue);
      expect(Rules.inside(5, 4, 2, 3, 2), isTrue);
      expect(Rules.isSquare(25), isTrue);
      expect(Rules.isSquare(26), isFalse);
      expect(Rules.rootOf(49), 7);
      expect(Rules.tellSquares([25, 26, 25, 1]), '5, root 26, 5, 1');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Leaning Hall']);
      final counts = <String, int>{
        for (final level in Levels.all) level.name: 0,
      };
      for (final (wide, tall, px, py) in Rules.settings()) {
        for (final level in Levels.all) {
          if (level.meets(wide, tall, px, py)) {
            counts[level.name] = counts[level.name]! + 1;
          }
        }
      }
      for (final level in Levels.all) {
        expect(counts[level.name], level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways), [26, 16, 90, 2, 0]);
      expect(Levels.all.map((l) => l.fewest), [1, 1, 2, 8, null]);
      expect(Levels.all.map((l) => l.lean), [0, 0, 0, 0, 2]);
      for (final level in Levels.all.where((l) => l.winnable)) {
        final aim = level.aim!;
        expect(level.meets(aim.$1, aim.$2, aim.$3, aim.$4), isTrue,
            reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(3).task,
          'stand the peg inside the hall with all four posts a whole number of paces off');
      expect(Levels.at(4).task,
          'stand the peg so that the two sums agree on a hall leaned over by 2');
    });
  });

  group('the play', () {
    test('opens on a four by three with the peg two in and two up', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.wide, play.tall, play.px, play.py), (4, 3, 2, 2));
        expect(play.moves, 0);
        expect(play.isOver, isFalse, reason: level.name);
        expect(play.agrees, level.winnable,
            reason: 'a square hall agrees and a leaning one does not');
      }
    });

    test('the dials change the hall and a tap stands the peg', () {
      var play = Play.of(Levels.at(0));
      play = play.stepWide(1);
      expect(play.wide, 5);
      play = play.stepTall(-1);
      expect(play.tall, 2);
      expect(play.stepTall(-1), same(play), reason: 'two is the shortest');
      play = play.stand(0, 0);
      expect((play.px, play.py), (0, 0));
      expect(play.stand(0, 0), same(play));
      expect(play.stand(99, 0), same(play));
      expect(play.moves, 3);
      expect(play.back.px, 2);
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final aim = play.next;
          expect(aim, isNotNull, reason: level.name);
          play = play.follow(aim!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
      }
      expect(Play.pointed(('wide', 1, 0)), 'Widen the hall by a pace.');
      expect(Play.pointed(('tall', -1, 0)), 'Shorten the hall by a pace.');
      expect(Play.pointed(('peg', 3, 4)), 'Stand the peg at (3, 4).');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the leaning hall admits it after four standings', () {
      var play = Play.of(Levels.at(4));
      expect(play.agrees, isFalse);
      expect(play.apart, 2 * 2 * 4);
      play = play.stand(0, 0).stand(5, 5).stand(-3, 7);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isFalse);
      play = play.stepWide(1);
      expect(play.seen, hasLength(4));
      expect(play.gaveUp, isTrue);
      expect(play.stand(1, 1), same(play));
    });

    test('the why tells the flag and the lean', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('British flag theorem'));
      expect(words, contains('twice the lean times the width'));
      expect(words, contains('This is ask 5, The Leaning Hall.'));
      expect(words, contains('taken in full before the sham'));
    });
  });
}
