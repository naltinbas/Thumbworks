import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/splitland.dart';

/// One ask on the screen, split as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('split 20 into two primes'), findsOneWidget);
    expect(find.text('pick none'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Nothing picked: tap a number, and its partner to 20 lights.'), findsOneWidget);
  });

  testWidgets('a pick, its partner, a wrong one, and back', (tester) async {
    await open(tester, which: 0);
    await tapNumber(tester, 9);
    expect(state(tester).play.picked, 9);
    expect(find.text('9 + 11'), findsOneWidget);
    expect(find.text('9 + 11: 9 is not prime.'), findsOneWidget);
    await tapNumber(tester, 13);
    expect(find.text('13 + 7: both prime.'), findsNothing);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Again');
    await tapNumber(tester, 5);
    expect(find.text('5 + 15: 5 is prime, but 15 is not.'), findsOneWidget);
    expect(find.text('taps 1'), findsOneWidget);
    await tapNumber(tester, 15);
    expect(state(tester).play.picked, isNull);
    await press(tester, 'Back');
    expect(state(tester).play.picked, 5);
  });

  testWidgets('the twenty lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await tapNumber(tester, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Split.'), findsOneWidget);
    expect(find.text('As asked. 20 = 3 + 17, both prime.'), findsOneWidget);
    expect(find.textContaining('20 = 3 + 17, both prime; 2 splits in all, 3 + 17, 7 + 13; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Split.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the number', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Tap 3.'), findsOneWidget);
    expect(state(tester).pointing, 3);
  });

  testWidgets('the pointer splits the twins', (tester) async {
    await open(tester, which: 1);
    await splitByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 60 = 29 + 31, both prime.'), findsOneWidget);
  });

  testWidgets('the wide, by hand, and the near miss told', (tester) async {
    await open(tester, which: 2);
    await tapNumber(tester, 19);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('19 + 79: both prime, but not both over thirty.'), findsOneWidget);
    await tapNumber(tester, 37);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 98 = 37 + 61, both prime.'), findsOneWidget);
  });

  testWidgets('the twins, a miss told', (tester) async {
    await open(tester, which: 1);
    await tapNumber(tester, 7);
    expect(find.text('7 + 53: both prime, but 46 apart, not two.'), findsOneWidget);
  });

  testWidgets('the odd admits it at 2', (tester) async {
    await open(tester, which: 4);
    await tapNumber(tester, 2);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Odd, and no 2 to be had.'), findsOneWidget);
    expect(find.text('2 + 49, and 49 is 7 sevens: an odd number splits only with a 2, and 51 does not split at all.'), findsOneWidget);
    expect(find.textContaining('no odd number to 2,000 splits without a 2'), findsOneWidget);
  });

  testWidgets('the why tells Goldbach and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Goldbach wrote to Euler in 1742'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
