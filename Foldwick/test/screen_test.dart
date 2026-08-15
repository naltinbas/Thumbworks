import 'package:flutter_test/flutter_test.dart';

import 'support/foldland.dart';
import 'support/fonts.dart';

/// One crossing on the screen, made as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a crossing opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('pass three sheep and three goats to the other ends'),
      findsOneWidget,
    );
    expect(find.text('moves 0 of 15'), findsOneWidget);
    expect(find.text('may move 2'), findsOneWidget);
    expect(find.text('order SSSGGG'), findsOneWidget);
    expect(find.text('Moves 0; 2 beasts may move.'), findsOneWidget);
  });

  testWidgets('a move counts, a beast off the movers is refused, back undoes',
      (tester) async {
    await open(tester, which: 1);
    await tapPen(tester, 1);
    expect(state(tester).play.plank, 'S_SGG');
    expect(find.text('moves 1 of 8'), findsOneWidget);
    await tapPen(tester, 4);
    expect(state(tester).play.moves, 1);
    await press(tester, 'Back');
    expect(state(tester).play.plank, 'SS_GG');
  });

  testWidgets('a stuck fold says so', (tester) async {
    await open(tester, which: 1);
    await moveAll(tester, [1, 0]);
    expect(find.text('stuck'), findsOneWidget);
    expect(find.text('Stuck: nobody can move. Take a move back.'), findsOneWidget);
  });

  testWidgets('the one and one crosses and shows the card', (tester) async {
    await open(tester, which: 0);
    await moveAll(tester, [0, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Crossed.'), findsOneWidget);
    expect(
      find.text('Crossed: sheep and goats have changed ends in 3 moves.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('3 moves, as every crossing takes.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Crossed.'), findsNothing);
  });

  testWidgets('show me rings a pen', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Move the beast in the ringed pen.'), findsOneWidget);
  });

  testWidgets('the pointer crosses the three and two', (tester) async {
    await open(tester, which: 2);
    await crossByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 11);
  });

  testWidgets('the hopeless crossing cracks when it sticks', (tester) async {
    await open(tester, which: 4);
    await moveAll(tester, [1, 0]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Steps alone never cross.'), findsOneWidget);
    expect(
      find.textContaining('the order along the plank never changes'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the order', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('nobody ever gets past anybody'),
      findsOneWidget,
    );
    expect(
      find.textContaining('five planks in all'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the three and three counts the jumps', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Lucas\'s arithmetic'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nine jumps and six steps'),
      findsOneWidget,
    );
  });
}
