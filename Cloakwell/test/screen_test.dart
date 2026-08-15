import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One rail on the screen, sorted as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a rail opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('sort the coats 4, 3, 2, 1 in six swaps of neighbours'),
      findsOneWidget,
    );
    expect(find.text('swaps 0 of 6'), findsOneWidget);
    expect(find.text('askew 6'), findsOneWidget);
    expect(find.text('parity even'), findsOneWidget);
    expect(find.text('6 pairs out of order, 6 swaps left: every swap must mend one.'), findsOneWidget);
  });

  testWidgets('a swap mends a pair, the arcs follow, back undoes', (tester) async {
    await open(tester, which: 1);
    await swapAt(tester, 0);
    expect(state(tester).play.row, [3, 4, 2, 1]);
    expect(find.text('swaps 1 of 6'), findsOneWidget);
    expect(find.text('askew 5'), findsOneWidget);
    expect(find.text('parity odd'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.row, [4, 3, 2, 1]);
  });

  testWidgets('a wasted swap says too many to mend', (tester) async {
    await open(tester, which: 0);
    await swapAt(tester, 1);
    expect(find.text('3 pairs out of order, 1 swap left: too many to mend.'), findsOneWidget);
    await swapAt(tester, 1);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Swaps spent, and 2 pairs still out of order.'), findsOneWidget);
    expect(find.text('A swap wasted.'), findsOneWidget);
  });

  testWidgets('the two askew sort and show the card', (tester) async {
    await open(tester, which: 0);
    await swapAll(tester, [0, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Sorted in 2 swaps: 1 to 4 along the rail.'), findsOneWidget);
    expect(find.text('askew 0'), findsOneWidget);
    expect(
      find.textContaining('The coats hang in order; 2 swaps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a descent', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('swap', 1));
    expect(find.text('Swap the ringed pair: the coat hangs before a smaller one.'), findsOneWidget);
  });

  testWidgets('the pointer sorts the reverse of five', (tester) async {
    await open(tester, which: 3);
    await sortByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('swaps 10 of 10'), findsOneWidget);
  });

  testWidgets('the hopeless rail cracks at five swaps', (tester) async {
    await open(tester, which: 4);
    await sortByDescents(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Swaps spent, and 1 pair still out of order.'), findsOneWidget);
    expect(find.text('Five never sort six pairs.'), findsOneWidget);
    expect(
      find.textContaining('a swap of neighbours mends one pair at the most'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts by one', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('changes that count by exactly one'),
      findsOneWidget,
    );
    expect(
      find.textContaining('an odd count of swaps leaves an odd count of pairs besides'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the reverse of four reads the sixteen', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('the sign by cycles agrees'),
      findsOneWidget,
    );
    expect(
      find.textContaining('16 of the 729 sequences of six sort them'),
      findsOneWidget,
    );
  });
}
