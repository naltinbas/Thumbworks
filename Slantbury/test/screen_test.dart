import 'package:flutter_test/flutter_test.dart';
import 'package:slantbury/pieces/geometry.dart';

import 'support/fonts.dart';
import 'support/buryland.dart';

/// One frame on the screen, laid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a frame opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('lay the four pieces of the eight-square in the thirteen-by-five frame with no overlap'),
      findsOneWidget,
    );
    expect(find.text('laid 0 of 4'), findsOneWidget);
    expect(find.text('overlap 0'), findsOneWidget);
    expect(find.text('bare 65'), findsOneWidget);
    expect(find.text('Laid 0 of 4; tap a piece in the tray to take it up.'), findsOneWidget);
  });

  testWidgets('a piece is taken up, turned, laid, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapSlot(tester, 0);
    expect(state(tester).play.held, 0);
    expect(find.text('A piece in hand: turn or flip it, then tap the square its corner goes on.'), findsOneWidget);
    await press(tester, 'Turn');
    expect(state(tester).play.ways[0], (1, false));
    await press(tester, 'Flip');
    expect(state(tester).play.ways[0], (1, true));
    await tapSquare(tester, 0, 0);
    expect(find.text('laid 1 of 4'), findsOneWidget);
    expect(state(tester).play.cornersOf(0), isNotNull);
    await press(tester, 'Back');
    expect(state(tester).play.laidCount, 0);
    expect(state(tester).play.held, isNull);
  });

  testWidgets('two pieces on one spot go rust, and a laid piece lifts', (tester) async {
    await open(tester, which: 1);
    await tapSlot(tester, 0);
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 1);
    await tapSquare(tester, 0, 0);
    expect(find.text('overlap 12'), findsOneWidget);
    expect(find.text('Pieces overlap by 12 squares, in rust.'), findsOneWidget);
    await tapLaid(tester, 1);
    expect(state(tester).play.held, 1);
    expect(find.text('laid 1 of 4'), findsOneWidget);
    expect(find.text('overlap 0'), findsOneWidget);
  });

  testWidgets('the frame lays and shows the card, one square bare', (tester) async {
    await open(tester, which: 1);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.gap, Q.one);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Laid: no overlap and 1 square bare.'), findsOneWidget);
    expect(
      find.textContaining('Every piece lies inside the frame, none overlapping and 1 square bare; 4 layings.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me takes the piece up, turns it and ghosts the laying', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lay', 0));
    expect(state(tester).play.held, 0);
    expect(find.text('Lay it with its corner on the ringed square, as the ghost shows.'), findsOneWidget);
    await tapSquare(tester, 1, 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 0));
    expect(find.text('Lift the ringed piece; it is off the laying.'), findsOneWidget);
  });

  testWidgets('the small frame lays with an overlap of one', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('overlap 1'), findsOneWidget);
    expect(find.text('Laid: an overlap of 1 and no square bare.'), findsOneWidget);
  });

  testWidgets('the hopeless frame shows the sliver', (tester) async {
    await open(tester, which: 4);
    await tapSlot(tester, 0);
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 1);
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await tapSquare(tester, 5, 2);
    await tapSlot(tester, 2);
    await press(tester, 'Turn');
    await press(tester, 'Flip');
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 3);
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await press(tester, 'Flip');
    await tapSquare(tester, 8, 0);
    expect(state(tester).play.sliverShown, isTrue);
    expect(find.text('The sliver stays.'), findsOneWidget);
    expect(
      find.textContaining('sixty-four squares of pieces in a frame of sixty-five'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the squares', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('The frame is 13 by 5, 65 squares, and the four pieces have 64 between them'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a Fibonacci number squared and the product of its two neighbours differ by one'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the small frame says a square must be shared', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('1 square must be shared'),
      findsOneWidget,
    );
  });
}
