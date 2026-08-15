import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/villageland.dart';

/// One village on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a village opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the fever and the test so a flagged villager is ill exactly one time in two'), findsOneWidget);
    expect(find.text('fever 1 in 2'), findsOneWidget);
    expect(find.text('flag right 90.00 in 100'), findsOneWidget);
    expect(find.text('settings 0'), findsOneWidget);
    expect(find.text('Fever one in 2, catch nine in ten, alarm one in ten: a flag is right 9 times in 10, 90.00 in a hundred.'), findsOneWidget);
  });

  testWidgets('a dial is set, and back undoes', (tester) async {
    await open(tester, which: 1);
    await tapDial(tester, 0, 3);
    expect(state(tester).play.oneIn, 20);
    expect(find.text('fever 1 in 20'), findsOneWidget);
    expect(find.text('settings 1'), findsOneWidget);
    expect(state(tester).play.isDone, isFalse);
    await tapDial(tester, 0, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.oneIn, 20);
    expect(find.text('settings 1'), findsOneWidget);
  });

  testWidgets('the even chance lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setVillage(tester, 5, 2, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Set.'), findsOneWidget);
    expect(find.text('As asked. Fever one in 100, catch ninety-nine in a hundred, alarm one in a hundred: a flag is right 1 time in 2, 50.00 in a hundred.'), findsOneWidget);
    expect(find.textContaining('99000 ill flagged against 99000 well, so a flag is right 1 time in 2; 3 settings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Set.'), findsNothing);
  });

  testWidgets('show me names the dial', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (0, 8));
    expect(find.text('Set the fever at one in 1000.'), findsOneWidget);
  });

  testWidgets('the pointer sets the coin toss fever', (tester) async {
    await open(tester, which: 3);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('9990 ill flagged against 9990 well'), findsOneWidget);
  });

  testWidgets('the rare fever trusted needs the alarm off', (tester) async {
    await open(tester, which: 2);
    await setVillage(tester, 8, 2, 2);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('flag right 9.01 in 100'), findsOneWidget);
    await tapDial(tester, 2, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('a flag is right 1 time in 1, 100.00 in a hundred'), findsOneWidget);
  });

  testWidgets('the sure flag never comes with the alarm on', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await tapDial(tester, 0, k % 2 == 0 ? 1 : 0);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The flag is never sure.'), findsOneWidget);
    expect(find.textContaining('the well outnumber the ill on every setting'), findsOneWidget);
  });

  testWidgets('the why counts the village', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the two agreeing on all 225'), findsOneWidget);
    expect(find.textContaining('45 settings make the flag sure, every one with the alarm at none'), findsOneWidget);
  });
}
