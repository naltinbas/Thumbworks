import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// One asking on the screen, picked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an asking opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('pick a heap of the hundred with exactly 12 even rows'),
      findsOneWidget,
    );
    expect(find.text('no heap'), findsOneWidget);
    expect(find.text('rows 0, asked 12'), findsOneWidget);
    expect(find.text('picks 0'), findsOneWidget);
    expect(find.text('No heap picked; 12 even rows asked.'), findsOneWidget);
  });

  testWidgets('a pick shows the rows and the divisors, back undoes',
      (tester) async {
    await open(tester, which: 3);
    await tapNumber(tester, 24);
    expect(state(tester).play.heap, 24);
    expect(find.text('heap 24'), findsOneWidget);
    expect(find.text('rows 8, asked 12'), findsOneWidget);
    expect(find.text('24 lays out in 8 even rows: 1, 2, 3, 4, 6, 8, 12, 24.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.heap, isNull);
  });

  testWidgets('the twelve rows meet at sixty and show the card',
      (tester) async {
    await open(tester, which: 3);
    await tapNumber(tester, 60);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Met.'), findsOneWidget);
    expect(find.text('Met: 60 lays out in 12 even rows.'), findsOneWidget);
    expect(
      find.textContaining('60 lays out in 12 even rows, as asked; 1 pick.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Met.'), findsNothing);
  });

  testWidgets('show me rings the smallest heap', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 48);
    expect(find.text('Pick the ringed heap, 48.'), findsOneWidget);
  });

  testWidgets('the pointer meets the nine rows', (tester) async {
    await open(tester, which: 1);
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.heap, 36);
  });

  testWidgets('the hopeless asking cracks at twelve picks', (tester) async {
    await open(tester, which: 4);
    for (var n = 1; n <= 12; n++) {
      await tapNumber(tester, n * 8);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Thirteen rows are off the board.'), findsOneWidget);
    expect(
      find.textContaining('a single prime to the twelfth'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the powers', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the powers each raised by one, multiplied'),
      findsOneWidget,
    );
    expect(
      find.textContaining('two to the twelfth is four thousand and ninety-six'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the twelve rows names the records', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('agree with it on every heap to a thousand'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the records up to a hundred run 1, 2, 4, 6, 12, 24, 36, 48 and 60'),
      findsOneWidget,
    );
  });
}
