import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One triangle on the screen, turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a triangle opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('turn the triangle of ten pennies upside down in three moves'),
      findsOneWidget,
    );
    expect(find.text('moves 0 of 3'), findsOneWidget);
    expect(find.text('best fit 7 of 10'), findsOneWidget);
    expect(find.text('placements 28'), findsOneWidget);
    expect(find.text('Moved 0 of 3; the best turned triangle over the pennies wants 3 more moves.'), findsOneWidget);
  });

  testWidgets('a penny is taken up, slid, and back undoes', (tester) async {
    await open(tester, which: 2);
    await tapSpot(tester, (0, 0));
    expect(state(tester).play.held, (0, 0));
    expect(find.text('A penny in hand; tap an empty spot to slide it there, or the penny to put it down.'), findsOneWidget);
    await tapSpot(tester, (2, 4));
    expect(find.text('moves 1 of 3'), findsOneWidget);
    expect(find.text('best fit 8 of 10'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
    expect(state(tester).play.lying, contains((0, 0)));
  });

  testWidgets('the ten turn and show the card', (tester) async {
    await open(tester, which: 2);
    await tapAll(tester, [(0, 0), (2, 4), (0, 3), (-1, 1), (3, 3), (2, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Turned: the triangle points down.'), findsOneWidget);
    expect(
      find.textContaining('Every penny lies in the triangle pointing down; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says take, then to', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('take', (0, 0)));
    expect(find.text('Take up the penny ringed.'), findsOneWidget);
    await tapSpot(tester, (0, 0));
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('to', (2, 4)));
    expect(find.text('Slide it to the spot ringed.'), findsOneWidget);
  });

  testWidgets('the pointer turns the fifteen', (tester) async {
    await open(tester, which: 3);
    await turnByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('moves 5 of 5'), findsOneWidget);
    expect(find.text('best fit 15 of 15'), findsOneWidget);
  });

  testWidgets('the hopeless triangle cracks at two moves', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [(0, 0), (2, 4), (0, 3), (-1, 1)]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two moves never turn it.'), findsOneWidget);
    expect(
      find.textContaining('its rows share at most seven of them as they lie, so three must move'),
      findsOneWidget,
    );
  });

  testWidgets('a miss shows its card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [(0, 0), (-1, -1)]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Not turned.'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('Not turned.'), findsNothing);
  });

  testWidgets('the why counts the rows', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('so it takes in at most 7 of the 10 as they lie'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a third of the pennies rounded down'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the fifteen counts the placements', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('3 placements of the 45 are within 5 moves.'),
      findsOneWidget,
    );
  });
}
