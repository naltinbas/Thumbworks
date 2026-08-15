import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/pollland.dart';

/// One ask on the screen, counted as a thumb would.
void main() {
  setUpAll(useRealFonts);
  const a = true, b = false;

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('count three Ash and two Birch in an order that keeps Ash ahead after every ballot'), findsOneWidget);
    expect(find.text('lead 0'), findsOneWidget);
    expect(find.text('level 0, turned 0'), findsOneWidget);
    expect(find.text('draws 0'), findsOneWidget);
    expect(find.text('Draw Ash, 3 left'), findsOneWidget);
    expect(find.text('Draw Birch, 2 left'), findsOneWidget);
    expect(find.text('Nothing drawn yet: 3 Ash and 2 Birch in the box.'), findsOneWidget);
  });

  testWidgets('draws move the lead, the box empties, and back undoes', (tester) async {
    await open(tester, which: 0);
    await draw(tester, a);
    expect(find.text('lead +1'), findsOneWidget);
    expect(find.text('1 drawn, Ash ahead by 1; 2 Ash and 2 Birch left in the box.'), findsOneWidget);
    await draw(tester, b);
    expect(find.text('lead 0'), findsOneWidget);
    expect(find.text('level 1, turned 0'), findsOneWidget);
    await draw(tester, b);
    expect(find.text('lead -1'), findsOneWidget);
    expect(find.text('Draw Birch, 0 left'), findsOneWidget);
    expect(find.text('draws 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.drawn, [a, b]);
    expect(find.text('draws 2'), findsOneWidget);
  });

  testWidgets('the clean lead lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await drawAll(tester, [a, a, b, a, b]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Counted.'), findsOneWidget);
    expect(find.text('As asked. Counted through: level 0 times, the lead changed hands 0, Ash ahead throughout.'), findsOneWidget);
    expect(find.textContaining('Counted A A B A B: level 0 times, the lead changed hands 0 times, Ash ahead throughout; one of 2 orders of 10 that land it; 5 draws.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Counted.'), findsNothing);
    expect(find.text('draws 0'), findsOneWidget);
  });

  testWidgets('a count through that misses is told, and show me calls for back', (tester) async {
    await open(tester, which: 0);
    await drawAll(tester, [a, b, a, b, a]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Counted through, Ash ahead by 1, but not as asked: take ballots back and draw again.'), findsOneWidget);
    await press(tester, 'Show me');
    expect(find.text('Take the last ballot back.'), findsOneWidget);
    await press(tester, 'Back');
    await press(tester, 'Back');
    await press(tester, 'Back');
    await press(tester, 'Back');
    await press(tester, 'Show me');
    expect(find.text('Draw an Ash ballot.'), findsOneWidget);
  });

  testWidgets('the pointer counts the two turns', (tester) async {
    await open(tester, which: 2);
    await countByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 8);
    expect(find.text('As asked. Counted through: level 2 times, the lead changed hands 2, Ash ahead at some point.'), findsNothing);
    expect(find.textContaining('the lead changed hands 2'), findsWidgets);
  });

  testWidgets('the never behind, by hand', (tester) async {
    await open(tester, which: 3);
    await drawAll(tester, [a, b, a, b, a, b, a, b]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Counted through: level 4 times, the lead changed hands 0, Ash never behind.'), findsOneWidget);
  });

  testWidgets('the level poll admits it once the count is through', (tester) async {
    await open(tester, which: 4);
    await drawAll(tester, [a, a, a, a, b, b, b, b]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Level at the end, always.'), findsOneWidget);
    expect(find.text('The last ballot lands the count level, as it must with four to four: no order keeps Ash ahead throughout.'), findsOneWidget);
    expect(find.textContaining('this order ends A A A A B B B B'), findsOneWidget);
  });

  testWidgets('the why tells Bertrand and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Bertrand answered in 1887'), findsOneWidget);
    expect(find.textContaining('read through in full'), findsOneWidget);
  });
}
