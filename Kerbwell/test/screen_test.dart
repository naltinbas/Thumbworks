import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/kerbland.dart';

/// One yard on the screen, laid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('lay 6 slabs joined, in a kerb of exactly 10'),
      findsOneWidget,
    );
    expect(find.text('slabs 0 of 6'), findsOneWidget);
    expect(find.text('kerb 0, asked 10'), findsOneWidget);
    expect(find.text('box none'), findsOneWidget);
    expect(find.text('Slabs 0 of 6, kerb 0.'), findsOneWidget);
  });

  testWidgets('slabs lay, the kerb and box follow, a lift undoes',
      (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [(1, 1), (2, 1)]);
    expect(find.text('kerb 6, asked 8'), findsOneWidget);
    expect(find.text('box 2 by 1, kerb 6'), findsOneWidget);
    await tapCell(tester, (2, 1));
    expect(state(tester).play.slabs, {(1, 1)});
    await press(tester, 'Back');
    expect(state(tester).play.slabs, {(1, 1), (2, 1)});
  });

  testWidgets('loose slabs are called out', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [(0, 0), (2, 0)]);
    expect(
      find.text('The slabs are not joined edge to edge.'),
      findsOneWidget,
    );
  });

  testWidgets('the square yard lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Laid.'), findsOneWidget);
    expect(
      find.textContaining('The slabs stand in the kerb asked; 4 moves.'),
      findsOneWidget,
    );
    expect(find.text('Laid: 4 slabs in a kerb of 8.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Laid.'), findsNothing);
  });

  testWidgets('a full yard with the wrong kerb says so', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [(0, 0), (1, 0), (2, 0), (3, 0)]);
    expect(find.text('Kerb 10, asked 8.'), findsOneWidget);
    expect(find.text('kerb 10, asked 8'), findsOneWidget);
  });

  testWidgets('show me rings a cell', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(state(tester).pointing!.$1, 'lay');
    expect(find.text('Lay a slab in the ringed cell.'), findsOneWidget);
  });

  testWidgets('the pointer lands the ten', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 10);
  });

  testWidgets('the hopeless yard cracks at eleven moves', (tester) async {
    await open(tester, which: 4);
    await layAll(tester, [(1, 1), (2, 1), (3, 1), (1, 2), (2, 2)]);
    expect(find.text('Kerb 10, asked 8.'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await layAll(tester, [(2, 2), (2, 2)]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Five never wear eight.'), findsOneWidget);
    expect(
      find.textContaining('their box is two by three at the least'),
      findsOneWidget,
    );
  });

  testWidgets('the why measures the box', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Look at the chalk box round the slabs'),
      findsOneWidget,
    );
    expect(
      find.textContaining('96 placings of the 571'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the eight names Harary and Harborth', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('Harary and Harborth\'s law'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nine slabs in twelve are the three by three alone'),
      findsOneWidget,
    );
  });
}
