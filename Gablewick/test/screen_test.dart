import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/gableland.dart';

/// One ask on the screen, framed as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('set the sides so the area is exactly 12'), findsOneWidget);
    expect(find.text('area 5.33'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('first 3'), findsOneWidget);
    expect(find.text('second 4'), findsOneWidget);
    expect(find.text('third 6'), findsOneWidget);
    expect(find.text('3, 4, 6: area 5.33, not whole.'), findsOneWidget);
  });

  testWidgets('a tap turns a side, a flat one is told, and back undoes', (tester) async {
    await open(tester, which: 1);
    await turn(tester, 'third', 1);
    expect(state(tester).play.sides, [3, 4, 7]);
    expect(find.text('no triangle'), findsOneWidget);
    expect(find.text('3, 4, 7 do not close into a triangle.'), findsOneWidget);
    await turn(tester, 'third', -1);
    await turn(tester, 'third', -1);
    expect(find.text('area 6'), findsOneWidget);
    expect(find.text('3, 4, 5: area 6, whole.'), findsOneWidget);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('taps 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.sides, [3, 4, 6]);
  });

  testWidgets('the twelve lands and the card is shown', (tester) async {
    await open(tester, which: 1);
    await setSides(tester, 5, 5, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Framed.'), findsOneWidget);
    expect(find.text('As asked. 5, 5, 6: area 12, whole.'), findsOneWidget);
    expect(find.textContaining('Sides 5, 5 and 6: sixteen times the area squared is 2304, and the area 12, whole; one of 2 triangles of the 372 to fifteen; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Framed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the side and the way', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Lengthen the first side.'), findsOneWidget);
    await setSides(tester, 13, 4, 6);
    await press(tester, 'Show me');
    expect(find.text('Lengthen the second side.'), findsOneWidget);
  });

  testWidgets('the pointer frames the uneven', (tester) async {
    await open(tester, which: 3);
    await frameByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.sides, [13, 14, 15]);
    expect(find.text('As asked. 13, 14, 15: area 84, whole.'), findsOneWidget);
  });

  testWidgets('the two alike, by hand, in another order', (tester) async {
    await open(tester, which: 2);
    await setSides(tester, 13, 10, 13);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 13, 10, 13: area 60, whole.'), findsOneWidget);
  });

  testWidgets('the three odds admit it once three odd sides close', (tester) async {
    await open(tester, which: 4);
    await setSides(tester, 3, 5, 7);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Odd all round, and never whole.'), findsOneWidget);
    expect(find.text('Three odd sides: sixteen times the area squared is 675, odd, and never a whole area.'), findsOneWidget);
    expect(find.textContaining('finds every whole-area one with an even side'), findsOneWidget);
  });

  testWidgets('the why tells Heron and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Heron of Alexandria'), findsOneWidget);
    expect(find.textContaining('372 of them, tried in full'), findsOneWidget);
  });
}
