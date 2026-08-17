import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/roostland.dart';

/// One ask on the screen, the birds moved as a thumb would move them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('settle the four birds of the two thickets'),
        findsOneWidget);
    expect(find.text('crowded 2'), findsOneWidget);
    expect(find.text('settles 9 of 16'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Crowded: A, D.'), findsOneWidget);
  });

  testWidgets('a tap sends one bird across, and back brings it home',
      (tester) async {
    await open(tester, which: 0);
    expect(state(tester).play.at, [0, 0, 3, 3]);
    await tapBird(tester, 0);
    expect(state(tester).play.at, [1, 0, 3, 3]);
    expect(find.text('taps 1'), findsOneWidget);
    expect(find.text('crowded 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.at, [0, 0, 3, 3]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('tapping a hollow rather than a bird does nothing and says so',
      (tester) async {
    await open(tester, which: 0);
    // Hollow C holds no bird at the opening, so the tap lands on nothing.
    await tester.tapAt(hollowAt(tester, 2));
    await tester.pumpAndSettle();
    expect(state(tester).play.taps, 0);
    expect(
        find.textContaining('A hollow does not move'), findsOneWidget);
  });

  testWidgets('the two thickets settle in two taps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 2);
    expect(find.text('Settled.'), findsOneWidget);
    expect(find.textContaining('One of 9 seatings of the 16'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Settled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the bird and the hollow it flies to',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Tap bird '), findsOneWidget);
    expect(find.textContaining('flies across to'), findsOneWidget);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 3);
  });

  testWidgets('the two rings come out in two taps', (tester) async {
    await open(tester, which: 2);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 2);
    expect(find.textContaining('One of 4 seatings of the 64'), findsOneWidget);
  });

  testWidgets('the hub opens with all six birds in one hollow and takes five',
      (tester) async {
    await open(tester, which: 3);
    expect(state(tester).play.at, [0, 0, 0, 0, 0, 0]);
    expect(find.text('crowded 1'), findsOneWidget);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 5);
    // Only the doubled tether between A and B is free; the four birds
    // hung off A have nowhere else to go, so C, D, E and F are forced.
    expect(state(tester).play.at.sublist(2), [2, 3, 4, 5]);
    expect(state(tester).play.at.sublist(0, 2).toSet(), {0, 1});
    expect(find.textContaining('One of 2 seatings of the 64'), findsOneWidget);
  });

  testWidgets('the shared tether gives itself up and shows the patch',
      (tester) async {
    await open(tester, which: 4);
    for (final bird in [0, 1, 2, 3, 4, 5, 0, 1]) {
      await tapBird(tester, bird);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The patch is overfull.'), findsOneWidget);
    expect(find.textContaining('Hollows A and B are the whole of it'),
        findsOneWidget);
    expect(find.textContaining('3 birds have both of their hollows in there'),
        findsOneWidget);
  });

  testWidgets('the why tells the rule, the paper and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
        find.textContaining(
            'If those birds ever outnumber the hollows, the wood cannot '
            'settle'),
        findsOneWidget);
    expect(find.textContaining('Pagh and Rodler published in 2001'),
        findsOneWidget);
    expect(find.textContaining('12,204,240'), findsOneWidget);
  });
}
