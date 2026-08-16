import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leverland.dart';

/// One ask on the screen, the levers turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on one slot and says what it does', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('build the loop Parrondo told it with'),
        findsOneWidget);
    expect(find.text('1 slot'), findsOneWidget);
    expect(find.text('stands still'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(
        find.text('The loop A: the purse gains nothing in the long run, and after 40 rounds it is at 0.000.'),
        findsOneWidget);
  });

  testWidgets('slots go on and off, and levers turn over', (tester) async {
    await open(tester, which: 1);
    await pressKey(tester, 'longer');
    expect(state(tester).play.loop, 'AA');
    expect(find.text('2 slots'), findsOneWidget);
    await tapSlot(tester, 1);
    expect(state(tester).play.loop, 'AB');
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.loop, 'AA');
    await pressKey(tester, 'shorter');
    expect(state(tester).play.loop, 'A');
  });

  testWidgets('the famous loop lands on ABB', (tester) async {
    await open(tester, which: 1);
    await buildLoop(tester, 'ABB');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Climbing.'), findsOneWidget);
    expect(
        find.textContaining(
            'The loop A B B climbs 2416/35601 of a coin a round, and after 40 rounds the purse stands at 2.784.'),
        findsOneWidget);
    expect(find.textContaining('One of 12 loops of the 8,190 that land the ask'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Climbing.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the tap, and the pointer builds the best loop',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Put another slot on the loop.'), findsOneWidget);
    await loopByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.loop, 'ABABB');
    expect(state(tester).play.moves, 7);
    expect(find.textContaining('One of 10 loops of the 8,190'), findsOneWidget);
  });

  testWidgets('a four climbs slower than a three', (tester) async {
    await open(tester, which: 2);
    await buildLoop(tester, 'AABB');
    expect(state(tester).play.isDone, isTrue);
    expect(
        find.text('As asked. The loop A A B B: the purse climbs 4/163 of a coin a round, and after 40 rounds it is at 0.905.'),
        findsOneWidget);
    expect(find.textContaining('One of 4 loops of the 8,190'), findsOneWidget);
  });

  testWidgets('one lever forever admits it once both are run alone',
      (tester) async {
    await open(tester, which: 4);
    await tapSlot(tester, 0);
    expect(state(tester).play.loop, 'B');
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One lever goes nowhere.'), findsOneWidget);
    expect(find.textContaining('One lever on its own never climbs.'),
        findsOneWidget);
    expect(find.textContaining('5/13, 2/13, 6/13'), findsOneWidget);
  });

  testWidgets('the why tells Parrondo and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Juan Parrondo'), findsOneWidget);
    expect(find.textContaining('run in full'), findsOneWidget);
  });
}
