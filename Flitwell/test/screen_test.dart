import 'package:flitwell/flit/rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/flitland.dart';

/// One ask on the screen, the tenants moved as a thumb would move them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('would rather be where they end up than in the '
            'cottage they own'),
        findsWidgets);
    expect(find.text('beaten'), findsOneWidget);
    expect(find.text('lands 9 of 24'), findsOneWidget);
    expect(find.text('swaps 0'), findsOneWidget);
    expect(
        find.textContaining('could all do better by trading among themselves'),
        findsOneWidget);
  });

  testWidgets('a tenant is picked up, then swapped, and back undoes it',
      (tester) async {
    await open(tester, which: 0);
    await tapTenant(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.textContaining('Tenant A is ready'), findsOneWidget);
    await tapTenant(tester, 1);
    expect(Rules.write(state(tester).play.where), 'BACD');
    expect(find.text('swaps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(Rules.write(state(tester).play.where), 'ABCD');
    expect(find.text('swaps 0'), findsOneWidget);
  });

  testWidgets('tapping the sky over a cottage moves nobody and says so', (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(skyOver(tester, 1));
    await tester.pumpAndSettle();
    expect(state(tester).play.swaps, 0);
    expect(find.textContaining('A cottage stays where it is'), findsOneWidget);
  });

  testWidgets('the willing lane lands in two swaps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.swaps, 2);
    expect(find.text('Flitted.'), findsOneWidget);
    expect(find.textContaining('One of 9 lanes of the 24'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Flitted.'), findsNothing);
    expect(find.text('swaps 0'), findsOneWidget);
  });

  testWidgets('the unbeaten lane is one of seven', (tester) async {
    await open(tester, which: 1);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.swaps, 2);
    expect(find.textContaining('One of 7 lanes of the 24'), findsOneWidget);
  });

  testWidgets('the three that suit take all three swaps', (tester) async {
    await open(tester, which: 2);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.swaps, 3);
    expect(find.textContaining('One of 3 lanes of the 24'), findsOneWidget);
  });

  testWidgets('the firm lane is the only one, and leaves C worst off',
      (tester) async {
    await open(tester, which: 3);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(Rules.write(state(tester).play.where), 'BDCA');
    expect(state(tester).play.topped, [0, 1, 3]);
    expect(find.textContaining('One of 1 lane of the 24'), findsOneWidget);
    expect(find.textContaining('3 of the four have the cottage they want most'),
        findsOneWidget);
  });

  testWidgets('show me names both tenants', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Tap tenant '), findsOneWidget);
  });

  testWidgets('the better lane gives itself up and names the three',
      (tester) async {
    await open(tester, which: 4);
    for (final pair in [(0, 1), (2, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nothing beats the firm lane.'), findsOneWidget);
    expect(find.textContaining('tenants A, B, D are each in the cottage they '
        'want most'), findsOneWidget);
  });

  testWidgets('the why tells the rings, the paper and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the pointing has to close into rings'),
        findsOneWidget);
    expect(find.textContaining('Shapley and Scarf published this in 1974'),
        findsOneWidget);
    expect(find.textContaining('331,776'), findsOneWidget);
  });
}
