import 'package:flutter_test/flutter_test.dart';

import 'support/almsland.dart';
import 'support/fonts.dart';

/// One ask on the screen, the grain shared as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 2);
    expect(
        find.textContaining('share the grain out until the bins stand 4, 3, '
            '2, 1, 0'),
        findsOneWidget);
    expect(find.text('shape 9, 1, 0, 0, 0'), findsOneWidget);
    expect(find.text('totals 9, 10, 10, 10, 10'), findsOneWidget);
    expect(find.text('shares 0'), findsOneWidget);
    expect(
        find.text('The bins stand 9, 1, 0, 0, 0, running totals 9, 10, 10, '
            '10, 10.'),
        findsOneWidget);
  });

  testWidgets('a lift and a drop make one share, and back undoes it',
      (tester) async {
    await open(tester, which: 2);
    await tapBin(tester, 4);
    expect(state(tester).play.holding, 4);
    expect(find.text('shares 0'), findsOneWidget);
    await tapBin(tester, 0);
    expect(state(tester).play.bins, [1, 0, 0, 1, 8]);
    expect(find.text('shares 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.bins, [0, 0, 0, 1, 9]);
    expect(find.text('shares 0'), findsOneWidget);
  });

  testWidgets('a bin with nothing to give says so', (tester) async {
    await open(tester, which: 2);
    await tapBin(tester, 3);
    expect(state(tester).play.holding, isNull);
    expect(
        find.text('Bin 4 is not two ahead of any other, so it has nothing to '
            'give.'),
        findsOneWidget);
  });

  testWidgets('a drop into a bin too close says so', (tester) async {
    await open(tester, which: 2);
    await tapBin(tester, 4);
    await tapBin(tester, 3);
    expect(state(tester).play.bins, [0, 0, 0, 2, 8]);
    await tapBin(tester, 3);
    await tapBin(tester, 4);
    expect(
        find.text('Bin 4 is not two ahead of bin 5, so the measure stays '
            'where it is.'),
        findsOneWidget);
  });

  testWidgets('three small heaps land in two shares and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await share(tester, 4, 0);
    await share(tester, 4, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Shared.'), findsOneWidget);
    expect(
        find.text('As asked. The bins stand 7, 1, 1, 1, 0, running totals 7, '
            '8, 9, 10, 10.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The bins stand 1, 1, 0, 1, 7, which is the shape 7, 1, 1, 1, 0, '
            'and their running totals are 7, 8, 9, 10, 10; one of 20 '
            'arrangements of the 1,001 that stand that way; 2 shares.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Shared.'), findsNothing);
    expect(find.text('shares 0'), findsOneWidget);
  });

  testWidgets('show me names the bin, and the pointer lands the level field',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.textContaining('Take a measure out of bin '), findsOneWidget);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.bins, [2, 2, 2, 2, 2]);
    expect(state(tester).play.moves, 7);
    expect(
        find.textContaining(
            'Nothing can move from here: no bin is two ahead of another.'),
        findsOneWidget);
  });

  testWidgets('the even halves take four shares', (tester) async {
    await open(tester, which: 1);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.textContaining('one of 10 arrangements of the 1,001'),
        findsOneWidget);
  });

  testWidgets('the one heap gives itself up after four arrangements',
      (tester) async {
    await open(tester, which: 4);
    for (final to in [0, 1, 2, 3]) {
      await share(tester, 4, to);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The fullest never rises.'), findsOneWidget);
    expect(
        find.text('A share takes from the fuller bin, so the fullest bin can '
            'only come down, and it has.'),
        findsOneWidget);
    expect(
        find.textContaining('Once grain has been spread it cannot be '
            'gathered.'),
        findsOneWidget);
  });

  testWidgets('the why tells majorization and the two voices', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('This is majorization'), findsOneWidget);
    expect(
        find.textContaining(
            'it compares the running totals, which moves no grain at all'),
        findsOneWidget);
  });
}
