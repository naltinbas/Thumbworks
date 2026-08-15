import 'package:flutter_test/flutter_test.dart';
import 'package:studwell/court/rules.dart';

import 'support/fonts.dart';
import 'support/studland.dart';

/// One court on the screen, paved as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a court opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('pave the five-court round the well with 8 elbows'),
      findsOneWidget,
    );
    expect(find.text('elbows 0 of 8'), findsOneWidget);
    expect(find.text('studs bare 8'), findsOneWidget);
    expect(find.text('Elbows laid 0 of 8.'), findsOneWidget);
  });

  testWidgets('the four-court counts bare flags instead',
      (tester) async {
    await open(tester, which: 0);
    expect(find.text('elbows 0 of 5'), findsOneWidget);
    expect(find.text('flags bare 15'), findsOneWidget);
  });

  testWidgets('three taps lay an elbow and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 1);
    expect(state(tester).play.pending, [1]);
    expect(
      find.text('One flag picked; two more make an elbow.'),
      findsOneWidget,
    );
    await tapCell(tester, 2);
    expect(
      find.text('Two flags picked; one more makes an elbow.'),
      findsOneWidget,
    );
    await tapCell(tester, 6);
    expect(state(tester).play.laid, [
      [1, 2, 6]
    ]);
    expect(find.text('elbows 1 of 5'), findsOneWidget);
    expect(find.text('flags bare 12'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.laid, isEmpty);
    expect(find.text('flags bare 15'), findsOneWidget);
  });

  testWidgets('the well takes no tap', (tester) async {
    await open(tester, which: 4);
    await tapCell(tester, 11);
    expect(state(tester).play.pending, isEmpty);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a laid elbow lifts on a tap', (tester) async {
    await open(tester, which: 0);
    await lay(tester, [1, 2, 6]);
    await tapCell(tester, 6);
    expect(state(tester).play.laid, isEmpty);
    expect(state(tester).play.moves, 2);
  });

  testWidgets('the corner well paves by hand and shows the card',
      (tester) async {
    await open(tester, which: 0);
    for (final elbow in Rules(4, 0).quartering()!) {
      await lay(tester, elbow);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paved.'), findsOneWidget);
    expect(
      find.textContaining('Every flag under an elbow; 5 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Paved.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings an elbow', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(state(tester).pointing!.$1, 'lay');
    expect(
      find.textContaining('Lay the ringed elbow'),
      findsOneWidget,
    );
  });

  testWidgets('show me rings a stray elbow to lift', (tester) async {
    await open(tester, which: 0);
    await lay(tester, [1, 2, 6]);
    await press(tester, 'Show me');
    expect(state(tester).pointing!.$1, 'lift');
    expect(
      find.textContaining('Lift the ringed elbow'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer paves the wall well', (tester) async {
    await open(tester, which: 2);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 8);
  });

  testWidgets('the hopeless court cracks at thirteen moves',
      (tester) async {
    await open(tester, which: 4);
    const seven = [
      [0, 5, 6],
      [1, 2, 7],
      [3, 8, 9],
      [10, 15, 16],
      [12, 13, 18],
      [17, 21, 22],
      [19, 23, 24],
    ];
    for (final elbow in seven) {
      await lay(tester, elbow);
    }
    expect(find.text('studs bare 3'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await tapCell(tester, 0);
      await lay(tester, [0, 5, 6]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The stray well never paves.'), findsOneWidget);
    expect(
      find.textContaining('one stud to an elbow at most'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the studs', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('nine studs, one to every two-by-two'),
      findsOneWidget,
    );
    expect(
      find.textContaining('seven elbows can be laid'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four-court speaks the quartering',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('Golomb\'s quartering builds a paving'),
      findsOneWidget,
    );
    expect(
      find.textContaining('sixteen wells of the four-court'),
      findsOneWidget,
    );
  });
}
