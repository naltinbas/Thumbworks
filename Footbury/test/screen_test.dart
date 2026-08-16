import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fieldland.dart';

/// One ask on the screen, the pegs tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set a triangle on the rim and a point whose feet make a quarter of it'), findsOneWidget);
    expect(find.text('corners 0 of 3'), findsOneWidget);
    expect(find.text('no feet yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No corners set: tap three rim pegs, then a peg for the point.'), findsOneWidget);
  });

  testWidgets('taps set the corners on the rim only, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, (5, 0));
    expect(state(tester).play.pegs, [(5, 0)]);
    expect(find.text('1 of 3 corners set, at (5, 0): 2 more on the rim.'), findsOneWidget);
    await tapPeg(tester, (1, 1));
    expect(state(tester).play.pegs, [(5, 0)]);
    await tapPeg(tester, (-4, 3));
    await tapPeg(tester, (-3, -4));
    expect(find.text('Triangle (5, 0), (-4, 3), (-3, -4): now tap any peg for the point.'), findsOneWidget);
    expect(find.text('corners 3 of 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.pegs, [(5, 0), (-4, 3)]);
    await press(tester, 'Back');
    await press(tester, 'Back');
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the quarter lands at the middle and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(5, 0), (-4, 3), (-3, -4), (0, 0)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Footed.'), findsOneWidget);
    expect(find.text('As asked. Point (0, 0), root 0 from the middle: the feet make 1/4 of the whole, no line.'), findsOneWidget);
    expect(find.textContaining('Triangle (5, 0), (-4, 3), (-3, -4) with the point (0, 0): feet at (-7/2, -1/2), (1, -2), (1/2, 3/2), their triangle 1/4 of the whole, by the feet and by Euler\'s rule; one of 220 settings of the 25,960; 4 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Footed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer sets the level line', (tester) async {
    await open(tester, which: 3);
    await tapPeg(tester, (0, 5));
    await press(tester, 'Show me');
    expect(find.text('Lift the peg at (0, 5).'), findsOneWidget);
    expect(state(tester).pointing, ((0, 5), true));
    await pegsByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(find.text('As asked. Point (0, 5), on the rim: the feet lie in a line.'), findsOneWidget);
    expect(find.textContaining('one of 114 settings of the 25,960; 6 taps.'), findsOneWidget);
  });

  testWidgets('the fifth at (1, 2)', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [(5, 0), (-4, 3), (-3, -4), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Point (1, 2), root 5 from the middle: the feet make 1/5 of the whole, no line.'), findsOneWidget);
    expect(find.textContaining('one of 1,760 settings of the 25,960'), findsOneWidget);
  });

  testWidgets('the middle line', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(5, 0), (4, 3), (-5, 0), (0, -5)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Point (0, -5), on the rim: the feet lie in a line.'), findsOneWidget);
    expect(find.textContaining('one of 156 settings of the 25,960'), findsOneWidget);
  });

  testWidgets('a point short of the ask says its share', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(5, 0), (-4, 3), (-3, -4), (2, 2)]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Point (2, 2), root 8 from the middle: the feet make 17/100 of the whole, no line.'), findsOneWidget);
    expect(find.text('feet 17/100'), findsOneWidget);
  });

  testWidgets('the line off the rim admits it after three points', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(5, 0), (-4, 3), (-3, -4), (0, 0)]);
    await tapPeg(tester, (0, 0));
    await tapPeg(tester, (1, 2));
    await tapPeg(tester, (1, 2));
    await tapPeg(tester, (2, 2));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('On the rim alone, always.'), findsOneWidget);
    expect(find.text('Point (2, 2), root 8 from the middle: the feet make 17/100 of the whole, no line. Off the rim, never a line.'), findsOneWidget);
    expect(find.textContaining('Here the point (2, 2) stands root 8 from the middle, and its feet make 17/100 of the whole.'), findsOneWidget);
  });

  testWidgets('the why tells Wallace and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Wallace found in 1799'), findsOneWidget);
    expect(find.textContaining('footed in full'), findsOneWidget);
  });
}
