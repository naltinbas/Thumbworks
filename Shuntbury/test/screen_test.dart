import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One ask on the screen, shunted as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('shunt the wagons home from 1 2 _ / 4 5 3 / 7 8 6, the fewest being two'), findsOneWidget);
    expect(find.text('fewest from here 2'), findsOneWidget);
    expect(find.text('shunts 0'), findsOneWidget);
    expect(find.text('0 shunts so far, and 2 more would do it: 4 pairs out of order, even.'), findsOneWidget);
  });

  testWidgets('a tap shunts, a far tap does nothing, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapBerth(tester, 0);
    expect(state(tester).play.moves, 0);
    await tapBerth(tester, 5);
    expect(state(tester).play.moves, 1);
    expect(find.text('fewest from here 1'), findsOneWidget);
    expect(find.text('1 shunt so far, and 1 more would do it: 2 pairs out of order, even.'), findsOneWidget);
    await tapBerth(tester, 4);
    expect(find.text('fewest from here 2'), findsOneWidget);
    expect(find.text('shunts 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('shunts 1'), findsOneWidget);
  });

  testWidgets('the two shunts lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await shuntAll(tester, [5, 8]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Home.'), findsOneWidget);
    expect(find.text('As asked. Home in 2, the fewest being 2.'), findsOneWidget);
    expect(find.textContaining('Home in 2 shunts; the fewest from the start is 2, and that was it.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Home.'), findsNothing);
    expect(find.text('shunts 0'), findsOneWidget);
  });

  testWidgets('show me rings the next wagon', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Shunt the ringed wagon'), findsOneWidget);
    expect(state(tester).pointing, isNotNull);
  });

  testWidgets('the pointer shunts the seven home in seven', (tester) async {
    await open(tester, which: 1);
    await shuntByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 7);
    expect(find.text('As asked. Home in 7, the fewest being 7.'), findsOneWidget);
  });

  testWidgets('a long way round is home too, and told', (tester) async {
    await open(tester, which: 0);
    await shuntAll(tester, [5, 4, 5, 8]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.textContaining('Home in 4 shunts; the fewest from the start is 2, 2 fewer.'), findsOneWidget);
  });

  testWidgets('the swapped pair admits it after forty shunts', (tester) async {
    await open(tester, which: 4);
    expect(find.text('no way home'), findsOneWidget);
    expect(find.text('1 pair out of order, odd: no shunt changes that, and home has nought.'), findsOneWidget);
    for (var k = 0; k < 40; k++) {
      await tapBerth(tester, k.isEven ? 7 : 8);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never home.'), findsOneWidget);
    expect(find.text('Forty shunts, and the pair is still swapped: one pair out of order, odd, and no shunt makes it even.'), findsOneWidget);
    expect(find.textContaining('reaches every yard with an even count, 181,440 of them, and none with an odd one'), findsOneWidget);
  });

  testWidgets('the why tells the parity and the walk', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Sam Loyd offered a thousand dollars'), findsOneWidget);
    expect(find.textContaining('181,440 of the 362,880 arrangements'), findsOneWidget);
  });
}
