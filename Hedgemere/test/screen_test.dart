import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hedgeland.dart';

/// One ask on the screen, the hedge stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining(
            'peel the hedge down to a single middle post in 2 rounds'),
        findsOneWidget);
    expect(find.text('middle 3 and 4'), findsOneWidget);
    expect(find.text('rounds 2'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('The hedge peels to posts 3 and 4 in 2 rounds.'),
        findsOneWidget);
  });

  testWidgets('a post hangs off the next one along, and back undoes',
      (tester) async {
    await open(tester, which: 3);
    await step(tester, 5, -1);
    expect(state(tester).play.hanging, [2, 3, 2, 4, 6]);
    expect(find.text('taps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.hanging, [2, 3, 3, 4, 6]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a step off the end of a dial leaves the go where it was',
      (tester) async {
    await open(tester, which: 3);
    await step(tester, 3, 1);
    expect(state(tester).play.hanging, [2, 3, 3, 4, 6]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the middle post lands in a tap and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await setHanging(tester, [2, 3, 3, 4, 5]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Peeled.'), findsOneWidget);
    expect(find.text('As asked. The hedge peels to post 3 in 2 rounds.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The hedge 3 off 2, 4 off 3, 5 off 3, 6 off 4, 7 off 5 peels to '
            'post 3 in 2 rounds, and walking outward from every post names '
            'the same post; one of 378 hangings of the 720 that land it; '
            '1 tap.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Peeled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the post, and the pointer lands the long hedge',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Hang post 3 off the post before.'), findsOneWidget);
    expect(state(tester).pointing, (0, -1));
    await peelByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.hanging, [1, 2, 3, 4, 6]);
    expect(state(tester).play.moves, 2);
    expect(find.textContaining('one of 32 hangings of the 720 that land it; '
        '2 taps.'), findsOneWidget);
  });

  testWidgets('the even hedge leaves two posts standing after one round',
      (tester) async {
    await open(tester, which: 2);
    await setHanging(tester, [2, 2, 2, 2, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. The hedge peels to posts 2 and 6 in 1 round.'),
        findsOneWidget);
    expect(find.textContaining('names the same posts; one of 82 hangings'),
        findsOneWidget);
  });

  testWidgets('the round bush takes eight taps', (tester) async {
    await open(tester, which: 3);
    await setHanging(tester, [2, 2, 2, 2, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 8);
    expect(find.textContaining('one of 2 hangings of the 720 that land it; '
        '8 taps.'), findsOneWidget);
  });

  testWidgets('a hedge short of the ask says what it peels to',
      (tester) async {
    await open(tester, which: 1);
    await setHanging(tester, [2, 2, 2, 2, 2]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('middle 2'), findsOneWidget);
    expect(find.text('rounds 1'), findsOneWidget);
  });

  testWidgets('the three middles gives itself up after four hedges',
      (tester) async {
    await open(tester, which: 4);
    await setHanging(tester, [1, 2, 2, 3, 6]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One or two, never three.'), findsOneWidget);
    expect(
        find.textContaining(
            'Peeling takes a step off each end of the longest walk'),
        findsOneWidget);
    expect(
        find.textContaining(
            'A walk of an even number of steps has one post halfway and a '
            'walk of an odd number has two'),
        findsOneWidget);
  });

  testWidgets('the why tells the peeling and the man who wrote it down',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Camille Jordan wrote this down in 1869'),
        findsOneWidget);
    expect(
        find.textContaining(
            'walks outward from every post in turn and keeps the ones whose '
            'worst walk is shortest'),
        findsOneWidget);
  });
}
