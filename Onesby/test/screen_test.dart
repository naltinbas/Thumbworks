import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/onesland.dart';

/// One ask on the screen, wound as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('dial a prime exponent whose row of ones is not prime'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('length 2, prime'), findsOneWidget);
    expect(find.text('row prime'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('2 ones are 3, prime, the smallest of Mersenne\'s numbers, below the reach of the chain.'), findsOneWidget);
  });

  testWidgets('a wind moves the length, and back undoes it', (tester) async {
    await open(tester, which: 0);
    await wind(tester, 1);
    expect(state(tester).play.exponent, 3);
    expect(find.text('3 ones are 7, prime: no factor to 2, and the Lucas-Lehmer chain ends at 0.'), findsOneWidget);
    await wind(tester, 1);
    expect(find.text('length 4, composite'), findsOneWidget);
    expect(find.text('row composite'), findsOneWidget);
    expect(find.text('4 ones are 15, 3 times 5: 4 is 2 times 2, and the row of 2 ones divides.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.exponent, 3);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the prime that is not lands on eleven and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setExponent(tester, 11);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 9);
    expect(find.text('Told.'), findsOneWidget);
    expect(find.text('As asked. 11 ones are 2,047, 23 times 89: a prime length, but no prime row.'), findsOneWidget);
    expect(find.textContaining('11 ones are 2,047: 23 times 89, so not prime, though 11 is; one of 3 exponents of the 30; 9 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Told.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the twenty-three lands on twenty-two too', (tester) async {
    await open(tester, which: 1);
    await setExponent(tester, 22);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 22 ones are 4,194,303, 3 times 1,398,101: 22 is 2 times 11, and the row of 2 ones divides.'), findsOneWidget);
    expect(find.textContaining('22 ones are 4,194,303: 3 times 1,398,101, so not prime, as 22 is 2 times 11; one of 2 exponents of the 30; 2 taps.'), findsOneWidget);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('the perfect eight thousand lands on seven', (tester) async {
    await open(tester, which: 2);
    await setExponent(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 7 ones are 127, prime: no factor to 11, and the Lucas-Lehmer chain ends at 0.'), findsOneWidget);
    expect(find.textContaining('7 ones are 127: prime, by trial division and by the Lucas-Lehmer chain, and 64 times it is 8,128, whose divisors below it add back to it; one of 1 exponent of the 30; 5 taps.'), findsOneWidget);
  });

  testWidgets('show me names the wind, and the pointer lands the longest row', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Wind up by 10.'), findsOneWidget);
    expect(state(tester).pointing, 10);
    await tellByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.exponent, state(tester).play.moves), (31, 11));
    expect(find.text('As asked. 31 ones are 2,147,483,647, prime: no factor to 46,340, and the Lucas-Lehmer chain ends at 0.'), findsOneWidget);
    expect(find.textContaining('31 ones are 2,147,483,647: prime, by trial division and by the Lucas-Lehmer chain; one of 1 exponent of the 30; 11 taps.'), findsOneWidget);
  });

  testWidgets('the composite row admits it after four composite lengths', (tester) async {
    await open(tester, which: 4);
    await setExponent(tester, 4);
    await setExponent(tester, 6);
    await setExponent(tester, 8);
    expect(state(tester).play.gaveUp, isFalse);
    await setExponent(tester, 9);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('A shorter row divides.'), findsOneWidget);
    expect(find.text('Every composite length shows a factor: the row of its smallest prime factor divides it, and no such row is prime.'), findsOneWidget);
    expect(find.textContaining('four ones, 15, are 3 times 5, and nine ones, 511, are 7 times 73'), findsOneWidget);
  });

  testWidgets('the why tells Mersenne, Euclid and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('as they are called, hold the biggest primes'), findsOneWidget);
    expect(find.textContaining('told prime or not both ways'), findsOneWidget);
  });
}
