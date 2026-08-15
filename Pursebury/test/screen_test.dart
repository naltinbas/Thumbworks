import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/duelland.dart';

/// One ask on the screen, staked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the purses and the coin so Ash takes the pot one time in four exactly'), findsOneWidget);
    expect(find.text('chance 3/5'), findsOneWidget);
    expect(find.text('lasts 6'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Ash 3'), findsWidgets);
    expect(find.text('Birch 2'), findsWidgets);
    expect(find.text('The coin fair, 1/2'), findsOneWidget);
    expect(find.text('Ash 3 to Birch\'s 2, the coin fair: Ash\'s chance of the pot is 3/5, and the duel lasts 6 tosses on average.'), findsOneWidget);
  });

  testWidgets('a tap fills a purse, the coin turns, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'Ash', 1);
    expect(state(tester).play.ash, 4);
    expect(find.text('chance 2/3'), findsOneWidget);
    expect(find.text('lasts 8'), findsOneWidget);
    await turnCoin(tester);
    expect(find.text('The coin for Ash, 2/3'), findsOneWidget);
    expect(find.text('chance 20/21'), findsOneWidget);
    expect(find.text('lasts 36/7'), findsOneWidget);
    expect(find.text('Ash 4 to Birch\'s 2, the coin for Ash: Ash\'s chance of the pot is 20/21, and the duel lasts 36/7 tosses on average.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.coin, 1);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the quarter lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDuel(tester, 1, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Staked.'), findsOneWidget);
    expect(find.text('As asked. Ash 1 to Birch\'s 3, the coin fair: Ash\'s chance of the pot is 1/4, and the duel lasts 3 tosses on average.'), findsOneWidget);
    expect(find.textContaining('Ash one coin to Birch\'s three, the coin fair: Ash takes the pot one time in four, 1/4, and the duel lasts 3 tosses on average; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Staked.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the coin, the purse and the way', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Turn the coin over.'), findsOneWidget);
    await turnCoin(tester);
    await turnCoin(tester);
    await press(tester, 'Show me');
    expect(find.text('Take Birch a coin.'), findsOneWidget);
  });

  testWidgets('the pointer stakes the two to one', (tester) async {
    await open(tester, which: 1);
    await stakeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(find.text('As asked. Ash 2 to Birch\'s 1, the coin fair: Ash\'s chance of the pot is 2/3, and the duel lasts 2 tosses on average.'), findsOneWidget);
  });

  testWidgets('the two to one with the coin for Ash, by hand', (tester) async {
    await open(tester, which: 1);
    await setDuel(tester, 1, 1, coin: 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Ash 1 to Birch\'s 1, the coin for Ash: Ash\'s chance of the pot is 2/3, and the duel lasts 1 toss on average.'), findsOneWidget);
  });

  testWidgets('a purse at its end stays', (tester) async {
    await open(tester, which: 0);
    await setDuel(tester, 6, 6);
    expect(state(tester).play.isDone, isFalse);
    await turn(tester, 'Ash', 1);
    expect(state(tester).play.ash, 6);
    expect(find.text('taps 7'), findsOneWidget);
    expect(find.text('chance 1/2'), findsOneWidget);
  });

  testWidgets('the even duel against the coin admits it at six to one', (tester) async {
    await open(tester, which: 4);
    await setDuel(tester, 6, 1, coin: 0);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never even.'), findsOneWidget);
    expect(find.text('Six coins to one against the coin is as near as it comes, 63/127: 2 to the pot less 1 is odd, and never twice anything.'), findsOneWidget);
    expect(find.textContaining('the nearest of the 108 settings is six coins to one, 63/127'), findsOneWidget);
  });

  testWidgets('the why tells the share and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('an odd number is never twice anything'), findsOneWidget);
    expect(find.textContaining('108 settings, tried in full'), findsOneWidget);
  });
}
