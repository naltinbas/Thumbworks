import 'package:flutter_test/flutter_test.dart';
import 'package:pailsworth/pail/errands.dart';
import 'package:pailsworth/pail/play.dart';

import '../support/pail.dart';

void main() {
  group('the screen', () {
    testWidgets('opens dry with the ask named', (tester) async {
      await open(tester, which: 1);
      expect(state(tester).play.held, [0, 0]);
      expect(find.text('fetch 4 pints; 6 pours away'), findsOne);
      expect(find.text('0 poured'), findsOne);
    });

    testWidgets('spring then pail fills it', (tester) async {
      await open(tester, which: 1);
      await pourFrom(tester, Play.spring, 1);
      expect(state(tester).play.held, [0, 5]);
      expect(find.text('1 poured'), findsOne);
    });

    testWidgets('pail tips into pail until stopped', (tester) async {
      await open(tester, which: 1);
      await pourFrom(tester, Play.spring, 1);
      await pourFrom(tester, 1, 0);
      expect(state(tester).play.held, [3, 2]);
    });

    testWidgets('the drain gives nothing', (tester) async {
      await open(tester, which: 1);
      await tapEnd(tester, Play.drain);
      expect(state(tester).armed, isNull);
      expect(find.textContaining('takes; it does not give'), findsOne);
    });

    testWidgets('arming and disarming pours nothing', (tester) async {
      await open(tester, which: 1);
      await tapEnd(tester, 0);
      expect(state(tester).armed, 0);
      await tapEnd(tester, 0);
      expect(state(tester).armed, isNull);
      expect(state(tester).play.pours, 0);
    });

    testWidgets('a full pail refuses the spring with the words',
        (tester) async {
      await open(tester, which: 1);
      await pourFrom(tester, Play.spring, 0);
      await pourFrom(tester, Play.spring, 0);
      expect(state(tester).play.pours, 1);
      expect(find.textContaining('already full'), findsOne);
    });

    testWidgets('Back unpours the last pour', (tester) async {
      await open(tester, which: 1);
      await pourFrom(tester, Play.spring, 0);
      await press(tester, 'Back');
      expect(state(tester).play.held, [0, 0]);
    });

    testWidgets('Again dries the well', (tester) async {
      await open(tester, which: 1);
      await pourFrom(tester, Play.spring, 0);
      await pourFrom(tester, 0, 1);
      await press(tester, 'Again');
      expect(state(tester).play.pours, 0);
    });
  });

  group('the words under the well', () {
    testWidgets('a wandering pour is called out with the live number',
        (tester) async {
      await open(tester, which: 1);
      final went = state(tester).play.next!;
      await pourFrom(tester, went.$1, went.$2);
      // Straight down the drain: the water and the count both gone.
      final full = state(tester).play.held[0] > 0 ? 0 : 1;
      await pourFrom(tester, full, Play.drain);
      expect(find.textContaining('wandered'), findsOne);
    });

    testWidgets('Show me points at the walk\'s pour', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('measured every waterline'), findsOne);
    });

    testWidgets('Why speaks the walk on a winnable errand',
        (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(find.textContaining('96 of them'), findsOne);
      expect(find.textContaining('runs in 14'), findsOne);
    });

    testWidgets('the third pint says so as it opens, and Why gives the '
        'measure', (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('No pouring runs this errand'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('multiples of 3'), findsOne);
      expect(find.textContaining('no multiple'), findsOne);
    });
  });

  group('an errand run', () {
    testWidgets('following the game runs every winnable errand',
        (tester) async {
      for (var number = 0; number < Errands.count; number++) {
        final errand = Errands.at(number);
        if (!errand.winnable) continue;
        await open(tester, which: number);
        await runItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: errand.name);
        expect(state(tester).play.pours, errand.fewest,
            reason: errand.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten',
        (tester) async {
      await open(tester, which: 0);
      await pourFrom(tester, Play.spring, 0);
      await pourFrom(tester, 0, Play.drain);
      await runItAll(tester);
      expect(find.text('the errand is run'), findsOne);
      expect(find.textContaining('The fewest is 2'), findsOne);
    });

    testWidgets('Next opens the errand after', (tester) async {
      await open(tester, which: 0);
      await runItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.errand.name, Errands.at(1).name);
    });
  });
}
