import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/bubbleland.dart';

/// One ask on the screen, the dials stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the three bends so that the outer bubble has a bend of -1'), findsOneWidget);
    expect(find.text('gap 3 + 2 root 3'), findsOneWidget);
    expect(find.text('outer 3 - 2 root 3'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Bends 1, 1 and 1: 3 + 2 root 3 in the gap, 3 - 2 root 3 round the outside.'), findsOneWidget);
  });

  testWidgets('a dial steps a bend, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 2, 1);
    expect(state(tester).play.bends, [1, 1, 2]);
    expect(find.text('Bends 1, 1 and 2: 4 + 2 root 5 in the gap, 4 - 2 root 5 round the outside.'), findsOneWidget);
    expect(find.text('gap 4 + 2 root 5'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.bends, [1, 1, 1]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the unit ring lands at 2, 2 and 3 and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setBends(tester, [2, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Kissed.'), findsOneWidget);
    expect(find.text('As asked. Bends 2, 2 and 3: 15 in the gap, -1 round the outside, both whole.'), findsOneWidget);
    expect(find.textContaining('Bends 2, 2 and 3: the fourths 15 in the gap and -1 round the outside, by the formula and by the relation tried whole bend by whole bend, the pairwise sum 16, a square; one of 27 settings of the 8,000; 4 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Kissed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer reaches the far gap', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Step bend 3 up.'), findsOneWidget);
    expect(state(tester).pointing, (2, 1));
    await bendsByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.bends, [1, 1, 12]);
    expect(state(tester).play.moves, 11);
    expect(find.text('As asked. Bends 1, 1 and 12: 24 in the gap, 4 in the far gap, both whole.'), findsOneWidget);
    expect(find.textContaining('one of 18 settings of the 8,000; 11 taps.'), findsOneWidget);
  });

  testWidgets('the flat fourth at 1, 1 and 4', (tester) async {
    await open(tester, which: 1);
    await setBends(tester, [1, 1, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Bends 1, 1 and 4: 12 in the gap, 0 flattened to a line, both whole.'), findsOneWidget);
    expect(find.textContaining('one of 33 settings of the 8,000'), findsOneWidget);
  });

  testWidgets('the whole wrap lands on the way to 2, 3 and 6', (tester) async {
    await open(tester, which: 2);
    await setBends(tester, [2, 3, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.bends, [2, 3, 2]);
    expect(find.text('As asked. Bends 2, 3 and 2: 15 in the gap, -1 round the outside, both whole.'), findsOneWidget);
    expect(find.textContaining('one of 156 settings of the 8,000; 4 taps.'), findsOneWidget);
  });

  testWidgets('a setting short of the ask says its fourths', (tester) async {
    await open(tester, which: 0);
    await setBends(tester, [1, 2, 3]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Bends 1, 2 and 3: 6 + 2 root 11 in the gap, 6 - 2 root 11 round the outside.'), findsOneWidget);
    expect(find.text('gap 6 + 2 root 11'), findsOneWidget);
  });

  testWidgets('the twin fourths admits it after twelve taps', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 12; k++) {
      await turn(tester, 0, k.isEven ? 1 : -1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Apart, every time.'), findsOneWidget);
    expect(find.text('Bends 1, 1 and 1: 3 + 2 root 3 in the gap, 3 - 2 root 3 round the outside. Apart, whatever the bends.'), findsOneWidget);
    expect(find.textContaining('Here the bends 1, 1 and 1 give 3 + 2 root 3 and 3 - 2 root 3, apart by 4 root 3.'), findsOneWidget);
  });

  testWidgets('the why tells Descartes and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Soddy set it to verse'), findsOneWidget);
    expect(find.textContaining('worked in full'), findsOneWidget);
  });
}
