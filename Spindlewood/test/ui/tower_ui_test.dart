import 'package:flutter_test/flutter_test.dart';
import 'package:spindlewood/tower/spindles.dart';

import '../support/tower.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the tower stacked', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.made, 0);
      expect(find.text('7 moves from home'), findsOne);
      expect(find.text('0 moved'), findsOne);
    });

    testWidgets('two taps move a round', (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.topOf(2), 0);
      expect(find.text('1 moved'), findsOne);
    });

    testWidgets('lifting and setting back moves nothing', (tester) async {
      await open(tester, which: 0);
      await tapSpindle(tester, 0);
      expect(state(tester).lifted, 0);
      await tapSpindle(tester, 0);
      expect(state(tester).lifted, -1);
      expect(state(tester).play.made, 0);
    });

    testWidgets('a bare spindle cannot be lifted from', (tester) async {
      await open(tester, which: 0);
      await tapSpindle(tester, 1);
      expect(state(tester).lifted, -1);
      expect(find.textContaining('bare'), findsOne);
    });

    testWidgets('a round is refused a smaller landing with the rule',
        (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      await lift(tester, 0, 2);
      expect(state(tester).play.made, 1);
      expect(find.textContaining('never rests on a smaller'), findsOne);
    });

    testWidgets('Back takes the last move off', (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
    });

    testWidgets('Again restacks the tower', (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      await lift(tester, 0, 1);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the bench', () {
    testWidgets('a wandering move is called out with the live number',
        (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      await lift(tester, 2, 0);
      expect(find.textContaining('wandered'), findsOne);
      expect(find.textContaining('rose to 7'), findsOne);
    });

    testWidgets('Show me points at the walk\'s move', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('measured every board'), findsOne);
    });

    testWidgets('Why speaks all three voices on three spindles',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('Three things that share nothing'),
          findsOne);
      expect(find.textContaining('all 81 boards'), findsOne);
    });

    testWidgets('Why speaks the leapfrog on four spindles',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(find.textContaining('leapfrog'), findsOne);
      expect(find.textContaining('2014'), findsOne);
    });

    testWidgets('the wager says the house is safe as it opens',
        (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('wagers you cannot'), findsOne);
      expect(find.textContaining('the wager asks 14; the floor is 15'),
          findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('lost before the first lift'),
          findsOne);
    });
  });

  group('a tower raised', () {
    testWidgets('following the game raises every tower at its fewest',
        (tester) async {
      for (var number = 0; number < Spindles.count; number++) {
        final spindle = Spindles.at(number);
        await open(tester, which: number);
        await raiseItHome(tester);
        expect(state(tester).play.isHome, isTrue, reason: spindle.name);
        expect(state(tester).play.made, spindle.fewest,
            reason: spindle.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten',
        (tester) async {
      await open(tester, which: 0);
      await lift(tester, 0, 2);
      await lift(tester, 2, 0);
      await raiseItHome(tester);
      expect(find.text('the tower stands home'), findsOne);
      expect(find.textContaining('The fewest is 7'), findsOne);
    });

    testWidgets('the wager\'s card says the house was always safe',
        (tester) async {
      await open(tester, which: 5);
      await raiseItHome(tester);
      expect(find.textContaining('house was always safe'), findsOne);
      expect(find.textContaining('walked the proof'), findsOne);
    });

    testWidgets('Next opens the tower after', (tester) async {
      await open(tester, which: 0);
      await raiseItHome(tester);
      await press(tester, 'Next');
      expect(state(tester).play.spindle.name, Spindles.at(1).name);
    });
  });
}
