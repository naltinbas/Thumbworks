import 'package:flutter_test/flutter_test.dart';
import 'package:churnwick/churn/dairies.dart';

import '../support/churn.dart';

void main() {
  testWidgets('a morning opens with empty churns', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.standing, [0, 0]);
    expect(play.goes, 0);
    expect(find.text(Mornings.at(0).name), findsOneWidget);
    expect(find.textContaining('4 gallons wanted'), findsOneWidget);
  });

  testWidgets('picking a churn up and filling it from the vat',
      (tester) async {
    await open(tester, which: 0);
    await fill(tester, 1);

    expect(state(tester).play.standing, [0, 5]);
    expect(state(tester).play.goes, 1);
    expect(state(tester).play.holding, -1);
  });

  testWidgets('pouring one churn into another', (tester) async {
    await open(tester, which: 0);
    await fill(tester, 1);
    await tip(tester, 1, 0);

    expect(state(tester).play.standing, [3, 2]);
    expect(state(tester).play.goes, 2);
  });

  testWidgets('and emptying one down the drain', (tester) async {
    await open(tester, which: 0);
    await fill(tester, 1);
    await drain(tester, 1);

    expect(state(tester).play.standing, [0, 0]);
    expect(state(tester).play.goes, 2);
  });

  testWidgets('tapping the vat with nothing picked up says so', (tester) async {
    await open(tester, which: 0);
    await tapVat(tester);

    expect(state(tester).play.goes, 0);
    expect(find.text('Pick a churn up first.'), findsOneWidget);
  });

  testWidgets('a pour that would change nothing says so', (tester) async {
    await open(tester, which: 0);
    await fill(tester, 1);
    await fill(tester, 1);

    expect(state(tester).play.goes, 1);
    expect(find.text('That would not change anything.'), findsOneWidget);
  });

  testWidgets('Take back undoes the last one and Again empties everything',
      (tester) async {
    await open(tester, which: 0);
    await fill(tester, 1);
    await tip(tester, 1, 0);
    await press(tester, 'Take back');
    expect(state(tester).play.standing, [0, 5]);

    await press(tester, 'Again');
    expect(state(tester).play.standing, [0, 0]);
    expect(state(tester).play.goes, 0);
  });

  testWidgets('it says when the fewest has been thrown away', (tester) async {
    // On three and five, filling the three first is the wrong way round.
    await open(tester, which: 0);
    await fill(tester, 0);

    expect(state(tester).play.couldFinishIn, greaterThan(6));
    expect(find.textContaining('The best this can be finished in now is'),
        findsOneWidget);
  });

  testWidgets('Show me does the next thing and says what it did',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    expect(state(tester).hints, 1);
    expect(state(tester).play.goes, 1);
    expect(find.textContaining('more after that'), findsOneWidget);
  });

  testWidgets('Why says what a dairy can measure at all', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');

    expect(state(tester).showSteps, isTrue);
    expect(find.textContaining('Every churn here is a whole number of 2'),
        findsOneWidget);
    expect(find.textContaining('2, 4, 6, 8, 10'), findsOneWidget);
  });

  testWidgets('and on a dairy where everything can be measured it says that',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(find.textContaining('no whole number in common but one'),
        findsOneWidget);
  });

  testWidgets('every morning can be measured out in the fewest through the '
      'screen', (tester) async {
    // The proof that the game is playable: every morning measured out by
    // tapping churns, in as few goes as it can be done in.
    for (var which = 0; which < Mornings.count; which++) {
      final morning = Mornings.at(which);
      await open(tester, which: which);
      await measureItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: morning.name);
      expect(play.isFewest, isTrue, reason: morning.name);
      expect(play.goes, morning.fewest, reason: morning.name);
      expect(find.bySemanticsLabel('the milk is measured'), findsOneWidget,
          reason: morning.name);
    }
  });

  testWidgets('and the last one can be measured by hand as well',
      (tester) async {
    // Three churns, done with the fingers rather than by asking.
    await open(tester, which: 6);
    for (final pour in Mornings.answerFor(6).how) {
      if (pour.isFill) {
        await fill(tester, pour.churn);
      } else if (pour.isEmpty) {
        await drain(tester, pour.churn);
      } else {
        await tip(tester, pour.churn, pour.into);
      }
    }
    expect(state(tester).play.isFewest, isTrue);
  });
}
