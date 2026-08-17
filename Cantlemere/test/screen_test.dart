import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plotland.dart';

/// One ask on the screen, the plots laid as a thumb would lay them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('cut the field into 2 plots'), findsWidgets);
    expect(find.text('plots 0 of 2'), findsOneWidget);
    expect(find.text('left 18 of 18'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.textContaining('Tap three pegs to lay the first plot'),
        findsOneWidget);
  });

  testWidgets('three pegs lay a plot, and back takes it off', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, 0, 0);
    expect(state(tester).play.holding.length, 1);
    expect(find.textContaining('1 of three pegs taken'), findsOneWidget);
    await tapPeg(tester, 3, 0);
    await tapPeg(tester, 3, 3);
    expect(state(tester).play.laid.length, 1);
    expect(find.text('plots 1 of 2'), findsOneWidget);
    expect(find.text('left 9 of 18'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.laid, isEmpty);
  });

  testWidgets('three pegs in a line lay nothing and say so', (tester) async {
    await open(tester, which: 0);
    await layPlot(tester, const [(0, 0), (1, 0), (2, 0)]);
    expect(state(tester).play.laid, isEmpty);
    expect(find.textContaining('Those three pegs make no plot'),
        findsOneWidget);
  });

  testWidgets('a laid plot lifts off when it is tapped', (tester) async {
    await open(tester, which: 0);
    await layPlot(tester, const [(0, 0), (3, 0), (3, 3)]);
    expect(state(tester).play.laid.length, 1);
    await tester.tapAt(insideAt(tester, state(tester).play.laid.first));
    await tester.pumpAndSettle();
    expect(state(tester).play.laid, isEmpty);
  });

  testWidgets('the two plots cut in six taps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 6);
    expect(state(tester).play.sizes, [9, 9]);
    expect(find.text('Cut.'), findsOneWidget);
    expect(find.textContaining('One of 2 cuts'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cut.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the three plots come out three, six and nine', (tester) async {
    await open(tester, which: 1);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 9);
    expect(state(tester).play.sizes..sort(), [3, 6, 9]);
    expect(find.textContaining('One of 32 cuts'), findsOneWidget);
  });

  testWidgets('the even six gives six plots of three', (tester) async {
    await open(tester, which: 3);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 18);
    expect(state(tester).play.sizes, [3, 3, 3, 3, 3, 3]);
    expect(find.textContaining('One of 68 cuts'), findsOneWidget);
  });

  testWidgets('show me names a peg and how many more it wants',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Tap the peg at'), findsOneWidget);
  });

  testWidgets('the even three gives itself up and shows a three-plot cut',
      (tester) async {
    await open(tester, which: 4);
    for (final trio in const [
      [(0, 0), (1, 0), (0, 1)],
      [(1, 0), (2, 0), (1, 1)],
      [(2, 0), (3, 0), (2, 1)],
      [(0, 1), (1, 1), (0, 2)],
      [(1, 1), (2, 1), (1, 2)],
      [(0, 2), (1, 2), (0, 3)],
    ]) {
      await layPlot(tester, trio);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Three equal plots are not to be had.'), findsOneWidget);
    expect(find.textContaining('the plot ringed in blue'), findsOneWidget);
    expect(find.textContaining('ringed in gold wears all three peg colours'),
        findsOneWidget);
    expect(find.textContaining('Every cut into three leaves a plot of 9'),
        findsOneWidget);
  });

  testWidgets('the why names Monsky and both reasons', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Monsky proved that in 1970'), findsOneWidget);
    expect(find.textContaining('Half is not a third'), findsOneWidget);
    expect(find.textContaining('26,822,326'), findsOneWidget);
  });
}
