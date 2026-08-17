import 'package:cantlemere/plot/levels.dart';
import 'package:cantlemere/plot/play.dart';
import 'package:cantlemere/plot/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The field itself, with no screen anywhere near it.
void main() {
  group('the field', () {
    test('is three across, nine acres, sixteen pegs', () {
      expect(Rules.side, 3);
      expect(Rules.pegs, 16);
      expect(Rules.field, 18);
      expect(Rules.peg(0), (0, 0));
      expect(Rules.peg(15), (3, 3));
      expect(Rules.pegAt(2, 1), 6);
    });

    test('allows 516 plots, and no plot with its corners in a line', () {
      expect(Rules.plots.length, 516);
      for (final p in Rules.plots) {
        expect(Rules.halves(p), greaterThan(0));
      }
      // The two diagonals are the biggest plots there are.
      expect(Rules.halves([Rules.pegAt(0, 0), Rules.pegAt(3, 0), Rules.pegAt(3, 3)]),
          9);
    });

    test('cuts itself into 624 cells with 62 lines, worked out in fractions',
        () {
      expect(Rules.lines.length, 62);
      expect(Rules.cells, 624);
    });
  });

  group('the colouring', () {
    test('takes each peg from its own two numbers', () {
      expect(Rules.colour(Rules.pegAt(0, 0)), 0);
      expect(Rules.colour(Rules.pegAt(1, 0)), 1);
      expect(Rules.colour(Rules.pegAt(0, 1)), 2);
      expect(Rules.colour(Rules.pegAt(2, 2)), 0);
      expect(Rules.colour(Rules.pegAt(3, 2)), 1);
    });

    test('comes to four red, eight blue and four green', () {
      final census = <int, int>{};
      for (var p = 0; p < Rules.pegs; p++) {
        census[Rules.colour(p)] = (census[Rules.colour(p)] ?? 0) + 1;
      }
      expect(census, {0: 4, 1: 8, 2: 4});
    });

    test('steps between red and blue an odd number of times round the rim',
        () {
      expect(Rules.rimSteps(), 3);
      expect(Rules.rimSteps().isOdd, isTrue);
    });

    test('puts no line through two pegs on all three colours', () {
      for (final (a, b, c) in Rules.lines) {
        final on = <int>{};
        for (var p = 0; p < Rules.pegs; p++) {
          final (x, y) = Rules.peg(p);
          if (a * x + b * y == c) on.add(Rules.colour(p));
        }
        expect(on.length, lessThan(3));
      }
    });

    test('makes every motley plot an odd number of half acres', () {
      var motley = 0;
      for (final p in Rules.plots) {
        if (!Rules.motley(p)) continue;
        motley++;
        expect(Rules.halves(p).isOdd, isTrue, reason: '$p');
      }
      expect(motley, 128);
    });
  });

  group('two plots', () {
    test('lie apart when a line separates them', () {
      final lower = [Rules.pegAt(0, 0), Rules.pegAt(3, 0), Rules.pegAt(3, 3)];
      final upper = [Rules.pegAt(0, 0), Rules.pegAt(3, 3), Rules.pegAt(0, 3)];
      expect(Rules.apart(lower, upper), isTrue);
      expect(Rules.cuts([lower, upper]), isTrue);
    });

    test('do not lie apart when one sits inside the other', () {
      final big = [Rules.pegAt(0, 0), Rules.pegAt(3, 0), Rules.pegAt(3, 3)];
      final small = [Rules.pegAt(1, 0), Rules.pegAt(2, 0), Rules.pegAt(2, 1)];
      expect(Rules.apart(big, small), isFalse);
    });

    test('may share an edge or a corner', () {
      final left = [Rules.pegAt(0, 0), Rules.pegAt(1, 0), Rules.pegAt(0, 1)];
      final right = [Rules.pegAt(1, 0), Rules.pegAt(1, 1), Rules.pegAt(0, 1)];
      expect(Rules.apart(left, right), isTrue);
    });
  });

  group('the cuts', () {
    test('come to 2, 32, 272, 1688 and 8836 for two plots up to six', () {
      final byCount = <int, int>{};
      Rules.walkCuts((laid) {
        byCount[laid.length] = (byCount[laid.length] ?? 0) + 1;
      }, most: 6);
      expect(byCount, {2: 2, 3: 32, 4: 272, 5: 1688, 6: 8836});
    });

    test('are counted the same by the voice that knows nothing of cells', () {
      var held = 0, seen = 0;
      Rules.walkCuts((laid) {
        seen++;
        if (Rules.cuts([for (final p in laid) Rules.plots[p]])) held++;
      }, most: 6);
      expect(seen, 10830);
      expect(held, seen);
    });

    test('into three always come out 3, 6 and 9 with one motley plot', () {
      final threes = Rules.cutsOf(3);
      expect(threes.length, 32);
      for (final cut in threes) {
        final sizes = [for (final p in cut) Rules.halves(Rules.plots[p])]
          ..sort();
        expect(sizes, [3, 6, 9]);
        expect(cut.where((p) => Rules.motley(Rules.plots[p])).length, 1);
      }
    });

    test('into equal plots can be had at two and six and never at three', () {
      expect(Rules.cutsOf(2, even: true).length, 2);
      expect(Rules.cutsOf(6, even: true).length, 68);
      expect(Rules.cutsOf(3, even: true), isEmpty);
      expect(Rules.cutsOf(9, even: true), isEmpty);
    });
  });

  group('every ask', () {
    test('lands as many cuts as it claims', () {
      for (final level in Levels.all) {
        expect(Rules.cutsOf(level.pieces, even: level.even).length, level.ways,
            reason: level.name);
      }
    });

    test('opens on an empty field, which lands nothing', () {
      for (final level in Levels.all) {
        expect(level.meets(const []), isFalse, reason: level.name);
      }
    });

    test('wants three taps a plot and says so', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(level.fewest, level.pieces * 3, reason: level.name);
      }
    });

    test('is cut by the pointer in the taps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.taps < 40) {
          play = play.tap(play.next!);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.taps, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('takes two pegs under the hand and lays the plot on the third', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(Rules.pegAt(0, 0));
      expect(play.holding.length, 1);
      expect(play.laid, isEmpty);
      play = play.tap(Rules.pegAt(3, 0));
      expect(play.holding.length, 2);
      play = play.tap(Rules.pegAt(3, 3));
      expect(play.laid.length, 1);
      expect(play.holding, isEmpty);
      expect(play.taps, 3);
      expect(play.taken, 9);
      expect(play.left, 9);
    });

    test('takes a peg back off the hand when it is tapped again', () {
      var play = Play.of(Levels.at(0)).tap(Rules.pegAt(1, 1));
      play = play.tap(Rules.pegAt(1, 1));
      expect(play.holding, isEmpty);
      expect(play.taps, 2);
    });

    test('refuses three pegs in a line', () {
      var play = Play.of(Levels.at(0));
      final was = play
          .tap(Rules.pegAt(0, 0))
          .tap(Rules.pegAt(1, 0));
      play = was.tap(Rules.pegAt(2, 0));
      expect(identical(play, was), isTrue);
      expect(play.laid, isEmpty);
    });

    test('refuses a plot that would lie over one already down', () {
      var play = Play.of(Levels.at(0))
          .tap(Rules.pegAt(0, 0))
          .tap(Rules.pegAt(3, 0))
          .tap(Rules.pegAt(3, 3));
      final was = play.tap(Rules.pegAt(1, 0)).tap(Rules.pegAt(2, 0));
      play = was.tap(Rules.pegAt(2, 1));
      expect(identical(play, was), isTrue);
    });

    test('lifts a plot off again', () {
      final play = Play.of(Levels.at(0))
          .tap(Rules.pegAt(0, 0))
          .tap(Rules.pegAt(3, 0))
          .tap(Rules.pegAt(3, 3));
      expect(play.lift(play.laid.first).laid, isEmpty);
    });

    test('points at a peg and says how many more are wanted', () {
      final play = Play.of(Levels.at(0));
      final peg = play.next!;
      expect(play.pointed(peg), contains('Tap the peg at'));
      expect(play.pointed(peg), contains('more to lay the plot'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('is landed by no cut at all, though the field divides by three', () {
      expect(Rules.cutsOf(3, even: true), isEmpty);
      expect(dead.shares, isTrue);
      expect(dead.share, 6);
    });

    test('keeps no pointer, since nothing carries on to a landing', () {
      expect(Play.of(dead).next, isNull);
    });

    test('admits it after six cuts', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      for (final trio in const [
        [0, 1, 4], [1, 2, 5], [2, 3, 6], [4, 5, 8], [5, 6, 9], [8, 9, 12],
      ]) {
        for (final peg in trio) {
          play = play.tap(peg);
        }
      }
      expect(play.laid.length, 6);
      expect(play.gaveUp, isTrue);
    });

    test('hands back a three-plot cut with the whole argument on it', () {
      var play = Play.of(dead);
      for (final peg in const [0, 1, 4]) {
        play = play.tap(peg);
      }
      final shown = play.asThree;
      expect(shown.laid.length, 3);
      expect(shown.sizes..sort(), [3, 6, 9]);
      expect(shown.motley.length, 1);
    });
  });

  group('the why', () {
    test('names Monsky, the colouring and the sweep', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('Monsky proved that in 1970'));
      expect(words, contains('motley'));
      expect(words, contains('26,822,326'));
      expect(words, contains('The Even Six'));
    });
  });
}
