import 'package:flutter_test/flutter_test.dart';
import 'package:glintmere/glint/level.dart';
import 'package:glintmere/glint/levels.dart';
import 'package:glintmere/glint/play.dart';
import 'package:glintmere/glint/rules.dart';

/// The mirror itself, with no screen anywhere near it.
void main() {
  group('the whole-number arithmetic', () {
    test('finds a whole root, or says there is none', () {
      expect(Rules.root(0), 0);
      expect(Rules.root(25), 5);
      expect(Rules.root(100), 10);
      expect(Rules.root(24), isNull);
      expect(Rules.root(101), isNull);
    });

    test('holds two roots added against a whole number', () {
      // 5 and 5 come to 10 exactly.
      expect(Rules.within(25, 25, 10), isTrue);
      expect(Rules.within(25, 25, 9), isFalse);
      // The root of 2 twice is about 2.83.
      expect(Rules.within(2, 2, 3), isTrue);
      expect(Rules.within(2, 2, 2), isFalse);
    });

    test('holds two roots added against another root', () {
      expect(Rules.equals(25, 25, 100), isTrue);
      expect(Rules.equals(20, 80, 100), isFalse);
      expect(Rules.equals(0, 49, 49), isTrue);
    });

    test('adds two roots only when both are whole', () {
      expect(Rules.paces(25, 25), 10);
      expect(Rules.paces(9, 16), 7);
      expect(Rules.paces(20, 80), isNull);
    });
  });

  group('the mirror', () {
    test('measures a leg by its two sides', () {
      expect(Rules.leg(2, 4, 5), 9 + 16);
      expect(Rules.leg(8, 4, 5), 9 + 16);
      expect(Rules.leg(0, 3, 0), 9);
    });

    test('folds the eye under and measures the straight run', () {
      expect(Rules.folded(2, 4, 8, 4), 100);
      expect(Rules.root(Rules.folded(2, 4, 8, 4)), 10);
    });

    test('matches the angles by crossing runs with rises', () {
      expect(Rules.anglesMatch(2, 4, 8, 4, 5), isTrue);
      expect(Rules.anglesMatch(2, 4, 8, 4, 4), isFalse);
      expect(Rules.anglesMatch(2, 4, 8, 4, 6), isFalse);
      // A bounce outside the two never crosses the mirror.
      expect(Rules.anglesMatch(2, 4, 8, 4, 0), isFalse);
      expect(Rules.anglesMatch(2, 4, 8, 4, 12), isFalse);
    });
  });

  group('the two voices', () {
    test('agree on every setting of lamp, eye and bounce', () {
      var settings = 0, matched = 0, shorter = 0;
      for (var lampY = 1; lampY <= Rules.sky; lampY++) {
        for (var eyeY = 1; eyeY <= Rules.sky; eyeY++) {
          for (var lampX = 0; lampX < Rules.mirror; lampX++) {
            for (var eyeX = 0; eyeX < Rules.mirror; eyeX++) {
              final run = Rules.folded(lampX, lampY, eyeX, eyeY);
              for (final bounce in Rules.bounces) {
                settings++;
                final (one, two) =
                    Rules.legs(lampX, lampY, eyeX, eyeY, bounce);
                final byPacing = Rules.equals(one, two, run);
                final byAngle =
                    Rules.anglesMatch(lampX, lampY, eyeX, eyeY, bounce);
                expect(byAngle, byPacing,
                    reason: 'lamp($lampX,$lampY) eye($eyeX,$eyeY) $bounce');
                if (byAngle) matched++;
                // Nothing beats its own straight run.
                final over = run - one - two;
                if (over >= 0 && 4 * one * two < over * over) shorter++;
              }
            }
          }
        }
      }
      expect(settings, 54925);
      expect(matched, 1125);
      expect(shorter, 0);
    });
  });

  group('the board the asks stand on', () {
    test('puts the lamp and the eye eight apart and six across', () {
      expect(Level.lampX, 2);
      expect(Level.lampY, 4);
      expect(Level.eyeX, 8);
      expect(Level.eyeY, 4);
      expect(Level.folded, 100);
      expect(Level.least, 10);
    });

    test('has one bounce where the angles match, with legs of five', () {
      final even = [
        for (final p in Rules.bounces)
          if (Rules.anglesMatch(
              Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, p))
            p,
      ];
      expect(even, [5]);
      final (one, two) =
          Rules.legs(Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, 5);
      expect(Rules.root(one), 5);
      expect(Rules.root(two), 5);
      expect(Rules.paces(one, two), 10);
    });
  });

  group('every ask', () {
    test('lands as many pegs as it claims', () {
      for (final level in Levels.all) {
        final n = Rules.bounces.where(level.meets).length;
        expect(n, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways).toList(), [9, 7, 5, 1, 0]);
    });

    test('tightens by one pace at a time and the count falls with it', () {
      for (var i = 1; i < Levels.count; i++) {
        expect(Levels.at(i).paces, Levels.at(i - 1).paces - 1);
        expect(Levels.at(i).ways, lessThan(Levels.at(i - 1).ways));
      }
    });

    test('opens on a bounce that lands nothing', () {
      for (final level in Levels.all) {
        expect(level.meets(Level.opening), isFalse, reason: level.name);
      }
    });

    test('is landed by the pointer in the slides it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.slides < 20) {
          play = play.slide(play.next!);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.slides, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('slides one peg at a time, towards wherever it is told', () {
      final play = Play.of(Levels.at(0));
      expect(play.bounce, 0);
      expect(play.slide(12).bounce, 1);
      expect(play.slide(12).slides, 1);
      expect(play.slide(1).bounce, 1);
    });

    test('will not slide off the end of the glass', () {
      final play = Play.at(Levels.at(0), 0);
      expect(identical(play.slide(0), play), isTrue);
    });

    test('takes a slide back', () {
      final one = Play.of(Levels.at(0)).slide(12);
      expect(one.back.bounce, 0);
      expect(one.back.slides, 0);
    });

    test('knows the angles match only at the one bounce', () {
      for (final p in Rules.bounces) {
        expect(Play.at(Levels.at(3), p).even, p == 5, reason: '$p');
        expect(Play.at(Levels.at(3), p).straight, p == 5, reason: '$p');
      }
    });

    test('points the way and says which way it is', () {
      final play = Play.of(Levels.at(3));
      expect(play.next, 5);
      expect(play.pointed(5), contains('right'));
      expect(Play.at(Levels.at(3), 9).pointed(5), contains('left'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('asks for less than the straight run and so lands nothing', () {
      expect(dead.paces, lessThan(Level.least));
      expect(Rules.bounces.where(dead.meets), isEmpty);
    });

    test('keeps no pointer at all', () {
      expect(Play.of(dead).next, isNull);
    });

    test('admits it after seven bounces', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (var k = 0; k < Play.enough; k++) {
        play = play.slide(Rules.mirror - 1);
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });

  group('the why', () {
    test('names Hero, the folding and the sweep', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('Hero of Alexandria'));
      expect(words, contains('fold the board'));
      expect(words, contains('54,925'));
      expect(words, contains('The Even Angles'));
    });
  });
}
