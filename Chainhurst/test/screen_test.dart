import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hurst.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh field names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The One Chain'), findsOneWidget);
    expect(
      find.textContaining('set 3 stones showing 0 bare chains'),
      findsOneWidget,
    );
    expect(find.text('0 set, 3 to go; 0 bare so far.'), findsOneWidget);
  });

  testWidgets('a row of three lands the one chain', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 4), (2, 2), (4, 0)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.textContaining('3 touches'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('the chips count bare and laden as stones go down',
      (tester) async {
    await open(tester, which: 2);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (1, 3)]);
    expect(find.text('bare 3'), findsOneWidget);
    expect(find.text('laden 1'), findsOneWidget);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('tapping a stone lifts it again', (tester) async {
    await open(tester, which: 0);
    await tapCross(tester, 2, 2);
    expect(state(tester).play.stones, hasLength(1));
    await tapCross(tester, 2, 2);
    expect(state(tester).play.stones, isEmpty);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('the row bar speaks when five share a row', (tester) async {
    await open(tester, which: 3);
    await setAll(
        tester, const [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]);
    expect(state(tester).play.isDone, isFalse);
    expect(
      find.text('All 5 share one row: the asking bars it.'),
      findsOneWidget,
    );
  });

  testWidgets('back takes back a touch and unfreezes the field',
      (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (1, 1), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.stones, hasLength(2));
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a crossing and says which way',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.text('Set a stone on the ringed crossing.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the ways', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(find.textContaining('all 68,080'), findsOneWidget);
    expect(
      find.textContaining('3,088 placings land this field'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nought, three, or six'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless field admits it and speaks the law',
      (tester) async {
    await open(tester, which: 4);
    await setAll(
        tester, const [(0, 0), (1, 0), (2, 0), (3, 0), (0, 1)]);
    for (var touch = 5; touch < 16; touch++) {
      await tapCross(tester, 0, 1);
    }
    expect(state(tester).play.moves, 16);
    expect(find.text('No bare-less field.'), findsOneWidget);
    expect(
      find.textContaining('the twelve rows the asking bars'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('Sylvester and Gallai'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the field over', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (1, 1), (2, 2)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Landed.'), findsNothing);
  });
}
