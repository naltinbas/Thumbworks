import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// One cording on the screen, pegged as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a cording opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('set four pegs whose midpoint figure is a rectangle'),
      findsOneWidget,
    );
    expect(find.text('pegs 0 of 4'), findsOneWidget);
    expect(find.text('figure unfinished'), findsOneWidget);
    expect(
      find.text('Pegs 0 of 4; tap the next hole, or the last peg to lift it.'),
      findsOneWidget,
    );
  });

  testWidgets('pegs set, the figure reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(0, 0), (4, 0), (4, 2), (0, 2)]);
    expect(find.text('figure a rhombus'), findsOneWidget);
    expect(find.text('The midpoint figure is a rhombus.'), findsOneWidget);
    expect(find.text('diagonals 20 and 20 squared, dot -12'), findsOneWidget);
    await tapHole(tester, (0, 2));
    expect(state(tester).play.pegs, hasLength(3));
    await press(tester, 'Back');
    expect(state(tester).play.pegs, hasLength(4));
  });

  testWidgets('a given peg takes no tap', (tester) async {
    await open(tester, which: 3);
    await tapHole(tester, (4, 3));
    expect(state(tester).play.moves, 0);
    expect(find.text('pegs 3 of 4'), findsOneWidget);
  });

  testWidgets('the square cords land and show the card', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(0, 0), (4, 0), (4, 4), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Landed: the midpoint figure is a square.'), findsOneWidget);
    expect(
      find.textContaining('The midpoint figure is a square; 4 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a hole', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('set', (1, 4)));
    expect(find.text('Set the next peg in the ringed hole.'), findsOneWidget);
  });

  testWidgets('the pointer lands the even cords', (tester) async {
    await open(tester, which: 1);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the hopeless cording cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 2)]);
    expect(find.text('figure a parallelogram'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await setPegs(tester, [(1, 2), (1, 2)]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The figure is never skew.'), findsOneWidget);
    expect(
      find.textContaining('two to a diagonal, equal and parallel'),
      findsOneWidget,
    );
  });

  testWidgets('the why halves the diagonal', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('half the diagonal from the first peg to the third'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a parallelogram every time'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the cross cords reads two ways', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('every figure is read two ways that must agree'),
      findsOneWidget,
    );
    expect(
      find.textContaining('27,952 ordered fours'),
      findsOneWidget,
    );
  });
}
