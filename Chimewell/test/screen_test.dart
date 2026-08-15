import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/coilland.dart';

/// One ask on the screen, sounded as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the fifths and the octaves so the note sounds 9/8 of the start'), findsOneWidget);
    expect(find.text('sounds 1/1'), findsOneWidget);
    expect(find.text('+0.00 cents'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('fifths 0'), findsOneWidget);
    expect(find.text('octaves 0'), findsOneWidget);
    expect(find.text('No fifths and no octaves: the note is the start itself.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'fifths', 1);
    expect(state(tester).play.fifths, 1);
    expect(find.text('sounds 3/2'), findsOneWidget);
    expect(find.text('+701.96 cents'), findsOneWidget);
    expect(find.text('fifths +1'), findsOneWidget);
    expect(find.text('One fifth up and no octaves: 3/2 of the start, 701.96 cents sharp.'), findsOneWidget);
    await turn(tester, 'octaves', -1);
    expect(find.text('sounds 3/4'), findsOneWidget);
    expect(find.text('-498.04 cents'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.octaves, 0);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the whole tone lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 2, -1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Sounded.'), findsOneWidget);
    expect(find.text('As asked. Two fifths up and one octave down: 9/8 of the start, 203.91 cents sharp.'), findsOneWidget);
    expect(find.textContaining('the note sounds 9/8 of the start, 203.91 cents sharp; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Sounded.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Lower the fifths.'), findsOneWidget);
    await setDials(tester, -5, 0);
    await press(tester, 'Show me');
    expect(find.text('Raise the octaves.'), findsOneWidget);
  });

  testWidgets('the pointer sounds the circle', (tester) async {
    await open(tester, which: 3);
    await soundByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 19);
    expect(find.text('As asked. Twelve fifths up and seven octaves down: 531,441/524,288 of the start, 23.46 cents sharp.'), findsOneWidget);
  });

  testWidgets('the third, by hand, and a dial at its end stays', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 4, -2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Four fifths up and two octaves down: 81/64 of the start, 407.82 cents sharp.'), findsOneWidget);
    await press(tester, 'Again');
    await setDials(tester, 12, 0);
    await turn(tester, 'fifths', 1);
    expect(state(tester).play.fifths, 12);
    expect(find.text('taps 12'), findsOneWidget);
  });

  testWidgets('the return admits it at the comma', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 12, -7);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The coil never closes.'), findsOneWidget);
    expect(find.text('The comma is as near as fifths come: 3 to any power is odd, 2 to any power even, and no stack lands home.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 425 settings finds nothing nearer'), findsOneWidget);
  });

  testWidgets('the why tells the comma and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the comma, 23.46 cents sharp of home'), findsOneWidget);
    expect(find.textContaining('not one of the 425 settings with a fifth in it lands'), findsOneWidget);
  });
}
