import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/boardland.dart';

/// One ask on the screen, the pegs tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set four pegs whose four square-centres all fall on peg places'), findsOneWidget);
    expect(find.text('pegs 0 of 4'), findsOneWidget);
    expect(find.text('no joins yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No pegs set: tap four pegs in order and the squares are built.'), findsOneWidget);
  });

  testWidgets('taps set pegs, the last lifts, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPeg(tester, (1, 1));
    expect(state(tester).play.pegs, [(1, 1)]);
    expect(find.text('1 of 4 pegs set, at (1, 1): 3 more to set.'), findsOneWidget);
    expect(find.text('pegs 1 of 4'), findsOneWidget);
    await tapPeg(tester, (3, 1));
    expect(find.text('2 of 4 pegs set, at (1, 1), (3, 1): 2 more to set.'), findsOneWidget);
    await tapPeg(tester, (3, 1));
    expect(state(tester).play.pegs, [(1, 1)]);
    await press(tester, 'Back');
    await press(tester, 'Back');
    await press(tester, 'Back');
    expect(state(tester).play.pegs, isEmpty);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the whole centres land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(1, 1), (3, 1), (3, 3), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Squared.'), findsOneWidget);
    expect(find.text('As asked. Pegs (1, 1), (3, 1), (3, 3), (1, 3): joins 4 long both, at right angles, the turned join the other.'), findsOneWidget);
    expect(find.textContaining('Pegs (1, 1), (3, 1), (3, 3), (1, 3): centres at (2, 0), (4, 2), (2, 4), (0, 2), the joins 4 long both and at right angles, by the centres and by the turned join, crossing at (2, 2); one of 18,528 fours of the 227,952; 4 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Squared.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer sets the square', (tester) async {
    await open(tester, which: 1);
    await tapPeg(tester, (2, 2));
    await press(tester, 'Show me');
    expect(find.text('Lift the peg at (2, 2).'), findsOneWidget);
    expect(state(tester).pointing, ((2, 2), true));
    await pegsByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(find.text('As asked. Pegs (0, 0), (1, 0), (1, 1), (0, 1): joins 2 long both, at right angles, the turned join the other.'), findsOneWidget);
    expect(find.textContaining('one of 5,192 fours of the 227,952; 6 taps.'), findsOneWidget);
  });

  testWidgets('the meeting peg on the parallelogram', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Pegs (0, 0), (3, 1), (4, 4), (1, 3): joins 6 long both, at right angles, the turned join the other.'), findsOneWidget);
    expect(find.textContaining('crossing at (2, 2); one of 31,480 fours of the 227,952'), findsOneWidget);
  });

  testWidgets('the fives', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [(0, 0), (1, 0), (3, 1), (1, 4)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Pegs (0, 0), (1, 0), (3, 1), (1, 4): joins 5 long both, at right angles, the turned join the other.'), findsOneWidget);
    expect(find.textContaining('one of 2,960 fours of the 227,952'), findsOneWidget);
  });

  testWidgets('a four short of the ask still has its joins equal and square', (tester) async {
    await open(tester, which: 3);
    await setPegs(tester, [(0, 0), (4, 1), (3, 4), (1, 2)]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Pegs (0, 0), (4, 1), (3, 4), (1, 2): joins root 65/2 long both, at right angles, the turned join the other.'), findsOneWidget);
    expect(find.text('equal and square'), findsOneWidget);
  });

  testWidgets('the skew cross admits it after three fours', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 3)]);
    await tapPeg(tester, (1, 3));
    await tapPeg(tester, (2, 3));
    await tapPeg(tester, (2, 3));
    await tapPeg(tester, (0, 4));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Equal and square, always.'), findsOneWidget);
    expect(find.text('Pegs (0, 0), (3, 1), (4, 4), (0, 4): joins 7 long both, at right angles, the turned join the other. Equal and square, every time.'), findsOneWidget);
    expect(find.textContaining('Here the joins are 7 long both, at right angles.'), findsOneWidget);
  });

  testWidgets('the why tells Van Aubel and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Van Aubel proved it in 1878'), findsOneWidget);
    expect(find.textContaining('squared in full'), findsOneWidget);
  });
}
