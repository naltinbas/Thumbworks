import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/albumland.dart';

/// One ask on the screen, collected as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set six stickers and the fewest packets that make the album more likely full than not'), findsOneWidget);
    expect(find.text('average 14.70'), findsOneWidget);
    expect(find.text('full 0.27'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('stickers 6'), findsOneWidget);
    expect(find.text('packets 10'), findsOneWidget);
    expect(find.text('A set of 6 takes 147/10 packets on average, 14.70; full after 10 with chance 0.27.'), findsOneWidget);
  });

  testWidgets('turns move the dials, and back undoes', (tester) async {
    await open(tester, which: 0);
    await windPackets(tester, 1);
    expect(state(tester).play.packets, 11);
    expect(find.text('full 0.35'), findsOneWidget);
    await turnStickers(tester, -1);
    expect(find.text('average 11.41'), findsOneWidget);
    expect(find.text('A set of 5 takes 137/12 packets on average, 11.41; full after 11 with chance 0.60.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.stickers, 6);
    await windPackets(tester, -10);
    expect(state(tester).play.packets, 1);
    expect(find.text('full 0.00'), findsOneWidget);
  });

  testWidgets('the half dozen lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 6, 13);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Collected.'), findsOneWidget);
    expect(find.text('As asked. A set of 6 takes 147/10 packets on average, 14.70; full after 13 with chance 0.51.'), findsOneWidget);
    expect(find.textContaining('A set of 6 and 13 packets: 147/10 packets on average, 14.70, and the album full after 13 with chance 0.51; one of 1 settings of 720; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Collected.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('One more sticker in the set.'), findsOneWidget);
    await setDials(tester, 12, 10);
    await press(tester, 'Show me');
    expect(find.text('Up 10 packets.'), findsOneWidget);
  });

  testWidgets('the pointer collects the twelve', (tester) async {
    await open(tester, which: 1);
    await collectByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.stickers, state(tester).play.packets), (12, 35));
    expect(find.text('As asked. A set of 12 takes 86021/2310 packets on average, 37.23; full after 35 with chance 0.53.'), findsOneWidget);
  });

  testWidgets('the whole average, by hand, and one sticker is certain', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 2, 10);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. A set of 2 takes 3 packets on average, 3.00; full after 10 with chance 0.99.'), findsOneWidget);
  });

  testWidgets('one sticker is certain, and told so', (tester) async {
    await open(tester, which: 1);
    await setDials(tester, 1, 10);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('A set of 1 takes 1 packets on average, 1.00; full after 10 with chance 1, certain.'), findsOneWidget);
  });

  testWidgets('the certain album admits it at sixty packets', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 6, 60);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never certain.'), findsOneWidget);
    expect(find.text('Sixty packets and the album is full with chance 0.99, not 1: the same sticker could come every time.'), findsOneWidget);
    expect(find.textContaining('finds only the set of one certain'), findsOneWidget);
  });

  testWidgets('the why tells the harmonic number and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('n times the n-th harmonic number'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
