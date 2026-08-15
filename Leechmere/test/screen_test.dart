import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One ask on the screen, the dials turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('set the loads so Ash cures a smaller share of the year than Birch'),
      findsOneWidget,
    );
    expect(find.text('Ash 60 in 100'), findsOneWidget);
    expect(find.text('Birch 50 in 100'), findsOneWidget);
    expect(find.text('turns 0'), findsOneWidget);
    expect(find.text('Ash cures 60 in a hundred over the year, Birch 50: Ash ahead.'), findsOneWidget);
  });

  testWidgets('a turn reads its shares, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapDial(tester, 3);
    expect(state(tester).play.loads, [30, 30, 30, 40]);
    expect(find.text('Birch 46 in 100'), findsOneWidget);
    expect(find.text('turns 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.loads, [30, 30, 30, 30]);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('three turns of Birch\'s autumn reverse the year and the card is shown', (tester) async {
    await open(tester, which: 0);
    await turnDial(tester, 3, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('As asked: Ash 60 in a hundred over the year, Birch 65, Birch ahead.'), findsOneWidget);
    expect(find.textContaining('Ash cures 36 of 60 over the year and Birch 26 of 40'), findsOneWidget);
    expect(find.textContaining('3 turns.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
    expect(state(tester).play.loads, [30, 30, 30, 30]);
  });

  testWidgets('show me rings the dial', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 0);
    expect(find.text('Turn the ringed dial: Ash in spring.'), findsOneWidget);
  });

  testWidgets('the pointer sets the wide reversal', (tester) async {
    await open(tester, which: 2);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.loads, [10, 20, 50, 10]);
    expect(find.text('As asked: Ash 50 in a hundred over the year, Birch 70, Birch ahead.'), findsOneWidget);
    expect(find.textContaining('Ash cures 15 of 30 over the year and Birch 42 of 60'), findsOneWidget);
  });

  testWidgets('the level year lands and says so', (tester) async {
    await open(tester, which: 1);
    await tapDial(tester, 2);
    await turnDial(tester, 3, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked: Ash 60 in a hundred over the year, Birch 60, level.'), findsOneWidget);
  });

  testWidgets('equal loads never reverse', (tester) async {
    await open(tester, which: 4);
    await tapDial(tester, 1);
    expect(state(tester).play.loads, [30, 40, 30, 40]);
    for (var k = 1; k < 20; k++) {
      await tapDial(tester, k % 4);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Equal loads never reverse.'), findsOneWidget);
    expect(
      find.textContaining('the healer ahead in both seasons is ahead in the year'),
      findsWidgets,
    );
  });

  testWidgets('the why counts the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('of the 25 equal loads none reverses, and every reversal among the 625 has the loads uneven'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the reversal counts its ways', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(find.textContaining('Of the 625, 154 land this ask.'), findsOneWidget);
    expect(find.textContaining('Simpson\'s paradox'), findsOneWidget);
  });
}
