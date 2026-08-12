import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/village.dart';

/// The screen, worked the way a finger would.
const fano = [
  (0, 1, 2), (0, 3, 4), (0, 5, 6), (1, 3, 5),
  (1, 4, 6), (2, 3, 6), (2, 4, 5),
];

void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh green names itself and its task', (tester) async {
    await open(tester, which: 3);
    expect(find.text('The Seven Ropes'), findsOneWidget);
    expect(
      find.textContaining('string 7 ropes so every pair of 7'),
      findsOneWidget,
    );
    expect(
      find.text('0 of 21 pairs share a rope; 0 of 7 strung.'),
      findsOneWidget,
    );
  });

  testWidgets('picks speak and the third strings the rope',
      (tester) async {
    await open(tester, which: 3);
    await tapLantern(tester, 0);
    await tapLantern(tester, 1);
    expect(
      find.text('Picked 1 and 2; a third strings the rope.'),
      findsOneWidget,
    );
    await tapLantern(tester, 2);
    expect(state(tester).play.laid, [(0, 1, 2)]);
    expect(find.text('pairs 3 of 21'), findsOneWidget);
  });

  testWidgets('the whole fano closes the green', (tester) async {
    await open(tester, which: 3);
    await stringAll(tester, fano);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Closed.'), findsOneWidget);
    expect(find.textContaining('7 ropes strung'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a clash is called out by lantern', (tester) async {
    await open(tester, which: 3);
    await stringRope(tester, (0, 1, 2));
    await stringRope(tester, (0, 1, 3));
    expect(
      find.text('Lanterns 1 and 2 share two ropes: take one back.'),
      findsOneWidget,
    );
    expect(find.text('clashes 1'), findsOneWidget);
  });

  testWidgets('back takes back the last rope', (tester) async {
    await open(tester, which: 3);
    await stringRope(tester, (0, 1, 2));
    expect(state(tester).play.laid, hasLength(1));
    await press(tester, 'Back');
    expect(state(tester).play.laid, isEmpty);
  });

  testWidgets('show me names the rope to string', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final (a, b, c) = aim!;
    expect(
      find.text('Rope lanterns ${a + 1}, ${b + 1} and ${c + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the three voices', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('the search strings every roping'),
      findsOneWidget,
    );
    expect(find.textContaining('30 closings'), findsOneWidget);
    expect(
      find.textContaining('exactly 3 ropes'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless green admits it and speaks the half rope',
      (tester) async {
    await open(tester, which: 4);
    final triples = [
      for (var a = 0; a < 6; a++)
        for (var b = a + 1; b < 6; b++)
          for (var c = b + 1; c < 6; c++) (a, b, c),
    ];
    for (final rope in triples.take(12)) {
      await stringRope(tester, rope);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The green stays open.'), findsOneWidget);
    expect(
      find.textContaining('two and a half ropes is nobody\'s count'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('5 is odd, so no whole count'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the green over', (tester) async {
    await open(tester, which: 3);
    await stringAll(tester, fano);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Closed.'), findsNothing);
  });
}
