import 'package:flutter_test/flutter_test.dart';
import 'package:rimeworth/round/parishes.dart';

import '../support/round.dart';

void main() {
  testWidgets('a parish opens with the lorry not yet set down', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.at, -1);
    expect(play.runs, 0);
    expect(play.done, 0);
    expect(find.text(Grittings.at(1).name), findsOneWidget);
    expect(find.textContaining('0 of 8 lanes salted'), findsOneWidget);
  });

  testWidgets('the first tap sets the lorry down', (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);

    final play = state(tester).play;
    expect(play.at, 0);
    expect(play.runs, 1);
    expect(play.done, 0);
  });

  testWidgets('and the next one salts a lane', (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);
    await drive(tester, 1);

    final play = state(tester).play;
    expect(play.at, 1);
    expect(play.done, 1);
  });

  testWidgets('a tap on a lane drives down it', (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);
    await driveLane(tester, 1);

    final play = state(tester).play;
    expect(play.done, 1);
    expect(play.salted, [1]);
  });

  testWidgets('a tap somewhere it cannot reach says so', (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);
    await drive(tester, 4);

    expect(state(tester).play.done, 0);
    expect(find.textContaining('No lane from'), findsOneWidget);
  });

  testWidgets('a lane cannot be salted twice', (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);
    await drive(tester, 1);
    await drive(tester, 0);

    expect(state(tester).play.done, 1);
  });

  testWidgets('it says when the fewest runs has been thrown away',
      (tester) async {
    // Gable Row takes one run, and it has to start at one of the two
    // junctions with three lanes on them. Setting off anywhere else costs a
    // run, and the game says so as soon as it does.
    await open(tester, which: 1);
    await drive(tester, 4);
    await drive(tester, 2);

    expect(state(tester).play.couldFinishIn, 2);
    expect(find.textContaining('The best this can be finished in now is 2'),
        findsOneWidget);
  });

  testWidgets('Take back undoes a lane, and Again empties the parish',
      (tester) async {
    await open(tester, which: 1);
    await drive(tester, 0);
    await drive(tester, 1);
    await press(tester, 'Take back');
    expect(state(tester).play.done, 0);
    expect(state(tester).play.at, 0);

    await drive(tester, 1);
    await press(tester, 'Again');
    expect(state(tester).play.done, 0);
    expect(state(tester).play.runs, 0);
    expect(state(tester).play.at, -1);
  });

  testWidgets('Show me names a junction a run has to start at', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(Grittings.at(1).parish.oddJunctions, contains(screen.pointing));
    expect(find.textContaining('so a run has to start or finish there'),
        findsOneWidget);
  });

  testWidgets('and part way through it points at where to go next',
      (tester) async {
    await open(tester, which: 2);
    await drive(tester, 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, isNonNegative);
    expect(screen.play.laneTo(screen.pointing), isNonNegative);
  });

  testWidgets('Why rings the odd junctions and counts them', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');

    expect(state(tester).showOdd, isTrue);
    expect(find.textContaining('have an odd number of lanes'), findsOneWidget);
    expect(find.textContaining('2 runs is the fewest'), findsOneWidget);
  });

  testWidgets('and on a parish where every junction is even it says that',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(find.textContaining('finishes where it set off'), findsOneWidget);
  });

  testWidgets('a stuck lorry is set down again by tapping somewhere else',
      (tester) async {
    await open(tester, which: 2);
    var guard = 0;
    while (!state(tester).play.isStuck && !state(tester).play.isDone) {
      if (guard++ > 40) fail('it never got stuck');
      await drive(tester, state(tester).play.next!);
    }
    expect(state(tester).play.isStuck, isTrue);

    final away = state(tester).play.next!;
    final runs = state(tester).play.runs;
    await drive(tester, away);
    expect(state(tester).play.runs, runs + 1);
    expect(state(tester).play.at, away);
  });

  testWidgets('every parish can be salted in the fewest through the screen',
      (tester) async {
    // The proof that the game is playable: every parish driven by tapping
    // junctions, in as few runs as it can be done in.
    for (var which = 0; which < Grittings.count; which++) {
      final gritting = Grittings.at(which);
      await open(tester, which: which);
      await saltItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: gritting.name);
      expect(play.runs, gritting.runs, reason: gritting.name);
      expect(find.bySemanticsLabel('the parish is salted'), findsOneWidget,
          reason: gritting.name);
    }
  });
}
