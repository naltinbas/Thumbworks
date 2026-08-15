import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/denland.dart';

/// One yard on the screen, lined up as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('line the four up so each threw the next'),
      findsOneWidget,
    );
    expect(find.text('lined 0 of 4'), findsOneWidget);
    expect(find.text('links 0 of 0 hold'), findsOneWidget);
    expect(find.text('yard: 3 lines, 0 rings'), findsOneWidget);
    expect(find.text('Nobody in line yet; tap a wrestler on the bench.'), findsOneWidget);
  });

  testWidgets('wrestlers step in, the links read, back undoes', (tester) async {
    await open(tester, which: 0);
    await stepAll(tester, [0, 1, 3]);
    expect(find.text('lined 3 of 4'), findsOneWidget);
    expect(find.text('links 1 of 2 hold'), findsOneWidget);
    expect(find.text('Link 2 breaks: Bram did not throw Dane.'), findsOneWidget);
    await tapWrestler(tester, 3);
    expect(state(tester).play.line, [0, 1]);
    await tapWrestler(tester, 0);
    expect(state(tester).play.line, [0, 1]);
    await press(tester, 'Back');
    expect(state(tester).play.line, [0, 1, 3]);
  });

  testWidgets('the four line up and show the card', (tester) async {
    await open(tester, which: 0);
    await stepAll(tester, [0, 3, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Lined up: each threw the next.'), findsOneWidget);
    expect(find.text('links 3 of 3 hold'), findsOneWidget);
    expect(
      find.textContaining('The line holds; 4 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a full line with the ring open says so', (tester) async {
    await open(tester, which: 2);
    await stepAll(tester, [4, 3, 2, 0, 1]);
    expect(state(tester).play.chainHolds, isTrue);
    expect(find.text('The line holds but the ring is open: Bram did not throw Eli.'), findsOneWidget);
    expect(find.text('yard: 13 lines, 2 rings'), findsOneWidget);
  });

  testWidgets('show me rings a wrestler on the bench', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('in', 4));
    expect(find.text('Step the ringed wrestler in.'), findsOneWidget);
  });

  testWidgets('show me steps a strayed line out', (tester) async {
    await open(tester, which: 1);
    await stepAll(tester, [0]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('out', 0));
    expect(find.text('Step the ringed wrestler out: the line has strayed.'), findsOneWidget);
  });

  testWidgets('the pointer closes the ring', (tester) async {
    await open(tester, which: 2);
    await lineByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('The ring closes: each threw the next, and'), findsOneWidget);
    expect(find.textContaining('The ring closes; 5 moves.'), findsOneWidget);
  });

  testWidgets('the hopeless yard cracks at thirteen moves', (tester) async {
    await open(tester, which: 4);
    await stepAll(tester, [4, 3, 2, 1, 0]);
    expect(find.text('The line holds but the ring is open: Ash did not throw Eli.'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await stepAll(tester, [0, 0]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('A champion breaks every ring.'), findsOneWidget);
    expect(
      find.textContaining('nobody threw the champion, so nobody can stand before him'),
      findsOneWidget,
    );
  });

  testWidgets('the why names the champion and Camion', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('A ring needs someone before the champion who threw him'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nobody reaches Eli'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the six counts odd', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('23 of the 720 line up so each threw the next, an odd count'),
      findsOneWidget,
    );
    expect(
      find.textContaining('across all 32,768 yards of six the count is never even'),
      findsOneWidget,
    );
  });
}
