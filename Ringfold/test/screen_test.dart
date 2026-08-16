import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/periodland.dart';

/// One ask on the screen, wound as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('dial a clock on which the Fibonacci numbers come round every 20 steps'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('period 3'), findsOneWidget);
    expect(find.text('odd'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('2 hours: 0, 1, 1, and 0, 1 comes round after 3 steps, an odd period; the matrix says 3 too.'), findsOneWidget);
  });

  testWidgets('a wind moves the clock, and back undoes it', (tester) async {
    await open(tester, which: 1);
    await wind(tester, 1);
    expect(state(tester).play.clock, 3);
    expect(find.text('period 8'), findsOneWidget);
    expect(find.text('even'), findsOneWidget);
    expect(find.text('3 hours: 0, 1, 1, 2, 0, 2, 2, 1, and 0, 1 comes round after 8 steps, an even period; the matrix says 8 too.'), findsOneWidget);
    await wind(tester, 1);
    expect(find.text('4 hours: 0, 1, 1, 2, 3, 1, and 0, 1 comes round after 6 steps, an even period; the matrix says 6 too.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.clock, 3);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the eight lands on three hours and the card is shown', (tester) async {
    await open(tester, which: 0);
    await wind(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Come round.'), findsOneWidget);
    expect(find.text('As asked. 3 hours: 0, 1, 1, 2, 0, 2, 2, 1, and 0, 1 comes round after 8 steps, an even period; the matrix says 8 too.'), findsOneWidget);
    expect(find.textContaining('On the 3-hour clock the Fibonacci numbers run 0, 1, 1, 2, 0, 2, 2, 1, and then 0, 1 again: period 8, the matrix agreeing, and its bound 8; one of 1 clock of the 39; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Come round.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the wind, and the pointer lands the sixty', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Wind up by 1.'), findsOneWidget);
    expect(state(tester).pointing, 1);
    await windByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.clock, state(tester).play.moves), (10, 8));
    expect(find.text('As asked. 10 hours: 0, 1, 1, 2, 3, 5 and on, and 0, 1 comes round after 60 steps, an even period; the matrix says 60 too.'), findsOneWidget);
    expect(find.textContaining('period 60, the matrix agreeing, and its bound 60; one of 3 clocks of the 39; 8 taps.'), findsOneWidget);
  });

  testWidgets('the twenty on five hours', (tester) async {
    await open(tester, which: 1);
    await setClock(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 5 hours: 0, 1, 1, 2, 3, 0 and on, and 0, 1 comes round after 20 steps, an even period; the matrix says 20 too.'), findsOneWidget);
    expect(find.textContaining('On the 5-hour clock the Fibonacci numbers run 0, 1, 1, 2, 3, 0, 3, 3 and on to 4, 1, and then 0, 1 again: period 20, the matrix agreeing, and its bound 20; one of 1 clock of the 39; 3 taps.'), findsOneWidget);
  });

  testWidgets('the own length on twenty-four hours', (tester) async {
    await open(tester, which: 3);
    await setClock(tester, 24);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 24 hours: 0, 1, 1, 2, 3, 5 and on, and 0, 1 comes round after 24 steps, an even period; the matrix says 24 too.'), findsOneWidget);
    expect(find.textContaining('one of 1 clock of the 39; 4 taps.'), findsOneWidget);
  });

  testWidgets('the odd period admits it on the four-hour clock', (tester) async {
    await open(tester, which: 4);
    await setClock(tester, 4);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Even, by Cassini.'), findsOneWidget);
    expect(find.text('4 hours: 0, 1, 1, 2, 3, 1, and 0, 1 comes round after 6 steps, an even period; the matrix says 6 too. Six is the shortest period past two hours, and it is even like every other: Cassini forbids an odd one.'), findsOneWidget);
    expect(find.textContaining('here the 4-hour clock has period 6, even, and the sweep of every clock to two hundred finds the two-hour clock alone with an odd period, three.'), findsOneWidget);
  });

  testWidgets('the why tells Lagrange, Cassini and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Lagrange saw it in 1774'), findsOneWidget);
    expect(find.textContaining('walked round in full'), findsOneWidget);
  });
}
