import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tableland.dart';

/// One table on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a table opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the table so the ball drops in the far pocket'), findsOneWidget);
    expect(find.text('table 3 by 2'), findsOneWidget);
    expect(find.text('bounces 3'), findsOneWidget);
    expect(find.text('settings 0'), findsOneWidget);
    expect(find.text('3 by 2: 3 bounces in 6 steps, and the ball drops in the top pocket.'), findsOneWidget);
  });

  testWidgets('the sides turn, and back undoes', (tester) async {
    await open(tester, which: 1);
    await set(tester, 'along-');
    expect(state(tester).play.along, 2);
    expect(find.text('table 2 by 2'), findsOneWidget);
    expect(find.text('2 by 2: 0 bounces in 2 steps, and the ball drops in the far pocket.'), findsOneWidget);
    await set(tester, 'up+');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.up, 2);
    expect(find.text('settings 1'), findsOneWidget);
  });

  testWidgets('the far pocket lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setTable(tester, 5, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Pocketed.'), findsOneWidget);
    expect(find.text('As asked. 5 by 3: 6 bounces in 15 steps, and the ball drops in the far pocket.'), findsOneWidget);
    expect(find.textContaining('The 5 by 3: the ball bounces 6 times in 15 steps and drops in the far pocket, as the parity says; 3 settings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Pocketed.'), findsNothing);
  });

  testWidgets('show me names the side', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 'along+');
    expect(find.text('Lengthen the table along.'), findsOneWidget);
  });

  testWidgets('the pointer sets the longest rally', (tester) async {
    await open(tester, which: 3);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 11 by 12: 21 bounces in 132 steps, and the ball drops in the top pocket.'), findsOneWidget);
  });

  testWidgets('one bounce, by hand', (tester) async {
    await open(tester, which: 2);
    await setTable(tester, 2, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('the ball bounces 1 time in 4 steps and drops in the top pocket'), findsOneWidget);
  });

  testWidgets('the ball never comes home', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await set(tester, k.isEven ? 'up+' : 'up-');
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The ball never comes home.'), findsOneWidget);
    expect(find.textContaining('so they share no factor and cannot both be even'), findsOneWidget);
  });

  testWidgets('the why tells the unfolding', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('every table to thirty a side, 841 tables, and the roll agrees with the rule on every one'), findsOneWidget);
    expect(find.textContaining('none of the 121 tables sends the ball home'), findsOneWidget);
  });
}
