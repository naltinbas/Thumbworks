import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/showland.dart';

/// One show on the screen, judged as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a show opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('rank the three pies so the majority runs in a ring'), findsOneWidget);
    expect(find.text('winner apple'), findsOneWidget);
    expect(find.text('no ring'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.text('Apple beats every other pie, somebody\'s first, and top on points: 6.'), findsOneWidget);
  });

  testWidgets('a tap moves a pie up, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPie(tester, 1, 2);
    expect(state(tester).play.profile[1], [0, 2, 1]);
    expect(find.text('moves 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.profile[1], [0, 1, 2]);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('the ring lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setBallot(tester, 1, [1, 2, 0]);
    await setBallot(tester, 2, [2, 0, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Judged.'), findsOneWidget);
    expect(find.text('a ring'), findsNothing);
    expect(find.text('As asked: Apple beats bramble 2 to 1, bramble beats cherry 2 to 1, cherry beats apple 2 to 1: a ring.'), findsOneWidget);
    expect(find.textContaining('apple over bramble over cherry over apple, though every judge ranked the pies straight'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Judged.'), findsNothing);
  });

  testWidgets('show me names the pie and the judge', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (1, 1));
    expect(find.text('Move bramble up on the miller\'s card.'), findsOneWidget);
  });

  testWidgets('the pointer judges the modest winner of four', (tester) async {
    await open(tester, which: 3);
    await judgeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked: Bramble beats every other pie, first on no ballot, and top on points: 6.'), findsOneWidget);
    expect(find.textContaining('Bramble beats every other pie head to head, and is first on no ballot'), findsOneWidget);
  });

  testWidgets('the points betray, by the pointer', (tester) async {
    await open(tester, which: 2);
    await judgeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('but not top on points'), findsOneWidget);
  });

  testWidgets('the modest winner never comes', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await tapPie(tester, k % 3, 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The modest winner never comes.'), findsOneWidget);
    expect(find.textContaining('beating both takes two of each, four'), findsOneWidget);
  });

  testWidgets('the why counts the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('12 of the 216 shows, exactly when the three ballots are the three turnings of one ranking'), findsOneWidget);
    expect(find.textContaining('that pie is somebody\'s first in all 204'), findsOneWidget);
  });
}
