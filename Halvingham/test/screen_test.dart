import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hamland.dart';

/// One ledger on the screen, kept as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a ledger opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('keep rows of the halving of 13 by 7 so the doubles kept add to 91'),
      findsOneWidget,
    );
    expect(find.text('kept 0 of 4'), findsOneWidget);
    expect(find.text('sum 0 of 91'), findsOneWidget);
    expect(find.text('odd halves 3'), findsOneWidget);
    expect(find.text('Kept 0 rows, 0 of 91, 91 short.'), findsOneWidget);
  });

  testWidgets('rows keep and let go, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapRow(tester, 0);
    expect(find.text('kept 1 of 4'), findsOneWidget);
    expect(find.text('sum 7 of 91'), findsOneWidget);
    expect(find.text('Kept 1 row, 7 of 91, 84 short.'), findsOneWidget);
    await tapRow(tester, 0);
    expect(find.text('kept 0 of 4'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.kept, [0]);
  });

  testWidgets('thirteen by seven kept and the card shown', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [0, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Kept: the doubles add to 91.'), findsOneWidget);
    expect(
      find.textContaining('7 + 28 + 56 is 91, 13 7s; 3 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a wrong keeping reads over', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [1, 2, 3]);
    expect(find.text('Kept 3 rows, 98 of 91, 7 over.'), findsOneWidget);
  });

  testWidgets('show me says keep, or let go', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('keep', 0));
    expect(find.text('Keep the ringed row: its half is odd.'), findsOneWidget);
    await tapRow(tester, 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('let', 2));
    expect(find.text('Let the ringed row go: its half is even.'), findsOneWidget);
  });

  testWidgets('the pointer keeps ninety-nine by nine', (tester) async {
    await open(tester, which: 3);
    await keepByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('sum 891 of 891'), findsOneWidget);
  });

  testWidgets('the hopeless ledger cracks at twelve taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [2, 3]);
    expect(find.text('Kept 2 rows, 84 of 91, 7 short.'), findsOneWidget);
    await tapAll(tester, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two rows never make it.'), findsOneWidget);
    expect(
      find.textContaining('thirteen is eight and four and one, three twos'),
      findsOneWidget,
    );
  });

  testWidgets('the why spells the twos', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the odd halves are 13, 3, 1, and 7 + 28 + 56 is 91'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Every keeping of exactly 2 rows was swept as well, 6 of them, and none lands'),
      findsOneWidget,
    );
  });

  testWidgets('the why of forty by twenty-five counts the keepings', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('64 keepings of the 6 rows, and 1 lands'),
      findsOneWidget,
    );
  });
}
