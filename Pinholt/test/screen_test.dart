import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// One plot on the screen, pinned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a plot opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('set 5 pins, no three in a line, holding exactly one frame'),
      findsOneWidget,
    );
    expect(find.text('pins 0 of 5'), findsOneWidget);
    expect(find.text('frames 0, asked 1'), findsOneWidget);
    expect(find.text('fence 0'), findsOneWidget);
    expect(find.text('Pins 0 of 5, 0 frames, fence of 0.'), findsOneWidget);
  });

  testWidgets('pins set, the fence and frames follow, a lift undoes',
      (tester) async {
    await open(tester, which: 0);
    await setPins(tester, [(0, 0), (4, 0), (4, 4)]);
    expect(find.text('fence 3'), findsOneWidget);
    await tapHole(tester, (0, 4));
    expect(state(tester).play.frames, hasLength(1));
    expect(find.text('frames 1, asked 1'), findsOneWidget);
    expect(find.text('Landed.'), findsOneWidget);
    await press(tester, 'Again');
    await setPins(tester, [(0, 0), (4, 0), (2, 4)]);
    await tapHole(tester, (2, 4));
    expect(state(tester).play.pins, hasLength(2));
    await press(tester, 'Back');
    expect(state(tester).play.pins, hasLength(3));
  });

  testWidgets('a third pin in a line is refused', (tester) async {
    await open(tester, which: 0);
    await setPins(tester, [(0, 0), (1, 1), (2, 2)]);
    expect(state(tester).play.pins, hasLength(2));
    expect(
      find.text('Refused: three pins in a line are not allowed.'),
      findsOneWidget,
    );
  });

  testWidgets('the tucked four lands and shows the card', (tester) async {
    await open(tester, which: 1);
    await setPins(tester, [(0, 0), (4, 0), (2, 4), (2, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(
      find.textContaining('The pins stand as asked; 4 moves.'),
      findsOneWidget,
    );
    expect(find.text('Landed: no frame among 4 pins.'), findsOneWidget);
  });

  testWidgets('show me rings a hole', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(state(tester).pointing!.$1, 'set');
    expect(find.text('Set a pin in the ringed hole.'), findsOneWidget);
  });

  testWidgets('the pointer lands the three frames', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(state(tester).play.frames, hasLength(3));
  });

  testWidgets('the hopeless plot cracks at eleven moves', (tester) async {
    await open(tester, which: 4);
    await setPins(tester, [(0, 0), (4, 0), (2, 4), (1, 1), (3, 1)]);
    expect(find.text('frames 1, asked 0'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await tapHole(tester, (3, 1));
      await tapHole(tester, (3, 1));
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Five pins always frame.'), findsOneWidget);
    expect(
      find.textContaining('the fence runs through five, four or three'),
      findsOneWidget,
    );
  });

  testWidgets('the why walks the fence', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('There is no fourth kind of fence.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('over all 25,052 placings'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the three frames names the fewest', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Three frames is the fewest six pins ever hold'),
      findsOneWidget,
    );
  });
}
