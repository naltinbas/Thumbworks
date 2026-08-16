import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mintland.dart';

/// One ask on the screen, the coins tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pay 90 with no two neighbouring coins'), findsOneWidget);
    expect(find.text('0 of 90'), findsOneWidget);
    expect(find.text('nothing laid'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Nothing laid: tap coins on the rack to pay 90.'), findsOneWidget);
  });

  testWidgets('taps lay the coins, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapRack(tester, 89);
    expect(state(tester).play.picked, [89]);
    expect(find.text('89 makes 89, 1 to go, no two neighbours.'), findsOneWidget);
    expect(find.text('89 of 90'), findsOneWidget);
    expect(find.text('tidy'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.picked, isEmpty);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('neighbours are named, and a tap on the counter takes a coin back', (tester) async {
    await open(tester, which: 0);
    await lay(tester, [55, 34]);
    expect(state(tester).play.tidy, isFalse);
    expect(find.text('55 and 34 make 89, 1 to go, 55 and 34 neighbours.'), findsOneWidget);
    expect(find.text('1 neighbouring pair'), findsOneWidget);
    await tapCounter(tester, 34);
    expect(state(tester).play.picked, [55]);
    expect(find.text('55 makes 55, 35 to go, no two neighbours.'), findsOneWidget);
  });

  testWidgets('the ninety is paid and the card is shown', (tester) async {
    await open(tester, which: 0);
    await lay(tester, [89, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paid.'), findsOneWidget);
    expect(find.text('As asked. 89 and 1 make 90, no two neighbours.'), findsOneWidget);
    expect(find.textContaining('89 and 1: 90 paid, no two neighbours, the greedy purse\'s own picking; the one tidy picking of the 5 that pay 90; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Paid.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the coin, and the pointer pays the tidy top', (tester) async {
    await open(tester, which: 1);
    await tapRack(tester, 55);
    await press(tester, 'Show me');
    expect(find.text('Take back the 55.'), findsOneWidget);
    expect(state(tester).pointing, (55, true));
    await payByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 7);
    expect(find.text('As asked. 89, 34, 13, 5 and 2 make 143, no two neighbours.'), findsOneWidget);
    expect(find.textContaining('the one picking of the purse that pays 143; 7 taps.'), findsOneWidget);
  });

  testWidgets('the untidy hundred through 55, 34, 8 and 3', (tester) async {
    await open(tester, which: 2);
    await lay(tester, [55, 34, 8, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 55, 34, 8 and 3 make 100, 55 and 34 neighbours.'), findsOneWidget);
    expect(find.textContaining('one of 8 untidy pickings of the 9 that pay 100'), findsOneWidget);
  });

  testWidgets('the tidy hundred does not land the untidy ask', (tester) async {
    await open(tester, which: 2);
    await lay(tester, [89, 8, 3]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('89, 8 and 3 make 100, no two neighbours.'), findsOneWidget);
    expect(find.text('tidy'), findsOneWidget);
    expect(find.text('100 of 100'), findsOneWidget);
  });

  testWidgets('the unminted through 89 and 55', (tester) async {
    await open(tester, which: 3);
    await lay(tester, [89, 55]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 89 and 55 make 144, 89 and 55 neighbours.'), findsOneWidget);
    expect(find.textContaining('one of 5 pickings that pay 144, none of them tidy'), findsOneWidget);
  });

  testWidgets('the held-back coin stays on the rack, and the ask admits it when nothing more fits', (tester) async {
    await open(tester, which: 4);
    expect(find.text('Nothing laid: tap coins on the rack to pay 90, the 89 kept back.'), findsOneWidget);
    await tapRack(tester, 89);
    expect(state(tester).play.picked, isEmpty);
    await lay(tester, [55, 21, 8, 3, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One short, always.'), findsOneWidget);
    expect(find.text('55, 21, 8, 3 and 1 make 88, 2 to go, no two neighbours. Nothing more fits tidily.'), findsOneWidget);
    expect(find.textContaining('Here 55, 21, 8, 3 and 1 come to 88 and nothing more fits.'), findsOneWidget);
  });

  testWidgets('the why tells Zeckendorf and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Zeckendorf'), findsOneWidget);
    expect(find.textContaining('summed in full'), findsOneWidget);
  });
}
