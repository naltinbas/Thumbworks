import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/trainland.dart';

/// One train on the screen, geared as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a train opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the gear of one so the crank turns the mill'), findsOneWidget);
    expect(find.text('set 0 of 1'), findsOneWidget);
    expect(find.text('turning 1 of 2'), findsOneWidget);
    expect(find.text('placings 0'), findsOneWidget);
    expect(find.text('The mill stands still: no train reaches it.'), findsOneWidget);
  });

  testWidgets('a gear is taken, set where it fits, and lifted, and back undoes', (tester) async {
    await open(tester, which: 1);
    await takeSlot(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.text('Holding a gear of one: tap the peg for it.'), findsOneWidget);
    await tapPeg(tester, 1, 0);
    expect(find.text('That peg is too near another gear: teeth would overlap.'), findsOneWidget);
    await tapPeg(tester, 2, 0);
    expect(state(tester).play.placed, [(2, 0, 1)]);
    expect(find.text('placings 1'), findsOneWidget);
    expect(find.text('turning 2 of 3'), findsOneWidget);
    await tapPeg(tester, 2, 0);
    expect(state(tester).play.placed, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.placed, [(2, 0, 1)]);
  });

  testWidgets('the idler lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setGear(tester, 0, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Geared.'), findsOneWidget);
    expect(find.text('As asked: the mill turns with the crank, 1 turn for every turn of it.'), findsOneWidget);
    expect(find.textContaining('The mill turns with the crank, 2 meshes on, 1 turn for every turn of it, the crank\'s 2 over the mill\'s 2; 1 placing.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Geared.'), findsNothing);
  });

  testWidgets('show me names the gear and the peg', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Take the gear of one from the tray.'), findsOneWidget);
    await takeSlot(tester, 0);
    await press(tester, 'Show me');
    expect(find.text('Set it on the ringed peg.'), findsOneWidget);
  });

  testWidgets('the pointer gears the ring of four', (tester) async {
    await open(tester, which: 3);
    await gearByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked: 4 of 4 gears turn, all in a ring.'), findsOneWidget);
    expect(find.textContaining('The ring of 4 turns, 2 gears with the crank and 2 against'), findsOneWidget);
  });

  testWidgets('the twice, by hand', (tester) async {
    await open(tester, which: 2);
    await setGear(tester, 0, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked: the mill turns with the crank, 2 turns for every turn of it.'), findsOneWidget);
  });

  testWidgets('the ring of three jams', (tester) async {
    await open(tester, which: 4);
    await setGear(tester, 0, 3, 0);
    await setGear(tester, 1, 0, 4);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The odd ring jams.'), findsOneWidget);
    expect(find.text('The ring of three jams: round it the crank would turn both ways.'), findsOneWidget);
    expect(find.textContaining('only rings with an even count of gears turn'), findsOneWidget);
  });

  testWidgets('the why tells the mesh law and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('an idler changes nothing but the way'), findsOneWidget);
    expect(find.textContaining('none of the 8 ways to peg the two turns as a ring'), findsOneWidget);
  });
}
