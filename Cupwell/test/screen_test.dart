import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One tray on the screen, righted as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a tray opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('right four cups, four down, turning three at a time, in four turns'),
      findsOneWidget,
    );
    expect(find.text('turns 0 of 4'), findsOneWidget);
    expect(find.text('down 4'), findsOneWidget);
    expect(find.text('down count even'), findsOneWidget);
    expect(find.text('4 down; 0 of 3 marked; 4 turns left.'), findsOneWidget);
  });

  testWidgets('marks gather and turn, the count follows, back undoes', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [0, 1]);
    expect(find.text('4 down; 2 of 3 marked; 4 turns left.'), findsOneWidget);
    await tapCup(tester, 2);
    expect(state(tester).play.moves, 1);
    expect(find.text('turns 1 of 4'), findsOneWidget);
    expect(find.text('down 1'), findsOneWidget);
    expect(find.text('down count odd'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the two of three rights and shows the card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [0, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('All up in 1 turn.'), findsOneWidget);
    expect(find.text('down 0'), findsOneWidget);
    expect(
      find.textContaining('Every cup is up; 1 turn.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a wasted turn ends short', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [1, 2]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Turns spent, and 2 still down.'), findsOneWidget);
    expect(find.text('A turn wasted.'), findsOneWidget);
  });

  testWidgets('show me rings a cup to mark', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing!.$1, 'mark');
    expect(find.text('Mark the ringed cup for the turn.'), findsOneWidget);
  });

  testWidgets('the pointer rights the six by four', (tester) async {
    await open(tester, which: 3);
    await rightByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('turns 3 of 3'), findsOneWidget);
  });

  testWidgets('the hopeless tray cracks at six turns', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 6; k++) {
      await tapAll(tester, [0, 1]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Odd never comes even by twos.'), findsOneWidget);
    expect(
      find.textContaining('an odd count stays odd, and all up is even'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts by twos', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('changes the count down by two, when both went the same way, or by nought'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the law held on all of them'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the six by four reads the reach', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('turning the whole tray reaches only the tray and its opposite'),
      findsOneWidget,
    );
    expect(
      find.textContaining('only 32 of the 64 trays are ever reached'),
      findsOneWidget,
    );
  });
}
