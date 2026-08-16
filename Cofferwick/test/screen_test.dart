import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/cofferland.dart';

/// One ask on the screen, the coins turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('lay the coins so that a gold coin drawn at random has a gold mate with chance 2 in 3'), findsOneWidget);
    expect(find.text('gold 0'), findsOneWidget);
    expect(find.text('pairs 0'), findsOneWidget);
    expect(find.text('chance none'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('All silver: no gold coin to draw, and no chance to speak of.'), findsOneWidget);
  });

  testWidgets('a tap turns a coin, and back undoes it', (tester) async {
    await open(tester, which: 0);
    await tapCoin(tester, 0);
    expect(state(tester).play.coins[0], isTrue);
    expect(find.text('gold 1'), findsOneWidget);
    expect(find.text('chance 0'), findsOneWidget);
    expect(find.text('1 gold coin, no pair: of the 1 a draw might give, none has a gold mate, chance 0, never.'), findsOneWidget);
    await tapCoin(tester, 1);
    expect(find.text('2 gold coins, 1 pair: of the 2 a draw might give, all have a gold mate, chance 1, certain.'), findsOneWidget);
    expect(find.text('chance 1'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.coins[1], isFalse);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the two thirds land on Bertrand\'s laying and the card is shown', (tester) async {
    await open(tester, which: 0);
    await lay(tester, [true, true, true, false, false, false]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Drawn.'), findsOneWidget);
    expect(find.text('As asked. 3 gold coins, 1 pair: of the 3 a draw might give, 2 have a gold mate, chance 2/3.'), findsOneWidget);
    expect(find.textContaining('First coffer gold and gold, second gold and silver, third silver and silver: chance 2/3; one of 12 layings of the 64; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Drawn.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the coin, and the pointer lays the half', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Turn the left coin of the first coffer.'), findsOneWidget);
    expect(state(tester).pointing, 0);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.text('As asked. 4 gold coins, 1 pair: of the 4 a draw might give, 2 have a gold mate, chance 1/2.'), findsOneWidget);
    expect(find.textContaining('First coffer gold and gold, second gold and silver, third gold and silver: chance 1/2; one of 12 layings of the 64; 4 taps.'), findsOneWidget);
  });

  testWidgets('the four fifths', (tester) async {
    await open(tester, which: 2);
    await lay(tester, [true, true, true, true, true, false]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 5 gold coins, 2 pairs: of the 5 a draw might give, 4 have a gold mate, chance 4/5.'), findsOneWidget);
    expect(find.textContaining('one of 6 layings of the 64; 5 taps.'), findsOneWidget);
  });

  testWidgets('the certain lands on one gold pair', (tester) async {
    await open(tester, which: 3);
    await lay(tester, [false, false, true, true, false, false]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 2 gold coins, 1 pair: of the 2 a draw might give, all have a gold mate, chance 1, certain.'), findsOneWidget);
    expect(find.textContaining('First coffer silver and silver, second gold and gold, third silver and silver: chance 1, certain; one of 7 layings of the 64; 2 taps.'), findsOneWidget);
  });

  testWidgets('the half of three admits it at three gold coins, either way', (tester) async {
    await open(tester, which: 4);
    await lay(tester, [true, false, true, false, true, false]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never a half.'), findsOneWidget);
    expect(find.text('Three gold coins, no pair: none of the three has a gold mate, chance 0, and a half never comes.'), findsOneWidget);
    expect(find.textContaining('the sweep of the 20 layings of three gold and three silver finds 2/3 twelve times and 0 eight times'), findsOneWidget);
  });

  testWidgets('the half of three with a pair', (tester) async {
    await open(tester, which: 4);
    await lay(tester, [true, true, true, false, false, false]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Three gold coins, one pair: two of the three have a gold mate, chance 2/3, and a half never comes.'), findsOneWidget);
  });

  testWidgets('the why tells Bertrand and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Bertrand set the puzzle in 1889'), findsOneWidget);
    expect(find.textContaining('drawn out in full'), findsOneWidget);
  });
}
