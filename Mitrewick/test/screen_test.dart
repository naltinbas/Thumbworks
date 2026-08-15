import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One board on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a board opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('stand six bishops on the four-by-four board with none on another\'s diagonal'),
      findsOneWidget,
    );
    expect(find.text('bishops 0 of 6'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('diagonals 0 of 7'), findsOneWidget);
    expect(find.text('Bishops 0 of 6, all at peace; tap a square.'), findsOneWidget);
  });

  testWidgets('bishops set, a clash reads, back undoes', (tester) async {
    await open(tester, which: 1);
    await setAll(tester, [(0, 0), (1, 1), (0, 2)]);
    expect(find.text('bishops 3 of 6'), findsOneWidget);
    expect(find.text('clashes 2'), findsOneWidget);
    expect(find.text('diagonals 2 of 7'), findsOneWidget);
    expect(find.text('Bishops at (0, 0) and (1, 1) share a diagonal, and 1 more pair clash.'), findsOneWidget);
    await tapSquare(tester, (1, 1));
    expect(state(tester).play.bishops, hasLength(2));
    await press(tester, 'Back');
    expect(state(tester).play.bishops, hasLength(3));
  });

  testWidgets('a held bishop takes no tap', (tester) async {
    await open(tester, which: 3);
    await tapSquare(tester, (0, 0));
    expect(state(tester).play.moves, 0);
    expect(find.text('bishops 1 of 6'), findsOneWidget);
  });

  testWidgets('the four land and show the card', (tester) async {
    await open(tester, which: 1);
    await setAll(tester, [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Peaceful: 6 bishops, no two on a diagonal.'), findsOneWidget);
    expect(find.text('diagonals 6 of 7'), findsOneWidget);
    expect(
      find.textContaining('The bishops stand at peace; 6 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a square', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Set a bishop on the ringed square.'), findsOneWidget);
  });

  testWidgets('show me rings a bishop off the setting to lift', (tester) async {
    await open(tester, which: 1);
    await setAll(tester, [(1, 1)]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', (1, 1)));
    expect(find.text('Lift the ringed bishop: it is off the setting.'), findsOneWidget);
  });

  testWidgets('the pointer lands the held corner', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('bishops 6 of 6'), findsOneWidget);
  });

  testWidgets('the hopeless board cracks at thirteen moves', (tester) async {
    await open(tester, which: 4);
    await setAll(tester, [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2), (3, 3)]);
    expect(find.text('Bishops at (0, 0) and (3, 3) share a diagonal.'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await setAll(tester, [(3, 3), (3, 3)]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Seven never stand at peace.'), findsOneWidget);
    expect(
      find.textContaining('those two corners share the long falling one'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the diagonals', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('there are 7 of them on a board of 4'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the diagonals counted it nought first'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four keeps to the edge', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('walked diagonal by diagonal'),
      findsOneWidget,
    );
    expect(
      find.textContaining('A bishop in the middle four kills it'),
      findsOneWidget,
    );
  });
}
