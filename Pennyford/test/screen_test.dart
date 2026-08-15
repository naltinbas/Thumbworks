import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ringland.dart';

/// One ask on the screen, ringed as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the sizes so exactly four coins fit round the middle coin, and no more'), findsOneWidget);
    expect(find.text('9 fit'), findsOneWidget);
    expect(find.text('9.5° spare'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('middle 2'), findsOneWidget);
    expect(find.text('ring 1'), findsOneWidget);
    expect(find.text('A middle of 2 and rings of 1: each takes 38.9 degrees, so 9 fit, 9.5 degrees to spare.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'middle', 1);
    expect(state(tester).play.middle, 3);
    expect(find.text('12 fit'), findsOneWidget);
    expect(find.text('12.5° spare'), findsOneWidget);
    expect(find.text('A middle of 3 and rings of 1: each takes 29.0 degrees, so 12 fit, 12.5 degrees to spare.'), findsOneWidget);
    await turn(tester, 'ring', 1);
    expect(find.text('7 fit'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.ring, 1);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the four lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Ringed.'), findsOneWidget);
    expect(find.text('As asked. A middle of 1 and rings of 2: each takes 83.6 degrees, so 4 fit, 25.5 degrees to spare.'), findsOneWidget);
    expect(find.textContaining('A middle of one and rings of two: each takes 83.6 degrees of the turn, so four fit with 25.5 degrees to spare and no more; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Ringed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the coin and the way', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Widen the middle coin.'), findsOneWidget);
    await turn(tester, 'middle', 1);
    await press(tester, 'Show me');
    expect(find.text('Widen the ring coins.'), findsOneWidget);
  });

  testWidgets('the pointer rings the six with equal coins', (tester) async {
    await open(tester, which: 1);
    await ringByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 1);
    expect(find.text('As asked. A middle of 1 and rings of 1: each takes 60.0 degrees, so 6 fit, nothing to spare.'), findsOneWidget);
    expect(find.textContaining('so six fit with nothing to spare and no more; 1 tap.'), findsOneWidget);
  });

  testWidgets('the seven, by hand, and a dial at its end stays', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 4, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. A middle of 4 and rings of 3: each takes 50.8 degrees, so 7 fit, 4.7 degrees to spare.'), findsOneWidget);
    await press(tester, 'Again');
    await setDials(tester, 6, 1);
    await turn(tester, 'middle', 1);
    expect(state(tester).play.middle, 6);
    expect(find.text('taps 4'), findsOneWidget);
    expect(find.text('21 fit'), findsOneWidget);
  });

  testWidgets('the seven pennies admit it at equal coins', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 2, 2);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Six, and never seven.'), findsOneWidget);
    expect(find.text('Equal coins take sixty degrees each: six fit exactly, a seventh never, and a bigger ring coin takes more.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 36 settings finds nothing nearer'), findsOneWidget);
  });

  testWidgets('the why tells the sixty degrees and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('seven sixties are more than a turn'), findsOneWidget);
    expect(find.textContaining('36 settings, tried in full'), findsOneWidget);
  });
}
