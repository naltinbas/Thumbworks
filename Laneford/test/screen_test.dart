import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// One green on the screen, laid out as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a green opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('lay the six lanes between four hamlets, each to each, so no two cross'), findsOneWidget);
    expect(find.text('crossings 1'), findsOneWidget);
    expect(find.text('lanes 6 of 6 allowed'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.text('1 crossing.'), findsOneWidget);
  });

  testWidgets('a hamlet is taken up and stood, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapHamlet(tester, 1);
    expect(state(tester).play.held, 1);
    expect(find.text('1 crossing. Holding B: tap a bare point.'), findsOneWidget);
    // A tap on another hamlet takes that one up instead.
    await tapPoint(tester, 0, 0);
    expect(state(tester).play.held, 0);
    await tapHamlet(tester, 1);
    expect(state(tester).play.held, 1);
    await tapPoint(tester, 1, 1);
    expect(state(tester).play.at[1], (1, 1));
    expect(find.text('moves 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.at[1], (2, 2));
  });

  testWidgets('the four hamlets land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await moveHamlet(tester, 1, 1, 1);
    await moveHamlet(tester, 3, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Clear.'), findsOneWidget);
    expect(find.text('Clear: 6 lanes, and no two cross.'), findsOneWidget);
    expect(find.textContaining('6 lanes between 4 hamlets, none crossing and none through a hamlet, on the 3 by 3 grid; 2 moves.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Clear.'), findsNothing);
    expect(state(tester).play.at, [(0, 0), (2, 2), (2, 0), (0, 2)]);
  });

  testWidgets('show me names the hamlet and rings the point', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (2, (1, 1)));
    expect(find.text('Take C and stand it on the ringed point.'), findsOneWidget);
    await tapHamlet(tester, 2);
    await press(tester, 'Show me');
    expect(find.text('Stand C on the ringed point.'), findsOneWidget);
  });

  testWidgets('the pointer lays the three and the three less one', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('8 lanes between 6 hamlets, none crossing'), findsOneWidget);
  });

  testWidgets('a lane through a hamlet is called', (tester) async {
    await open(tester, which: 0);
    await moveHamlet(tester, 3, 1, 1);
    expect(find.text('3 crossings and 1 lane through a hamlet.'), findsOneWidget);
  });

  testWidgets('the three and the three never clear', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 12; k++) {
      final h = k % 6;
      await moveHamlet(tester, h, 3, h < 3 ? 1 : 2);
      await moveHamlet(tester, h, h % 3, h < 3 ? 0 : 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The ninth lane crosses.'), findsOneWidget);
    expect(find.textContaining('eight for six hamlets, and the ninth lane must cross'), findsOneWidget);
  });

  testWidgets('the why counts the sweep and tells Euler', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('None of the 5,765,760 placings on the four-by-four is clear'), findsOneWidget);
    expect(find.textContaining('the lanes are at most 2v - 4'), findsOneWidget);
  });
}
