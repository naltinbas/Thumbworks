import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/knotland.dart';

/// One rope on the screen, marked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a rope opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('stand two pegs on the rope of twelve knots so the corner comes square'),
      findsOneWidget,
    );
    expect(find.text('pegs 0 of 2'), findsOneWidget);
    expect(find.text('squares waiting'), findsOneWidget);
    expect(find.text('corner open'), findsOneWidget);
    expect(find.text('Pegs 0 of 2 stand; tap a knot.'), findsOneWidget);
  });

  testWidgets('pegs stand, the corner reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await standAll(tester, [2, 7]);
    expect(find.text('sides 2, 5, 5'), findsOneWidget);
    expect(find.text('squares 4 + 25 against 25'), findsOneWidget);
    expect(find.text('corner sharp'), findsOneWidget);
    expect(find.text('Sharp corner: 4 + 25 is 29 against 25, 4 over.'), findsOneWidget);
    await tapKnot(tester, 7);
    expect(state(tester).play.marks, [2]);
    expect(find.text('pegs 1 of 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.marks, [2, 7]);
  });

  testWidgets('a rope that will not close says so', (tester) async {
    await open(tester, which: 0);
    await standAll(tester, [3, 6]);
    expect(find.text('No triangle: 3 + 3 is not more than 6.'), findsOneWidget);
    expect(find.text('corner none'), findsOneWidget);
  });

  testWidgets('a blunt corner reads short', (tester) async {
    await open(tester, which: 4);
    await standAll(tester, [5, 14]);
    expect(find.text('Blunt corner: 25 + 81 is 106 against 121, 15 short.'), findsOneWidget);
    expect(find.text('corner blunt'), findsOneWidget);
  });

  testWidgets('the twelve squares and shows the card', (tester) async {
    await open(tester, which: 0);
    await standAll(tester, [3, 7]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Square: 9 + 16 = 25.'), findsOneWidget);
    expect(find.text('sides 3, 4, 5'), findsOneWidget);
    expect(find.text('corner square'), findsOneWidget);
    expect(
      find.textContaining('The corner is square; 2 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a knot', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Stand a peg on the ringed knot.'), findsOneWidget);
  });

  testWidgets('show me rings a peg off the marking to lift', (tester) async {
    await open(tester, which: 1);
    await standAll(tester, [7]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 7));
    expect(find.text('Lift the ringed peg: it is off the marking.'), findsOneWidget);
  });

  testWidgets('the pointer lands the sixty', (tester) async {
    await open(tester, which: 3);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('corner square'), findsOneWidget);
  });

  testWidgets('the hopeless rope cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    await standAll(tester, [5, 14]);
    for (var dither = 0; dither < 5; dither++) {
      await standAll(tester, [14, 14]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('An odd rope never squares.'), findsOneWidget);
    expect(
      find.textContaining('a square corner needs an even count of knots'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the remainders', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Every square leaves nought or one when divided by four'),
      findsOneWidget,
    );
    expect(
      find.textContaining('nor does any odd rope, swept to two hundred'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the thirty names Euclid\'s numbers', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('reads each corner two ways that must agree'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Euclid\'s with m 3 and n 2'),
      findsOneWidget,
    );
  });
}
