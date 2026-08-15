import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One yard on the screen, paved as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pave the three-by-three yard with one flag of one and two of two'), findsOneWidget);
    expect(find.text('laid 0 of 4'), findsOneWidget);
    expect(find.text('bare 9'), findsOneWidget);
    expect(find.text('layings 0'), findsOneWidget);
    expect(find.textContaining('0 of 4 laid, 9 cells bare'), findsOneWidget);
  });

  testWidgets('a flag is taken, laid and lifted, and back undoes', (tester) async {
    await open(tester, which: 0);
    await takeKind(tester, 1);
    expect(state(tester).play.held, 1);
    expect(find.text('Holding the 2: tap the yard where its top left corner goes.'), findsOneWidget);
    await tapCell(tester, 2, 0);
    expect(find.text('That does not fit there: a flag must lie inside the yard over bare cells.'), findsOneWidget);
    await tapCell(tester, 1, 0);
    expect(state(tester).play.laid, [(1, 2, 2, 1, 0)]);
    expect(find.text('layings 1'), findsOneWidget);
    expect(find.text('bare 5'), findsOneWidget);
    await tapCell(tester, 2, 1);
    expect(state(tester).play.laid, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.laid, [(1, 2, 2, 1, 0)]);
  });

  testWidgets('a half turns with the button', (tester) async {
    await open(tester, which: 0);
    await takeKind(tester, 2);
    expect(find.text('Holding the half 2: tap the yard where its top left corner goes.'), findsOneWidget);
    await press(tester, 'Turn');
    expect(state(tester).play.upright, isTrue);
    await tapCell(tester, 0, 1);
    expect(state(tester).play.laid, [(2, 1, 2, 0, 1)]);
  });

  testWidgets('the three lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await lay(tester, 0, 0, 0);
    await lay(tester, 1, 1, 0);
    await lay(tester, 2, 0, 1, upright: true);
    await lay(tester, 2, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paved.'), findsOneWidget);
    expect(find.text('Paved: 4 flags, 9 cells, none bare.'), findsOneWidget);
    expect(find.textContaining('The cubes of one to 2, 9 cells, pave the 3 by 3 yard exactly, the square of one to 2 summed, 4 flags; 4 layings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Paved.'), findsNothing);
    expect(state(tester).play.laid, isEmpty);
  });

  testWidgets('show me names the flag, the turn and the place', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.text('Take the 1 from the tray.'), findsOneWidget);
    await lay(tester, 0, 0, 0);
    await lay(tester, 1, 1, 0);
    await takeKind(tester, 2);
    await press(tester, 'Show me');
    expect(find.text('Turn the half the other way up.'), findsOneWidget);
    await press(tester, 'Turn');
    await press(tester, 'Show me');
    expect(find.text('Lay it with its corner at the ringed place.'), findsOneWidget);
  });

  testWidgets('the pointer paves the six', (tester) async {
    await open(tester, which: 1);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('36 cells, pave the 6 by 6 yard exactly'), findsOneWidget);
  });

  testWidgets('a flag in the way is pointed at to lift', (tester) async {
    await open(tester, which: 1);
    await lay(tester, 3, 0, 0);
    await press(tester, 'Show me');
    expect(find.text('Lift the flag ringed rust: it is in the way.'), findsOneWidget);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the whole twos overlap and the card says why', (tester) async {
    await open(tester, which: 4);
    await lay(tester, 1, 0, 0);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The twos overlap.'), findsOneWidget);
    expect(find.text('Nowhere left for a whole two: every two covers the middle.'), findsOneWidget);
    expect(find.textContaining('every two-by-two flag in the three-by-three covers the middle cell'), findsOneWidget);
  });

  testWidgets('the why tells the identity and the counts', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Nicomachus\'s theorem, checked to a hundred'), findsOneWidget);
    expect(find.textContaining('nor do the whole flags pave the six, the ten or the fifteen'), findsOneWidget);
  });
}
