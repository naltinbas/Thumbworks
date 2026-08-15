import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One hand on the screen, laid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a hand opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('hide one of 2H 9S 5D KC 7H and lay the other four'),
      findsOneWidget,
    );
    expect(find.text('hidden none'), findsOneWidget);
    expect(find.text('laid 0 of 4'), findsOneWidget);
    expect(find.text('partner waiting'), findsOneWidget);
    expect(find.text('Nothing hidden yet; tap a card to hide it.'), findsOneWidget);
  });

  testWidgets('a card hides, cards lay, the partner speaks, back undoes', (tester) async {
    await open(tester, which: 0);
    await tapCard(tester, 32);
    expect(find.text('hidden 7H'), findsOneWidget);
    expect(find.text('7H hidden; 0 of 4 laid.'), findsOneWidget);
    await tapAll(tester, [27, 17, 12, 47]);
    expect(find.text('laid 4 of 4'), findsOneWidget);
    expect(find.text('partner says 4H'), findsOneWidget);
    expect(find.text('The partner names 4H, and 7H is hidden: wrong.'), findsOneWidget);
    await tapCard(tester, 47);
    expect(state(tester).play.row, hasLength(3));
    await press(tester, 'Back');
    expect(state(tester).play.row, hasLength(4));
  });

  testWidgets('the pair of hearts lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [32, 27, 12, 17, 47]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('The partner names 7H: right.'), findsOneWidget);
    expect(find.text('partner says 7H'), findsOneWidget);
    expect(
      find.textContaining('The partner names the hidden card; 5 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me points at the card to hide, then to lay', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('hide', 13));
    expect(find.text('Hide the ringed card.'), findsOneWidget);
    await tapCard(tester, 13);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lay', 20));
    expect(find.text('Lay the ringed card next.'), findsOneWidget);
  });

  testWidgets('the pointer lays the three spades', (tester) async {
    await open(tester, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the fixed card takes no tap, and the hopeless hand cracks at four laid', (tester) async {
    await open(tester, which: 4);
    expect(find.text('hidden 4C'), findsOneWidget);
    await tapCard(tester, 3);
    expect(state(tester).play.hidden, 3);
    await tapAll(tester, [31, 36, 47, 24]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('A lone suit cannot be told.'), findsOneWidget);
    expect(
      find.textContaining('no card of the hidden one\'s suit is left to lay'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the row', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the first card names the suit'),
      findsOneWidget,
    );
    expect(
      find.textContaining('every one of the 24 orders names a card of another suit'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the wrap round goes round the corner', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('2,598,960 hands of the whole deck'),
      findsOneWidget,
    );
    expect(
      find.textContaining('from the 8 round through the king to the ace is six'),
      findsOneWidget,
    );
  });
}
