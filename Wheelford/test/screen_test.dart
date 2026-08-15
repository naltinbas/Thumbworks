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
      find.textContaining('cord three pegs into a triangle with a square corner'),
      findsOneWidget,
    );
    expect(find.text('pegs 0 of 3'), findsOneWidget);
    expect(find.text('Pegs 0 of 3; tap a rim peg.'), findsOneWidget);
  });

  testWidgets('pegs cord, the corner reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await cordAll(tester, [(5, 0), (4, 3), (3, 4)]);
    expect(find.text('a blunt corner'), findsOneWidget);
    expect(find.text('diameters 0'), findsOneWidget);
    expect(find.text('A blunt corner, no diameter among the cords.'), findsOneWidget);
    await tapPeg(tester, (3, 4));
    expect(state(tester).play.pegs, hasLength(2));
    await press(tester, 'Back');
    expect(state(tester).play.pegs, hasLength(3));
  });

  testWidgets('a given peg takes no tap', (tester) async {
    await open(tester, which: 3);
    await tapPeg(tester, (5, 0));
    expect(state(tester).play.moves, 0);
    expect(find.text('pegs 2 of 3'), findsOneWidget);
  });

  testWidgets('the right corner lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await cordAll(tester, [(-5, 0), (5, 0), (3, 4)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('square corner at peg 3'), findsOneWidget);
    expect(find.text('diameters 1'), findsOneWidget);
    expect(
      find.textContaining('The cording stands as asked; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a peg', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Cord the ringed peg.'), findsOneWidget);
  });

  testWidgets('the pointer lands the square wheel', (tester) async {
    await open(tester, which: 2);
    await cordByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('Landed: four pegs into a square'), findsOneWidget);
  });

  testWidgets('the hopeless cording cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    await cordAll(tester, [(-5, 0), (5, 0), (3, 4)]);
    expect(find.text('Square at peg 3, across a diameter.'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await cordAll(tester, [(3, 4), (3, 4)]);
    }
    await tapPeg(tester, (3, 4));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The far cord is always a diameter.'), findsOneWidget);
    expect(
      find.textContaining('square exactly when the cord across it runs through the hub'),
      findsOneWidget,
    );
  });

  testWidgets('the why splits the triangle', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the triangle splits into two with two equal sides each'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Thales, both ways, on all 220'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the right corner reads two ways', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('every corner is read two ways that must agree'),
      findsOneWidget,
    );
    expect(
      find.textContaining('six diameters, and ten other pegs'),
      findsOneWidget,
    );
  });
}
