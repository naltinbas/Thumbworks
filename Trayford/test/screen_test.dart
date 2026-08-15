import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// One tray on the screen, filled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a tray opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('leaving 2 over by threes, 3 over by fives and 2 over by sevens'),
      findsOneWidget,
    );
    expect(find.text('eggs 0'), findsOneWidget);
    expect(find.text('by 3s 0 of 2'), findsOneWidget);
    expect(find.text('by 5s 0 of 3'), findsOneWidget);
    expect(find.text('by 7s 0 of 2'), findsOneWidget);
    expect(find.text('0 eggs; 0 of 3 askings met.'), findsOneWidget);
  });

  testWidgets('a slot fills the tray, the last egg comes out, back undoes',
      (tester) async {
    await open(tester, which: 0);
    await tapSlot(tester, 8);
    expect(state(tester).play.eggs, 8);
    expect(find.text('eggs 8'), findsOneWidget);
    expect(find.text('by 3s 2 of 2'), findsOneWidget);
    expect(find.text('by 5s 3 of 4'), findsOneWidget);
    expect(find.text('8 eggs; 1 of 2 askings met.'), findsOneWidget);
    await tapSlot(tester, 8);
    expect(state(tester).play.eggs, 7);
    await press(tester, 'Back');
    expect(state(tester).play.eggs, 8);
  });

  testWidgets('the threes and fives land at fourteen and show the card',
      (tester) async {
    await open(tester, which: 0);
    await tapSlot(tester, 14);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Met.'), findsOneWidget);
    expect(find.text('Met: 14 eggs leave what was asked.'), findsOneWidget);
    expect(
      find.textContaining('14 eggs leave what was asked by every row; 1 filling.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Met.'), findsNothing);
  });

  testWidgets('show me rings a slot', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 18);
    expect(find.text('Fill the tray to the ringed slot: 18 eggs.'), findsOneWidget);
  });

  testWidgets('the pointer fills the fours and sixes', (tester) async {
    await open(tester, which: 3);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.eggs, 9);
  });

  testWidgets('the hopeless tray cracks at twelve fillings', (tester) async {
    await open(tester, which: 4);
    for (var count = 1; count <= 12; count++) {
      await tapSlot(tester, count);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Odd never goes even.'), findsOneWidget);
    expect(
      find.textContaining('one over by fours is odd, two over by sixes is even'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the shared two', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('No count is both.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the shared factor said so first'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the old count builds it', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('Sun Tzu\'s construction builds the count'),
      findsOneWidget,
    );
    expect(
      find.textContaining('140 plus 63 plus 30 over 105'),
      findsOneWidget,
    );
  });
}
