import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One stall on the screen, a die picked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a stall opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('pick a die that beats die A in more than half the thirty-six rolls'),
      findsOneWidget,
    );
    expect(find.text('picks 0'), findsOneWidget);
    expect(find.text('wins 0 of 36'), findsOneWidget);
    expect(find.text('needs 19'), findsOneWidget);
    expect(find.text('Pick a die; the house shows its faces in madder.'), findsOneWidget);
  });

  testWidgets('a losing pick reads its count, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapDie(tester, 1);
    expect(find.text('wins 12 of 36'), findsOneWidget);
    expect(find.text('B against A wins 12 of 36, half or fewer; try another.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.picked, isNull);
    await tapDie(tester, 0);
    expect(state(tester).play.picked, isNull);
  });

  testWidgets('D beats A and the card is shown', (tester) async {
    await open(tester, which: 0);
    await tapDie(tester, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Beaten: D wins 24 rolls of 36.'), findsOneWidget);
    expect(find.textContaining('Die D wins 24 rolls of 36 against the house; 1 pick.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me names the die', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 0);
    expect(find.text('Pick die A.'), findsOneWidget);
  });

  testWidgets('the pointer picks against C', (tester) async {
    await open(tester, which: 2);
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('wins 24 of 36'), findsOneWidget);
  });

  testWidgets('the champion never comes', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [0, 1, 2, 3]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The ring has no champion.'), findsOneWidget);
    expect(
      find.textContaining('every die loses to the one before it round the ring'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the ring', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('A beats B, B beats C, C beats D and D beats A, 24 rolls of 36 each'),
      findsOneWidget,
    );
    expect(
      find.textContaining('A loses to D, B to A, C to B and D to C'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the house rolling A counts both beaters', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('C, 20 of 36; D, 24 of 36'),
      findsOneWidget,
    );
  });
}
