import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/crownland.dart';

/// One board on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a board opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('set four kings on the four by four board so none attacks another'),
      findsOneWidget,
    );
    expect(find.text('kings 0 of 4'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('blocks 4'), findsOneWidget);
    expect(find.text('Set 0 of 4; none attacks another so far.'), findsOneWidget);
  });

  testWidgets('kings set, a clash reads, back undoes', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [0, 1]);
    expect(find.text('kings 2 of 4'), findsOneWidget);
    expect(find.text('clashes 1'), findsOneWidget);
    expect(find.text('Two kings touch.'), findsOneWidget);
    await tapSquare(tester, 1);
    expect(find.text('clashes 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.kings, [0, 1]);
  });

  testWidgets('the four by four seats and shows the card', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [0, 2, 8, 10]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Set: 4 kings and none attacks another.'), findsOneWidget);
    expect(
      find.textContaining('Every king stands unattacked; 4 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says set, or lift', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('set', 0));
    expect(find.text('Set a king on the ringed square.'), findsOneWidget);
    await tapSquare(tester, 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 1));
    expect(find.text('Lift the ringed king; it is off the even squares.'), findsOneWidget);
  });

  testWidgets('the pointer seats the six by six', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('kings 9 of 9'), findsOneWidget);
  });

  testWidgets('the hopeless board cracks at thirteen taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [0, 2, 8, 10, 5]);
    expect(find.text('Two kings touch, and 3 more pairs do.'), findsOneWidget);
    await tapAll(tester, [5, 5, 5, 5, 5, 5, 5, 5]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Four blocks, five kings.'), findsOneWidget);
    expect(
      find.textContaining('five kings on four blocks put two in one of them'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the blocks', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('The 16 squares cut into 4 blocks of two by two'),
      findsOneWidget,
    );
    expect(
      find.textContaining('half the side rounded up and squared'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the five by five names the most', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('so 9 is the most'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the even squares seat 9'),
      findsOneWidget,
    );
  });
}
