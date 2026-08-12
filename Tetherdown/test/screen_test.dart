import 'package:flutter_test/flutter_test.dart';

import 'support/downland.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh down names itself and its task', (tester) async {
    await open(tester, which: 2);
    expect(find.text('The Six'), findsOneWidget);
    expect(
      find.textContaining('tie 6 ropes between 5 posts'),
      findsOneWidget,
    );
    expect(
      find.text('0 tied, 6 to go; nothing knotted.'),
      findsOneWidget,
    );
  });

  testWidgets('two taps tie a rope and the chips count it',
      (tester) async {
    await open(tester, which: 2);
    await tapPost(tester, 0);
    expect(
      find.text('Picked post 1; tap another to rope them.'),
      findsOneWidget,
    );
    await tapPost(tester, 2);
    expect(state(tester).play.ropes, [(0, 2)]);
    expect(find.text('ropes 1 of 6'), findsOneWidget);
  });

  testWidgets('a knot is called out by its posts', (tester) async {
    await open(tester, which: 1);
    await tieAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    expect(
      find.text('Posts 1, 2 and 3 knot a triangle: untie a side.'),
      findsOneWidget,
    );
    expect(find.text('knots 1'), findsOneWidget);
  });

  testWidgets('the square lands and records', (tester) async {
    await open(tester, which: 0);
    await tieAll(tester, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Tethered.'), findsOneWidget);
    expect(find.textContaining('4 tyings all told'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a tying and unfreezes', (tester) async {
    await open(tester, which: 0);
    await tieAll(tester, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.ropes, hasLength(3));
    expect(find.text('Tethered.'), findsNothing);
  });

  testWidgets('show me names the rope to tie', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final ((a, b), tie) = aim!;
    expect(tie, isTrue);
    expect(
      find.text('Rope posts ${a + 1} and ${b + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the fence line and the pastures',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('a quarter of the square of the posts'),
      findsOneWidget,
    );
    expect(find.textContaining('counts 10 landing'), findsOneWidget);
    expect(
      find.textContaining('pastures of three and three'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless down admits it and speaks the pastures',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 6; round++) {
      await tieRope(tester, (0, 1));
      await tieRope(tester, (0, 1));
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The seventh rope knots.'), findsOneWidget);
    expect(
      find.textContaining('six ropes at their best split'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('found a triangle in each'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the down over', (tester) async {
    await open(tester, which: 0);
    await tieAll(tester, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Tethered.'), findsNothing);
  });
}
