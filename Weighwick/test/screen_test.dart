import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One load on the screen, balanced as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a load opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('balance a load of twenty with the four weights on either pan'),
      findsOneWidget,
    );
    expect(find.text('across 0'), findsOneWidget);
    expect(find.text('beside 0'), findsOneWidget);
    expect(find.text('tipped by 20'), findsOneWidget);
    expect(find.text('The load\'s pan is heavier by 20: 20 and 0 against 0.'), findsOneWidget);
  });

  testWidgets('weights move, the beam tips, back undoes', (tester) async {
    await open(tester, which: 1);
    await moveAll(tester, [3]);
    expect(find.text('across 27'), findsOneWidget);
    expect(find.text('tipped by 7'), findsOneWidget);
    expect(find.text('The weights\' pan is heavier by 7: 27 against 20 and 0.'), findsOneWidget);
    await moveAll(tester, [2, 2]);
    expect(find.text('beside 9'), findsOneWidget);
    expect(find.text('tipped by 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.across, 36);
  });

  testWidgets('the twenty balances and shows the card', (tester) async {
    await open(tester, which: 1);
    await moveAll(tester, [3, 2, 2, 1, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Level: 20 and 10 beside against 30 across.'), findsOneWidget);
    expect(find.text('level'), findsOneWidget);
    expect(
      find.textContaining('The scale is level; 6 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a barred weight takes no tap', (tester) async {
    await open(tester, which: 4);
    await tapWeight(tester, 0);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a weight', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('move', 0));
    expect(find.text('Move the ringed weight.'), findsOneWidget);
  });

  testWidgets('the pointer balances the forty', (tester) async {
    await open(tester, which: 3);
    await moveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('across 40'), findsOneWidget);
  });

  testWidgets('the hopeless load cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    await moveAll(tester, [2, 1]);
    for (var dither = 0; dither < 5; dither++) {
      await moveAll(tester, [1, 1]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Ten needs the one.'), findsOneWidget);
    expect(
      find.textContaining('they weigh a multiple of three against the load'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts in threes', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('27 placings, 27 amounts, all multiples of three'),
      findsOneWidget,
    );
    expect(
      find.textContaining('this one as 9 and 1 across'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the forty reads the eighty-one', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('81 different amounts from -40 to 40'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the 81 placings weigh 81 different amounts'),
      findsOneWidget,
    );
  });
}
