import 'package:flutter_test/flutter_test.dart';
import 'package:feltmere/hat/levels.dart';

import 'support/fonts.dart';
import 'support/hatland.dart';

/// One ask on the screen, the cells turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with everybody quiet', (tester) async {
    await open(tester, which: 3);
    expect(find.textContaining('agree a rule that wins 6 of the eight hattings'),
        findsOneWidget);
    expect(find.text('0 of 8 won'), findsOneWidget);
    expect(find.text('0 words, 0 wrong'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(
        find.textContaining('The village wins 0 of the eight hattings and loses BBB'),
        findsOneWidget);
  });

  testWidgets('a tap turns a cell round, and back undoes it', (tester) async {
    await open(tester, which: 3);
    await tapCell(tester, 0, 0);
    expect(state(tester).play.agreement[0][0], 0);
    expect(find.text('1 word, 1 wrong'), findsOneWidget);
    await tapCell(tester, 0, 0);
    expect(state(tester).play.agreement[0][0], 1);
    await press(tester, 'Back');
    expect(state(tester).play.agreement[0][0], 0);
  });

  testWidgets('the six is landed by the matching rule', (tester) async {
    await open(tester, which: 3);
    await setAgreement(tester, Levels.at(3).aim);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.wins, 6);
    expect(find.text('Agreed.'), findsOneWidget);
    expect(
        find.textContaining('The village wins 6 of the eight hattings and loses'),
        findsWidgets);
    expect(find.textContaining('One of 4 agreements of the 531,441'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Agreed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the cell, and the pointer lands the five',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.textContaining('Set Ash on'), findsOneWidget);
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.wins, 5);
    expect(state(tester).play.moves, 5);
  });

  testWidgets('the silent one wants a villager who never speaks',
      (tester) async {
    await open(tester, which: 1);
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.wins, 4);
    expect(find.textContaining('One of 2652 agreements'), findsOneWidget);
  });

  testWidgets('the seven admits it once the six has been found twice',
      (tester) async {
    await open(tester, which: 4);
    await setAgreement(tester, Levels.at(3).aim);
    expect(state(tester).play.wins, 6);
    expect(state(tester).play.gaveUp, isFalse);
    // The matching rule, which is a different one of the four sixes.
    await setAgreement(tester, const [
      [1, 2, 2, 0],
      [1, 2, 2, 0],
      [1, 2, 2, 0],
    ]);
    expect(state(tester).play.wins, 6);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Six is the ceiling.'), findsOneWidget);
    expect(find.textContaining('Seven is not to be had.'), findsOneWidget);
  });

  testWidgets('the why tells Ebert and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Todd Ebert asked the question in 1998'),
        findsOneWidget);
    expect(find.textContaining('before the sham was built'), findsOneWidget);
  });
}
