import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/laneland.dart';

/// One ask on the screen, laned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the three gates so the lanes meet, every gate at the middle of its side'), findsOneWidget);
    expect(find.text('the lanes miss'), findsOneWidget);
    expect(find.text('gates 3, 3, 3'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('D 1:3, E 1:3, F 1:3: the product is 1 to 27, and the lanes miss.'), findsOneWidget);
  });

  testWidgets('a tap moves a gate, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapGate(tester, 0, 6);
    expect(state(tester).play.gates, [6, 3, 3]);
    expect(find.text('D 1:1, E 1:3, F 1:3: the product is 1 to 9, and the lanes miss.'), findsOneWidget);
    await tapGate(tester, 1, 9);
    expect(find.text('D 1:1, E 3:1, F 1:3: the product is 1 to 1, and the lanes meet.'), findsOneWidget);
    expect(find.text('the lanes meet'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.gates, [6, 3, 3]);
  });

  testWidgets('the medians land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setGates(tester, 6, 6, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Met.'), findsOneWidget);
    expect(find.text('As asked. D 1:1, E 1:1, F 1:1: the product is 1 to 1, and the lanes meet.'), findsOneWidget);
    expect(find.textContaining('the lanes meet at (4, 4), found by crossing; one of 1 settings of 1,331; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Met.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the gate and the paces', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Move gate D to 4 paces from B.'), findsOneWidget);
    await tapGate(tester, 0, 4);
    await press(tester, 'Show me');
    expect(find.text('Move gate E to 8 paces from C.'), findsOneWidget);
  });

  testWidgets('the pointer lanes the two set', (tester) async {
    await open(tester, which: 3);
    await laneByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.gates, [4, 8, 6]);
    expect(find.textContaining('the lanes meet at (24/5, 12/5), found by crossing'), findsOneWidget);
  });

  testWidgets('the quarter, by hand', (tester) async {
    await open(tester, which: 2);
    await setGates(tester, 3, 9, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. D 1:3, E 3:1, F 1:1: the product is 1 to 1, and the lanes meet.'), findsOneWidget);
  });

  testWidgets('the thirds admit it once every gate is a third along', (tester) async {
    await open(tester, which: 4);
    await setGates(tester, 4, 4, 4);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One to eight, never one.'), findsOneWidget);
    expect(find.text('The thirds: the product is 1 to 8, not 1 to 1, and the lanes miss, as they must.'), findsOneWidget);
    expect(find.textContaining('every one with a gate at a middle'), findsOneWidget);
  });

  testWidgets('the why tells Ceva and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Ceva showed in 1678'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
