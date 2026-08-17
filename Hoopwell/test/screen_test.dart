import 'package:flutter_test/flutter_test.dart';
import 'package:hoopwell/hoop/rules.dart';

import 'support/fonts.dart';
import 'support/hoopland.dart';

/// One ask on the screen, the stones laid as a thumb would lay them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('lay 3 dark stones and 3 pale so that 6 lamps '
            'light'),
        findsWidgets);
    expect(find.text('stones 1 and 1'), findsOneWidget);
    expect(find.text('lamps 1 of 6'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.textContaining('the floor for 1 and 1 stones is 1'),
        findsOneWidget);
  });

  testWidgets('a tap lays a stone and back lifts it again', (tester) async {
    await open(tester, which: 0);
    await tapHole(tester, 0, 3);
    expect(Rules.at(state(tester).play.dark), [0, 3]);
    expect(find.text('taps 1'), findsOneWidget);
    expect(find.text('stones 2 and 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(Rules.at(state(tester).play.dark), [0]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('tapping a lamp lays nothing and says so', (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(lampAt(tester, 4));
    await tester.pumpAndSettle();
    expect(state(tester).play.taps, 0);
    expect(find.textContaining('The lamps are not tapped'), findsOneWidget);
  });

  testWidgets('the six lands in four taps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 4);
    expect(state(tester).play.lampCount, 6);
    expect(find.text('Lit.'), findsOneWidget);
    expect(find.textContaining('One of 686 boards of the 1225'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Lit.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('every lamp lights the whole hoop', (tester) async {
    await open(tester, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.lampCount, 7);
    expect(find.textContaining('One of 392 boards of the 1225'),
        findsOneWidget);
  });

  testWidgets('the floor lands exactly five lamps', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.lampCount, 5);
    expect(state(tester).play.floor, 5);
    expect(find.textContaining('One of 147 boards of the 735'), findsOneWidget);
    expect(find.textContaining('the floor for 2 and 4 stones is 5'),
        findsOneWidget);
  });

  testWidgets('show me names a hole and whether to lay or lift',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(
        find.textContaining(RegExp('Put a (dark|pale) stone in hole|'
            'Take the (dark|pale) stone out of hole')),
        findsOneWidget);
  });

  testWidgets('four alight gives itself up and shows the walk',
      (tester) async {
    await open(tester, which: 4);
    for (final tap in [(0, 1), (1, 1), (1, 2), (1, 3), (0, 2), (1, 4),
      (1, 5), (0, 3)]) {
      await tapHole(tester, tap.$1, tap.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Under the floor.'), findsOneWidget);
    expect(find.textContaining('The floor for 2 dark stones and 4 pale is 5'),
        findsOneWidget);
    expect(find.textContaining('With the stones the ask calls for, stepping by'),
        findsOneWidget);
    expect(find.textContaining('passes through every hole'), findsWidgets);
  });

  testWidgets('the why tells the floor, the walk and the two dates',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Cauchy proved it in 1813'), findsOneWidget);
    expect(find.textContaining('found Cauchy\'s proof in 1947'),
        findsOneWidget);
    expect(find.textContaining('16,384'), findsOneWidget);
  });
}
