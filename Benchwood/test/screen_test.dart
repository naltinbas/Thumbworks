import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/benchland.dart';

/// One ask on the screen, the tools carried back as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with the bench already filling', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('work the card of 6 calls on a bench of 2 slots'),
        findsOneWidget);
    expect(find.text('walks 2 of 4'), findsOneWidget);
    expect(find.text('bench A B'), findsOneWidget);
    expect(
        find.text('Call 3 is for C, and 2 walks so far. The bench is full: tap the tool to carry back.'),
        findsOneWidget);
  });

  testWidgets('a carry swaps the tool in that slot, and back undoes it',
      (tester) async {
    await open(tester, which: 1);
    await carry(tester, 0);
    expect(state(tester).play.bench, [2, 1]);
    expect(find.text('walks 3 of 4'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.bench, [0, 1]);
    expect(find.text('walks 2 of 4'), findsOneWidget);
  });

  testWidgets('the round is landed by carrying B back and then A',
      (tester) async {
    await open(tester, which: 1);
    await carryAll(tester, [1, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Fewest walks.'), findsOneWidget);
    expect(
        find.textContaining('The card is worked out in 4 walks, which is the fewest there is.'),
        findsOneWidget);
    expect(find.textContaining('1 of the 8 ways of playing this card keeps to 4'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Fewest walks.'), findsNothing);
    expect(find.text('walks 2 of 4'), findsOneWidget);
  });

  testWidgets('too many walks says so', (tester) async {
    await open(tester, which: 1);
    // Always carrying back whatever is in the first slot takes five
    // walks here, one more than the ask allows.
    await carryAll(tester, [0, 0, 0, 0]);
    expect(state(tester).play.finished, isTrue);
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.walks, 5);
    expect(find.text('Too many walks.'), findsOneWidget);
    expect(find.textContaining('worked out, but in 5 walks and the ask wants 4'),
        findsOneWidget);
  });

  testWidgets('show me names the tool, and the pointer works the card',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.textContaining('back to the store'), findsOneWidget);
    await workByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.walks, 7);
    expect(find.textContaining('5 of the 1377 ways'), findsOneWidget);
  });

  testWidgets('the fourth slot needs one walk fewer', (tester) async {
    await open(tester, which: 3);
    await workByPointer(tester);
    expect(state(tester).play.walks, 6);
    expect(find.textContaining('6 of the 94 ways'), findsOneWidget);
  });

  testWidgets('the three walks ask ends on the floor', (tester) async {
    await open(tester, which: 4);
    await workByPointer(tester);
    expect(state(tester).play.finished, isTrue);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Four is the floor.'), findsOneWidget);
    expect(find.textContaining('three is not possible'), findsOneWidget);
  });

  testWidgets('the why tells Belady and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Laszlo Belady showed in 1966'), findsOneWidget);
    expect(find.textContaining('worked in full'), findsOneWidget);
  });
}
