import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yokeland.dart';

/// One ask on the screen, the oxen changed over as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pulls exactly 42'), findsWidgets);
    expect(find.text('pull 35 of 42'), findsOneWidget);
    expect(find.text('crossed'), findsOneWidget);
    expect(find.text('swaps 0'), findsOneWidget);
    expect(state(tester).play.pull, 35);
  });

  testWidgets('two taps change a pair over, and back undoes it',
      (tester) async {
    await open(tester, which: 0);
    await tapPlace(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.textContaining('Place 1 is in hand'), findsOneWidget);
    await tapPlace(tester, 1);
    expect(state(tester).play.swaps, 1);
    expect(state(tester).play.order, [3, 4, 2, 1, 0]);
    await press(tester, 'Back');
    expect(state(tester).play.swaps, 0);
  });

  testWidgets('tapping above the rows changes nothing and says so',
      (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(skyAt(tester));
    await tester.pumpAndSettle();
    expect(state(tester).play.swaps, 0);
    expect(find.textContaining('Tap one place, then another'), findsOneWidget);
  });

  testWidgets('the slack pull lands in one swap and the card is shown',
      (tester) async {
    await open(tester, which: 1);
    await yokeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.swaps, 1);
    expect(state(tester).play.pull, 39);
    expect(find.text('Yoked.'), findsOneWidget);
    expect(find.textContaining('One of 7 yokings of the 120'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Yoked.'), findsNothing);
    expect(find.text('swaps 0'), findsOneWidget);
  });

  testWidgets('the best team leaves nothing crossed', (tester) async {
    await open(tester, which: 3);
    await yokeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.pull, 55);
    expect(state(tester).play.anyCrossed, isFalse);
    expect(state(tester).play.order, [0, 1, 2, 3, 4]);
    expect(find.textContaining('this is the best team there is'),
        findsOneWidget);
  });

  testWidgets('show me names the two places', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.textContaining('Take hold of place'), findsOneWidget);
  });

  testWidgets('past the best gives itself up on the swap', (tester) async {
    await open(tester, which: 4);
    for (final pair in const [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4),
      (0, 2)]) {
      if (state(tester).play.gaveUp) break;
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nothing pulls harder.'), findsOneWidget);
    expect(find.textContaining('The hardest any team here can pull is 55'),
        findsWidgets);
  });

  testWidgets('the why names the gaps and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('near gap multiplied'), findsOneWidget);
    expect(find.textContaining('15,876'), findsOneWidget);
  });
}
