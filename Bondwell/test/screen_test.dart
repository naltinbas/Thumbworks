import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/bondland.dart';

/// One ask on the screen, the coins dropped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with the chest full', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('divide 12 coins so that every scale hangs level'),
        findsOneWidget);
    expect(find.text('chest 12'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('3 of 3 scales level'), findsOneWidget);
    expect(
        find.text('The purses hold 0, 0, 0 with 12 left in the chest. Every scale hangs level.'),
        findsOneWidget);
  });

  testWidgets('a tap on a purse drops a coin in, and back takes it out',
      (tester) async {
    await open(tester, which: 0);
    await tapPurse(tester, 0);
    expect(state(tester).play.purses, [1, 0, 0]);
    expect(find.text('chest 11'), findsOneWidget);
    expect(find.text('taps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.purses, [0, 0, 0]);
  });

  testWidgets('a scale out of true says who is short', (tester) async {
    await open(tester, which: 0);
    await setPurses(tester, [3, 0, 0]);
    expect(
        find.textContaining('A and B are 1 1/2 out, B short'),
        findsOneWidget);
    expect(find.text('1 of 3 scales level'), findsOneWidget);
  });

  testWidgets('the small estate goes equally', (tester) async {
    await open(tester, which: 0);
    await setPurses(tester, [4, 4, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('All three level.'), findsOneWidget);
    expect(
        find.textContaining('12 coins go 4, 4, 4, which is 33 1/3, 33 1/3, 33 1/3 zuz'),
        findsOneWidget);
    expect(find.textContaining('only one of the 91 divisions that does it'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('All three level.'), findsNothing);
    expect(find.text('chest 12'), findsOneWidget);
  });

  testWidgets('the middling estate goes 6, 9 and 9', (tester) async {
    await open(tester, which: 1);
    await divideByPointer(tester);
    expect(state(tester).play.purses, [6, 9, 9]);
    expect(state(tester).play.moves, 8);
    expect(find.textContaining('24 coins go 6, 9, 9, which is 50, 75, 75 zuz'),
        findsOneWidget);
  });

  testWidgets('show me names the purse and the coins', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Put 3 coins in A\'s purse.'), findsOneWidget);
    await divideByPointer(tester);
    expect(state(tester).play.purses, [6, 12, 18]);
    expect(find.textContaining('50, 100, 150 zuz'), findsOneWidget);
  });

  testWidgets('the long bond ask admits it after three tries', (tester) async {
    await open(tester, which: 4);
    await setPurses(tester, [0, 0, 12]);
    await setPurses(tester, [0, 3, 9]);
    await setPurses(tester, [3, 3, 6]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The long bond gains nothing.'), findsOneWidget);
    expect(
        find.textContaining('No division of 12 coins puts the longest bond ahead'),
        findsOneWidget);
  });

  testWidgets('the why tells the Mishnah and the table', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Bava Metzia 1:1'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
