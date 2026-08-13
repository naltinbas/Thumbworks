import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// One house on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a house opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('go dark in exactly 3 turns'),
      findsOneWidget,
    );
    expect(find.text('turns 0, asked 3'), findsOneWidget);
    expect(find.text('windows 0 · 0 · 0'), findsOneWidget);
  });

  testWidgets('a tap lights a window and the road follows',
      (tester) async {
    await open(tester, which: 4);
    await tapWindow(tester, 0);
    expect(state(tester).play.windows, [1, 0, 0]);
    expect(
      find.textContaining('circles for ever'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect(state(tester).play.windows, [0, 0, 0]);
  });

  testWidgets('all alike lands and shows the card', (tester) async {
    await open(tester, which: 3);
    for (var window = 0; window < 3; window++) {
      await tapWindow(tester, window);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Gone dark.'), findsOneWidget);
    expect(
      find.textContaining('go dark in exactly 1 turn;'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Gone dark.'), findsNothing);
  });

  testWidgets('show me rings a window', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Tap the ringed window'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer darkens the common lot', (tester) async {
    await open(tester, which: 1);
    await darkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.turns, 4);
  });

  testWidgets('the hopeless house cracks at fourteen taps',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 14; dither++) {
      await tapWindow(tester, dither % 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The ring never lands.'), findsOneWidget);
    expect(
      find.textContaining('circles the parity ring'),
      findsOneWidget,
    );
  });

  testWidgets('the why treads the parity ring', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('nought-one-one'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the 504 not alike circled'),
      findsOneWidget,
    );
  });
}
