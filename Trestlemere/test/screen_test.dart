import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tableland.dart';

/// One ask on the screen, the guests moved as a thumb would move them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('seat the guests at 3 tables'), findsWidgets);
    expect(find.text('tables 1 of 3'), findsOneWidget);
    expect(find.text('seatings 90 of 203'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.textContaining('1 table laid'), findsOneWidget);
  });

  testWidgets('a guest is picked up, moved, and the move taken back',
      (tester) async {
    await open(tester, which: 0);
    await tapGuest(tester, 0);
    expect(state(tester).holding, 0);
    expect(find.textContaining('A is up'), findsOneWidget);
    await tester.tapAt(trestleAt(tester, 1));
    await tester.pumpAndSettle();
    expect(state(tester).play.laid, 2);
    expect(find.text('moves 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.laid, 1);
  });

  testWidgets('tapping a trestle with nobody in hand says so', (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(trestleAt(tester, 3));
    await tester.pumpAndSettle();
    expect(state(tester).play.moves, 0);
    expect(find.textContaining('Tap a guest first'), findsOneWidget);
  });

  testWidgets('the three tables are seated in two moves and the card shows',
      (tester) async {
    await open(tester, which: 0);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(state(tester).play.laid, 3);
    expect(find.text('Seated.'), findsOneWidget);
    expect(find.textContaining('One of 90 seatings of the 203'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Seated.'), findsNothing);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('the three sizes come out one, two and three', (tester) async {
    await open(tester, which: 1);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.sizes, [1, 2, 3]);
    expect(find.textContaining('One of 60 seatings'), findsOneWidget);
  });

  testWidgets('the three pairs come out two, two and two', (tester) async {
    await open(tester, which: 2);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.sizes, [2, 2, 2]);
    expect(state(tester).play.moves, 4);
    expect(find.textContaining('One of 15 seatings'), findsOneWidget);
  });

  testWidgets('show me names a guest and a trestle', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.textContaining('Move '), findsOneWidget);
    expect(find.textContaining('trestle'), findsWidgets);
  });

  testWidgets('the four sizes gives itself up on the adding', (tester) async {
    await open(tester, which: 4);
    for (final step in const [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
      (1, 0)]) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('There are not enough guests.'), findsOneWidget);
    expect(find.textContaining('That is 10 guests and there are 6'),
        findsOneWidget);
  });

  testWidgets('the why names Stirling and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Stirling counted these'), findsOneWidget);
    expect(find.textContaining('203'), findsWidgets);
  });
}
