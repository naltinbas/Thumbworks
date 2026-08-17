import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ringland.dart';

/// One ask on the screen, the dials set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('bid above what the beast is worth to you, win '
            'it, and pay more than it is worth'),
        findsOneWidget);
    expect(
        find.textContaining(
            'the sealed ring, where the winner pays the second bid'),
        findsOneWidget);
    expect(find.text('you earn 0'), findsOneWidget);
    expect(find.text('the truth earns 0'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(
        find.text('The rivals take the beast, so you earn nothing; the '
            'truthful bid earns 0 crowns.'),
        findsOneWidget);
  });

  testWidgets('a dial steps a crown, and back undoes', (tester) async {
    // Worked on the hopeless ask, which is run in the sealed ring and
    // is never landed by a tap.
    await open(tester, which: 4);
    await step(tester, 'rival', -1);
    expect((state(tester).play.worth, state(tester).play.bid,
        state(tester).play.rival), (10, 12, 11));
    expect(find.text('you earn -1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.rival, 12);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a dial will not step past its end', (tester) async {
    await open(tester, which: 3);
    await step(tester, 'bid', 1);
    expect(state(tester).play.bid, 12);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the overbid loss lands in a tap and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 10, 12, 11);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Sold.'), findsOneWidget);
    expect(
        find.text('As asked. You take the beast and pay 11, earning -1 '
            'crown; the truthful bid earns 0 crowns.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'A beast worth 10 crowns to you, a bid of 12 against a best rival '
            'bid of 11 in the sealed ring, where the winner pays the second '
            'bid: you take it and pay 11, so the bid earns -1 crown where the '
            'truthful bid earns 0 crowns; one of 286 settings of the 2,197 '
            'that land it; 1 tap.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Sold.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer lands the windfall',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Put the best bid against you down a crown.'),
        findsOneWidget);
    expect(state(tester).pointing, (2, -1));
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.textContaining('one of 650 settings of the 2,197 that land '
        'it; 3 taps.'), findsOneWidget);
  });

  testWidgets('the sale passed up leaves the truth in pocket', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 12, 11, 11);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.paid, 0);
    expect(state(tester).play.truthPaid, 1);
    expect(
        find.textContaining('the bid earns 0 crowns where the truthful bid '
            'earns 1 crown'),
        findsOneWidget);
  });

  testWidgets('the shading gain runs in the open ring', (tester) async {
    await open(tester, which: 3);
    expect(
        find.textContaining(
            'the open ring, where the winner pays what he bid'),
        findsOneWidget);
    await setDials(tester, 12, 11, 10);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.paid, 1);
    expect(state(tester).play.truthPaid, 0);
    expect(find.textContaining('one of 286 settings of the 2,197'),
        findsOneWidget);
  });

  testWidgets('outbidding the truth gives itself up after four settings',
      (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 8, 8, 8);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The truth is never beaten.'), findsOneWidget);
    expect(
        find.text('Your bid never sets the price in this ring, only whether '
            'you win, so it has nowhere better to sit than the worth.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'Push the bid above the worth and the only beasts it takes are '
            'the ones already bid at or past their worth'),
        findsOneWidget);
  });

  testWidgets('the why tells Vickrey and the window', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('William Vickrey published this in 1961'),
        findsOneWidget);
    expect(
        find.textContaining(
            'closed at the lower end because a bid level with a rival loses'),
        findsOneWidget);
  });
}
