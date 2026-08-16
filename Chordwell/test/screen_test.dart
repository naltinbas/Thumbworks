import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/chordland.dart';

/// One ask on the screen, the pegs tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(find.textContaining('set two chords so that one cuts the other in half, away from the middle'), findsOneWidget);
    expect(find.text('pegs 0 of 4'), findsOneWidget);
    expect(find.text('no crossing'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No pegs set: tap four pegs, two for each chord.'), findsOneWidget);
  });

  testWidgets('taps set the pegs one by one, and back undoes', (tester) async {
    await open(tester, which: 3);
    await tapPeg(tester, 1);
    expect(state(tester).play.chosen, [1]);
    expect(find.text('One peg set at (3, 4): tap another to make the first chord.'), findsOneWidget);
    await tapPeg(tester, 5);
    expect(find.text('Chord (3, 4) to (3, -4) set: tap two more pegs for the second.'), findsOneWidget);
    expect(find.text('pegs 2 of 4'), findsOneWidget);
    await tapPeg(tester, 3);
    expect(find.text('The second chord starts at (5, 0): tap its other end.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.chosen, [1, 5]);
    expect(find.text('taps 2'), findsOneWidget);
    await tapPeg(tester, 5);
    expect(state(tester).play.chosen, [1]);
  });

  testWidgets('the halved lands on the mark\'s crossing and the card is shown', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [1, 5, 3, 9]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Crossed.'), findsOneWidget);
    expect(find.text('As asked. Crossing at (3, 0): 4 times 4 is 16 on the one chord, 2 times 8 is 16 on the other, and 25 less 9 is 16.'), findsOneWidget);
    expect(find.textContaining('Chords (3, 4) to (3, -4) and (5, 0) to (-5, 0), crossing at (3, 0): 4 times 4 and 2 times 8, both 16; one of 64 crossings of the 495; 4 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Crossed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('chords that miss say so', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [0, 1, 2, 3]);
    expect(state(tester).play.crossing, isNull);
    expect(find.text('The chords do not cross inside the wheel: lift a peg and try another.'), findsOneWidget);
    expect(find.text('no crossing'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer lands the middle', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, 3);
    await press(tester, 'Show me');
    expect(find.text('Lift the peg at (5, 0).'), findsOneWidget);
    expect(state(tester).pointing, (3, true));
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(find.text('As asked. Crossing at (0, 0): 5 times 5 is 25 on the one chord, 5 times 5 is 25 on the other, and 25 less 0 is 25.'), findsOneWidget);
    expect(find.textContaining('one of 15 crossings of the 495; 6 taps.'), findsOneWidget);
  });

  testWidgets('the nine: one and nine across three and three', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [0, 6, 1, 11]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Crossing at (0, 4): 1 times 9 is 9 on the one chord, 3 times 3 is 9 on the other, and 25 less 16 is 9.'), findsOneWidget);
    expect(find.text('products 9 and 9'), findsNothing);
    expect(find.textContaining('one of 4 crossings of the 495'), findsOneWidget);
  });

  testWidgets('the twenty: roots that multiply whole', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [0, 4, 1, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Crossing at (2, 1): root 20 times root 20 is 20 on the one chord, root 10 times root 40 is 20 on the other, and 25 less 5 is 20.'), findsOneWidget);
    expect(find.textContaining('one of 48 crossings of the 495'), findsOneWidget);
  });

  testWidgets('a crossing that misses the ask shows its products', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [1, 5, 3, 9]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('products 16 and 16'), findsOneWidget);
    expect(find.text('Crossing at (3, 0): 4 times 4 is 16 on the one chord, 2 times 8 is 16 on the other, and 25 less 9 is 16.'), findsOneWidget);
  });

  testWidgets('the odd cross admits it the moment the chords cross', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [1, 5, 3, 9]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Always equal.'), findsOneWidget);
    expect(find.text('Crossing at (3, 0): the products are 16 and 16, and they always agree, 25 less the crossing\'s distance from the middle squared.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 495 crossings finds them equal every time. Here at (3, 0) both are 16.'), findsOneWidget);
  });

  testWidgets('the why tells Euclid and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('thirty-fifth of his third book'), findsOneWidget);
    expect(find.textContaining('worked in full'), findsOneWidget);
  });
}
