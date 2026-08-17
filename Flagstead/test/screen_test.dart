import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hallland.dart';

/// One ask on the screen, the peg stood as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on a four by three', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('stand the peg so that all four posts are a whole number'),
        findsOneWidget);
    expect(find.text('wide 4'), findsOneWidget);
    expect(find.text('long 3'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('the peg is inside'), findsOneWidget);
  });

  testWidgets('a tap stands the peg, and back undoes it', (tester) async {
    await open(tester, which: 0);
    await standAt(tester, 5, 5);
    expect((state(tester).play.px, state(tester).play.py), (5, 5));
    expect(find.text('taps 1'), findsOneWidget);
    expect(find.text('the peg is out'), findsOneWidget);
    await press(tester, 'Back');
    expect((state(tester).play.px, state(tester).play.py), (2, 2));
  });

  testWidgets('the whole four lands with the peg on a post', (tester) async {
    await open(tester, which: 0);
    await standAt(tester, 0, 0);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Both the same.'), findsOneWidget);
    expect(find.textContaining('A hall 4 by 3 with the peg at (0, 0)'),
        findsOneWidget);
    expect(find.textContaining('One of 26 standings of the 11,025'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Both the same.'), findsNothing);
  });

  testWidgets('the peg within takes the six by eight', (tester) async {
    await open(tester, which: 3);
    await setStanding(tester, 6, 8, 3, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 8);
    expect(find.textContaining('the posts are 5, 5, 5, 5 paces off'),
        findsWidgets);
    expect(find.textContaining('One of 2 standings of the 11,025'),
        findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer lands the fifty',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.textContaining('the hall by a pace'), findsOneWidget);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.acrossOne, 50);
  });

  testWidgets('the leaning hall admits it after four standings',
      (tester) async {
    await open(tester, which: 4);
    await standAt(tester, 0, 0);
    await standAt(tester, 5, 5);
    await standAt(tester, -3, 7);
    await standAt(tester, 1, 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The lean will not have it.'), findsOneWidget);
    expect(find.textContaining('The two sums never agree on a leaning hall'),
        findsOneWidget);
  });

  testWidgets('the why tells the flag and the lean', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('British flag theorem'), findsOneWidget);
    expect(find.textContaining('taken in full before the sham'), findsOneWidget);
  });
}
