import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rodland.dart';

/// One ask on the screen, the rod cut as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on an uncut rod', (tester) async {
    await open(tester, which: 2);
    expect(
        find.textContaining('cut the rod of 12 so that the parts multiply to 81'),
        findsOneWidget);
    expect(find.text('12'), findsWidgets);
    expect(find.text('1 part'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('The rod cut 12, which multiplies to 12.'), findsOneWidget);
  });

  testWidgets('a tap cuts the rod, and back mends it', (tester) async {
    await open(tester, which: 2);
    await cutAt(tester, 2);
    expect(state(tester).play.parts, [3, 9]);
    expect(find.text('2 parts'), findsOneWidget);
    expect(find.text('The rod cut 3 + 9, which multiplies to 27.'),
        findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.parts, [12]);
  });

  testWidgets('the twelve lands on four threes', (tester) async {
    await open(tester, which: 2);
    await cutAll(tester, [2, 5, 8]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cut.'), findsOneWidget);
    expect(
        find.textContaining('The rod of 12 cut 3 + 3 + 3 + 3, which multiplies to 81.'),
        findsOneWidget);
    expect(find.textContaining('The only cutting of the 2,048 that lands the ask'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cut.'), findsNothing);
  });

  testWidgets('the ten takes two cuts', (tester) async {
    await open(tester, which: 0);
    await cutByPointerAll(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(find.textContaining('One of 9 cuttings of the 512 that land the ask'),
        findsOneWidget);
  });

  testWidgets('show me names the cut', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.textContaining('Cut after hand'), findsOneWidget);
    await cutByPointerAll(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
  });

  testWidgets('beat the threes admits it after three best cuttings',
      (tester) async {
    await open(tester, which: 4);
    await cutAll(tester, [2, 5, 8, 11]);
    expect(state(tester).play.seen, hasLength(1));
    await cutAll(tester, [2, 5, 8, 11, 3, 6, 9, 12]);
    expect(state(tester).play.seen, hasLength(2));
    await cutAll(tester, [1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The threes have it.'), findsOneWidget);
    expect(find.textContaining('Nothing passes 324 on a rod of 16'),
        findsOneWidget);
  });

  testWidgets('the why tells the threes and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('three times what is left'), findsOneWidget);
    expect(find.textContaining('tried in full before the sham'), findsOneWidget);
  });
}
