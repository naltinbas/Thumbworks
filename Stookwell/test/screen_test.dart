import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One harvest on the screen, stooked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a harvest opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('stand seven sheaves in stooks of different sizes'),
      findsOneWidget,
    );
    expect(find.text('stood 0 of 7'), findsOneWidget);
    expect(find.text('stooks 0'), findsOneWidget);
    expect(find.text('alike 0'), findsOneWidget);
    expect(find.text('Nothing stood yet; tap the pool to begin a stook.'), findsOneWidget);
  });

  testWidgets('the pool begins a stook, a stook takes more, back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPool(tester);
    await tapStook(tester, 0);
    await tapPool(tester);
    await tapStook(tester, 1);
    expect(state(tester).play.stooks, [2, 2]);
    expect(find.text('stood 4 of 7'), findsOneWidget);
    expect(find.text('alike 1'), findsOneWidget);
    expect(find.text('Stooks 2, 2; 3 sheaves to stand.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.stooks, [2, 1]);
  });

  testWidgets('the seven apart land and show the card', (tester) async {
    await open(tester, which: 0);
    await stand(tester, [4, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Stood: 4, 2, 1, all apart.'), findsOneWidget);
    expect(find.text('stooks 3'), findsOneWidget);
    expect(
      find.textContaining('The stooks stand as asked; 7 sheaves stood.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a standing not as asked ends short', (tester) async {
    await open(tester, which: 1);
    await stand(tester, [4, 3]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('All stood, but a stook holds 4, which is even.'), findsOneWidget);
    expect(find.text('Not as asked.'), findsOneWidget);
    expect(find.text('even stooks 1'), findsOneWidget);
    await press(tester, 'Again');
    expect(state(tester).play.stooks, isEmpty);
  });

  testWidgets('show me points at the pool, a stook, or back', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('new', 0));
    expect(find.text('Begin a new stook from the pool.'), findsOneWidget);
    await tapPool(tester);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('add', 0));
    expect(find.text('Stand one more sheaf in the ringed stook.'), findsOneWidget);
    await tapPool(tester);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('back', 0));
    expect(find.text('Take a sheaf back: this standing has strayed.'), findsOneWidget);
  });

  testWidgets('the pointer lands the twelve odd', (tester) async {
    await open(tester, which: 3);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('stood 12 of 12'), findsOneWidget);
  });

  testWidgets('the hopeless harvest cracks when every sheaf is stood', (tester) async {
    await open(tester, which: 4);
    await stand(tester, [4, 3, 1, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('All stood, but two stooks hold 1 alike.'), findsOneWidget);
    expect(find.text('Nine never make four apart.'), findsOneWidget);
    expect(
      find.textContaining('four different sizes hold at the least 1, 2, 3 and 4 sheaves'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts to ten', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('nine sheaves are one short'),
      findsOneWidget,
    );
    expect(
      find.textContaining('eight are all apart, and none of those has four stooks'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the seven odd names Glaisher', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('which is Euler\'s identity'),
      findsOneWidget,
    );
    expect(
      find.textContaining('3, 3, 1 becomes 6 and 1'),
      findsOneWidget,
    );
  });
}
