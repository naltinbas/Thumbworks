import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/benchland.dart';

/// One ask on the screen, the dials stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('set a composite that passes on base two'), findsOneWidget);
    expect(find.text('lands on 64'), findsOneWidget);
    expect(find.text('composite'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('91 on base 2, composite, 7 times 13: the base raised to 90 lands on 64, so it fails.'), findsOneWidget);
  });

  testWidgets('a dial steps the base, and back undoes', (tester) async {
    await open(tester, which: 1);
    await turn(tester, 'a', 1);
    expect(state(tester).play.base, 3);
    expect(find.text('91 on base 3, composite, 7 times 13: the base raised to 90 lands on 1, so it passes, a liar.'), findsOneWidget);
    expect(find.text('lands on 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.base, 2);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the liar of two lands at 341 and the card is shown', (tester) async {
    await open(tester, which: 1);
    await setTest(tester, 341, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Tested.'), findsOneWidget);
    expect(find.text('As asked. 341 on base 2, composite, 11 times 31: the base raised to 340 lands on 1, so it passes, a liar.'), findsOneWidget);
    expect(find.textContaining('341 on base 2: composite, 11 times 31, the base raised to 340 lands on 1, so it passes, by squaring and by the whole power brought down, and it is lying: a composite passing the test; one of 4 settings of the 13,189; 25 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Tested.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the step, and the pointer reaches the Carmichael', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Step the number up by 10.'), findsOneWidget);
    expect(state(tester).pointing, ('n', 10));
    await testByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.number, state(tester).play.base), (561, 2));
    expect(find.text('As asked. 561 on base 2, composite, 3 times 187: the base raised to 560 lands on 1, so it passes, a liar.'), findsOneWidget);
    expect(find.textContaining('on every base it shares no factor with; one of 15 settings of the 13,189'), findsOneWidget);
  });

  testWidgets('the honest prime at 1009', (tester) async {
    await open(tester, which: 0);
    await setTest(tester, 1009, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 1009 on base 2, a prime: the base raised to 1008 lands on 1, so it passes.'), findsOneWidget);
    expect(find.textContaining('one of 308 settings of the 13,189'), findsOneWidget);
  });

  testWidgets('a prime caught by the base it divides', (tester) async {
    await open(tester, which: 0);
    await setTest(tester, 7, 7);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('7 on base 7, a prime: the base raised to 6 lands on 0, so it fails.'), findsOneWidget);
    expect(find.text('prime'), findsOneWidget);
    expect(find.text('lands on 0'), findsOneWidget);
  });

  testWidgets('the liar of three at 121', (tester) async {
    await open(tester, which: 2);
    await setTest(tester, 121, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 121 on base 3, composite, 11 times 11: the base raised to 120 lands on 1, so it passes, a liar.'), findsOneWidget);
    expect(find.textContaining('one of 7 settings of the 13,189'), findsOneWidget);
  });

  testWidgets('the failing prime admits it after three primes', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 'n', 10);
    await turn(tester, 'n', 1);
    await turn(tester, 'n', 1);
    await turn(tester, 'n', 1);
    await turn(tester, 'n', 1);
    await turn(tester, 'n', 1);
    await turn(tester, 'n', 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Every prime passes, always.'), findsOneWidget);
    expect(find.text('107 on base 2, a prime: the base raised to 106 lands on 1, so it passes. Every prime passes, whatever the base.'), findsOneWidget);
    expect(find.textContaining('Here 107 passes on base 2, landing on 1.'), findsOneWidget);
  });

  testWidgets('the why tells Fermat and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('as Fermat wrote in 1640'), findsOneWidget);
    expect(find.textContaining('tested in full'), findsOneWidget);
  });
}
