import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lineland.dart';

/// One ask on the screen, the pegs moved as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the pegs so the orthocentre sits on a corner of the triangle'), findsOneWidget);
    expect(find.text('acute'), findsOneWidget);
    expect(find.text('O inside'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.text('Acute triangle, sides squared 17, 13 and 10: G (8/3, 7/3), O (63/22, 45/22) inside, H (25/11, 32/11), in a line, HG twice GO.'), findsOneWidget);
  });

  testWidgets('a tap lifts a peg, a tap sets it down, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, (1, 1));
    expect(state(tester).play.held, 0);
    expect(find.text('Peg A lifted: tap a peg of the field to set it down, or tap it again to leave it.'), findsOneWidget);
    await tapPeg(tester, (0, 0));
    expect(state(tester).play.pegs, [(0, 0), (5, 2), (2, 4)]);
    expect(find.text('moves 1'), findsOneWidget);
    expect(find.text('Acute triangle, sides squared 29, 20 and 13: G (7/3, 2), O (19/8, 21/16) inside, H (9/4, 27/8), in a line, HG twice GO.'), findsOneWidget);
    expect(find.text('O inside'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.held, 0);
    await press(tester, 'Back');
    expect(state(tester).play.pegs, [(1, 1), (5, 2), (2, 4)]);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('a line of three is refused', (tester) async {
    await open(tester, which: 0);
    await movePeg(tester, 0, (0, 0));
    await tapPeg(tester, (5, 2));
    await tapPeg(tester, (1, 2));
    expect(state(tester).play.pegs, [(0, 0), (5, 2), (2, 4)]);
    expect(state(tester).play.held, 1);
    expect(find.text('moves 1'), findsOneWidget);
  });

  testWidgets('the right angle lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(0, 0), (1, 0), (0, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.text('In a line.'), findsOneWidget);
    expect(find.text('As asked. Right triangle at A, sides squared 2, 1 and 1: H sits on A, O (1/2, 1/2) halfway along BC, G (1/3, 1/3) between them, HG twice GO.'), findsOneWidget);
    expect(find.textContaining('A (0, 0), B (1, 0), C (0, 1): G (1/3, 1/3), O (1/2, 1/2), H (0, 0); one of 2,960 triangles of the 17,600; 3 moves.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('In a line.'), findsNothing);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('show me names the peg and its place, and the pointer lands the level line', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Move peg A to (0, 0).'), findsOneWidget);
    expect(state(tester).pointing, (0, (0, 0)));
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.text('As asked. Acute triangle, sides squared 18, 16 and 10: G (5/3, 1), O (2, 1) inside, H (1, 1), in a line, HG twice GO.'), findsOneWidget);
    expect(find.textContaining('one of 486 triangles of the 17,600; 3 moves.'), findsOneWidget);
  });

  testWidgets('the far centre lands off the field', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(0, 0), (1, 0), (4, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Obtuse triangle, sides squared 17, 10 and 1: G (5/3, 1/3), O (1/2, 13/2) off the field, H (4, -12), in a line, HG twice GO.'), findsOneWidget);
    expect(find.textContaining('one of 3,656 triangles of the 17,600'), findsOneWidget);
  });

  testWidgets('the whole three lands on the right isosceles', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [(0, 0), (6, 0), (0, 6)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Right triangle at A, sides squared 72, 36 and 36: H sits on A, O (3, 3) halfway along BC, G (2, 2) between them, HG twice GO.'), findsOneWidget);
    expect(find.textContaining('A (0, 0), B (6, 0), C (0, 6): G (2, 2), O (3, 3), H (0, 0); one of 20 triangles of the 17,600'), findsOneWidget);
  });

  testWidgets('the one point admits it at the nearest the field comes', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(0, 0), (4, 1), (1, 4)]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('No equilateral on pegs.'), findsOneWidget);
    expect(find.text('As near as the field comes, sides squared 18, 17 and 17, and the centres still three: G (5/3, 5/3), O (17/10, 17/10), H (8/5, 8/5).'), findsOneWidget);
    expect(find.textContaining('the tangent of sixty degrees is the square root of three'), findsOneWidget);
  });

  testWidgets('the why tells Euler and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Euler showed in 1765'), findsOneWidget);
    expect(find.textContaining('worked exactly'), findsOneWidget);
  });
}
