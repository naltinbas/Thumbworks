import 'package:flutter_test/flutter_test.dart';
import 'package:roundhithe/road/rules.dart';

import 'support/fonts.dart';
import 'support/parishland.dart';

/// One ask on the screen, the villages tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('lay six roads with a round trip through all six villages'), findsOneWidget);
    expect(find.text('roads 0'), findsOneWidget);
    expect(find.text('no round trip'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No roads yet: tap a village, then another, to lay the road between them.'), findsOneWidget);
  });

  testWidgets('a tap holds a village, the next lays the road, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapVillage(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.text('Village A held: tap another to lay or lift the road between them, or A again to let it go.'), findsOneWidget);
    await tapVillage(tester, 1);
    expect(Rules.tell(state(tester).play.roads), 'AB');
    expect(find.text('1 road, A 1, B 1, C 0, D 0, E 0, F 0: no round trip.'), findsOneWidget);
    expect(find.text('roads 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.held, 0);
    await press(tester, 'Back');
    expect(state(tester).play.roads, 0);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the ring is laid and the card is shown', (tester) async {
    await open(tester, which: 0);
    await layRoads(tester, ['AB', 'BC', 'CD', 'DE', 'EF', 'FA']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Laid.'), findsOneWidget);
    expect(find.text('As asked. 6 roads, every village 2: a round trip, A B C D E F A.'), findsOneWidget);
    expect(find.textContaining('AB, AF, BC, CD, DE, EF: 6 roads, every village 2; a round trip, A B C D E F A, by the walk and by the table; one of 60 plans of the 32,768; 12 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Laid.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the road, and the pointer lays the nine roads', (tester) async {
    await open(tester, which: 2);
    await layRoads(tester, ['AB']);
    await press(tester, 'Show me');
    expect(find.text('Tap A, then B, to lift the road AB.'), findsOneWidget);
    expect(state(tester).pointing, (0, 1, true));
    await planByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 22);
    expect(find.text('As asked. 9 roads, every village 3: a round trip, A D B E C F A.'), findsOneWidget);
    expect(find.textContaining('one of 70 plans of the 32,768; 22 taps.'), findsOneWidget);
  });

  testWidgets('the two trios', (tester) async {
    await open(tester, which: 1);
    await layRoads(tester, ['AB', 'BC', 'CA', 'DE', 'EF', 'FD']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 6 roads, every village 2: no round trip.'), findsOneWidget);
    expect(find.textContaining('AB, AC, BC, DE, DF, EF: 6 roads, every village 2; no round trip, by the walk and by the table; one of 10 plans of the 32,768; 12 taps.'), findsOneWidget);
  });

  testWidgets('the eleven, five villages joined every way and the sixth hung on', (tester) async {
    await open(tester, which: 3);
    await layRoads(tester, ['AB', 'AC', 'AD', 'AE', 'BC', 'BD', 'BE', 'CD', 'CE', 'DE', 'EF']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 11 roads, A 4, B 4, C 4, D 4, E 5, F 1: no round trip.'), findsOneWidget);
    expect(find.textContaining('one of 30 plans of the 32,768; 22 taps.'), findsOneWidget);
  });

  testWidgets('a plan short of the ask says where it stands', (tester) async {
    await open(tester, which: 0);
    await layRoads(tester, ['AB', 'BC', 'CD', 'DE', 'EF']);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('5 roads, A 1, B 2, C 2, D 2, E 2, F 1: no round trip.'), findsOneWidget);
    expect(find.text('roads 5'), findsOneWidget);
    expect(find.text('no round trip'), findsOneWidget);
  });

  testWidgets('the three each admits it after three plans', (tester) async {
    await open(tester, which: 4);
    await layRoads(tester, ['AD', 'AE', 'AF', 'BD', 'BE', 'BF', 'CD', 'CE', 'CF']);
    expect(state(tester).play.isOver, isFalse);
    expect(find.text('9 roads, every village 3: a round trip, A D B E C F A.'), findsOneWidget);
    expect(find.text('a round trip'), findsOneWidget);
    await layRoads(tester, ['AB', 'AC']);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Round, every time.'), findsOneWidget);
    expect(find.text('11 roads, A 5, B 4, C 4, D 3, E 3, F 3: a round trip, A D B E C F A. Three each, a round trip, every time.'), findsOneWidget);
    expect(find.textContaining('Here AB, AC, AD, AE, AF, BD, BE, BF, CD, CE, CF has one, A D B E C F A.'), findsOneWidget);
  });

  testWidgets('the why tells Dirac and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Dirac proved in 1952'), findsOneWidget);
    expect(find.textContaining('walked in full'), findsOneWidget);
  });
}
