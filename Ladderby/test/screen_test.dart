import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/joinland.dart';

/// One ask on the screen, the pegs tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('pick the pegs so that the three crossings stand halfway between the rails'), findsOneWidget);
    expect(find.text('pegs 0 of 6'), findsOneWidget);
    expect(find.text('no crossings yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No pegs picked: tap three on each rail and the six cross-joins cross.'), findsOneWidget);
  });

  testWidgets('taps pick the pegs, and back undoes', (tester) async {
    await open(tester, which: 1);
    await tapPeg(tester, (0, 0));
    expect(state(tester).play.bottom, [0]);
    expect(find.text('1 of 3 on the bottom rail, 0 of 3 on the top: pick 5 more.'), findsOneWidget);
    expect(find.text('pegs 1 of 6'), findsOneWidget);
    await tapPeg(tester, (1, 7));
    expect(state(tester).play.top, [7]);
    expect(find.text('1 of 3 on the bottom rail, 1 of 3 on the top: pick 4 more.'), findsOneWidget);
    await press(tester, 'Back');
    await press(tester, 'Back');
    expect(state(tester).play.bottom, isEmpty);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a hexagon whose joins run parallel names the pair', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [0, 1, 2], [2, 1, 0]);
    expect(state(tester).play.crossings, isNull);
    expect(find.text('The joins A-b with a-B run parallel and never cross: lift a peg and pick another.'), findsOneWidget);
    expect(find.text('pegs 6 of 6'), findsOneWidget);
    expect(find.text('a pair parallel'), findsOneWidget);
    await tapPeg(tester, (1, 0));
    expect(state(tester).play.top, [2, 1]);
  });

  testWidgets('the middle rung lands and the card is shown', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [0, 1, 2], [0, 1, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Crossed.'), findsOneWidget);
    expect(find.text('As asked. X (1/2, 3), Y (1, 3), Z (3/2, 3), the closed form agreeing: in a line.'), findsOneWidget);
    expect(find.textContaining('Bottom A 0, B 1, C 2, top a 0, b 1, c 2: X (1/2, 3), Y (1, 3), Z (3/2, 3), by the general meeting of two lines and by the closed form, in a line; one of 196 hexagons of the 14,168; 6 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Crossed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer lands the level line', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, (0, 5));
    await press(tester, 'Show me');
    expect(find.text('Lift peg 5 on the bottom rail.'), findsOneWidget);
    expect(state(tester).pointing, ((0, 5), true));
    await joinByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 8);
    expect(find.text('As asked. X (1/2, 3), Y (1, 3), Z (3/2, 3), the closed form agreeing: in a line.'), findsOneWidget);
    expect(find.textContaining('one of 452 hexagons of the 14,168; 8 taps.'), findsOneWidget);
  });

  testWidgets('the whole points through bottom 0, 1, 2 and top 1, 2, 0', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [0, 1, 2], [1, 2, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. X (1, 3), Y (0, 12), Z (2, -6), the closed form agreeing: in a line.'), findsOneWidget);
    expect(find.textContaining('one of 908 hexagons of the 14,168'), findsOneWidget);
  });

  testWidgets('the steep line through bottom 0, 2, 3 and top 0, 6, 3', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [0, 2, 3], [0, 6, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. X (3/2, 3/2), Y (3/2, 3), Z (3/2, -3), the closed form agreeing: in a line.'), findsOneWidget);
    expect(find.textContaining('one of 16 hexagons of the 14,168'), findsOneWidget);
  });

  testWidgets('a hexagon that misses the ask still lies in a line', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [0, 2, 5], [1, 4, 6]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('X (8/5, 12/5), Y (3, 3), Z (22/5, 18/5), the closed form agreeing: in a line.'), findsOneWidget);
    expect(find.text('in a line'), findsOneWidget);
    expect(find.text('pegs 6 of 6'), findsOneWidget);
  });

  testWidgets('the bent line admits it after three hexagons', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [0, 1, 2], [0, 1, 2]);
    await tapPeg(tester, (1, 2));
    await tapPeg(tester, (1, 3));
    await tapPeg(tester, (1, 3));
    await tapPeg(tester, (1, 4));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('In a line, always.'), findsOneWidget);
    expect(find.text('X (1/2, 3), Y (4/3, 2), Z (7/4, 3/2), the closed form agreeing: in a line. In a line, every time.'), findsOneWidget);
    expect(find.textContaining('the three crossings in a line on every one. Here X (1/2, 3), Y (4/3, 2) and Z (7/4, 3/2) lie in a line.'), findsOneWidget);
  });

  testWidgets('the why tells Pappus and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Pappus of Alexandria'), findsOneWidget);
    expect(find.textContaining('crossed in full'), findsOneWidget);
  });
}
