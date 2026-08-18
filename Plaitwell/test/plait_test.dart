import 'package:flutter_test/flutter_test.dart';
import 'package:plaitwell/plait/levels.dart';
import 'package:plaitwell/plait/play.dart';
import 'package:plaitwell/plait/rules.dart';

/// The plait itself, with no screen anywhere near it.
void main() {
  group('a plait', () {
    test('breaks an arc wherever a rope dives under', () {
      // Three crossings on two ropes: the trefoil, and three arcs.
      expect(Rules.arcs(2, const [1, 1, 1]), 3);
      expect(Rules.crossings(2, const [1, 1, 1]),
          [(0, 1, 2), (2, 0, 1), (1, 2, 0)]);
    });

    test('joins its foot back to its head', () {
      final lanes = Rules.lanes(2, const [1, 1, 1]);
      expect(lanes.length, 4);
      expect(lanes.first, lanes.last);
    });

    test('closes into one rope or several', () {
      expect(Rules.ropes(2, const [1, 1, 1]), 1);
      expect(Rules.ropes(2, const [1, 1]), 2);
      expect(Rules.ropes(3, const [1, -2, 1, -2, 1, -2]), 3);
    });

    test('counts a crossing under as well as over', () {
      expect(Rules.arcs(3, const [1, -2, 1, -2]), 4);
      expect(Rules.crossings(3, const [1, -2, 1, -2]),
          [(0, 1, 3), (2, 0, 1), (3, 2, 0), (1, 3, 2)]);
    });
  });

  group('the rule', () {
    test('takes one colour or three at a crossing', () {
      const crossing = (0, 1, 2);
      expect(Rules.sound(crossing, const [0, 0, 0]), isTrue);
      expect(Rules.sound(crossing, const [0, 1, 2]), isTrue);
      expect(Rules.sound(crossing, const [1, 2, 0]), isTrue);
      expect(Rules.sound(crossing, const [0, 0, 1]), isFalse);
      expect(Rules.sound(crossing, const [1, 1, 0]), isFalse);
    });

    test('is kept by painting a whole plait one colour', () {
      for (final level in Levels.all) {
        for (var c = 0; c < Rules.colours; c++) {
          expect(Rules.legal(level.crossings, List.filled(level.arcs, c)),
              isTrue,
              reason: '${level.name} colour $c');
        }
      }
    });

    test('names the crossings a painting gets wrong', () {
      final level = Levels.at(0);
      expect(Rules.wrong(level.crossings, const [0, 0, 0]), isEmpty);
      expect(Rules.wrong(level.crossings, const [0, 0, 1]), isNotEmpty);
    });
  });

  group('the count', () {
    test('is what the sweep says on every ask', () {
      for (final level in Levels.all) {
        expect(Rules.paintings(level.crossings, level.arcs), level.legal,
            reason: level.name);
        expect(
            Rules.paintings(level.crossings, level.arcs, allThree: true),
            level.ways,
            reason: level.name);
      }
      expect(Levels.all.map((l) => l.legal).toList(), [9, 9, 27, 9, 3]);
      expect(Levels.all.map((l) => l.ways).toList(), [6, 6, 24, 6, 0]);
    });

    test('does not follow the drawing', () {
      // The trefoil plaited two ways, and the same 9 either way.
      expect(Rules.paintings(Rules.crossings(2, const [1, 1, 1]), 3), 9);
      expect(Rules.paintings(Rules.crossings(3, const [1, 2, 1, 2]), 4), 9);
      // A kink put in changes the picture and not the count.
      expect(Rules.paintings(Rules.crossings(3, const [1, 1, 1, 2, -2, 2]),
          Rules.arcs(3, const [1, 1, 1, 2, -2, 2])), 9);
    });

    test('comes to a power of three, never below three', () {
      for (final word in const [
        [1],
        [1, 1],
        [1, 1, 1],
        [1, -2],
        [1, 2, 1, 2],
        [1, 1, 1, 2, 2, 2],
        [1, -2, 1, -2],
      ]) {
        final n = Rules.paintings(Rules.crossings(3, word), Rules.arcs(3, word));
        expect(n, greaterThanOrEqualTo(3));
        var p = 1;
        while (p < n) {
          p *= 3;
        }
        expect(p, n, reason: '$word came to $n');
      }
    });

    test('multiplies when two knots are tied in a row', () {
      final one = Rules.paintings(
          Rules.crossings(3, const [1, 1, 1, 2]), Rules.arcs(3, const [1, 1, 1, 2]));
      final both = Rules.paintings(Rules.crossings(3, const [1, 1, 1, 2, 2, 2]),
          Rules.arcs(3, const [1, 1, 1, 2, 2, 2]));
      expect(one, 9);
      expect(both, 27);
      expect(one * one ~/ 3, both);
    });
  });

  group('every ask', () {
    test('is not landed by the opening', () {
      for (final level in Levels.all) {
        expect(level.meets(List.filled(level.arcs, 0)), isFalse,
            reason: level.name);
      }
    });

    test('is landed by the pointer in the taps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          play = play.tap(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.taps, level.fewest, reason: level.name);
      }
      expect(Levels.all.map((l) => l.fewest).toList(), [3, 3, 3, 6, null]);
    });
  });

  group('a go', () {
    test('steps one rope on a colour and counts one tap', () {
      final one = Play.of(Levels.at(0)).tap(1);
      expect(one.paint, [0, 1, 0]);
      expect(one.taps, 1);
    });

    test('comes round to where it started in three taps', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 3; k++) {
        play = play.tap(0);
      }
      expect(play.paint, [0, 0, 0]);
      expect(play.taps, 3);
    });

    test('takes a tap back', () {
      final one = Play.of(Levels.at(0)).tap(1);
      expect(one.back.paint, [0, 0, 0]);
      expect(one.back.taps, 0);
    });

    test('counts the colours on the rope and the crossings gone wrong', () {
      final play = Play.of(Levels.at(0)).tap(1);
      expect(play.shades, 2);
      expect(play.allSound, isFalse);
      expect(play.wrong.length, greaterThan(0));
    });

    test('points at a rope and says how many taps it wants', () {
      final play = Play.of(Levels.at(0));
      final arc = play.next!;
      expect(play.pointed(arc), contains('Rope '));
      expect(play.pointed(arc), contains('tap'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('has three legal paintings and every one is a single colour', () {
      final legal = <List<int>>[];
      for (var a = 0; a < 3; a++) {
        for (var b = 0; b < 3; b++) {
          for (var c = 0; c < 3; c++) {
            for (var d = 0; d < 3; d++) {
              final paint = [a, b, c, d];
              if (Rules.legal(dead.crossings, paint)) legal.add(paint);
            }
          }
        }
      }
      expect(legal.length, 3);
      for (final paint in legal) {
        expect(paint.toSet().length, 1);
      }
    });

    test('has no painting at all with every crossing in three colours', () {
      var found = 0;
      for (var a = 0; a < 3; a++) {
        for (var b = 0; b < 3; b++) {
          for (var c = 0; c < 3; c++) {
            for (var d = 0; d < 3; d++) {
              final paint = [a, b, c, d];
              final all = dead.crossings.every((x) =>
                  {paint[x.$1], paint[x.$2], paint[x.$3]}.length == 3);
              if (all) found++;
            }
          }
        }
      }
      expect(found, 0);
    });

    test('keeps no pointer and admits it after eight paintings', () {
      expect(Play.of(dead).next, isNull);
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final arc in const [0, 1, 2, 3, 0, 1, 2, 3]) {
        play = play.tap(arc);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });

  group('the why', () {
    test('names the three moves and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(1)));
      expect(words, contains('kink'));
      expect(words, contains('The Long Plait'));
      expect(words, contains('81'));
    });
  });
}
