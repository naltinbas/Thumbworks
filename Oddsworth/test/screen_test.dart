import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/oddland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('add up odd numbers from 1 to make 49'), findsOneWidget);
    expect(find.text('first 1'), findsOneWidget);
    expect(find.text('count 1'), findsOneWidget);
    expect(find.text('sum 1'), findsOneWidget);
    expect(find.text('1 squared less 0 squared'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('1 = 1: 1 squared, odd.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'count', 1);
    expect(state(tester).play.count, 2);
    expect(find.text('sum 4'), findsOneWidget);
    expect(find.text('1 + 3 = 4: 2 squared, a multiple of four.'), findsOneWidget);
    await turn(tester, 'first', 1);
    expect(state(tester).play.first, 3);
    expect(find.text('first 3'), findsOneWidget);
    expect(find.text('3 + 5 = 8: 3 squared less 1 squared, a multiple of four.'), findsOneWidget);
    expect(find.text('3 squared less 1 squared'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.first, 1);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the square of seven lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 1, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Added up.'), findsOneWidget);
    expect(find.text('As asked. 1 + 3 + 5 + 7 + 9 + 11 + 13 = 49: 7 squared, odd.'), findsOneWidget);
    expect(find.textContaining('1 + 3 + 5 + 7 + 9 + 11 + 13 = 49, 7 odd numbers: 7 squared; one of 1 run of the 1,000; 6 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Added up.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer lands the twenty-one', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Turn the first up.'), findsOneWidget);
    expect(state(tester).pointing, (0, 1));
    await runByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.first, state(tester).play.count, state(tester).play.moves), (5, 3, 4));
    expect(find.text('As asked. 5 + 7 + 9 = 21: 5 squared less 2 squared, odd.'), findsOneWidget);
    expect(find.textContaining('5 + 7 + 9 = 21, 3 odd numbers: 5 squared less 2 squared, 25 less 4; one of 2 runs of the 1,000; 4 taps.'), findsOneWidget);
  });

  testWidgets('twenty-one alone is a run of one', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 21, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 21 = 21: 11 squared less 10 squared, odd.'), findsOneWidget);
    expect(find.textContaining('one of 2 runs of the 1,000; 10 taps.'), findsOneWidget);
  });

  testWidgets('the sixty-four from thirteen', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 13, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 13 + 15 + 17 + 19 = 64: 10 squared less 6 squared, a multiple of four.'), findsOneWidget);
    expect(find.textContaining('13 + 15 + 17 + 19 = 64, 4 odd numbers: 10 squared less 6 squared, 100 less 36; one of 3 runs of the 1,000; 9 taps.'), findsOneWidget);
  });

  testWidgets('the hundred from one, ten odd numbers', (tester) async {
    await open(tester, which: 3);
    await setDials(tester, 1, 10);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 1 + 3 + ... + 19 = 100: 10 squared, a multiple of four.'), findsOneWidget);
    expect(find.textContaining('1 + 3 + ... + 19 = 100, 10 odd numbers: 10 squared; one of 2 runs of the 1,000; 9 taps.'), findsOneWidget);
  });

  testWidgets('the thirty admits it at twenty-eight', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 13, 2);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two past a multiple of four.'), findsOneWidget);
    expect(find.text('13 + 15 = 28: 8 squared less 6 squared, a multiple of four. Thirty is two past a multiple of four, and no run makes such a number.'), findsOneWidget);
    expect(find.textContaining('here 13 + 15 makes 28, and the sweep of all 1,000 runs on the dials makes 28 and 32 and never 30.'), findsOneWidget);
  });

  testWidgets('the why tells the squares and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('each new odd number an L of dots'), findsOneWidget);
    expect(find.textContaining('added out in full'), findsOneWidget);
  });
}
