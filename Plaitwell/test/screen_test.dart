import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plaitland.dart';

/// One ask on the screen, the ropes dyed as a thumb would dye them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('paint the 3 crossings of the trefoil'),
        findsWidgets);
    expect(find.text('crossings 3 of 3'), findsOneWidget);
    expect(find.text('colours 1 of 3'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(state(tester).play.paint, [0, 0, 0]);
    expect(find.textContaining('one colour proves nothing'), findsOneWidget);
  });

  testWidgets('a tap dyes one rope and back undoes it', (tester) async {
    await open(tester, which: 0);
    await dye(tester, 1);
    expect(state(tester).play.paint, [0, 1, 0]);
    expect(state(tester).play.taps, 1);
    expect(state(tester).play.allSound, isFalse);
    expect(find.textContaining('show two colours'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.taps, 0);
  });

  testWidgets('three taps on one rope bring it back round', (tester) async {
    await open(tester, which: 0);
    for (var k = 0; k < 3; k++) {
      await dye(tester, 0);
    }
    expect(state(tester).play.paint, [0, 0, 0]);
    expect(state(tester).play.taps, 3);
  });

  testWidgets('tapping the bare board dyes nothing and says so',
      (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(boardAt(tester));
    await tester.pumpAndSettle();
    expect(state(tester).play.taps, 0);
    expect(find.textContaining('That is board, not rope'), findsOneWidget);
  });

  testWidgets('the short plait is painted in three taps and the card shows',
      (tester) async {
    await open(tester, which: 0);
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 3);
    expect(state(tester).play.shades, 3);
    expect(find.text('Painted.'), findsOneWidget);
    expect(find.textContaining('One of 6 paintings of the 27'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Painted.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the granny takes 24 of its 729 paintings', (tester) async {
    await open(tester, which: 2);
    expect(find.text('crossings 6 of 6'), findsOneWidget);
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('One of 24 paintings of the 729'),
        findsOneWidget);
  });

  testWidgets('show me names a rope and how many taps it wants',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.textContaining('Rope '), findsOneWidget);
    expect(find.textContaining('tap'), findsWidgets);
  });

  testWidgets('the figure eight gives itself up', (tester) async {
    await open(tester, which: 4);
    for (final arc in const [0, 1, 2, 3, 0, 1, 2, 3]) {
      if (state(tester).play.gaveUp) break;
      await dye(tester, arc);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One colour or none.'), findsOneWidget);
    expect(find.textContaining('so this is not the trefoil'), findsOneWidget);
  });

  testWidgets('the why names the three moves', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('a kink is put in or taken out'),
        findsOneWidget);
    expect(find.textContaining('belongs to the knot rather than to the '
        'drawing'), findsOneWidget);
  });
}
