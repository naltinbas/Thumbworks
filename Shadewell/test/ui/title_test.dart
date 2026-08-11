import 'package:flutter_test/flutter_test.dart';
import 'package:shadewell/plot/plots.dart';

import '../support/plot.dart';

void main() {
  group('the garden of plots', () {
    testWidgets('names the game and every plot', (tester) async {
      await open(tester);
      expect(find.text('Shadewell'), findsOne);
      for (var number = 0; number < Plots.count; number++) {
        expect(find.text(Plots.at(number).name), findsOne);
      }
    });

    testWidgets('the flawed plots are labelled on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no shading keeps its tallies'),
          findsOne);
      expect(find.textContaining('2 pictures fit its tallies'),
          findsOne);
    });

    testWidgets('a row opens its plot', (tester) async {
      await open(tester);
      await tester.tap(find.text(Plots.at(1).name));
      await tester.pump();
      expect(state(tester).play.plot.name, Plots.at(1).name);
    });

    testWidgets('leaving a plot lands back on the garden', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the plots'));
      await tester.pump();
      expect(find.text('Shadewell'), findsOne);
    });
  });
}
