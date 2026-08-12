import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One mere on the screen, slid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a mere opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('no hour is shared'),
      findsWidgets,
    );
    expect(find.text('pairs 0 of 3'), findsOneWidget);
    expect(find.text('shared hours 0'), findsOneWidget);
  });

  testWidgets('a slide moves the watch and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await slide(tester, 1, false);
    expect(state(tester).play.starts[1], 3);
    expect(find.text('pairs 1 of 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.starts[1], 4);
  });

  testWidgets('the three watches land and show the card',
      (tester) async {
    await open(tester, which: 0);
    await slideTo(tester, 1, 3);
    await slideTo(tester, 2, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Dialled home.'), findsWidgets);
    await press(tester, 'Again');
    expect(state(tester).play.starts, [0, 4, 8]);
  });

  testWidgets('show me names the watch and the way',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Slide the ringed watch'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer dials the broken ring', (tester) async {
    await open(tester, which: 2);
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.pairs, 2);
    expect(state(tester).play.commonWidth, 0);
  });

  testWidgets('the hopeless mere cracks at sixteen slides',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 8; dither++) {
      await slide(tester, 0, true);
      await slide(tester, 0, false);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('The ring keeps its hour.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('sits inside everybody'),
      findsOneWidget,
    );
  });

  testWidgets('the why names the pair and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Name two watches before a lantern'),
      findsOneWidget,
    );
    expect(find.textContaining('all 729 diallings'), findsOneWidget);
  });
}
