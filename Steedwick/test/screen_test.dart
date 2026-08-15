import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One errand on the screen, ridden as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an errand opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('swap the pale steeds for the dark, corners for corners'),
      findsOneWidget,
    );
    expect(find.text('moves 0, fewest 16'), findsOneWidget);
    expect(find.text('round the ring 1 3 4 2'), findsOneWidget);
    expect(find.text('Moves 0; order round the ring 1 3 4 2.'), findsOneWidget);
  });

  testWidgets('a pick shows, a move counts, back undoes', (tester) async {
    await open(tester, which: 3);
    await tapStall(tester, 0);
    expect(state(tester).play.picked, 0);
    expect(
      find.textContaining('Steed 1 picked; tap an empty stall'),
      findsOneWidget,
    );
    await tapStall(tester, 5);
    expect(state(tester).play.standing, [5, 2, 6, 8]);
    expect(find.text('moves 1, fewest 16'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a stall out of a knight\'s reach is refused', (tester) async {
    await open(tester, which: 3);
    await tapStall(tester, 0);
    await tapStall(tester, 4);
    expect(state(tester).play.moves, 0);
    await tapStall(tester, 1);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the errand rides in three and shows the card', (tester) async {
    await open(tester, which: 0);
    await ride(tester, 2, 1);
    await ride(tester, 0, 5);
    await ride(tester, 0, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Ridden.'), findsOneWidget);
    expect(find.text('Ridden: the errand is done in 3 moves.'), findsOneWidget);
    expect(
      find.textContaining('The errand is ridden; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Ridden.'), findsNothing);
  });

  testWidgets('show me rings a steed and a stall', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('to the ringed stall'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer rides the colour swap in sixteen', (tester) async {
    await open(tester, which: 3);
    await rideByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 16);
  });

  testWidgets('the hopeless errand cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    for (var i = 0; i < 6; i++) {
      await ride(tester, 0, 5);
      await ride(tester, 0, 0);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The pale swap never comes.'), findsOneWidget);
    expect(
      find.textContaining('steeds on a ring keep their order'),
      findsOneWidget,
    );
  });

  testWidgets('the why walks the ring', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('it runs round in one ring'),
      findsOneWidget,
    );
    expect(
      find.textContaining('reaches 280 standings'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the colour swap names Guarini', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Guarini\'s puzzle of 1512'),
      findsOneWidget,
    );
    expect(
      find.textContaining('4,726,784 fewest rides'),
      findsOneWidget,
    );
  });
}
