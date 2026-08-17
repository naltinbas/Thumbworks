import 'package:flutter_test/flutter_test.dart';

import 'support/caskland.dart';
import 'support/fonts.dart';

/// One ask on the screen, the run stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pour a run of casks that passes 1 barrel'),
        findsOneWidget);
    expect(find.text('total 7/12'), findsOneWidget);
    expect(find.text('deepest 4'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(
        find.text('The run a 3rd to a 4th comes to 7/12 of a barrel, and the '
            '4th cask holds the most twos.'),
        findsOneWidget);
  });

  testWidgets('an end steps a cask at a time, and back undoes', (tester) async {
    await open(tester, which: 3);
    await step(tester, 'last', 1);
    expect((state(tester).play.first, state(tester).play.last), (3, 5));
    expect(find.text('total 47/60'), findsOneWidget);
    expect(find.text('deepest 4'), findsOneWidget);
    await press(tester, 'Back');
    expect((state(tester).play.first, state(tester).play.last), (3, 4));
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a run that cannot be made leaves the go where it was',
      (tester) async {
    await open(tester, which: 3);
    await step(tester, 'first', 1);
    expect((state(tester).play.first, state(tester).play.last), (3, 4));
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('past one lands in a tap and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setRun(tester, 2, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Poured.'), findsOneWidget);
    expect(
        find.text('As asked. The run a 2nd to a 4th comes to 13/12 of a '
            'barrel, and the 4th cask holds the most twos.'),
        findsOneWidget);
    expect(
        find.textContaining('The run a 2nd to a 4th, 3 casks, comes to 13/12 '
            'of a barrel, added cask by cask and again over a common bottom; '
            'one of 683 runs of the 1,770 that land it; 1 tap.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Poured.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the end, and the pointer lands the halves',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Take the first cask one back up.'), findsOneWidget);
    expect(state(tester).pointing, ('first', -1));
    await pourByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.first, state(tester).play.last), (1, 2));
    expect(state(tester).play.moves, 4);
    expect(
        find.textContaining(
            'comes to 3/2 of a barrel, added cask by cask and again over a '
            'common bottom; the only run of the 1,770 that lands it; 4 taps.'),
        findsOneWidget);
  });

  testWidgets('the eleventh cask carries the run past three barrels',
      (tester) async {
    await open(tester, which: 3);
    await setRun(tester, 1, 11);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Poured.'), findsOneWidget);
    expect(
        find.textContaining('The run a 1st to an 11th, 11 casks, comes to '
            '83711/27720 of a barrel'),
        findsOneWidget);
  });

  testWidgets('a run short of the ask says what it came to', (tester) async {
    await open(tester, which: 1);
    await setRun(tester, 1, 3);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('total 11/6'), findsOneWidget);
    expect(find.text('deepest 2'), findsOneWidget);
  });

  testWidgets('the whole barrel gives itself up after four runs',
      (tester) async {
    await open(tester, which: 4);
    await setRun(tester, 1, 6);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never whole.'), findsOneWidget);
    expect(
        find.textContaining(
            'Every run has one deepest cask and no run has two'),
        findsOneWidget);
    expect(
        find.textContaining('so over a common bottom it alone divides in an '
            'odd number of times'),
        findsOneWidget);
  });

  testWidgets('the why tells the twos and the two who wrote it down',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Jozsef Kurschak wrote it down in 1918'),
        findsOneWidget);
    expect(find.textContaining('every cask but that deepest one divides into '
        'it an even number of times'), findsOneWidget);
  });
}
