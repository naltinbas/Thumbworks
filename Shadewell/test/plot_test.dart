import 'package:flutter_test/flutter_test.dart';
import 'package:shadewell/plot/play.dart';
import 'package:shadewell/plot/plots.dart';
import 'package:shadewell/plot/rules.dart';

void main() {
  group('the patterns', () {
    test('place runs in order with a gap between', () {
      expect(Rules.patterns([5], 5), [0x1F]);
      expect(Rules.patterns([1, 1], 3), [0x05]);
      expect(Rules.patterns([2], 5), hasLength(4));
      expect(Rules.patterns([0], 5), [0]);
    });

    test('a finished line reads back its tally', () {
      expect(Rules.tallyOf(0x1F, 5), [5]);
      expect(Rules.tallyOf(0x15, 5), [1, 1, 1]);
      expect(Rules.tallyOf(0x00, 5), [0]);
      expect(Rules.tallyOf(0x0E, 5), [3]);
    });
  });

  group('the two ways of knowing', () {
    test('the stacking finds one picture where one is written', () {
      // The anchor, in both senses: every filling of the rows tried,
      // knowing nothing of deduction.
      for (var number = 0; number < Plots.count; number++) {
        final plot = Plots.at(number);
        final rules = Rules(plot.wide, plot.high);
        final all =
            rules.solutionsOf(plot.rowTallies, plot.colTallies);
        expect(all, hasLength(plot.solutions), reason: plot.name);
        final picture = plot.picture;
        if (picture != null) {
          expect(all.single, picture, reason: plot.name);
        }
      }
    });

    test('reason alone reaches every written picture', () {
      for (var number = 0; number < Plots.count; number++) {
        final plot = Plots.at(number);
        final picture = plot.picture;
        if (picture == null) continue;
        final rules = Rules(plot.wide, plot.high);
        final solved =
            rules.lineSolve(plot.rowTallies, plot.colTallies);
        expect(solved, isNotNull, reason: plot.name);
        expect(rules.complete(solved!.$1, solved.$2), isTrue,
            reason: plot.name);
        expect(solved.$1, picture, reason: plot.name);
      }
    });

    test('the short tally is dead by counting alone', () {
      final plot = Plots.at(5);
      expect(plot.rowsAsk, 9);
      expect(plot.colsAsk, 8);
    });

    test('the two gardens are each other, swung corner to corner', () {
      final plot = Plots.at(4);
      final rules = Rules(plot.wide, plot.high);
      final all = rules.solutionsOf(plot.rowTallies, plot.colTallies);
      expect(all, hasLength(2));
      // Turning one head over heels gives the other.
      expect(all.first.reversed.toList(), all.last);
    });
  });

  group('a plot in play', () {
    test('starts unknown everywhere', () {
      final play = Play.of(Plots.at(0));
      expect(play.decided, 0);
      expect(play.marks, 0);
      expect(play.isDone, isFalse);
    });

    test('taps cycle a cell through its three states', () {
      var play = Play.of(Plots.at(0));
      play = play.touch(2, 2);
      expect(play.isShaded(2, 2), isTrue);
      play = play.touch(2, 2);
      expect(play.isShaded(2, 2), isFalse);
      expect(play.isBare(2, 2), isTrue);
      play = play.touch(2, 2);
      expect(play.isBare(2, 2), isFalse);
      expect(play.marks, 3);
    });

    test('take back returns the plot as it stood', () {
      final start = Play.of(Plots.at(0));
      final marked = start.touch(0, 0);
      expect(marked.back.decided, 0);
      expect(identical(start.back, start), isTrue);
    });

    test('a fallen line is seen the moment it falls', () {
      // The tree's top row holds one: shade two cells there.
      var play = Play.of(Plots.at(0));
      play = play.touch(0, 0).touch(0, 1);
      expect(play.fallenRows, [0]);
      expect(play.next, isNull);
    });

    test('deduction offers a cell wherever reason can move', () {
      final play = Play.of(Plots.at(0));
      final offer = play.next;
      expect(offer, isNotNull);
      // Whatever it offers, marking it moves the plot forward.
      final (row, col, shade) = offer!;
      var marked = play.touch(row, col);
      if (!shade) marked = marked.touch(row, col);
      expect(marked.decided, 1);
      expect(marked.fallenRows, isEmpty);
    });

    test('following deduction shades every written picture home', () {
      for (var number = 0; number < Plots.count; number++) {
        final plot = Plots.at(number);
        if (plot.picture == null) continue;
        var play = Play.of(plot);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 60) fail('${plot.name} never came home');
          final (row, col, shade) = play.next!;
          play = play.touch(row, col);
          if (!shade) play = play.touch(row, col);
        }
        expect(play.shaded, plot.picture, reason: plot.name);
      }
    });

    test('either garden satisfies the two gardens', () {
      final plot = Plots.at(4);
      final rules = Rules(plot.wide, plot.high);
      final all = rules.solutionsOf(plot.rowTallies, plot.colTallies);
      for (final picture in all) {
        var play = Play.of(plot);
        for (var row = 0; row < 5; row++) {
          for (var col = 0; col < 5; col++) {
            play = play.touch(row, col);
            if (picture[row] & (1 << col) == 0) {
              play = play.touch(row, col);
            }
          }
        }
        expect(play.isDone, isTrue);
      }
    });

    test('the short tally never comes done', () {
      var play = Play.of(Plots.at(5));
      // Shade the rows their own way: the columns then fall.
      for (var row = 0; row < 5; row++) {
        final pattern =
            Rules.patterns(play.plot.rowTallies[row], 5).first;
        for (var col = 0; col < 5; col++) {
          play = play.touch(row, col);
          if (pattern & (1 << col) == 0) play = play.touch(row, col);
        }
      }
      expect(play.isDone, isFalse);
      expect(play.fallenCols, isNotEmpty);
    });
  });
}
