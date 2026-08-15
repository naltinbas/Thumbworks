import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/partyland.dart';

/// One party on the screen, gathered as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a party opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('gather the fewest guests that make a shared birthday more likely than not'), findsOneWidget);
    expect(find.text('guests 1'), findsOneWidget);
    expect(find.text('0.00 in 100'), findsOneWidget);
    expect(find.text('presses 0'), findsOneWidget);
    expect(find.text('1 guest: a shared birthday at 0.00 in a hundred, short of the mark.'), findsOneWidget);
  });

  testWidgets('presses add and take away, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 10);
    expect(state(tester).play.guests, 11);
    expect(find.text('guests 11'), findsOneWidget);
    expect(find.text('presses 1'), findsOneWidget);
    await turn(tester, -1);
    expect(state(tester).play.guests, 10);
    expect(find.text('10 guests: a shared birthday at 11.69 in a hundred, short of the mark.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.guests, 11);
  });

  testWidgets('twenty-three land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await gather(tester, 23);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Gathered.'), findsOneWidget);
    expect(find.text('As asked: 23 guests, a shared birthday at 50.72 in a hundred, and 22 short of it.'), findsOneWidget);
    expect(find.textContaining('23 guests make a shared birthday 50.72 in a hundred, and 22 make it 47.56; 4 presses.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Gathered.'), findsNothing);
    expect(state(tester).play.guests, 1);
  });

  testWidgets('past the mark is said', (tester) async {
    await open(tester, which: 0);
    await gather(tester, 31);
    expect(find.text('31 guests: a shared birthday at 73.04 in a hundred, past the mark, and so are 30.'), findsOneWidget);
  });

  testWidgets('show me names the press', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 10);
    expect(find.text('Press +10.'), findsOneWidget);
  });

  testWidgets('the pointer gathers ninety-nine in a hundred', (tester) async {
    await open(tester, which: 2);
    await gatherByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.guests, 57);
    expect(find.textContaining('57 guests make a shared birthday 99.01 in a hundred'), findsOneWidget);
  });

  testWidgets('the shared month lands at five', (tester) async {
    await open(tester, which: 3);
    await gather(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked: 5 guests, a shared birth month at 61.80 in a hundred, and 4 short of it.'), findsOneWidget);
  });

  testWidgets('the certain day never comes under 366', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await turn(tester, k.isEven ? 10 : -1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never certain under 366.'), findsOneWidget);
    expect(find.textContaining('a number 779 digits long over one 936 digits long'), findsOneWidget);
  });

  testWidgets('the why tells the fraction and the pigeonhole', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('At d + 1 guests the product has a nought in it and the chance is one, the pigeonhole'), findsOneWidget);
    expect(find.textContaining('the 366th guest has no day left, and then it is certain'), findsOneWidget);
  });
}
