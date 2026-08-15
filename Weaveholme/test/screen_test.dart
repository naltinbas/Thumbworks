import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// One plaid on the screen, woven as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a plaid opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('weave the four by four plaid so every two rows agree in exactly two squares'),
      findsOneWidget,
    );
    expect(find.text('pairs right 0 of 6'), findsOneWidget);
    expect(find.text('flips 0'), findsOneWidget);
    expect(find.text('free rows 4'), findsOneWidget);
    expect(find.text('0 of 6 pairs of rows agree in half; 6 off.'), findsOneWidget);
  });

  testWidgets('a square turns, a given row stays, and back undoes', (tester) async {
    await open(tester, which: 2);
    await tapSquare(tester, 0, 0);
    expect(state(tester).play.moves, 0);
    await tapSquare(tester, 6, 0);
    expect(state(tester).play.dark(6, 0), isTrue);
    expect(find.text('flips 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.dark(6, 0), isFalse);
  });

  testWidgets('the four woven and the card shown', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [(1, 1), (1, 3), (2, 2), (2, 3), (3, 1), (3, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Woven: every two rows agree in exactly 2.'), findsOneWidget);
    expect(find.textContaining('Every two rows agree in exactly 2; 6 flips.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a square', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Turn the ringed square.'), findsOneWidget);
  });

  testWidgets('the pointer weaves the eight over four rows', (tester) async {
    await open(tester, which: 3);
    await weaveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('pairs right 28 of 28'), findsOneWidget);
  });

  testWidgets('the six never weaves', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 30; k++) {
      await tapSquare(tester, k % 6, (k ~/ 6) % 6);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Six never weaves.'), findsOneWidget);
    expect(
      find.textContaining('two other rows agree in an even count of squares, and three is odd'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the triples', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Every triple of rows of six was swept, 262,144 of them'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four counts the fillings', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('65,536 of them, and 768 land'),
      findsOneWidget,
    );
  });
}
