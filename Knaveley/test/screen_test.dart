import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/isleland.dart';

/// One ask on the screen, the villagers named as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with everybody a knight', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('name the 3 villagers so that every telling holds'),
        findsOneWidget);
    expect(find.text('3 of 3 called knights'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.textContaining('caught out'), findsWidgets);
  });

  testWidgets('a tap turns a villager, and back turns them again',
      (tester) async {
    await open(tester, which: 1);
    await tapVillager(tester, 0);
    expect(state(tester).play.kinds, [false, true, true]);
    expect(find.text('taps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.kinds, [true, true, true]);
  });

  testWidgets('the three lands with Birch alone a knight', (tester) async {
    await open(tester, which: 1);
    await nameAll(tester, const [false, true, false]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Every telling holds.'), findsWidgets);
    expect(
        find.textContaining('Alder the knave, Birch the knight, Cedar the knave'),
        findsOneWidget);
    expect(find.textContaining('the only naming of the 8 that does'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the four has two namings that hold', (tester) async {
    await open(tester, which: 2);
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 1);
    expect(find.textContaining('one of 2 namings of the 16 that do'),
        findsOneWidget);
  });

  testWidgets('show me names the villager', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.textContaining('Call '), findsOneWidget);
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
  });

  testWidgets('the paradox admits it after four namings', (tester) async {
    await open(tester, which: 4);
    await tapVillager(tester, 0);
    await tapVillager(tester, 1);
    await tapVillager(tester, 2);
    await tapVillager(tester, 0);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nobody can say it.'), findsOneWidget);
    expect(find.textContaining('No naming holds these tellings'),
        findsOneWidget);
  });

  testWidgets('the why tells Smullyan', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Raymond Smullyan'), findsOneWidget);
    expect(find.textContaining('tried in full before the sham'), findsOneWidget);
  });
}
