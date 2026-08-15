import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One comb on the screen, filled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a comb opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('fill the four empty cells with the numbers left so every line of the comb sums to 38'),
      findsOneWidget,
    );
    expect(find.text('filled 15 of 19'), findsOneWidget);
    expect(find.text('lines right 7 of 15'), findsOneWidget);
    expect(find.text('sum 38'), findsOneWidget);
    expect(find.text('Filled 15 of 19; tap an empty cell, then a number.'), findsOneWidget);
  });

  testWidgets('a cell is picked, a number put, cleared, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 8);
    expect(state(tester).play.held, 8);
    expect(find.text('Cell picked: tap a number to put there.'), findsOneWidget);
    await put(tester, 2);
    expect(find.text('filled 16 of 19'), findsOneWidget);
    expect(state(tester).play.values[8], 2);
    await tapCell(tester, 8);
    expect(find.text('filled 15 of 19'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.values[8], 2);
  });

  testWidgets('a line off goes rust', (tester) async {
    await open(tester, which: 0);
    await fill(tester, 13, 2);
    expect(find.text('1 line complete and off, in rust.'), findsOneWidget);
    expect(state(tester).play.wrongLines, [3]);
  });

  testWidgets('the last four fill and show the card', (tester) async {
    await open(tester, which: 0);
    await fill(tester, 8, 2);
    await fill(tester, 9, 5);
    await fill(tester, 10, 6);
    await fill(tester, 13, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Filled: every line of the comb sums to 38.'), findsOneWidget);
    expect(
      find.textContaining('Every line of the comb sums to 38; 4 numbers set.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me picks the cell and names the number, or the cell to clear', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('set', 4, 7));
    expect(state(tester).play.held, 4);
    expect(find.text('Put 7 in the ringed cell.'), findsOneWidget);
    await put(tester, 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('clear', 4, 0));
    expect(find.text('Clear the ringed cell; it is off the filling.'), findsOneWidget);
  });

  testWidgets('the pointer fills the whole comb', (tester) async {
    await open(tester, which: 3);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('filled 19 of 19'), findsOneWidget);
    expect(find.text('lines right 15 of 15'), findsOneWidget);
  });

  testWidgets('the hopeless comb admits it when full', (tester) async {
    await open(tester, which: 4);
    for (var c = 0; c < 19; c++) {
      await fill(tester, c, c + 1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Thirty-eight or nothing.'), findsOneWidget);
    expect(
      find.textContaining('no comb ever sums to 37'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the rows', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('190 between them, so if every line is to sum alike each row sums 38'),
      findsOneWidget,
    );
    expect(
      find.textContaining('finds no filling for 37, and none for 36, 39 or 40 either'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the whole comb counts twelve', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('12 fillings of this comb sum to 38 on every line'),
      findsOneWidget,
    );
  });
}
