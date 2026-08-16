import 'package:flutter_test/flutter_test.dart';
import 'package:kithwell/kith/rules.dart';

import 'support/fonts.dart';
import 'support/fairland.dart';

/// One ask on the screen, the people tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('lay friendships so that everyone has the same number of friends'), findsOneWidget);
    expect(find.text('no friendships'), findsOneWidget);
    expect(find.text('friends none'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No friendships yet: tap a person, then another, to make them friends.'), findsOneWidget);
  });

  testWidgets('a tap holds a person, the next makes the friendship, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPerson(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.text('Ann held: tap another to make or part the friendship, or Ann again to let go.'), findsOneWidget);
    await tapPerson(tester, 1);
    expect(Rules.tell(state(tester).play.plan), 'Ann-Bess');
    expect(find.text('1 friendship, Ann 1, Bess 1, Cal 0, Dot 0, Ed 0, Fay 0: people average 1/3, the friends named 1, a gap of 2/3.'), findsOneWidget);
    expect(find.text('people 1/3'), findsOneWidget);
    expect(find.text('friends 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.held, 0);
    await press(tester, 'Back');
    expect(state(tester).play.plan, 0);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the even fair lands on three pairs and the card is shown', (tester) async {
    await open(tester, which: 0);
    await befriend(tester, [(0, 1), (2, 3), (4, 5)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Befriended.'), findsOneWidget);
    expect(find.text('As asked. 3 friendships, everyone 1: people average 1, the friends named 1, a gap of 0.'), findsOneWidget);
    expect(find.textContaining('Ann-Bess, Cal-Dot, Ed-Fay: everyone 1; people average 1 friends, the friends named 1, by the naming and by the squares, a gap of 0; one of 171 plans of the 32,767; 6 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Befriended.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the friendship, and the pointer lays the star', (tester) async {
    await open(tester, which: 2);
    await befriend(tester, [(1, 2)]);
    await press(tester, 'Show me');
    expect(find.text('Tap Bess, then Cal, to lift their friendship.'), findsOneWidget);
    expect(state(tester).pointing, (1, 2, true));
    await planByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 14);
    expect(find.text('As asked. 5 friendships, Ann 5, Bess 1, Cal 1, Dot 1, Ed 1, Fay 1: people average 1 2/3, the friends named 3, a gap of 1 1/3.'), findsOneWidget);
    expect(find.textContaining('one of 6 plans of the 32,767; 14 taps.'), findsOneWidget);
  });

  testWidgets('the gap of one', (tester) async {
    await open(tester, which: 1);
    await befriend(tester, [(0, 1), (0, 2), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 3 friendships, Ann 3, Bess 1, Cal 1, Dot 1, Ed 0, Fay 0: people average 1, the friends named 2, a gap of 1.'), findsOneWidget);
    expect(find.textContaining('one of 155 plans of the 32,767; 6 taps.'), findsOneWidget);
  });

  testWidgets('the half', (tester) async {
    await open(tester, which: 3);
    await befriend(tester, [(0, 2), (0, 3), (0, 4), (0, 5), (1, 2), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 6 friendships, Ann 4, Bess 2, Cal 2, Dot 2, Ed 1, Fay 1: people average 2, the friends named 2 1/2, a gap of 1/2.'), findsOneWidget);
    expect(find.textContaining('one of 1,080 plans of the 32,767; 12 taps.'), findsOneWidget);
  });

  testWidgets('a plan short of the ask says its two averages', (tester) async {
    await open(tester, which: 2);
    await befriend(tester, [(0, 1), (2, 3)]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('2 friendships, Ann 1, Bess 1, Cal 1, Dot 1, Ed 0, Fay 0: people average 2/3, the friends named 1, a gap of 1/3.'), findsOneWidget);
    expect(find.text('people 2/3'), findsOneWidget);
  });

  testWidgets('the popular few admits it after three even plans', (tester) async {
    await open(tester, which: 4);
    await befriend(tester, [(0, 1), (2, 3), (4, 5)]);
    expect(state(tester).play.isOver, isFalse);
    expect(find.text('3 friendships, everyone 1: people average 1, the friends named 1, a gap of 0.'), findsOneWidget);
    await befriend(tester, [(0, 1), (2, 3), (0, 2), (1, 3), (0, 2), (1, 3), (0, 3), (1, 2)]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never behind, always.'), findsOneWidget);
    expect(find.text('3 friendships, everyone 1: people average 1, the friends named 1, a gap of 0. Never behind, whatever the friendships.'), findsOneWidget);
    expect(find.textContaining('Here people average 1 and the friends named 1, level, as low as it goes.'), findsOneWidget);
  });

  testWidgets('the why tells Feld and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Feld set down in 1991'), findsOneWidget);
    expect(find.textContaining('named in full'), findsOneWidget);
  });
}
