import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/brookland.dart';

/// One number on the screen, made as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a number opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('make twelve of exactly three square stones'),
      findsOneWidget,
    );
    expect(find.text('stones 0 of 3'), findsOneWidget);
    expect(find.text('sum 0 of 12'), findsOneWidget);
    expect(find.text('fewest 3'), findsOneWidget);
    expect(find.text('0 so far with 0 stones; 3 to go.'), findsOneWidget);
  });

  testWidgets('a stone is picked, lifted, and back undoes', (tester) async {
    await open(tester, which: 0);
    await pickStone(tester, 4);
    expect(find.text('stones 1 of 3'), findsOneWidget);
    expect(find.text('sum 4 of 12'), findsOneWidget);
    await liftStone(tester, 0);
    expect(find.text('stones 0 of 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.picked, [4]);
  });

  testWidgets('twelve made of three fours and the card shown', (tester) async {
    await open(tester, which: 0);
    await pickAll(tester, [4, 4, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Made: 12 of 3 squares.'), findsOneWidget);
    expect(
      find.textContaining('12 is 4 + 4 + 4; 3 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('three stones short read as short', (tester) async {
    await open(tester, which: 0);
    await pickAll(tester, [1, 1, 1]);
    expect(find.text('3 stones make 3, 9 short; lift one and try another.'), findsOneWidget);
    await liftStone(tester, 2);
    expect(find.text('stones 2 of 3'), findsOneWidget);
  });

  testWidgets('show me rings a stone on the rack, or a picked one', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('pick', 1));
    expect(find.text('Pick the ringed stone from the rack.'), findsOneWidget);
    await pickStone(tester, 81);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 0));
    expect(find.text('Lift the ringed stone; it is off the making.'), findsOneWidget);
  });

  testWidgets('the pointer makes ninety-nine', (tester) async {
    await open(tester, which: 3);
    await makeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('sum 99 of 99'), findsOneWidget);
  });

  testWidgets('seven never comes of three squares', (tester) async {
    await open(tester, which: 4);
    await pickAll(tester, [4, 1, 1]);
    for (var k = 0; k < 9; k++) {
      if (k.isEven) {
        await liftStone(tester, 0);
      } else {
        await pickStone(tester, 1);
      }
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never three.'), findsOneWidget);
    expect(
      find.textContaining('no three of those add to seven'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts by eight', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('7 leaves 7 by eight, so three squares never make it'),
      findsOneWidget,
    );
    expect(
      find.textContaining('three squares leave 0, 1, 2, 3, 4, 5, 6 and never 7'),
      findsOneWidget,
    );
  });

  testWidgets('the why of fifty counts the pickings', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('28 pickings, and 2 make 50'),
      findsOneWidget,
    );
  });
}
