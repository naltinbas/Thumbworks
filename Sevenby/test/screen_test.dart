import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/turnland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('dial a fraction whose decimal comes round every six places'), findsOneWidget);
    expect(find.text('prime 11'), findsOneWidget);
    expect(find.text('top 1'), findsOneWidget);
    expect(find.text('period 2'), findsOneWidget);
    expect(find.text('of 10 possible'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('1 over 11 is 0.09 repeating, 2 places, a fifth of the whole turn: 10 comes back to 1 in 2 steps on the 11-hour clock.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 3);
    await turn(tester, 'top', 1);
    expect(state(tester).play.top, 2);
    expect(find.text('top 2'), findsOneWidget);
    expect(find.text('2 over 11 is 0.18 repeating, 2 places, a fifth of the whole turn: 10 comes back to 1 in 2 steps on the 11-hour clock.'), findsOneWidget);
    await turn(tester, 'prime', 1);
    expect(state(tester).play.prime, 13);
    expect(find.text('2 over 13 is 0.153846 repeating, 6 places, half of the whole turn: 10 comes back to 1 in 6 steps on the 13-hour clock.'), findsOneWidget);
    expect(find.text('period 6'), findsOneWidget);
    expect(find.text('of 12 possible'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.prime, 11);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the six lands on a seventh and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 7, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Come round.'), findsOneWidget);
    expect(find.text('As asked. 1 over 7 is 0.142857 repeating, 6 places, the whole turn: 10 comes back to 1 in 6 steps on the 7-hour clock.'), findsOneWidget);
    expect(find.textContaining('1 over 7 is 0.142857 repeating, 6 places: the remainders run 1, 3, 2, 6, 4, 5 and come round, and 142857 times 7 is 999,999; one of 18 fractions of the 308; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Come round.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way, and the pointer lands the rotation', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Turn the prime down.'), findsOneWidget);
    expect(state(tester).pointing, (0, -1));
    await turnByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.prime, state(tester).play.top, state(tester).play.moves), (7, 2, 2));
    expect(find.text('As asked. 2 over 7 is 0.285714 repeating, 6 places, the whole turn: 10 comes back to 1 in 6 steps on the 7-hour clock.'), findsOneWidget);
    expect(find.textContaining('2 over 7 is 0.285714 repeating, 6 places: the remainders run 2, 6, 4, 5, 1, 3 and come round, and 285714 times 7 is 1,999,998; one of 5 fractions of the 308; 2 taps.'), findsOneWidget);
  });

  testWidgets('the full turn on seventeen', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 17, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 1 over 17 is 0.0588235294117647 repeating, 16 places, the whole turn: 10 comes back to 1 in 16 steps on the 17-hour clock.'), findsOneWidget);
    expect(find.textContaining('one of 136 fractions of the 308; 2 taps.'), findsOneWidget);
  });

  testWidgets('the three lands on a thirty-seventh', (tester) async {
    await open(tester, which: 3);
    await setDials(tester, 37, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 1 over 37 is 0.027 repeating, 3 places, a twelfth of the whole turn: 10 comes back to 1 in 3 steps on the 37-hour clock.'), findsOneWidget);
    expect(find.textContaining('1 over 37 is 0.027 repeating, 3 places: the remainders run 1, 10, 26 and come round, and 027 times 37 is 999; one of 36 fractions of the 308; 7 taps.'), findsOneWidget);
  });

  testWidgets('the long turn admits it at a full turn', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 7, 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The whole turn at most.'), findsOneWidget);
    expect(find.text('1 over 7 takes the whole turn, 6 places, and no fraction over 7 can take more: only 6 remainders exist.'), findsOneWidget);
    expect(find.textContaining('1 over 7 takes the whole 6, the longest there is, and the sweep of all 308 fractions on the dial finds none longer.'), findsOneWidget);
  });

  testWidgets('the why tells the clock, Midy and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Midy\'s theorem'), findsOneWidget);
    expect(find.textContaining('divided out in full'), findsOneWidget);
  });
}
