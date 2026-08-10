import 'package:flutter_test/flutter_test.dart';
import 'package:shardlow/drop/ladders.dart';

import '../support/drop.dart';

void main() {
  testWidgets('a morning opens with everything possible', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.made, 0);
    expect(play.hand, 2);
    expect(find.text(Ladders.at(1).name), findsOneWidget);
    expect(find.textContaining('11 answers still stand'), findsOneWidget);
  });

  testWidgets('tapping a rung drops a pot and says what became of it',
      (tester) async {
    await open(tester, which: 1);
    await drop(tester, 4);

    expect(state(tester).play.made, 1);
    expect(
      find.textContaining(RegExp('It (broke on|lived from) rung 4')),
      findsOneWidget,
    );
  });

  testWidgets('a rung that can teach nothing says so', (tester) async {
    await open(tester, which: 1);
    await drop(tester, 4);
    // Rung 4 settled one way or the other; a rung outside the band refuses.
    final standing = state(tester).play.standing;
    final useless =
        standing.lowest > 0 ? standing.lowest : standing.highest + 1;
    await drop(tester, useless);

    expect(state(tester).play.made, 1);
    expect(find.textContaining('can teach nothing'), findsOneWidget);
  });

  testWidgets('a greedy drop is called out at once', (tester) async {
    await open(tester, which: 1);
    await drop(tester, 10);
    expect(find.textContaining('more than the 4 it takes'), findsOneWidget);
  });

  testWidgets('Take back and Again put the morning back', (tester) async {
    await open(tester, which: 1);
    await drop(tester, 4);
    await press(tester, 'Take back');
    expect(state(tester).play.made, 0);

    await drop(tester, 4);
    await press(tester, 'Again');
    expect(state(tester).play.made, 0);
    expect(state(tester).play.hand, 2);
  });

  testWidgets('Show me points at a rung and promises the rest',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(find.textContaining('whatever happens'), findsOneWidget);
  });

  testWidgets('Why counts the words', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');

    expect(find.textContaining('word of breaks and survivals'), findsOneWidget);
    expect(find.textContaining('11 answers to tell apart'), findsOneWidget);
  });

  testWidgets('the one pot morning goes rung by rung', (tester) async {
    await open(tester, which: 0);
    await settleItAll(tester);

    final play = state(tester).play;
    expect(play.isDone, isTrue);
    expect(play.made, Ladders.at(0).fewest);
    // The referee lets every pot live on the way up, then breaks the last
    // one on the top rung, its tie-break, so the answer lands one short.
    expect(play.answer, Ladders.at(0).rungs - 1);
  });

  testWidgets('every ladder can be settled at par through the screen',
      (tester) async {
    // The proof that the game is playable: every morning settled by tapping
    // rungs, in as few drops as are certain.
    for (var which = 0; which < Ladders.count; which++) {
      final ladder = Ladders.at(which);
      await open(tester, which: which);
      await settleItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: ladder.name);
      expect(play.made, ladder.fewest, reason: ladder.name);
      expect(play.isFewest, isTrue, reason: ladder.name);
      expect(find.bySemanticsLabel('the morning is settled'), findsOneWidget,
          reason: ladder.name);
    }
  });
}
