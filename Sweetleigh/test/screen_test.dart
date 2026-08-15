import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leighland.dart';

/// One share on the screen, cut as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a share opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('share RRRRBBBB, 4 red and 4 blue, with at most 2 cuts'),
      findsOneWidget,
    );
    expect(find.text('cuts 0 of 2'), findsOneWidget);
    expect(find.text('red 4 · 0'), findsOneWidget);
    expect(find.text('blue 4 · 0'), findsOneWidget);
    expect(
      find.text('Cuts 0 of 2; red and blue not yet halved.'),
      findsOneWidget,
    );
  });

  testWidgets('a cut shares the pieces, and a mend takes it back',
      (tester) async {
    await open(tester, which: 1);
    await tapGap(tester, 4);
    expect(state(tester).play.cuts, [4]);
    expect(find.text('red 4 · 0'), findsOneWidget);
    expect(find.text('blue 0 · 4'), findsOneWidget);
    await tapGap(tester, 4);
    expect(state(tester).play.cuts, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.cuts, [4]);
  });

  testWidgets('the two cuts land by hand and show the card',
      (tester) async {
    await open(tester, which: 1);
    await cutAll(tester, [2, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Shared.'), findsOneWidget);
    expect(find.text('red 2 · 2'), findsOneWidget);
    expect(
      find.textContaining('Each child holds half of every kind; 2 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Shared.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a third cut is refused where two are allowed',
      (tester) async {
    await open(tester, which: 3);
    await cutAll(tester, [1, 2, 3]);
    expect(state(tester).play.cuts, [1, 2]);
  });

  testWidgets('show me rings a gap', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('cut', 1));
    expect(find.text('Cut the string at the ringed gap.'), findsOneWidget);
  });

  testWidgets('the pointer shares the three kinds', (tester) async {
    await open(tester, which: 2);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.cuts, [1, 3, 5]);
  });

  testWidgets('the hopeless share cracks at nine moves', (tester) async {
    await open(tester, which: 4);
    await tapGap(tester, 4);
    expect(find.text('red 4 · 0'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await cutAll(tester, [4, 4]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One cut never shares it.'), findsOneWidget);
    expect(
      find.textContaining('any first piece with two blues holds all four reds'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the first pieces', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Read the first pieces off the string'),
      findsOneWidget,
    );
    expect(
      find.textContaining('R, RR, RRR, RRRR, RRRRB, RRRRBB and RRRRBBB'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the two cuts slides the window', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('slide a piece half the string long'),
      findsOneWidget,
    );
    expect(
      find.textContaining('34 that need two cuts'),
      findsOneWidget,
    );
  });
}
