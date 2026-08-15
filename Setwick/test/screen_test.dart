import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/setland.dart';

/// One set on the screen, paired as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a set opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('pair off the dancers 2 to 9 of the set of 11'),
      findsOneWidget,
    );
    expect(find.text('pairs 0 of 4'), findsOneWidget);
    expect(find.text('come to one 0'), findsOneWidget);
    expect(find.text('Pairs made 0 of 4.'), findsOneWidget);
  });

  testWidgets('a pick shows, a pair threads, a lift undoes',
      (tester) async {
    await open(tester, which: 1);
    await tapDancer(tester, 2);
    expect(state(tester).play.picked, 2);
    expect(find.text('Dancer 2 picked; tap a partner.'), findsOneWidget);
    await tapDancer(tester, 6);
    expect(state(tester).play.couples, [(2, 6)]);
    expect(find.text('pairs 1 of 4'), findsOneWidget);
    expect(find.text('come to one 1'), findsOneWidget);
    await pair(tester, 3, 5);
    expect(find.text('1 pair does not come to one.'), findsOneWidget);
    await tapDancer(tester, 3);
    expect(state(tester).play.couples, [(2, 6)]);
    await press(tester, 'Back');
    expect(state(tester).play.couples, [(2, 6), (3, 5)]);
  });

  testWidgets('1 and 10 take no tap', (tester) async {
    await open(tester, which: 1);
    await tapDancer(tester, 1);
    await tapDancer(tester, 10);
    expect(state(tester).play.picked, isNull);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the set of seven pairs off and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await pair(tester, 2, 4);
    await pair(tester, 3, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paired off.'), findsOneWidget);
    expect(
      find.textContaining('the whole set to 6 over 7; 2 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Paired off.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a pair', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('pair', 2, 7));
    expect(
      find.text('Pair the ringed dancers: 2 and 7 come to one.'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer pairs off the thirteen', (tester) async {
    await open(tester, which: 2);
    await pairByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
  });

  testWidgets('the hopeless set cracks at nine moves', (tester) async {
    await open(tester, which: 4);
    await pair(tester, 2, 5);
    await pair(tester, 4, 7);
    await pair(tester, 3, 6);
    expect(find.text('come to one 2'), findsOneWidget);
    for (var dither = 0; dither < 3; dither++) {
      await tapDancer(tester, 3);
      await pair(tester, 3, 6);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The set of nine never pairs.'), findsOneWidget);
    expect(
      find.textContaining('3 and 6 share a factor with nine'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the row of three', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Nine is three threes'),
      findsOneWidget,
    );
    expect(
      find.textContaining('8! is 4,480 nines exactly'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the seventeen speaks Wilson', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('that is Wilson\'s theorem'),
      findsOneWidget,
    );
    expect(
      find.textContaining('1,230,752,346,352 seventeens and 16'),
      findsOneWidget,
    );
  });
}
