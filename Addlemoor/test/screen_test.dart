import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moorland.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh moor names itself and its first bad sum',
      (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Four'), findsOneWidget);
    expect(
      find.textContaining('paint stones 1 to 4 with 2 paints'),
      findsOneWidget,
    );
    expect(
      find.text('1 and 1 make 2, all in one paint: repaint one.'),
      findsOneWidget,
    );
  });

  testWidgets('a tap swaps a paint and recounts the sums',
      (tester) async {
    await open(tester, which: 0);
    await tapStone(tester, 2);
    expect(state(tester).play.painting[1], 1);
    expect(state(tester).play.moves, 1);
    expect(find.textContaining('bad sums'), findsOneWidget);
  });

  testWidgets('a clean four lands and records', (tester) async {
    await open(tester, which: 0);
    await paintAll(tester, const [0, 1, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Painted.'), findsOneWidget);
    expect(find.textContaining('2 repaintings'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a repainting and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await paintAll(tester, const [0, 1, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Painted.'), findsNothing);
  });

  testWidgets('show me names the stone and the paint', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final names = ['madder', 'indigo', 'moss'];
    expect(
      find.text('Paint stone ${aim!.$1} ${names[aim.$2]}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the count', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('standing for all 1,594,323'),
      findsOneWidget,
    );
    expect(find.textContaining('18 paintings land'), findsOneWidget);
  });

  testWidgets('the hopeless moor admits it and speaks the wall',
      (tester) async {
    await open(tester, which: 4);
    for (var repaint = 0; repaint < 12; repaint++) {
      await tapStone(tester, 1 + repaint % 14);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The fourteenth breaks it.'), findsOneWidget);
    expect(
      find.textContaining('three paints end at thirteen'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('eighteen clean thirteens die'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the moor over', (tester) async {
    await open(tester, which: 0);
    await paintAll(tester, const [0, 1, 1, 0]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Painted.'), findsNothing);
  });
}
