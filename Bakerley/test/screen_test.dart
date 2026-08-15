import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/trayland.dart';

/// One tray on the screen, filled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a tray opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('fill the four-by-four tray with four tees'), findsOneWidget);
    expect(find.text('laid 0 of 4'), findsOneWidget);
    expect(find.text('bare 16'), findsOneWidget);
    expect(find.text('layings 0'), findsOneWidget);
    expect(find.textContaining('0 of 4 laid, 16 cells bare'), findsOneWidget);
  });

  testWidgets('a four is taken, turned, laid and lifted, and back undoes', (tester) async {
    await open(tester, which: 1);
    await takeKind(tester, 4);
    expect(state(tester).play.held, 4);
    expect(find.text('Holding the elbow: Turn and Flip it, then tap the cell for its top left corner.'), findsOneWidget);
    await press(tester, 'Turn');
    expect(state(tester).play.facing, isNot(0));
    await press(tester, 'Flip');
    await tapCell(tester, 3, 3);
    expect(find.text('That does not fit there: a four must lie inside the tray over bare cells.'), findsOneWidget);
    await tapCell(tester, 0, 0);
    expect(state(tester).play.laid.length, 1);
    expect(find.text('layings 1'), findsOneWidget);
    expect(find.text('bare 12'), findsOneWidget);
    await tapCell(tester, 1, 0);
    expect(state(tester).play.laid, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.laid.length, 1);
  });

  testWidgets('the pinwheel lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    for (final (k, o, x, y) in [(2, 0, 0, 0), (2, 3, 1, 0), (2, 1, 2, 1), (2, 2, 0, 2)]) {
      await lay(tester, k, o, x, y);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Filled.'), findsOneWidget);
    expect(find.text('Filled: 4 fours, 16 cells, none bare.'), findsOneWidget);
    expect(find.textContaining('Four tees fill the 4 by 4 tray exactly, 16 cells; 4 layings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Filled.'), findsNothing);
  });

  testWidgets('show me names the four, the turn and the cells', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.text('Take the tee from the bag.'), findsOneWidget);
    await takeKind(tester, 2);
    await press(tester, 'Show me');
    expect(find.text('Lay it with its corner at the ringed cells.'), findsOneWidget);
    await tapCell(tester, 0, 0);
    await takeKind(tester, 2);
    await press(tester, 'Show me');
    expect(find.textContaining(RegExp('Turn it a quarter|Flip it over')), findsOneWidget);
  });

  testWidgets('the pointer fills the mixed tray', (tester) async {
    await open(tester, which: 2);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('Two tees, two skews and an elbow fill the 5 by 4 tray exactly, 20 cells'), findsOneWidget);
  });

  testWidgets('a four in the way is pointed at to lift', (tester) async {
    await open(tester, which: 3);
    await lay(tester, 4, 0, 0, 0);
    await press(tester, 'Show me');
    expect(find.text('Lift the four ringed rust: it is in the way.'), findsOneWidget);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the five never fill the tray', (tester) async {
    await open(tester, which: 4);
    // The tee, then the bar along the top; the square and the skew and
    // the elbow crowd, and something is left with nowhere to lie.
    await lay(tester, 2, 3, 0, 0);
    await lay(tester, 0, 1, 0, 2);
    await lay(tester, 1, 0, 3, 0);
    expect(state(tester).play.isOver, isTrue);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The five never fill it.'), findsOneWidget);
    expect(find.textContaining('the tee three of one and one of the other, so the five cover eleven and nine'), findsOneWidget);
  });

  testWidgets('the why tells the colouring and the counts', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('a tray of equal dark and light needs an even count of tees'), findsOneWidget);
    expect(find.textContaining('the search finds no filling either'), findsOneWidget);
  });
}
