import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/glassland.dart';

/// One ask on the screen, poured as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the glasses and the spoon so exactly one unit of water ends in the wine glass'), findsOneWidget);
    expect(find.text('each way 10/11'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('wine 10'), findsOneWidget);
    expect(find.text('water 10'), findsOneWidget);
    expect(find.text('spoon 1'), findsOneWidget);
    expect(find.text('Water in the wine 10/11 of a unit, wine in the water 10/11: the same.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial, an empty spoon is told, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'spoon', 1);
    expect(state(tester).play.spoon, 2);
    expect(find.text('each way 5/3'), findsOneWidget);
    expect(find.text('Water in the wine 5/3 of a unit, wine in the water 5/3: the same.'), findsOneWidget);
    await setDials(tester, 1, 10, 2);
    expect(find.text('no spoonful'), findsOneWidget);
    expect(find.text('The spoon holds 2 and the wine glass 1: nothing to carry.'), findsOneWidget);
    expect(find.text('taps 10'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.wine, 2);
  });

  testWidgets('the one unit lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 10, 2, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Poured.'), findsOneWidget);
    expect(find.text('As asked. Water in the wine 1 of a unit, wine in the water 1: the same.'), findsOneWidget);
    expect(find.textContaining('Wine 10, water 2, a spoon of 2: 1 of a unit of water in the wine glass and 1 of wine in the water glass, the same as always; one of 9 settings of 500; 9 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Poured.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Less wine.'), findsOneWidget);
    await setDials(tester, 5, 10, 1);
    await press(tester, 'Show me');
    expect(find.text('Less water.'), findsOneWidget);
  });

  testWidgets('the pointer pours the whole spoon', (tester) async {
    await open(tester, which: 2);
    await pourByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.dials, [2, 2, 2]);
    expect(find.text('As asked. Water in the wine 1 of a unit, wine in the water 1: the same.'), findsOneWidget);
  });

  testWidgets('the tenth, by hand', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 9, 9, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Water in the wine 9/10 of a unit, wine in the water 9/10: the same.'), findsOneWidget);
  });

  testWidgets('the unequal admits it at the wildest pouring', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 10, 1, 5);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Equal, always.'), findsOneWidget);
    expect(find.text('A spoon of five against a glass of one: 5/6 of a unit each way, and the two are equal still, as the account says they must be.'), findsOneWidget);
    expect(find.textContaining('three stirs apiece, finds them equal every time'), findsOneWidget);
  });

  testWidgets('the why tells the account and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('fills exactly the room the missing wine left'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
