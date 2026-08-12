import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leigh.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh fold names itself and its task', (tester) async {
    await open(tester, which: 1);
    expect(find.text('The Fan'), findsOneWidget);
    expect(
      find.textContaining('so some post corners 4 pens'),
      findsOneWidget,
    );
    expect(find.text('0 laid, 3 to go.'), findsOneWidget);
  });

  testWidgets('a pick and a lay, with rim neighbours refused',
      (tester) async {
    await open(tester, which: 1);
    await tapPost(tester, 0);
    expect(
      find.textContaining('Post 1 picked'),
      findsOneWidget,
    );
    await tapPost(tester, 1);
    expect(state(tester).play.hurdles, isEmpty);
    await layHurdle(tester, (0, 2));
    expect(state(tester).play.hurdles, [(0, 2)]);
    expect(find.text('hurdles 1 of 3'), findsOneWidget);
  });

  testWidgets('the pentagon folds and records', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, const [(0, 2), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Folded.'), findsOneWidget);
    expect(find.textContaining('2 layings'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a crossing is called out', (tester) async {
    await open(tester, which: 1);
    await layAll(tester, const [(0, 2), (1, 3)]);
    expect(
      find.text('Two hurdles cross: lift one.'),
      findsOneWidget,
    );
  });

  testWidgets('a fenced miss asks for a relay', (tester) async {
    await open(tester, which: 3);
    await layAll(tester, const [(0, 2), (0, 3), (0, 4)]);
    expect(
      find.text('Folded, but the crowns miss the asking: lift '
          'and relay.'),
      findsOneWidget,
    );
  });

  testWidgets('back takes back a laying and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await layAll(tester, const [(0, 2), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Folded.'), findsNothing);
  });

  testWidgets('show me names the hurdle to lay', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final ((a, b), lay) = aim!;
    expect(lay, isTrue);
    expect(
      find.text('Lay a hurdle from post ${a + 1} to post '
          '${b + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the crowns', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('all 14 foldings laid'),
      findsOneWidget,
    );
    expect(
      find.textContaining('no two foldings sharing one'),
      findsOneWidget,
    );
    expect(find.textContaining('8 foldings land'), findsOneWidget);
  });

  testWidgets('the hopeless fold admits it and speaks the ears',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 6; round++) {
      await layHurdle(tester, (0, 2));
      await layHurdle(tester, (0, 2));
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The ears stay on.'), findsOneWidget);
    expect(
      find.textContaining('two-ears theorem keeps at least two'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('the ears never went below two'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the fold over', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, const [(0, 2), (0, 3)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Folded.'), findsNothing);
  });
}
