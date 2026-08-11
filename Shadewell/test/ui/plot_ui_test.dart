import 'package:flutter_test/flutter_test.dart';
import 'package:shadewell/plot/plots.dart';

import '../support/plot.dart';

void main() {
  group('the screen', () {
    testWidgets('opens unknown everywhere', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.decided, 0);
      expect(find.text('0 of 25 cells decided'), findsOne);
      expect(find.text('0 marked'), findsOne);
    });

    testWidgets('taps cycle a cell and count', (tester) async {
      await open(tester, which: 0);
      await tapCell(tester, 2, 2);
      expect(state(tester).play.isShaded(2, 2), isTrue);
      await tapCell(tester, 2, 2);
      expect(state(tester).play.isBare(2, 2), isTrue);
      expect(find.text('2 marked'), findsOne);
    });

    testWidgets('Back unmarks the last touch', (tester) async {
      await open(tester, which: 0);
      await tapCell(tester, 0, 0);
      await press(tester, 'Back');
      expect(state(tester).play.decided, 0);
    });

    testWidgets('Again clears the plot', (tester) async {
      await open(tester, which: 0);
      await tapCell(tester, 0, 0);
      await tapCell(tester, 1, 1);
      await press(tester, 'Again');
      expect(state(tester).play.marks, 0);
    });
  });

  group('the words under the garden', () {
    testWidgets('a fallen tally is called out the moment it falls',
        (tester) async {
      await open(tester, which: 0);
      await mark(tester, 0, 0, shade: true);
      await mark(tester, 0, 1, shade: true);
      expect(state(tester).play.fallenRows, [0]);
      expect(find.textContaining('Row 1 fits nothing now'), findsOne);
      expect(find.textContaining('tally has fallen'), findsOne);
    });

    testWidgets('Show me points at a settled cell', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('agrees: that cell'), findsOne);
    });

    testWidgets('Why speaks the one-picture claim', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('exactly one'), findsOne);
      expect(find.textContaining('share nothing'), findsOne);
    });

    testWidgets('the two gardens show each picture in turn',
        (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('more than one picture'), findsOne);
      await press(tester, 'Why');
      final first = state(tester).other;
      expect(first, isNotNull);
      await press(tester, 'Why');
      expect(state(tester).other, isNot(first));
    });

    testWidgets('the short tally says so as it opens, and Why counts',
        (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('No shading keeps these tallies'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('rows ask 9'), findsOne);
      expect(find.textContaining('columns 8'), findsOne);
    });
  });

  group('a plot finished', () {
    testWidgets('deduction alone shades every written picture',
        (tester) async {
      for (var number = 0; number < Plots.count; number++) {
        final plot = Plots.at(number);
        if (plot.picture == null) continue;
        await open(tester, which: number);
        await shadeItHome(tester);
        expect(state(tester).play.isDone, isTrue, reason: plot.name);
        expect(state(tester).play.shaded, plot.picture,
            reason: plot.name);
      }
    });

    testWidgets('the card owns the uniqueness', (tester) async {
      await open(tester, which: 0);
      await shadeItHome(tester);
      expect(find.text('every tally kept'), findsOne);
      expect(find.textContaining('this one alone'), findsOne);
    });

    testWidgets('the gardens\' card owns the ambiguity', (tester) async {
      // Reason stalls where the pictures disagree, so the hand must
      // choose one garden and shade it whole.
      await open(tester, which: 4);
      const garden = [3, 3, 0, 24, 24];
      for (var row = 0; row < 5; row++) {
        for (var col = 0; col < 5; col++) {
          await mark(tester, row, col,
              shade: garden[row] & (1 << col) != 0);
        }
      }
      expect(state(tester).play.isDone, isTrue);
      expect(find.textContaining('never named one garden'), findsOne);
    });

    testWidgets('Next opens the plot after', (tester) async {
      await open(tester, which: 0);
      await shadeItHome(tester);
      await press(tester, 'Next');
      expect(state(tester).play.plot.name, Plots.at(1).name);
    });
  });
}
