import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/starland.dart';

/// One ask on the screen, threaded as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the nails and the skip so a star of five nails is threaded in one stroke'), findsOneWidget);
    expect(find.text('the rim'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('nails 7'), findsOneWidget);
    expect(find.text('skip 1'), findsOneWidget);
    expect(find.text('7 nails, skip 1: the thread runs round the rim, no star.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'skip', 1);
    expect(state(tester).play.skip, 2);
    expect(find.text('1 stroke of 7'), findsOneWidget);
    expect(find.text('7 nails, skip 2: one stroke touches all 7, since they share no factor.'), findsOneWidget);
    await turn(tester, 'nails', 1);
    expect(find.text('2 strokes of 4'), findsOneWidget);
    expect(find.text('8 nails, skip 2: the thread comes home after 4, so it takes 2 strokes of 4; they share 2.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.nails, 7);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the pentagram lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 5, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Threaded.'), findsOneWidget);
    expect(find.text('As asked. 5 nails, skip 2: one stroke touches all 5, since they share no factor.'), findsOneWidget);
    expect(find.textContaining('Five nails, skip two: one stroke touches all five, since five and two share no factor; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Threaded.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Add a nail.'), findsOneWidget);
    await setDials(tester, 12, 1);
    await press(tester, 'Show me');
    expect(find.text('Widen the skip.'), findsOneWidget);
  });

  testWidgets('the pointer threads the three triangles', (tester) async {
    await open(tester, which: 2);
    await threadByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.text('As asked. 9 nails, skip 3: the thread comes home after 3, so it takes 3 strokes of 3; they share 3.'), findsOneWidget);
    expect(find.textContaining('the thread comes home after three nails, and three strokes of three cover the ring, since nine and three share the factor three; 4 taps.'), findsOneWidget);
  });

  testWidgets('the two squares, by hand, and a dial at its end stays', (tester) async {
    await open(tester, which: 1);
    // The skip first, so the landing is by six and not by two.
    for (var k = 0; k < 5; k++) {
      await turn(tester, 'skip', 1);
    }
    expect(find.text('7 nails, skip 6: the thread runs round the rim, no star.'), findsOneWidget);
    await turn(tester, 'nails', 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 8 nails, skip 6: the thread comes home after 4, so it takes 2 strokes of 4; they share 2.'), findsOneWidget);
    await press(tester, 'Again');
    await setDials(tester, 12, 1);
    await turn(tester, 'nails', 1);
    expect(state(tester).play.nails, 12);
    expect(find.text('taps 5'), findsOneWidget);
  });

  testWidgets('the star of David admits it once every skip of six is tried', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 6, 4);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two strokes, never one.'), findsOneWidget);
    expect(find.text('Six is two threes: skips two, three and four each share a factor with six, and the six-pointed star is never one stroke.'), findsOneWidget);
    expect(find.textContaining('the walk of all five skips finds no other'), findsOneWidget);
  });

  testWidgets('the why tells the factor and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the six-pointed star is two triangles and never one stroke'), findsOneWidget);
    expect(find.textContaining('60 settings, walked in full'), findsOneWidget);
  });
}
