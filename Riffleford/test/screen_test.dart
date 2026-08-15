import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// One riffle on the screen, dealt as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a riffle opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('cut 8 at 3, the packet turned, and riffle so every pair mixed'),
      findsOneWidget,
    );
    expect(find.text('dropped 0 of 8'), findsOneWidget);
    expect(find.text('mixed 0 of 0'), findsOneWidget);
    expect(find.text('piles 3 and 5'), findsOneWidget);
    expect(find.text('Dropped 0 of 8; 0 blocks dealt, 0 unmixed.'), findsOneWidget);
  });

  testWidgets('drops deal cards, the blocks follow, back undoes',
      (tester) async {
    await open(tester, which: 0);
    await dropAll(tester, 'AB');
    expect(state(tester).play.dealt, 'RB');
    expect(find.text('dropped 2 of 8'), findsOneWidget);
    expect(find.text('mixed 1 of 1'), findsOneWidget);
    expect(find.text('piles 2 and 4'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.dealt, 'R');
  });

  testWidgets('an empty pile drops nothing', (tester) async {
    await open(tester, which: 0);
    await dropAll(tester, 'AAAA');
    expect(state(tester).play.drops, 'AAA');
  });

  testWidgets('the odd cut lands however dealt and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await dropAll(tester, 'BABBAABB');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Dealt.'), findsOneWidget);
    expect(find.text('Dealt: every block mixed.'), findsOneWidget);
    expect(
      find.textContaining('The deck is dealt as asked; 8 drops.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Dealt.'), findsNothing);
  });

  testWidgets('the unturned packet dealt wrong says so', (tester) async {
    await open(tester, which: 2);
    await dropAll(tester, 'ABABABAB');
    expect(state(tester).play.full, isTrue);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Dealt, and 4 blocks unmixed.'), findsOneWidget);
    expect(find.text('mixed 0 of 4'), findsOneWidget);
  });

  testWidgets('show me rings a pile', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 'A');
    expect(find.text('Drop from the ringed pile, the first.'), findsOneWidget);
  });

  testWidgets('the pointer deals the three kinds', (tester) async {
    await open(tester, which: 3);
    await riffleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 9);
  });

  testWidgets('the hopeless riffle cracks once dealt', (tester) async {
    await open(tester, which: 4);
    await dropAll(tester, 'BBAABBAB');
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two reds never meet.'), findsOneWidget);
    expect(
      find.textContaining('after every pair their tops are one of each again'),
      findsOneWidget,
    );
  });

  testWidgets('the why walks the tops', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('their top cards differ'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the sweep dealt all 56 and found none'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the unturned packet names the six', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('the invariant fails at the first pair'),
      findsOneWidget,
    );
    expect(
      find.textContaining('only 6 riffles of the 70'),
      findsOneWidget,
    );
  });
}
