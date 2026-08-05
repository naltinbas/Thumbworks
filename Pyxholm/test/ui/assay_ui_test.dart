import 'package:flutter_test/flutter_test.dart';
import 'package:pyxholm/assay/boxes.dart';
import 'package:pyxholm/assay/pyx.dart';

import '../support/assay.dart';

void main() {
  testWidgets('a box opens with everything still possible', (tester) async {
    await open(tester, which: 3);
    final play = state(tester).play;

    expect(play.weighings, 0);
    expect(play.standing, hasLength(12));
    expect(find.text(Boxes.at(3).name), findsOneWidget);
    expect(find.textContaining('12 things it could be'), findsOneWidget);
  });

  testWidgets('tapping a coin puts it on the left pan, then the right',
      (tester) async {
    await open(tester, which: 3);
    await move(tester, 0);
    expect(state(tester).play.placeOf(0), 0);
    await move(tester, 0);
    expect(state(tester).play.placeOf(0), 1);
    await move(tester, 0);
    expect(state(tester).play.placeOf(0), -1);
  });

  testWidgets('the pans have to match before Weigh does anything',
      (tester) async {
    await open(tester, which: 3);
    await move(tester, 0);
    await press(tester, 'Weigh');

    expect(state(tester).play.weighings, 0);
    expect(find.textContaining('same number of coins'), findsOneWidget);
  });

  testWidgets('and with nothing on them it says that', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Weigh');
    expect(find.textContaining('Put some coins on the pans'), findsOneWidget);
  });

  testWidgets('weighing narrows it and says by how much', (tester) async {
    await open(tester, which: 3);
    await weigh(tester, [0], [1]);

    final play = state(tester).play;
    expect(play.weighings, 1);
    expect(play.standing, hasLength(8));
    expect(play.told.first.tip, Tip.level);
    expect(find.textContaining('8 things it could still be'), findsOneWidget);
  });

  testWidgets('it says when a weighing has thrown the fewest away',
      (tester) async {
    // On nine coins wrong either way, one against one tells almost nothing.
    await open(tester, which: 4);
    await weigh(tester, [0], [1]);

    expect(state(tester).play.couldFinishIn, greaterThan(3));
    expect(find.textContaining('more than the 3 it takes'), findsOneWidget);
  });

  testWidgets('Take back undoes a weighing, and Again empties the bench',
      (tester) async {
    await open(tester, which: 3);
    await weigh(tester, [0], [1]);
    await press(tester, 'Take back');
    expect(state(tester).play.weighings, 0);

    await weigh(tester, [0], [1]);
    await press(tester, 'Again');
    expect(state(tester).play.weighings, 0);
    expect(state(tester).play.standing, hasLength(12));
  });

  testWidgets('Show me lays a weighing out on the pans', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNotNull);
    expect(screen.play.canWeigh, isTrue);
    expect(screen.play.onLeft, screen.pointing!.left.toSet());
    expect(screen.play.onRight, screen.pointing!.right.toSet());
    expect(find.textContaining('against'), findsOneWidget);
  });

  testWidgets('Why counts the verdicts against what a weighing can tell apart',
      (tester) async {
    await open(tester, which: 6);
    await press(tester, 'Why');

    expect(find.textContaining('24 things to tell apart'), findsOneWidget);
    expect(find.textContaining('at most 9 apart'), findsOneWidget);
  });

  testWidgets('and on the four coin box it says counting was not enough',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(find.textContaining('might have done, by counting alone'),
        findsOneWidget);
  });

  testWidgets('every box can be settled in the fewest through the screen',
      (tester) async {
    // The proof that the game is playable: every box settled by tapping
    // coins onto pans, on as few weighings as it can be done in.
    for (var which = 0; which < Boxes.count; which++) {
      final pyx = Boxes.at(which);
      await open(tester, which: which);
      await settleItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: pyx.name);
      expect(play.weighings, pyx.fewest, reason: pyx.name);
      expect(play.isFewest, isTrue, reason: pyx.name);
      expect(find.bySemanticsLabel('the coin is found'), findsOneWidget,
          reason: pyx.name);
    }
  });
}
