import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/denland.dart';

/// One week on the screen, walked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a week opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('walk the nine out for a second day in rows of three'),
      findsOneWidget,
    );
    expect(find.text('placed 0 of 9'), findsOneWidget);
    expect(find.text('pairs met 9 of 36'), findsOneWidget);
    expect(find.text('twice 0'), findsOneWidget);
    expect(find.text('Day 2, row 1: 0 of 3 in it; pairs met 9 of 36.'), findsOneWidget);
  });

  testWidgets('girls are placed, the pairs count, back undoes', (tester) async {
    await open(tester, which: 0);
    await placeAll(tester, [0, 3, 6]);
    expect(find.text('placed 3 of 9'), findsOneWidget);
    expect(find.text('pairs met 12 of 36'), findsOneWidget);
    expect(find.text('Day 2, row 2: 0 of 3 in it; pairs met 12 of 36.'), findsOneWidget);
    await tapGirl(tester, 0);
    expect(state(tester).play.placed, hasLength(3));
    await placeAll(tester, [1, 2, 4]);
    expect(find.text('twice 1'), findsOneWidget);
    expect(find.text('Day 2, row 3: 0 of 3 in it; pairs met 14 of 36, 1 twice.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.placed, hasLength(5));
  });

  testWidgets('the second day lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await placeAll(tester, [0, 3, 6, 1, 4, 7, 2, 5, 8]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Walked: 2 days, 18 pairs met, none twice.'), findsOneWidget);
    expect(
      find.textContaining('Every day walked and no pair twice; 9 girls placed.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a filling with a pair twice ends short', (tester) async {
    await open(tester, which: 0);
    await placeAll(tester, [0, 1, 3, 2, 4, 6, 5, 7, 8]);
    expect(state(tester).play.missed, isTrue);
    expect(find.textContaining('Every day filled, but'), findsOneWidget);
    expect(find.text('Not as asked.'), findsOneWidget);
  });

  testWidgets('show me rings a girl, and points back off a strayed filling', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('in', 0));
    expect(find.text('Place the ringed girl next.'), findsOneWidget);
    await placeAll(tester, [0, 1]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('out', 1));
    expect(find.text('Take the last girl back: this filling has strayed.'), findsOneWidget);
  });

  testWidgets('the pointer walks the whole week', (tester) async {
    await open(tester, which: 3);
    await placeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('pairs met 36 of 36'), findsOneWidget);
  });

  testWidgets('the hopeless week cracks when three days are walked', (tester) async {
    await open(tester, which: 4);
    await placeAll(tester, [0, 3, 6, 1, 4, 7, 2, 5, 8, 0, 4, 8, 1, 5, 6, 2, 3, 7]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Every day filled, 27 pairs met of 36.'), findsOneWidget);
    expect(find.text('Three days never do.'), findsOneWidget);
    expect(
      find.textContaining('27 pairs is the most three days can walk of the 36'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts two new a day', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('she meets two others a day'),
      findsOneWidget,
    );
    expect(
      find.textContaining('78400 of them, was walked to be sure'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the third day names the slants', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('one of the 280 ways of walking nine out in rows of three'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the two ways of slanting'),
      findsOneWidget,
    );
  });
}
