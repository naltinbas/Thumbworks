import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// One stack on the screen, leaned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a stack opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('lean four books over the desk edge so the top hangs out a whole book'),
      findsOneWidget,
    );
    expect(find.text('overhang 0/24'), findsOneWidget);
    expect(find.text('asked 24/24'), findsOneWidget);
    expect(find.text('stands'), findsOneWidget);
    expect(find.text('Standing at 0 twenty-fourths; 24 more asked.'), findsOneWidget);
  });

  testWidgets('nudges move a book, the balance reads, back undoes', (tester) async {
    await open(tester, which: 2);
    await nudgeOut(tester, 0, 13);
    expect(state(tester).play.offsets, [13, 0, 0, 0]);
    expect(find.text('overhang 13/24'), findsOneWidget);
    expect(find.text('topples at book 1'), findsOneWidget);
    expect(find.text('Topples at book 1: the weight above it falls past the edge below.'), findsOneWidget);
    await nudge(tester, 0, -1);
    expect(state(tester).play.offsets, [12, 0, 0, 0]);
    expect(find.text('stands'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.offsets, [13, 0, 0, 0]);
  });

  testWidgets('the one lands at half and shows the card', (tester) async {
    await open(tester, which: 0);
    await lean(tester, [12]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Standing, and hanging out 12 twenty-fourths of a book.'), findsOneWidget);
    expect(
      find.textContaining('The stack stands with the reach asked; 12 nudges.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a half of a book', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('right', 0));
    expect(find.text('Nudge the ringed book out a twenty-fourth.'), findsOneWidget);
    await lean(tester, [13]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('left', 0));
    expect(find.text('Nudge the ringed book back a twenty-fourth.'), findsOneWidget);
  });

  testWidgets('the pointer leans the five', (tester) async {
    await open(tester, which: 3);
    await leanByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('overhang 27/24'), findsOneWidget);
  });

  testWidgets('the hopeless stack cracks at twenty-six nudges', (tester) async {
    await open(tester, which: 4);
    await lean(tester, [12, 6, 4]);
    expect(find.text('Standing at 22 twenty-fourths; 2 more asked.'), findsOneWidget);
    for (var dither = 0; dither < 2; dither++) {
      await nudge(tester, 0, 1);
      await nudge(tester, 0, -1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Three books never reach.'), findsOneWidget);
    expect(
      find.textContaining('eleven twelfths together, a twelfth short'),
      findsOneWidget,
    );
  });

  testWidgets('the why halves the harmonic numbers', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the harmonic numbers halved'),
      findsOneWidget,
    );
    expect(
      find.textContaining('finds 22 at the most, and a whole book is 24'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four counts the sixteen', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('16 of the 390625 stand with the reach asked'),
      findsOneWidget,
    );
    expect(
      find.textContaining('one reaches the twenty-fourth past'),
      findsOneWidget,
    );
  });
}
