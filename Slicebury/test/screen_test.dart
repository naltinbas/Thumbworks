import 'package:flutter_test/flutter_test.dart';

import 'support/buryland.dart';
import 'support/fonts.dart';

/// One cake on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a cake opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('make exactly 32 slices'),
      findsOneWidget,
    );
    expect(find.text('slices 1, asked 32'), findsOneWidget);
    expect(find.text('candles 0 of 6'), findsOneWidget);
  });

  testWidgets('a set candle cuts and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await tapSpot(tester, 0);
    await tapSpot(tester, 6);
    expect(state(tester).play.picked, [0, 6]);
    expect(find.text('slices 2, asked 8'), findsOneWidget);
    expect(
      find.textContaining('the knife cuts 2 slices'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect(state(tester).play.picked, [0]);
  });

  testWidgets('four candles cut the eight and show the card',
      (tester) async {
    await open(tester, which: 0);
    for (final spot in [0, 3, 6, 9]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cut true.'), findsOneWidget);
    expect(
      find.textContaining('Euler and the cut count agreeing'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Cut true.'), findsNothing);
  });

  testWidgets('show me rings a spot', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Set a candle at the ringed spot'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer cuts the thirty', (tester) async {
    await open(tester, which: 3);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.slices, 30);
  });

  testWidgets('the hopeless cake cracks at sixteen moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 16; dither++) {
      await tapSpot(tester, dither % 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The doubling lied.'), findsOneWidget);
    expect(
      find.textContaining('clumped crossings only lose'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the cut count and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('every crossing adds a slice again'),
      findsOneWidget,
    );
    expect(find.textContaining('all 924 picks'), findsOneWidget);
  });
}
