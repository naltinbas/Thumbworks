import 'package:flutter_test/flutter_test.dart';

import 'support/coteland.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh cote names itself and its round', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Four'), findsOneWidget);
    expect(
      find.textContaining('pair 4 players over 3 rounds'),
      findsOneWidget,
    );
    expect(
      find.text('Round 1 filling: 0 of 2 games paired.'),
      findsOneWidget,
    );
  });

  testWidgets('a pairing lands in the filling round', (tester) async {
    await open(tester, which: 0);
    await tapPlayer(tester, 0);
    expect(
      find.text('Player 1 waits; tap a partner.'),
      findsOneWidget,
    );
    await tapPlayer(tester, 1);
    expect(state(tester).play.filling, [(0, 1)]);
    expect(find.text('pairs 1 of 6'), findsOneWidget);
  });

  testWidgets('the four fixes and records', (tester) async {
    await open(tester, which: 0);
    await pairAll(tester, const [
      [(0, 1), (2, 3)],
      [(0, 2), (1, 3)],
      [(0, 3), (1, 2)],
    ]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Fixed.'), findsOneWidget);
    expect(find.textContaining('6 pairings'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a pairing and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await pairAll(tester, const [
      [(0, 1), (2, 3)],
      [(0, 2), (1, 3)],
      [(0, 3), (1, 2)],
    ]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Fixed.'), findsNothing);
  });

  testWidgets('show me names the pair', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Pair players ${aim!.$1 + 1} and '
          '${aim.$2 + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the cover and the sweep', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('every pair of players met exactly '
          'once'),
      findsOneWidget,
    );
    expect(find.textContaining('720 land'), findsOneWidget);
  });

  testWidgets('the hopeless cote admits it and sits someone',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 4; round++) {
      await pairUp(tester, (0, 1));
      await pairUp(tester, (0, 1));
    }
    expect(state(tester).play.moves, 8);
    expect(find.text('Someone always sits.'), findsOneWidget);
    expect(
      find.textContaining('five is odd'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('whoever pairs, someone is left'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the cote over', (tester) async {
    await open(tester, which: 0);
    await pairAll(tester, const [
      [(0, 1), (2, 3)],
      [(0, 2), (1, 3)],
      [(0, 3), (1, 2)],
    ]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Fixed.'), findsNothing);
  });
}
