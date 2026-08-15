import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rungland.dart';

/// One ask on the screen, measured as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the side and the diagonal so the diagonal squared is one over twice the side squared'), findsOneWidget);
    expect(find.text('2 over'), findsOneWidget);
    expect(find.text('off by 0.58579'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('side 1'), findsWidgets);
    expect(find.text('diagonal 2'), findsWidgets);
    expect(find.text('Climb the ladder: 3 and 4'), findsOneWidget);
    expect(find.text('Side 1, diagonal 2: 4 to 2, 2 over; 2.0000 to the root\'s 1.4142.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial, the ladder climbs, and back undoes', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 'diagonal', -1);
    expect(state(tester).play.diagonal, 1);
    expect(find.text('1 under'), findsOneWidget);
    expect(find.text('Side 1, diagonal 1: 1 to 2, 1 under; 1.0000 to the root\'s 1.4142, a rung of the ladder.'), findsOneWidget);
    await climb(tester);
    await climb(tester);
    expect((state(tester).play.side, state(tester).play.diagonal), (5, 7));
    expect(find.text('Climb the ladder: 12 and 17'), findsOneWidget);
    expect(find.text('off by 0.01421'), findsOneWidget);
    expect(find.text('taps 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.side, 2);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('the one over lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'diagonal', -1);
    await climb(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Measured.'), findsOneWidget);
    expect(find.text('As asked. Side 2, diagonal 3: 9 to 8, 1 over; 1.5000 to the root\'s 1.4142, a rung of the ladder.'), findsOneWidget);
    expect(find.textContaining('Side 2, diagonal 3: 3 squared is 9 and twice 2 squared 8, 1 over, and 3 over 2 is 1.50000, 0.08579 over the true diagonal, a rung of the ladder; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Measured.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, the way and the ladder', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Shorten the diagonal.'), findsOneWidget);
    await turn(tester, 'diagonal', -1);
    await press(tester, 'Show me');
    expect(find.text('Climb the ladder a rung.'), findsOneWidget);
  });

  testWidgets('the pointer measures the thousandth', (tester) async {
    await open(tester, which: 2);
    await measureByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(find.text('As asked. Side 29, diagonal 41: 1,681 to 1,682, 1 under; 1.4138 to the root\'s 1.4142, a rung of the ladder.'), findsOneWidget);
  });

  testWidgets('the thousandth off the ladder, by hand', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 'diagonal', -1);
    for (var k = 0; k < 4; k++) {
      await climb(tester);
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Again');
    // 41 and 58 by the dials from the top: side up to 41 from 29 is a
    // long walk, so climb to (29, 41) then step the side and diagonal.
    await turn(tester, 'diagonal', -1);
    for (var k = 0; k < 4; k++) {
      await climb(tester);
    }
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('a dial at its end stays', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 'side', -1);
    expect(state(tester).play.side, 1);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the true diagonal admits it at the top rung', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 'diagonal', -1);
    for (var k = 0; k < 5; k++) {
      await climb(tester);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never a whole diagonal.'), findsOneWidget);
    expect(find.text('The top rung, 99 and 70, misses by one like every rung: a whole diagonal squared is never twice a whole side squared, since halving both would never end.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 14,400 pairs finds no true diagonal'), findsOneWidget);
  });

  testWidgets('the why tells the halving and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('which cannot go on for ever'), findsOneWidget);
    expect(find.textContaining('14,400 pairs, tried in full'), findsOneWidget);
  });
}
