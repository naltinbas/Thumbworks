import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// One share on the screen, dealt as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a share opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('share the tokens 1 to 8, four and four'),
      findsOneWidget,
    );
    expect(find.text('trays 8 · 0'), findsOneWidget);
    expect(find.text('sums 36 · 0'), findsOneWidget);
    expect(find.text('squares 204 · 0'), findsOneWidget);
    expect(find.text('cubes 1296 · 0'), findsNothing);
    expect(
      find.textContaining('Trays hold 8 and 0; 4 each wanted.'),
      findsOneWidget,
    );
  });

  testWidgets('a tap carries a token and the chips follow',
      (tester) async {
    await open(tester, which: 1);
    await carry(tester, [2, 3, 5, 8]);
    expect(state(tester).play.rightTray, [2, 3, 5, 8]);
    expect(find.text('trays 4 · 4'), findsOneWidget);
    expect(find.text('sums 18 · 18'), findsOneWidget);
    expect(find.text('squares 102 · 102'), findsOneWidget);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Shared.'), findsOneWidget);
    expect(
      find.textContaining('Every power agreeing across the trays; 4 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Shared.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a part share says which powers agree', (tester) async {
    await open(tester, which: 1);
    await carry(tester, [5, 6, 7, 8]);
    expect(find.text('trays 4 · 4'), findsOneWidget);
    expect(find.text('sums 10 · 26'), findsOneWidget);
    expect(
      find.text('Half and half, no power agreeing yet.'),
      findsOneWidget,
    );
    await carry(tester, [8, 7]);
    expect(
      find.text('Trays hold 6 and 2; 4 each wanted.'),
      findsOneWidget,
    );
    await carry(tester, [3, 4]);
    expect(state(tester).play.rightTray, [3, 4, 5, 6]);
    expect(find.text('sums 18 · 18'), findsOneWidget);
    expect(find.text('squares 118 · 86'), findsOneWidget);
    expect(find.text('sums agree; 1 to go.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.rightTray, [3, 5, 6]);
  });

  testWidgets('show me rings a token', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 2);
    expect(
      find.textContaining('Carry token 2 across'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer deals the dozen', (tester) async {
    await open(tester, which: 2);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(state(tester).play.leftTray, [1, 3, 7, 8, 9, 11]);
  });

  testWidgets('the hopeless share cracks at eight moves',
      (tester) async {
    await open(tester, which: 4);
    await carry(tester, [2, 3]);
    expect(find.text('sums 5 · 5'), findsOneWidget);
    expect(find.text('squares 17 · 13'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await carry(tester, [1, 1]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The four never square.'), findsOneWidget);
    expect(
      find.textContaining('its squares are 17 against 13'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the three pairings', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('three pairings, and you can read them all'),
      findsOneWidget,
    );
    expect(
      find.textContaining('whose squares come to 17 and 13'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the sixteen speaks the doubling',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Prouhet\'s doubling pattern is dealt'),
      findsOneWidget,
    );
    expect(
      find.textContaining('263 agree in sums'),
      findsOneWidget,
    );
  });
}
