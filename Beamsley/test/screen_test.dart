import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lanternland.dart';

/// One ask on the screen, the pegs tapped and the casts stepped as a
/// thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(find.textContaining('all three meetings are far off'), findsOneWidget);
    expect(find.text('pegs 0 of 3'), findsOneWidget);
    expect(find.text('no meetings yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No pegs set: tap three, and each casts a shadow along its ray.'), findsOneWidget);
  });

  testWidgets('taps set the pegs, a peg on a used ray is refused, and back undoes', (tester) async {
    await open(tester, which: 2);
    await tapPeg(tester, (1, 0));
    expect(state(tester).play.pegs, [(1, 0)]);
    expect(find.text('1 of 3 pegs set, at (1, 0): 2 more, none on a ray already used.'), findsOneWidget);
    await tapPeg(tester, (2, 0));
    expect(state(tester).play.pegs, [(1, 0)]);
    await tapPeg(tester, (0, 1));
    expect(find.text('2 of 3 pegs set, at (1, 0), (0, 1): 1 more, none on a ray already used.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.pegs, [(1, 0)]);
    await press(tester, 'Back');
    expect(state(tester).play.pegs, isEmpty);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the far line lands on three pegs and the card is shown', (tester) async {
    await open(tester, which: 2);
    await setPegs(tester, [(1, 0), (0, 1), (-1, -1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cast.'), findsOneWidget);
    expect(find.text('As asked. Pegs (1, 0), (0, 1), (-1, -1) cast 2, 2 and 2: every side parallel to its shadow, so all three meetings run off to infinity and the axis is the line at infinity.'), findsOneWidget);
    expect(find.textContaining('Pegs (1, 0), (0, 1), (-1, -1) cast 2, 2 and 2: the shadows at (2, 0), (0, 2), (-2, -2), the sides meeting at far off along 1, -1, far off along 1, 2, far off along 2, 1, all three on the line at infinity, by the crossings and by the fractions; one of 31,968 settings of the 511,488; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cast.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a cast step moves one shadow out', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(1, 0), (0, 1), (-1, -1)]);
    await stepCast(tester, 0, 1);
    expect(state(tester).play.casts, [3, 2, 2]);
    expect(state(tester).play.shadows, [(3, 0), (0, 2), (-2, -2)]);
    expect(find.text('one far off'), findsOneWidget);
  });

  testWidgets('show me names the peg, and the pointer lands the whole meets', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.text('Set peg A at (-2, -2).'), findsOneWidget);
    expect(state(tester).pointing, ('peg', 0));
    await castByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.pegs, [(-2, -2), (0, -2), (-2, 1)]);
    expect(state(tester).play.casts, [-1, 3, 2]);
    expect(state(tester).play.moves, 5);
    expect(find.textContaining('one of 1,248 settings of the 511,488; 5 taps.'), findsOneWidget);
  });

  testWidgets('the level axis', (tester) async {
    await open(tester, which: 1);
    await setPegs(tester, [(-2, -2), (-1, -2), (-2, -1)]);
    await setCasts(tester, [-2, -2, -1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('one of 43,872 settings of the 511,488'), findsOneWidget);
  });

  testWidgets('a setting short of the ask still lines its meetings up', (tester) async {
    await open(tester, which: 0);
    await setPegs(tester, [(1, 0), (0, 1), (-1, -1)]);
    await setCasts(tester, [2, 3, -1]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Pegs (1, 0), (0, 1), (-1, -1) cast 2, 3 and -1: the sides meet at (4, -3), (1/2, 2), (5/3, 1/3), all three on the line -10 x - 7 y = -19.'), findsOneWidget);
    expect(find.text('three meetings'), findsOneWidget);
  });

  testWidgets('the crooked axis admits it after three settings', (tester) async {
    await open(tester, which: 4);
    await setPegs(tester, [(1, 0), (0, 1), (-1, -1)]);
    await stepCast(tester, 0, 1);
    await stepCast(tester, 1, 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Straight, every time.'), findsOneWidget);
    expect(find.textContaining('Straight, whatever the casting.'), findsOneWidget);
    expect(find.textContaining('No casting bends the axis.'), findsOneWidget);
  });

  testWidgets('the why tells Desargues and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Desargues proved it in 1639'), findsOneWidget);
    expect(find.textContaining('crossed in full'), findsOneWidget);
  });
}
