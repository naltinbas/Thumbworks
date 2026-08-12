import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One yard on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('brick the 4 by 4 yard whole'),
      findsOneWidget,
    );
    expect(find.text('bricks 0 of 8'), findsOneWidget);
    expect(find.text('lines uncrossed 6 of 6'), findsOneWidget);
  });

  testWidgets('taps lay bricks and the chips keep count',
      (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0);
    expect(
      find.textContaining('One cell picked'),
      findsOneWidget,
    );
    await tapCell(tester, 1);
    expect(find.text('bricks 1 of 8'), findsOneWidget);
    expect(find.text('lines uncrossed 5 of 6'), findsOneWidget);
    expect(state(tester).play.laid, [(0, 1)]);
  });

  testWidgets('show me points a brick and the verdict says so',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Lay a brick across the marked cells'),
      findsOneWidget,
    );
    // A tap anywhere clears the pointer.
    await tapCell(tester, 0);
    expect(state(tester).pointing, isNull);
  });

  testWidgets('back unpicks first, then lifts the laying back',
      (tester) async {
    await open(tester, which: 0);
    await brickOver(tester, (0, 1));
    await tapCell(tester, 2);
    await press(tester, 'Back');
    expect(state(tester).play.picked, isNull);
    expect(state(tester).play.laid, [(0, 1)]);
    await press(tester, 'Back');
    expect(state(tester).play.laid, isEmpty);
  });

  testWidgets('landing the four-square shows the card, gold seams '
      'counted', (tester) async {
    await open(tester, which: 0);
    for (var brick = 0; brick < 8; brick++) {
      await brickOver(tester, (brick * 2, brick * 2 + 1));
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Bricked.'), findsOneWidget);
    expect(
      find.textContaining('Exactly 4 lines run the yard unbroken'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(state(tester).play.laid, isEmpty);
    expect(find.text('Bricked.'), findsNothing);
  });

  testWidgets('the sound course lands by the pointer', (tester) async {
    await open(tester, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(
      find.textContaining('Sound: every line crossed'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless yard cracks at eighteen moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 9; dither++) {
      await brickOver(tester, (0, 1));
      await brickOver(tester, (1, 0));
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The yard always cracks.'), findsOneWidget);
    expect(
      find.textContaining('ten lines want twenty crossings'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the sweep and the pairing of crossings',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Crossings come in pairs'),
      findsOneWidget,
    );
    expect(find.textContaining('6,728'), findsOneWidget);
  });
}
