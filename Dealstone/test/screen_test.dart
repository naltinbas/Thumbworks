import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stoneland.dart';

/// One handful on the screen, piled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a handful opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('a hand the deal cannot move'),
      findsWidgets,
    );
    expect(find.text('hand 8'), findsOneWidget);
  });

  testWidgets('a sweep refills the pool and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await tapSlot(tester, 0);
    expect(state(tester).play.pool, 6);
    expect(find.text('pool 6'), findsOneWidget);
    await tapSlot(tester, 0);
    expect(state(tester).play.piles, [1]);
    await press(tester, 'Back');
    expect(state(tester).play.pool, 6);
  });

  testWidgets('the stair of six lands and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Dealt home.'), findsOneWidget);
    expect(
      find.textContaining('stands 0 deals from the stair'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Dealt home.'), findsNothing);
    expect(state(tester).play.piles, [6]);
  });

  testWidgets('show me rings a slot and says which way',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('ringed'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer piles the middle road home',
      (tester) async {
    await open(tester, which: 2);
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.deals, 3);
  });

  testWidgets('the hopeless handful cracks at eighteen moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 19; dither++) {
      await tapSlot(tester, 0);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Eight never stands.'), findsOneWidget);
    expect(
      find.textContaining('never eight'),
      findsWidgets,
    );
  });

  testWidgets('the why speaks the standstill law and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('takings pile holds one stone per pile'),
      findsOneWidget,
    );
    expect(find.textContaining('all 22 hands'), findsOneWidget);
  });
}
