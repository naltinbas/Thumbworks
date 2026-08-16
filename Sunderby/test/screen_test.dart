import 'package:flutter_test/flutter_test.dart';
import 'package:sunderby/part/play.dart';

import 'support/fonts.dart';
import 'support/partland.dart';

/// One ask on the screen, sundered as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('sunder 8 into parts all different, three parts or more'), findsOneWidget);
    expect(find.text('sum 0 of 8'), findsOneWidget);
    expect(find.text('parts 0'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No parts laid: add parts from the shelf to make 8.'), findsOneWidget);
  });

  testWidgets('parts are laid, a row is dropped, and back undoes', (tester) async {
    await open(tester, which: 0);
    await addPart(tester, 5);
    expect(state(tester).play.parts, [5]);
    expect(find.text('5 = 5, 3 to go.'), findsOneWidget);
    await addPart(tester, 2);
    expect(find.text('5 + 2 = 7, 1 to go.'), findsOneWidget);
    expect(find.text('sum 7 of 8'), findsOneWidget);
    expect(find.text('parts 2'), findsOneWidget);
    await dropRow(tester, 0);
    expect(state(tester).play.parts, [2]);
    expect(find.text('taps 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.parts, [5, 2]);
  });

  testWidgets('a part too big for the room is refused', (tester) async {
    await open(tester, which: 0);
    await addAll(tester, [5, 2]);
    await addPart(tester, 4);
    expect(state(tester).play.parts, [5, 2]);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('the different lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await addAll(tester, [1, 5, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Sundered.'), findsOneWidget);
    expect(find.text('As asked. 8 = 5 + 2 + 1.'), findsOneWidget);
    expect(find.textContaining('8 = 5 + 2 + 1, turned 3 + 2 + 1 + 1 + 1; one of 2 partitions of its 22; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Sundered.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a full sum that misses says why: alike, or too few', (tester) async {
    await open(tester, which: 0);
    await addAll(tester, [4, 4]);
    expect(find.text('4 + 4 = 8, but two parts alike: drop a part and try again.'), findsOneWidget);
    await dropRow(tester, 1);
    await addPart(tester, 3);
    await addPart(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 8 = 4 + 3 + 1.'), findsOneWidget);
  });

  testWidgets('two different parts are too few for the different', (tester) async {
    await open(tester, which: 0);
    await addAll(tester, [5, 3]);
    expect(find.text('5 + 3 = 8, but too few parts: drop a part and try again.'), findsOneWidget);
    await dropRow(tester, 0);
    expect(state(tester).play.parts, [3]);
    await addAll(tester, [4, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 8 = 4 + 3 + 1.'), findsOneWidget);
  });

  testWidgets('an even part spoils the odd four', (tester) async {
    await open(tester, which: 1);
    await addAll(tester, [3, 3, 2]);
    expect(find.text('3 + 3 + 2 = 8, but an even part in it: drop a part and try again.'), findsOneWidget);
  });

  testWidgets('three parts of nine with the largest four miss the square', (tester) async {
    await open(tester, which: 3);
    await addAll(tester, [4, 3, 2]);
    expect(find.text('4 + 3 + 2 = 9, but not as asked: drop a part and try again.'), findsOneWidget);
  });

  testWidgets('the odd four lands and the card tells the folding', (tester) async {
    await open(tester, which: 1);
    await addAll(tester, [5, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 8 = 5 + 1 + 1 + 1.'), findsOneWidget);
    expect(find.textContaining('8 = 5 + 1 + 1 + 1, which Glaisher folds to 5 + 2 + 1; one of 2 partitions of its 22; 4 taps.'), findsOneWidget);
  });

  testWidgets('show me names the size, and calls a stray to be dropped', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Add a part of 3.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.add, 3));
    await addPart(tester, 4);
    await press(tester, 'Show me');
    expect(find.text('Drop the ringed part.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.drop, 0));
  });

  testWidgets('the pointer sunders the square', (tester) async {
    await open(tester, which: 3);
    await addPart(tester, 4);
    await sunderByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(find.text('As asked. 9 = 3 + 3 + 3.'), findsOneWidget);
    expect(find.textContaining('9 = 3 + 3 + 3, which Glaisher folds to 6 + 3; one of 1 partition of its 30; 5 taps.'), findsOneWidget);
  });

  testWidgets('the ten by hand, its own turning', (tester) async {
    await open(tester, which: 2);
    await addAll(tester, [4, 3, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 10 = 4 + 3 + 2 + 1.'), findsOneWidget);
    expect(find.textContaining('10 = 4 + 3 + 2 + 1, turned 4 + 3 + 2 + 1; one of 10 partitions of its 42; 4 taps.'), findsOneWidget);
  });

  testWidgets('the odd evens admit it once nine is made whole', (tester) async {
    await open(tester, which: 4);
    await addAll(tester, [8, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Evens add to even.'), findsOneWidget);
    expect(find.text('8 + 1 makes nine, with an odd part in it as every way must: even parts add up to even.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 30 partitions of nine finds not one with even parts throughout'), findsOneWidget);
  });

  testWidgets('the why tells Euler and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Euler found in 1748'), findsOneWidget);
    expect(find.textContaining('laid out in full'), findsOneWidget);
  });
}
