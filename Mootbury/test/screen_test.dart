import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mootland.dart';

/// One moot on the screen, sized as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a moot opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('size the moot of hamlets of 6, 6 and 2 hundred so that one more seat'), findsOneWidget);
    expect(find.text('seats 5'), findsOneWidget);
    expect(find.text('next seat: nobody loses'), findsOneWidget);
    expect(find.text('sizings 0'), findsOneWidget);
    expect(find.text('5 seats: remainders 2, 2, 1, dealing 3, 2, 0; 6 would give 3, 2, 1 by remainders.'), findsOneWidget);
  });

  testWidgets('a sizing changes the shares, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 1);
    expect(state(tester).play.seats, 6);
    expect(find.text('seats 6'), findsOneWidget);
    expect(find.text('sizings 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.seats, 5);
  });

  testWidgets('the alabama paradox lands at ten and the card is shown', (tester) async {
    await open(tester, which: 0);
    await sizeTo(tester, 10);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Sized.'), findsOneWidget);
    expect(find.text('As asked. 10 seats: remainders 4, 4, 2, dealing 5, 4, 1; 11 would give 5, 5, 1 by remainders, Cote losing a seat.'), findsOneWidget);
    expect(find.textContaining('At 10 seats largest remainders give 4, 4, 2 and dealing 5, 4, 1; at 11, 5, 5, 1 by remainders; 1 sizing.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Sized.'), findsNothing);
  });

  testWidgets('show me names the press', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 5);
    expect(find.text('Press +5.'), findsOneWidget);
  });

  testWidgets('the pointer sizes the four hamlets', (tester) async {
    await open(tester, which: 1);
    await sizeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.seats, 19);
    expect(find.textContaining('Dale losing a seat.'), findsOneWidget);
  });

  testWidgets('the broken quota at seven', (tester) async {
    await open(tester, which: 2);
    await sizeTo(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('remainders 4, 2, 1, dealing 5, 2, 0'), findsWidgets);
  });

  testWidgets('the whole shares at seven', (tester) async {
    await open(tester, which: 3);
    await sizeTo(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('remainders 3, 3, 1, dealing 3, 3, 1'), findsWidgets);
  });

  testWidgets('the jefferson paradox never comes', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await turn(tester, k.isEven ? 1 : -1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The dealing never falls.'), findsOneWidget);
    expect(find.textContaining('a moot of one more seat is the same dealing with one more seat dealt'), findsOneWidget);
  });

  testWidgets('the why tells the paradox and the counts', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the Alabama paradox, found in 1880'), findsOneWidget);
    expect(find.textContaining('On none of the 29 moots does a hamlet fall'), findsOneWidget);
  });
}
