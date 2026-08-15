import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moorland.dart';

/// One pegging on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a pegging opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('set four pegs with no halfway post on a hole'),
      findsOneWidget,
    );
    expect(find.text('pegs 0 of 4'), findsOneWidget);
    expect(find.text('on holes 0, asked 0'), findsOneWidget);
    expect(find.text('kinds used 0 of 4'), findsOneWidget);
    expect(find.text('Pegs 0 of 4, 0 posts on holes so far.'), findsOneWidget);
  });

  testWidgets('pegs set, the posts read, back undoes', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(0, 0), (2, 0), (1, 1)]);
    expect(find.text('pegs 3 of 4'), findsOneWidget);
    expect(find.text('on holes 1, asked 0'), findsOneWidget);
    expect(find.text('kinds used 2 of 4'), findsOneWidget);
    expect(find.text('Pegs 3 of 4, 1 post on holes so far.'), findsOneWidget);
    await tapHole(tester, (2, 0));
    expect(state(tester).play.pegs, hasLength(2));
    await press(tester, 'Back');
    expect(state(tester).play.pegs, hasLength(3));
  });

  testWidgets('a full moor short of the ask says so', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(0, 0), (2, 0), (1, 1), (3, 3)]);
    expect(state(tester).play.full, isTrue);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('2 posts on holes, 0 asked; kinds used 2 of 4.'), findsOneWidget);
    await tapHole(tester, (4, 4));
    expect(state(tester).play.moves, 4);
  });

  testWidgets('the four apart land and show the card', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(0, 0), (1, 0), (0, 1), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Landed: 0 halfway posts on holes.'), findsOneWidget);
    expect(find.text('kinds used 4 of 4'), findsOneWidget);
    expect(
      find.textContaining('The pegs stand as asked; 4 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a hole', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Set a peg in the ringed hole.'), findsOneWidget);
  });

  testWidgets('show me rings a peg off the aim to lift', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [(3, 3)]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', (3, 3)));
    expect(find.text('Lift the ringed peg: it is off the placing.'), findsOneWidget);
  });

  testWidgets('the pointer lands the ten', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed: 10 halfway posts on holes.'), findsOneWidget);
  });

  testWidgets('the hopeless pegging cracks at thirteen moves', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(0, 0), (1, 0), (0, 1), (1, 1), (4, 4)]);
    expect(find.text('1 post on holes, 0 asked; kinds used 4 of 4.'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await setPegs(tester, [(4, 4), (4, 4)]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Five pegs always land a post.'), findsOneWidget);
    expect(
      find.textContaining('five pegs in four kinds of hole put two in one kind'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the kinds', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Five pegs in four kinds: two share a kind'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the sweep of all 53,130 placings finds one post landed at the least'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four apart reads two ways', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('every halfway post is read two ways that must agree'),
      findsOneWidget,
    );
    expect(
      find.textContaining('9 times 6 times 6 times 4 is 1,296 of the 12,650'),
      findsOneWidget,
    );
  });
}
