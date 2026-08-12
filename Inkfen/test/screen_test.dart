import 'package:flutter_test/flutter_test.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// One line on the screen, dipped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a line opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('ink the 5 strings from a pot of 2'),
      findsOneWidget,
    );
    expect(find.text('inked 0 of 5'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
  });

  testWidgets('a dip inks the string and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapString(tester, 0);
    expect(state(tester).play.inks[0], 1);
    expect(find.text('inked 1 of 5'), findsOneWidget);
    await tapString(tester, 1);
    expect(
      find.textContaining('1 clash at the posts'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect(state(tester).play.inks[1], 0);
  });

  testWidgets('the path lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await tapString(tester, 0);
    await dipTo(tester, 1, 2);
    await tapString(tester, 2);
    await dipTo(tester, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Inked home.'), findsOneWidget);
    expect(
      find.textContaining('not one clash at a post'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Inked home.'), findsNothing);
  });

  testWidgets('show me rings a string', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Dip the ringed string'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer lands the ring mended', (tester) async {
    await open(tester, which: 3);
    await inkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the hopeless line cracks at fourteen dips',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 14; dither++) {
      await tapString(tester, dither % 5);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The odd ring refuses.'), findsOneWidget);
    expect(
      find.textContaining('five is odd'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the alternation and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('can only take turns'),
      findsOneWidget,
    );
    expect(find.textContaining('all 32 inkings'), findsOneWidget);
  });
}
