import 'package:carterfen/round/rounds_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/round.dart';

void main() {
  testWidgets('a round opens at the yard', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.called, [0]);
    expect(play.gone, 0);
    expect(find.text(Rounds.at(2).name), findsOneWidget);
    expect(find.textContaining('still to call at'), findsOneWidget);
  });

  testWidgets('tapping a farm drives there', (tester) async {
    await open(tester, which: 2);
    await driveTo(tester, 3);

    final play = state(tester).play;
    expect(play.at, 3);
    expect(play.gone, play.moor.between(0, 3));
  });

  testWidgets('and a farm it has called at says so', (tester) async {
    await open(tester, which: 2);
    await driveTo(tester, 3);
    await driveTo(tester, 3);
    expect(find.textContaining('already called'), findsOneWidget);
    expect(state(tester).play.called, hasLength(2));
  });

  testWidgets('and the yard says it comes home on its own', (tester) async {
    await open(tester, which: 2);
    await driveTo(tester, 0);
    expect(find.textContaining('gets there on its own'), findsOneWidget);
  });

  testWidgets('a call that costs something says how much', (tester) async {
    // The one thing the game says on its own, and it can say it because it
    // works out the shortest way home from where the cart is standing.
    await open(tester, which: 4);
    final play = state(tester).play;

    var said = false;
    for (var stop = 1; stop < play.count && !said; stop++) {
      await open(tester, which: 4);
      await driveTo(tester, stop);
      final after = state(tester).play;
      if (after.gone + after.restOfIt.length > Rounds.at(4).shortest) {
        said = true;
      }
    }
    expect(said, isTrue);
    expect(find.textContaining('over the'), findsOneWidget);
  });

  testWidgets('Take back undoes the last call', (tester) async {
    await open(tester, which: 2);
    await driveTo(tester, 2);
    await press(tester, 'Take back');

    expect(state(tester).play.at, 0);
    expect(state(tester).play.gone, 0);
  });

  testWidgets('Show me names the next farm', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, isNonNegative);
    expect(screen.hints, 1);
    expect(find.textContaining('next.'), findsOneWidget);
    expect(find.textContaining('to get home from here'), findsOneWidget);
  });

  testWidgets('every round can be driven shortest through the screen',
      (tester) async {
    // The proof that the game is playable: every round driven by tapping
    // farms, coming home in the fewest furlongs there are.
    for (var which = 0; which < Rounds.count; which++) {
      await open(tester, which: which);
      await driveItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Rounds.at(which).name);
      expect(play.length, Rounds.at(which).shortest,
          reason: Rounds.at(which).name);
      expect(find.bySemanticsLabel('home again'), findsOneWidget,
          reason: Rounds.at(which).name);
    }
  });
}
