import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One yard on the screen, loaded as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('load the sacks of 6, 4, 3, 3, 2 and 2 stone into two carts of ten'), findsOneWidget);
    expect(find.text('loaded 0 of 6'), findsOneWidget);
    expect(find.text('carts 0, 0'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('0 of 6 loaded, 0, 0; tap a sack to move it to the next cart.'), findsOneWidget);
  });

  testWidgets('a tap loads a sack, an overload is called, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapSack(tester, 0);
    expect(state(tester).play.cartOf[0], 0);
    expect(find.text('carts 6, 0'), findsOneWidget);
    await tapSack(tester, 1);
    await tapSack(tester, 2);
    expect(find.text('Cart 1 past ten: 13, 0.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.loads, [10, 0]);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('the two carts land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await load(tester, [0, 0, 1, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Loaded.'), findsOneWidget);
    expect(find.text('As asked: loaded 10, 10, no cart past ten.'), findsOneWidget);
    expect(find.textContaining('20 stone in 2 carts of ten, loaded 10, 10; 10 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Loaded.'), findsNothing);
  });

  testWidgets('show me names the sack and the taps', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (0, 1));
    expect(find.text('Tap the ringed sack once, into cart 1.'), findsOneWidget);
    await tapSack(tester, 0);
    await press(tester, 'Show me');
    expect(find.text('Tap the ringed sack 2 times, into cart 2.'), findsOneWidget);
  });

  testWidgets('the pointer loads where the carrier slips', (tester) async {
    await open(tester, which: 3);
    await loadByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('30 stone in 3 carts of ten, loaded 10, 10, 10'), findsOneWidget);
  });

  testWidgets('the tight load, one of its five ways', (tester) async {
    await open(tester, which: 2);
    await load(tester, [0, 1, 2, 1, 0, 2, 2, 2, 2]);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the thirty-one never load', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 40; k++) {
      await tapSack(tester, k % 6);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Thirty-one never in three.'), findsOneWidget);
    expect(find.textContaining('a floor no loading beats; four carts take these ten ways'), findsOneWidget);
  });

  testWidgets('the why tells the search and the carrier', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('on four of the 3,003 loads of six sacks of one to nine stone it needs a cart too many'), findsOneWidget);
    expect(find.textContaining('four carts take these ten ways'), findsOneWidget);
  });
}
