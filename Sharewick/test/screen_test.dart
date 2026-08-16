import 'package:flutter_test/flutter_test.dart';
import 'package:sharewick/trio/rules.dart';

import 'support/fonts.dart';
import 'support/trioland.dart';

/// One ask on the screen, the trios tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pick ten trios so that every two share a friend'), findsOneWidget);
    expect(find.text('trios 0'), findsOneWidget);
    expect(find.text('none apart'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No trios picked: tap trios so that every two share a friend.'), findsOneWidget);
  });

  testWidgets('taps pick the trios, a pair apart is named, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapTrio(tester, 'ABC');
    expect(Rules.tell(state(tester).play.family), 'ABC');
    expect(find.text('1 trio, every two sharing a friend.'), findsOneWidget);
    expect(find.text('trios 1'), findsOneWidget);
    await tapTrio(tester, 'DEF');
    expect(find.text('2 trios, 1 pair apart, ABC and DEF.'), findsOneWidget);
    expect(find.text('1 apart'), findsOneWidget);
    await press(tester, 'Back');
    expect(Rules.tell(state(tester).play.family), 'ABC');
    await press(tester, 'Back');
    expect(state(tester).play.family, 0);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the ten is picked and the card is shown', (tester) async {
    await open(tester, which: 0);
    await pickAll(tester, ['ABC', 'ABD', 'ACE', 'ADF', 'AEF', 'BCF', 'BDE', 'BEF', 'CDE', 'CDF']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Picked.'), findsOneWidget);
    expect(find.text('As asked. 10 trios, every two sharing a friend.'), findsOneWidget);
    expect(find.textContaining('ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF: 10 trios, every two sharing a friend, by every pair looked at and by one of each missing pair; hands 5 each; one of 1,024 families of the 1,048,576; 10 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Picked.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the trio, and the pointer picks the even hand', (tester) async {
    await open(tester, which: 2);
    await tapTrio(tester, 'DEF');
    await press(tester, 'Show me');
    expect(find.text('Unpick DEF.'), findsOneWidget);
    expect(state(tester).pointing, (Rules.trioOf('DEF'), true));
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 12);
    expect(find.text('As asked. 10 trios, every two sharing a friend.'), findsOneWidget);
    expect(find.textContaining('one of 12 families of the 1,048,576; 12 taps.'), findsOneWidget);
  });

  testWidgets('the star of A', (tester) async {
    await open(tester, which: 1);
    await pickAll(tester, ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 10 trios, every two sharing a friend, all holding A.'), findsOneWidget);
    expect(find.textContaining('hands A 10, B 4, C 4, D 4, E 4, F 4; one of 6 families of the 1,048,576; 10 taps.'), findsOneWidget);
  });

  testWidgets('the fifteen with five pairs apart', (tester) async {
    await open(tester, which: 3);
    await pickAll(tester, ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF', 'BCD', 'BCE', 'BCF', 'BDE', 'BDF']);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 15 trios, 5 pairs apart, ACE and BDF, ACF and BDE and 3 more.'), findsOneWidget);
    expect(find.textContaining('15 trios, 5 pairs apart, ACE and BDF, ACF and BDE and 3 more; hands A 10, B 9, C 7, D 7, E 6, F 6; one of 8,064 families of the 1,048,576; 15 taps.'), findsOneWidget);
  });

  testWidgets('a family short of the ask says where it stands', (tester) async {
    await open(tester, which: 2);
    await pickAll(tester, ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF']);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('10 trios, every two sharing a friend, all holding A.'), findsOneWidget);
    expect(find.text('every two share'), findsOneWidget);
    expect(find.text('trios 10'), findsOneWidget);
  });

  testWidgets('the eleven admits it after three families', (tester) async {
    await open(tester, which: 4);
    await pickAll(tester, ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF', 'BCD']);
    expect(state(tester).play.isOver, isFalse);
    expect(find.text('11 trios, 1 pair apart, AEF and BCD.'), findsOneWidget);
    await pickAll(tester, ['BCD', 'BCE', 'BCE', 'BCF']);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Ten at most, always.'), findsOneWidget);
    expect(find.text('11 trios, 1 pair apart, ADE and BCF. Ten at most, every time.'), findsOneWidget);
    expect(find.textContaining('Here 11 trios have 1 pair apart, ADE and BCF.'), findsOneWidget);
  });

  testWidgets('the why tells Erdos, Ko and Rado and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Erdos, Ko and Rado proved'), findsOneWidget);
    expect(find.textContaining('looked at in full'), findsOneWidget);
  });
}
