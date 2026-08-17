import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stripland.dart';

/// One ask on the screen, the beads turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on light beads', (tester) async {
    await open(tester, which: 1);
    expect(
        find.textContaining('string 6 beads that repeat every 3 and every 5'),
        findsOneWidget);
    expect(find.text('repeats every 3 and every 5'), findsOneWidget);
    expect(find.text('and every 1'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.textContaining('L L L L L L repeats every 1, 2, 3, 4, 5, 6.'),
        findsOneWidget);
  });

  testWidgets('a tap turns a bead, and back turns it again', (tester) async {
    await open(tester, which: 1);
    await turn(tester, 1);
    expect(state(tester).play.beads, [0, 1, 0, 0, 0, 0]);
    expect(find.text('taps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.beads, [0, 0, 0, 0, 0, 0]);
  });

  testWidgets('the three and the five lands on the Fibonacci strip',
      (tester) async {
    await open(tester, which: 1);
    await turnAll(tester, [1, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Strung.'), findsOneWidget);
    expect(
        find.textContaining('L D L L D L repeats every 3 and every 5 and not every 1.'),
        findsOneWidget);
    expect(find.textContaining('one of 2 strips of the 64 that land the ask'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Strung.'), findsNothing);
  });

  testWidgets('the four and the six takes one dark bead', (tester) async {
    await open(tester, which: 2);
    await stringByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 1);
    expect(find.textContaining('one of 4 strips of the 128 that land the ask'),
        findsOneWidget);
  });

  testWidgets('show me names the bead, and the pointer strings the eleven',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.textContaining('Turn bead'), findsOneWidget);
    await stringByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
  });

  testWidgets('one too long admits it after sixteen taps', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 16; k++) {
      if (state(tester).play.isOver) break;
      await turn(tester, k % 7);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One bead too many.'), findsOneWidget);
    expect(find.textContaining('No strip of 7 beads repeats every 3 and every 5'),
        findsOneWidget);
  });

  testWidgets('the why tells Fine and Wilf', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Nathan Fine and Herbert Wilf'), findsOneWidget);
    expect(find.textContaining('read in full before the sham'), findsOneWidget);
  });
}
