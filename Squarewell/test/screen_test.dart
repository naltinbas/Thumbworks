import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/squareland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('dial a base on the seven-hour clock whose square is 2'), findsOneWidget);
    expect(find.text('base 1'), findsOneWidget);
    expect(find.text('clock 7'), findsNothing);
    expect(find.text('square 1'), findsOneWidget);
    expect(find.text('squares 3 of 6'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Base 1 on the seven-hour clock squares to 1, as does its opposite 6; 1 itself is a square, Euler\'s power coming to 1.'), findsOneWidget);
  });

  testWidgets('a free ask shows both dials', (tester) async {
    await open(tester, which: 2);
    expect(find.text('clock 11'), findsOneWidget);
    expect(find.text('base 1'), findsOneWidget);
    expect(find.text('squares 5 of 10'), findsOneWidget);
    expect(find.textContaining('Turn the dials, a step a tap'), findsOneWidget);
  });

  testWidgets('a tap turns the base and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'base', 1);
    expect(state(tester).play.base, 2);
    expect(find.text('base 2'), findsOneWidget);
    expect(find.text('square 4'), findsOneWidget);
    expect(find.text('Base 2 on the seven-hour clock squares to 4, as does its opposite 5; 2 itself is a square, Euler\'s power coming to 1.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.base, 1);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the two of seven lands on 3 and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 7, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Squared.'), findsOneWidget);
    expect(find.text('As asked. Base 3 on the seven-hour clock squares to 2, as does its opposite 4; 3 itself is no square, Euler\'s power coming to 6.'), findsOneWidget);
    expect(find.textContaining('Base 3 on the seven-hour clock: 3 times 3 is 9, 1 seven and 2 over, so it squares to 2, as does 4; the squares on seven are 1, 2 and 4; one of 2 bases of its 6; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Squared.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the odd hour lands on a base that is nobody\'s square', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 7, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Base 3 on the seven-hour clock squares to 2, as does its opposite 4; 3 itself is no square, Euler\'s power coming to 6.'), findsOneWidget);
    expect(find.textContaining('one of 3 bases of its 6; 2 taps.'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way, and the pointer lands the minus one', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Turn the clock down.'), findsOneWidget);
    expect(state(tester).pointing, (0, -1));
    await squareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.clock, state(tester).play.base, state(tester).play.moves), (5, 2, 3));
    expect(find.text('As asked. Base 2 on the five-hour clock squares to 4, as does its opposite 3; 2 itself is no square, Euler\'s power coming to 4.'), findsOneWidget);
    expect(find.textContaining('Base 2 on the five-hour clock: 2 times 2 is 4, less than five, so it squares to 4, as does 3; the squares on five are 1 and 4; one of 6 settings of the 90; 3 taps.'), findsOneWidget);
  });

  testWidgets('the two on the seventeen-hour clock', (tester) async {
    await open(tester, which: 3);
    await setDials(tester, 17, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Base 6 on the seventeen-hour clock squares to 2, as does its opposite 11; 6 itself is no square, Euler\'s power coming to 16.'), findsOneWidget);
    expect(find.textContaining('6 times 6 is 36, 2 seventeens and 2 over, so it squares to 2, as does 11; the squares on seventeen are 1, 2, 4, 8, 9, 13, 15 and 16; one of 6 settings of the 90; 7 taps.'), findsOneWidget);
  });

  testWidgets('the two of eleven admits it once every base is tried', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 11, 10);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two is no square.'), findsOneWidget);
    expect(find.text('Every square on the eleven-hour clock seen: 1, 3, 4, 5 and 9, and 2 is not among them.'), findsOneWidget);
    expect(find.textContaining('the squares of 1 to 5 are 1, 4, 9, 5 and 3, and 6 to 10 repeat them backwards'), findsOneWidget);
  });

  testWidgets('the why tells Euler and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Euler found in 1748'), findsOneWidget);
    expect(find.textContaining('squared in full'), findsOneWidget);
  });
}
