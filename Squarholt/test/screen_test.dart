import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// One hoard on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a hoard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('pay 43 with two square tiles'),
      findsOneWidget,
    );
    expect(find.text('hoard 43'), findsOneWidget);
    expect(find.text('3 past the fours'), findsOneWidget);
    expect(
      find.textContaining('The tiles pay 2, 41 short'),
      findsOneWidget,
    );
  });

  testWidgets('the dials turn the tiles and the sum follows',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'copper +');
    await press(tester, 'slate +');
    expect((state(tester).play.a, state(tester).play.b), (2, 2));
    expect(
      find.textContaining('The tiles pay 8, 17 short'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect((state(tester).play.a, state(tester).play.b), (2, 1));
  });

  testWidgets('one turn pays the five and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'slate +');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paid.'), findsOneWidget);
    expect(
      find.textContaining('1 and 4 make 5'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Paid.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me names the dial and the way', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (false, true));
    expect(find.text('Grow the slate tile.'), findsOneWidget);
  });

  testWidgets('the pointer pays the half hundred', (tester) async {
    await open(tester, which: 2);
    await payByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.paid, 50);
  });

  testWidgets('the hopeless hoard cracks at sixteen turns',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 8; dither++) {
      await press(tester, 'copper +');
      await press(tester, 'copper −');
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Three past never pays.'), findsOneWidget);
    expect(
      find.textContaining('forty-three sits three past'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the remainder and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('whole rows of four'),
      findsOneWidget,
    );
    expect(
      find.textContaining('no pair pays it'),
      findsOneWidget,
    );
  });
}
