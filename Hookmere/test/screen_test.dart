import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hookland.dart';

/// One ask on the screen, the boxes moved as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 1);
    expect(
        find.textContaining(
            'lay the eight boxes in a staircase with exactly 90 fillings'),
        findsOneWidget);
    expect(find.text('fillings 42'), findsOneWidget);
    expect(find.text('hooks multiply to 960'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(
        find.text('The hooks multiply to 960, so the staircase has 42 '
            'fillings.'),
        findsOneWidget);
  });

  testWidgets('a lift and a drop make one move, and back undoes it',
      (tester) async {
    await open(tester, which: 3);
    await tapRow(tester, 2);
    expect(state(tester).play.holding, 2);
    expect(find.text('moves 0'), findsOneWidget);
    await tapRow(tester, 3);
    expect(state(tester).play.rows, [3, 3, 1, 1]);
    expect(find.text('moves 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.rows, [3, 3, 2]);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('a row with no corner says so', (tester) async {
    await open(tester, which: 3);
    await tapRow(tester, 0);
    expect(state(tester).play.holding, isNull);
    expect(
        find.text('Row 1 has a row under it just as long, so its last box is '
            'not on a corner and cannot be lifted.'),
        findsOneWidget);
  });

  testWidgets('a drop that would widen a row below says so', (tester) async {
    await open(tester, which: 3);
    await tapRow(tester, 1);
    await tapRow(tester, 2);
    expect(state(tester).play.rows, [3, 3, 2]);
    expect(
        find.text('A box cannot go there: every row must stay no longer than '
            'the one above it.'),
        findsOneWidget);
  });

  testWidgets('seventy lands in one move and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await shift(tester, 2, 0);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Laid.'), findsOneWidget);
    expect(
        find.text('As asked. The hooks multiply to 576, so the staircase has '
            '70 fillings.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The staircase 4, 3, 1 has hooks 6, 4, 3, 1, 4, 2, 1, 1, which '
            'multiply to 576, and 40320 over that is 70. Counting the '
            'fillings one at a time gives 70 as well; one of 2 staircases of '
            'the 22 that land it; 1 move.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Laid.'), findsNothing);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('show me names the row, and the pointer lands ninety',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Lift a box off row '), findsOneWidget);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.rows, [4, 2, 1, 1]);
    expect(state(tester).play.moves, 2);
    expect(find.textContaining('one of 1 staircase of the 22 that lands it; '
        '2 moves.'), findsOneWidget);
  });

  testWidgets('the single file is five moves off', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(state(tester).play.byHooks, 1);
    expect(find.textContaining('one of 2 staircases of the 22'), findsOneWidget);
  });

  testWidgets('against the hooks gives itself up after four staircases',
      (tester) async {
    await open(tester, which: 4);
    for (final move in [(1, 0), (0, 1), (1, 3), (0, 3)]) {
      await shift(tester, move.$1, move.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The hooks are never wrong.'), findsOneWidget);
    expect(
        find.textContaining('No staircase gets the hooks wrong.'),
        findsOneWidget);
  });

  testWidgets('the why tells the three who published it', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Frame, Robinson and Thrall published it in 1954'),
        findsOneWidget);
    expect(
        find.textContaining(
            'once by the hooks, which counts nothing, and once by taking the '
            'largest number off a corner'),
        findsOneWidget);
  });
}
