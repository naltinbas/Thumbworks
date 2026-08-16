import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/cutland.dart';

/// One ask on the screen, the pegs tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('set a line that cuts AB at its middle'), findsOneWidget);
    expect(find.text('pegs 0 of 2'), findsOneWidget);
    expect(find.text('no line yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No pegs set: tap two pegs and the line through them cuts the triangle.'), findsOneWidget);
  });

  testWidgets('taps set the pegs, and back undoes', (tester) async {
    await open(tester, which: 1);
    await tapPeg(tester, (6, 0));
    expect(state(tester).play.chosen, [(6, 0)]);
    expect(find.text('One peg set at (6, 0): tap another to draw the line.'), findsOneWidget);
    expect(find.text('pegs 1 of 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.chosen, isEmpty);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a line that misses a side names its flaw', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(1, 2), (5, 2)]);
    expect(state(tester).play.crosses, isFalse);
    expect(find.text('The line through (1, 2) and (5, 2) gives no three cuts: it runs level with AB and never meets it.'), findsOneWidget);
    expect(find.text('pegs 2 of 2'), findsOneWidget);
    expect(find.text('no line yet'), findsOneWidget);
    await tapPeg(tester, (5, 2));
    expect(state(tester).play.chosen, [(1, 2)]);
  });

  testWidgets('the middle cut lands and the card is shown', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [(6, 0), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cut.'), findsOneWidget);
    expect(find.text('As asked. F (6, 0), D (24, -12), E (0, 4): AF:FB 1, BD:DC -1/2, CE:EA 2, product -1; two sides cut inside.'), findsOneWidget);
    expect(find.textContaining('Line through (6, 0) and (0, 4): F (6, 0), D (24, -12), E (0, 4); AF:FB 1, BD:DC -1/2, CE:EA 2, product -1, by the crossings and by the areas; 2 sides cut inside; one of 90 lines of the 6,140; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cut.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer lands the two inside', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, (5, 5));
    await press(tester, 'Show me');
    expect(find.text('Lift the peg at (5, 5).'), findsOneWidget);
    expect(state(tester).pointing, ((5, 5), true));
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.text('As asked. F (1, 0), D (13/2, 11/2), E (0, -1): AF:FB 1/11, BD:DC 11/13, CE:EA -13, product -1; two sides cut inside.'), findsOneWidget);
    expect(find.textContaining('one of 5,572 lines of the 6,140; 4 taps.'), findsOneWidget);
  });

  testWidgets('the whole cuts through (2, 4) and (6, 6)', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(2, 4), (6, 6)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. F (-6, 0), D (6, 6), E (0, 3): AF:FB -1/3, BD:DC 1, CE:EA 3, product -1; two sides cut inside.'), findsOneWidget);
    expect(find.textContaining('one of 152 lines of the 6,140'), findsOneWidget);
  });

  testWidgets('the twice through (4, 8) and (0, 4)', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [(4, 8), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. F (-4, 0), D (4, 8), E (0, 4): AF:FB -1/4, BD:DC 2, CE:EA 2, product -1; two sides cut inside.'), findsOneWidget);
    expect(find.textContaining('one of 74 lines of the 6,140'), findsOneWidget);
  });

  testWidgets('a line outside the triangle still multiplies to -1', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [(12, 1), (11, 3)]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('F (25/2, 0), D (13, -1), E (0, 25): AF:FB -25, BD:DC -1/13, CE:EA -13/25, product -1; no side cut inside.'), findsOneWidget);
    expect(find.text('inside 0 of 3'), findsOneWidget);
    expect(find.text('product -1'), findsOneWidget);
  });

  testWidgets('the three inside admits it after three lines', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(1, 0), (2, 1)]);
    await tapPeg(tester, (2, 1));
    await tapPeg(tester, (0, 4));
    await tapPeg(tester, (1, 0));
    await tapPeg(tester, (6, 0));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('In and out, once.'), findsOneWidget);
    expect(find.text('F (6, 0), D (24, -12), E (0, 4): AF:FB 1, BD:DC -1/2, CE:EA 2, product -1; two sides cut inside. Two inside or none, every time.'), findsOneWidget);
    expect(find.textContaining('finds 5,572 cutting two inside and 568 none, and not one cutting one or three. Here the line cuts 2 inside.'), findsOneWidget);
  });

  testWidgets('the why tells Menelaus and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Menelaus of Alexandria'), findsOneWidget);
    expect(find.textContaining('cut in full'), findsOneWidget);
  });
}
