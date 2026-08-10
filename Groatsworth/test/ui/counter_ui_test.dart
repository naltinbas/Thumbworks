import 'package:flutter_test/flutter_test.dart';
import 'package:groatsworth/till/rounds.dart';

import '../support/counter.dart';

void main() {
  testWidgets('a round opens with an empty tray', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.used, 0);
    expect(play.owed, 48);
    expect(find.text(Rounds.at(2).name), findsOneWidget);
    expect(find.textContaining('4/- wanted'), findsOneWidget);
  });

  testWidgets('tapping a till coin puts it down', (tester) async {
    await open(tester, which: 2);
    await put(tester, 4);

    expect(state(tester).play.onTray(4), 1);
    expect(state(tester).play.owed, 24);
  });

  testWidgets('and tapping it on the tray takes it back', (tester) async {
    await open(tester, which: 2);
    await put(tester, 4);
    await take(tester, 0);
    expect(state(tester).play.used, 0);
  });

  testWidgets('a coin that would go over is refused with a word',
      (tester) async {
    await open(tester, which: 0);
    await put(tester, 5);
    expect(state(tester).play.isDone, isTrue);

    await open(tester, which: 2);
    await put(tester, 4);
    await put(tester, 5);
    expect(state(tester).play.onTray(5), 0);
    expect(find.textContaining('would go over'), findsOneWidget);
  });

  testWidgets('the wrong coin is called out at once', (tester) async {
    // The half crown on Four Bob strands the amount between coins.
    await open(tester, which: 2);
    await put(tester, 5);

    expect(find.textContaining('more than the 2 it takes'), findsOneWidget);
  });

  testWidgets('Again empties the tray', (tester) async {
    await open(tester, which: 2);
    await put(tester, 4);
    await press(tester, 'Again');
    expect(state(tester).play.used, 0);
  });

  testWidgets('Show me names the coin and how many follow', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(find.textContaining('more after it'), findsOneWidget);
  });

  testWidgets('Why gives the floor, and the trap where there is one',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');

    expect(find.textContaining('come to at most'), findsOneWidget);
    expect(find.textContaining('Two florins go further'), findsOneWidget);
  });

  testWidgets('and on the new till it says the quick way always works',
      (tester) async {
    await open(tester, which: 6);
    await press(tester, 'Why');
    expect(find.textContaining('always the fewest'), findsOneWidget);
  });

  testWidgets('a round paid the long way says so at the end', (tester) async {
    await open(tester, which: 2);
    await put(tester, 5);
    await payItAll(tester);

    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.isFewest, isFalse);
    expect(find.textContaining('It can be done in 2'), findsOneWidget);
  });

  testWidgets('every round can be paid in the fewest through the screen',
      (tester) async {
    // The proof that the game is playable: every customer served by tapping
    // coins, in as few coins as the till allows.
    for (var which = 0; which < Rounds.count; which++) {
      final round = Rounds.at(which);
      await open(tester, which: which);
      await payItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: round.name);
      expect(play.isFewest, isTrue, reason: round.name);
      expect(play.used, round.fewest, reason: round.name);
      expect(find.bySemanticsLabel('the amount is met'), findsOneWidget,
          reason: round.name);
    }
  });
}
