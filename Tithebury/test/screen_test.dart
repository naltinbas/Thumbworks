import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/titheland.dart';

/// One ask on the screen, tallied as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the number so its proper divisors add up to it exactly'), findsOneWidget);
    expect(find.text('divisors add to 8'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('10: 1, 2 and 5 add up to 8, 2 short; the divisors of 8 add up to 7.'), findsOneWidget);
  });

  testWidgets('a wind moves the dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await wind(tester, 10);
    expect(state(tester).play.number, 20);
    expect(find.text('divisors add to 22'), findsOneWidget);
    expect(find.text('20: 1, 2, 4, 5 and 10 add up to 22, 2 over; the divisors of 22 add up to 14.'), findsOneWidget);
    await wind(tester, -1);
    expect(find.text('19: 1 add up to 1, 18 short; the divisors of 1 add up to 0.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.number, 20);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the perfect lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setNumber(tester, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Tallied.'), findsOneWidget);
    expect(find.text('As asked. 6: 1, 2 and 3 add up to 6, the number itself; the divisors of 6 add up to 6.'), findsOneWidget);
    expect(find.textContaining('The proper divisors of 6, 1, 2 and 3, add up to 6, the number itself; 4 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Tallied.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the wind', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Wind up by 10.'), findsOneWidget);
    await setNumber(tester, 215);
    await press(tester, 'Show me');
    expect(find.text('Wind up by 1.'), findsOneWidget);
  });

  testWidgets('the pointer tallies the friends', (tester) async {
    await open(tester, which: 1);
    await tallyByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 21);
    expect(find.text('As asked. 220: 11 divisors from 1 to 110 add up to 284, 64 over; the divisors of 284 add up to 220.'), findsOneWidget);
    expect(find.textContaining('add up to 284, 64 over, and the divisors of 284 add up to 220; 21 taps.'), findsOneWidget);
  });

  testWidgets('the twice over, by hand, and the dial stops at the ends', (tester) async {
    await open(tester, which: 3);
    await setNumber(tester, 120);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 120: 15 divisors from 1 to 60 add up to 240, 120 over; the divisors of 240 add up to 504.'), findsOneWidget);
    expect(find.textContaining('add up to 240, twice the number; 11 taps.'), findsOneWidget);
    await press(tester, 'Again');
    await setNumber(tester, 1);
    await wind(tester, -10);
    expect(state(tester).play.number, 1);
    expect(find.text('1: no proper divisors, so nothing back, 1 short.'), findsOneWidget);
  });

  testWidgets('the power of two admits it at 256', (tester) async {
    await open(tester, which: 4);
    await setNumber(tester, 256);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One short, always.'), findsOneWidget);
    expect(find.text('256 gets 255, one short like every power of two: 1 + 2 + 4 + ... up to half of it is always one less than it.'), findsOneWidget);
    expect(find.textContaining('the nine that come one short to be exactly the powers of two'), findsOneWidget);
  });

  testWidgets('the why tells the one short and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('a power of two always comes one short'), findsOneWidget);
    expect(find.textContaining('every number from one to 500, tried in full'), findsOneWidget);
  });
}
