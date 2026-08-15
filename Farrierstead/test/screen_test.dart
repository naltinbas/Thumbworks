import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/steadland.dart';

/// One board on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a board opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('set eight knights on the four by four board so none attacks another'),
      findsOneWidget,
    );
    expect(find.text('knights 0 of 8'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('pairs 8'), findsOneWidget);
    expect(find.text('Set 0 of 8; none attacks another so far.'), findsOneWidget);
  });

  testWidgets('knights set, a clash reads, back undoes', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [0, 6]);
    expect(find.text('knights 2 of 8'), findsOneWidget);
    expect(find.text('clashes 1'), findsOneWidget);
    expect(find.text('Two knights attack each other along the L.'), findsOneWidget);
    await tapSquare(tester, 6);
    expect(find.text('clashes 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.knights, [0, 6]);
  });

  testWidgets('the four by four seats and shows the card', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [0, 2, 5, 7, 8, 10, 13, 15]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Set: 8 knights and none attacks another.'), findsOneWidget);
    expect(
      find.textContaining('Every knight stands unattacked; 8 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says set, or lift', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('set', 0));
    expect(find.text('Set a knight on the ringed square.'), findsOneWidget);
    await tapSquare(tester, 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 1));
    expect(find.text('Lift the ringed knight; it is off the colour.'), findsOneWidget);
  });

  testWidgets('the pointer seats the six by six', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('knights 18 of 18'), findsOneWidget);
  });

  testWidgets('the hopeless board cracks at thirteen taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [0, 2, 5, 7, 8, 10, 13, 15, 1]);
    expect(find.text('Two knights attack each other along the L, and 2 more pairs do.'), findsOneWidget);
    await tapAll(tester, [1, 1, 1, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Eight pairs, nine knights.'), findsOneWidget);
    expect(
      find.textContaining('nine knights on eight pairs put two on one of them'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the pairs', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('The 16 squares pair off as 8 knight\'s moves'),
      findsOneWidget,
    );
    expect(
      find.textContaining('half the board rounded up'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the five by five counts the square left over', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('12 pairs and 1 square left over'),
      findsOneWidget,
    );
    expect(
      find.textContaining('so 13 is the most'),
      findsOneWidget,
    );
  });
}
