import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// One ask on the screen, the stones tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('cross to a dry stone past the hundredth'),
        findsOneWidget);
    expect(find.text('stone 2'), findsOneWidget);
    expect(find.text('1 dry in reach'), findsOneWidget);
    expect(find.text('hops 0'), findsOneWidget);
    expect(find.text('On stone 2, the rope out to 4: the dry stones under it are 3.'),
        findsOneWidget);
  });

  testWidgets('a hop moves you on, and back undoes it', (tester) async {
    await open(tester, which: 0);
    await tapStone(tester, 3);
    expect(state(tester).play.at, 3);
    expect(find.text('On stone 3, the rope out to 6: the dry stones under it are 5.'),
        findsOneWidget);
    expect(find.text('hops 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.at, 2);
    expect(find.text('hops 0'), findsOneWidget);
  });

  testWidgets('a stone out of reach or under moss is refused, with the reason',
      (tester) async {
    await open(tester, which: 0);
    await tapStone(tester, 11);
    expect(state(tester).play.at, 2);
    expect(
        find.text('No hop: the rope from stone 2 reaches only as far as 4.'),
        findsOneWidget);
    await tapStone(tester, 4);
    expect(find.text('No hop: stone 4 is even, and mossy.'), findsOneWidget);
    expect(find.text('hops 0'), findsOneWidget);
    await tapStone(tester, 3);
    expect(state(tester).play.at, 3);
    expect(find.textContaining('No hop'), findsNothing);
  });

  testWidgets('the hundred ford lands past the hundredth stone', (tester) async {
    await open(tester, which: 0);
    await hopAlong(tester, [3, 5, 7, 13, 23, 43, 83, 113]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Across.'), findsOneWidget);
    expect(
        find.textContaining(
            'Stone 113, by 2, 3, 5, 7, 13, 23, 43, 83, 113: 8 hops, and the fewest the ford allows is 8.'),
        findsOneWidget);
    expect(find.textContaining('One of 5 stones of the 120 that land the ask.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Across.'), findsNothing);
    expect(find.text('hops 0'), findsOneWidget);
  });

  testWidgets('show me names the stone, and the pointer crosses', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Hop to stone 3.'), findsOneWidget);
    expect(state(tester).pointing, 3);
    await crossByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.at, 53);
    expect(state(tester).play.moves, 7);
    expect(find.textContaining('One of 2 stones of the 120 that land the ask.'),
        findsOneWidget);
  });

  testWidgets('the far bank ask ends where the rope runs off the ford',
      (tester) async {
    await open(tester, which: 2);
    await crossByPointer(tester);
    expect(state(tester).play.at, 61);
    expect(state(tester).play.moves, 7);
    expect(find.textContaining('Stone 61, by 2, 3, 5, 7, 11, 17, 31, 61'),
        findsOneWidget);
  });

  testWidgets('the last dry stone leaves nothing in reach', (tester) async {
    await open(tester, which: 3);
    await hopAlong(tester, [3, 5, 7, 13, 23, 43, 83, 113]);
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.stuck, isTrue);
    expect(
        find.text('On stone 113, the rope out to 226: nothing dry left on the ford.'),
        findsOneWidget);
    expect(find.text('nothing dry left'), findsOneWidget);
  });

  testWidgets('the long shallows admit it after three ropes over them',
      (tester) async {
    await open(tester, which: 4);
    await hopAlong(tester, [3, 5, 7, 13, 23, 43, 53, 59, 61]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Not there, not ever.'), findsOneWidget);
    expect(find.textContaining('No crossing ends between 89 and 97.'),
        findsOneWidget);
    expect(find.textContaining('stone 91 is 7 times 13'), findsOneWidget);
  });

  testWidgets('the why tells Bertrand and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Bertrand\'s postulate says there is always one'),
        findsOneWidget);
    expect(find.textContaining('taken in turn'), findsOneWidget);
  });
}
