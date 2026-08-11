import 'package:colthorpe/tour/yards.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/tour.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the yard unridden', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.started, isFalse);
      expect(find.text('0 / 12'), findsOne);
      expect(find.text('ride them all'), findsOne);
    });

    testWidgets('the first tap stands the colt in the yard', (tester) async {
      await open(tester, which: 0);
      await ride(tester, 5);
      expect(state(tester).play.path, [5]);
      expect(find.text('1 / 12'), findsOne);
    });

    testWidgets('a gated yard starts at the gate only', (tester) async {
      await open(tester, which: 2);
      await ride(tester, 12);
      expect(state(tester).play.started, isFalse);
      expect(find.textContaining('starts at the gate'), findsOne);
      await ride(tester, 0);
      expect(state(tester).play.path, [0]);
    });

    testWidgets('a jump the colt cannot make is refused with the rule',
        (tester) async {
      await open(tester, which: 0);
      await ride(tester, 5);
      await ride(tester, 4);
      expect(state(tester).play.path, [5]);
      expect(find.textContaining('two paddocks one way'), findsOne);
    });

    testWidgets('Back unrides the last paddock', (tester) async {
      await open(tester, which: 0);
      await ride(tester, 5);
      await press(tester, 'Back');
      expect(state(tester).play.started, isFalse);
    });

    testWidgets('Again clears the yard', (tester) async {
      await open(tester, which: 0);
      await ride(tester, 5);
      await press(tester, 'Again');
      expect(state(tester).play.started, isFalse);
    });
  });

  group('the words under the yard', () {
    testWidgets('a stranding jump is called out the moment it is made',
        (tester) async {
      await open(tester, which: 0);
      var guard = 0;
      var called = false;
      while (guard++ < 12 && !called) {
        final play = state(tester).play;
        if (!play.started) {
          await ride(tester, play.next!);
          continue;
        }
        var strander = -1;
        for (var paddock = 0; paddock < play.yard.paddocks; paddock++) {
          if (!play.mayRide(paddock)) continue;
          if (!play.ride(paddock).canStillRide) {
            strander = paddock;
            break;
          }
        }
        if (strander >= 0) {
          await ride(tester, strander);
          // The words under the yard say it, and so does the ledger.
          expect(find.textContaining('Take the jump back'), findsOne);
          expect(find.text('a paddock is stranded'), findsOne);
          called = true;
        } else {
          await ride(tester, play.next!);
        }
      }
      expect(called, isTrue,
          reason: 'no stranding jump ever offered itself');
    });

    testWidgets('Show me points at a jump the walk has checked',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 0);
      expect(state(tester).hints, 1);
      expect(find.textContaining('Start there'), findsOne);
    });

    testWidgets('Why tallies the grasses and speaks the yard\'s note',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(state(tester).showColours, isTrue);
      expect(find.textContaining('needs thirteen'), findsOne);
      expect(find.textContaining('the whole proof'), findsOne);
    });

    testWidgets('the cross paddocks own that only the walk knows',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('nothing to say against'), findsOne);
      expect(find.textContaining('walk of every ride'), findsOne);
    });

    testWidgets('a hopeless yard says so as it opens', (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('No round rides this yard'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
    });
  });

  group('a round ridden', () {
    testWidgets('following the game rides every possible yard home',
        (tester) async {
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        if (!yard.possible) continue;
        await open(tester, which: number);
        await rideItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: yard.name);
      }
    });

    testWidgets('the closed round says it came home', (tester) async {
      await open(tester, which: 4);
      await rideItAll(tester);
      expect(find.text('every paddock once, and home'), findsOne);
      expect(find.textContaining('home a jump away'), findsOne);
    });

    testWidgets('Next opens the yard after', (tester) async {
      await open(tester, which: 0);
      await rideItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.yard.name, Yards.at(1).name);
    });
  });
}
