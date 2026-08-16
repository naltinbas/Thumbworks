import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/orchardland.dart';

/// One ask on the screen, the trees tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('pick a tree in sight in the tenth row'), findsOneWidget);
    expect(find.text('no tree'), findsOneWidget);
    expect(find.text('63 in sight'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No tree picked: tap a tree to look along the line to it from the gate.'), findsOneWidget);
  });

  testWidgets('a tap picks a tree, a hidden one names what is in the way, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapTree(tester, (6, 9));
    expect(state(tester).play.picked, (6, 9));
    expect(find.text('tree (6, 9)'), findsOneWidget);
    expect(find.text('hidden'), findsOneWidget);
    expect(find.text('Tree (6, 9): hidden behind (2, 3) and (4, 6), 6 and 9 sharing the factor 3.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.picked, isNull);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the far row lands at (3, 10) and the card is shown', (tester) async {
    await open(tester, which: 0);
    await tapTree(tester, (3, 10));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Picked.'), findsOneWidget);
    expect(find.text('As asked. Tree (3, 10): in sight, 3 and 10 sharing no factor, hiding none.'), findsOneWidget);
    expect(find.textContaining('Tree (3, 10): in sight, 3 and 10 sharing no factor, by the factor and by the line, hiding none; one of 4 trees of the 100; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Picked.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the tree, and the pointer lands the long shadow', (tester) async {
    await open(tester, which: 2);
    await tapTree(tester, (5, 5));
    await press(tester, 'Show me');
    expect(find.text('Tap the tree at (2, 1).'), findsOneWidget);
    expect(state(tester).pointing, (2, 1));
    await doByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(find.text('As asked. Tree (2, 1): in sight, 2 and 1 sharing no factor, hiding (4, 2), (6, 3), (8, 4) and (10, 5).'), findsOneWidget);
    expect(find.textContaining('one of 2 trees of the 100; 2 taps.'), findsOneWidget);
  });

  testWidgets('the twice hidden at (6, 9)', (tester) async {
    await open(tester, which: 1);
    await tapTree(tester, (6, 9));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Tree (6, 9): hidden behind (2, 3) and (4, 6), 6 and 9 sharing the factor 3.'), findsOneWidget);
    expect(find.textContaining('hidden, 6 and 9 sharing the factor 3, behind (2, 3) and (4, 6), by the factor and by the line; one of 7 trees of the 100'), findsOneWidget);
  });

  testWidgets('the deep corner at (9, 10)', (tester) async {
    await open(tester, which: 3);
    await tapTree(tester, (9, 10));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Tree (9, 10): in sight, 9 and 10 sharing no factor, hiding none.'), findsOneWidget);
    expect(find.textContaining('one of 10 trees of the 100'), findsOneWidget);
  });

  testWidgets('a tree short of the ask says what stands in the way', (tester) async {
    await open(tester, which: 0);
    await tapTree(tester, (2, 10));
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Tree (2, 10): hidden behind (1, 5), 2 and 10 sharing the factor 2.'), findsOneWidget);
    expect(find.text('hidden'), findsOneWidget);
  });

  testWidgets('the hidden edge admits it after three edge trees', (tester) async {
    await open(tester, which: 4);
    await tapTree(tester, (1, 5));
    await tapTree(tester, (3, 1));
    await tapTree(tester, (1, 1));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('In sight, every time.'), findsOneWidget);
    expect(find.text('Tree (1, 1): in sight, 1 and 1 sharing no factor, hiding (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9) and (10, 10). The edges are in sight, every tree.'), findsOneWidget);
    expect(find.textContaining('Here (1, 1) is in sight, hiding (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9) and (10, 10).'), findsOneWidget);
  });

  testWidgets('the why tells Euclid and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Euclid\'s orchard'), findsOneWidget);
    expect(find.textContaining('looked at in full'), findsOneWidget);
  });
}
