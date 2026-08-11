import 'package:flutter_test/flutter_test.dart';
import 'package:shroveham/griddle/batches.dart';

import '../support/griddle.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the batch as the carter dealt it', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.made, 0);
      expect(find.text('0 / 3'), findsOne);
      expect(find.text('3 gaps on the stack'), findsOne);
    });

    testWidgets('tapping a cake turns everything above it', (tester) async {
      await open(tester, which: 0);
      await flip(tester, 0);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.cakes, [1, 4, 2, 3]);
    });

    testWidgets('the slice under the top cake alone is refused',
        (tester) async {
      await open(tester, which: 0);
      await flip(tester, 3);
      expect(state(tester).play.made, 0);
      expect(find.textContaining('changes nothing'), findsOne);
    });

    testWidgets('Back returns the batch as it lay', (tester) async {
      await open(tester, which: 0);
      await flip(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
      expect(state(tester).play.cakes, Batches.at(0).cakes);
    });

    testWidgets('Again starts the batch over', (tester) async {
      await open(tester, which: 0);
      await flip(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the griddle', () {
    testWidgets('a wasted flip is called out the moment it costs',
        (tester) async {
      await open(tester, which: 1);
      final play = state(tester).play;
      var wasted = -1;
      for (var under = 0; under <= 3; under++) {
        if (play.flip(under).couldStillBe > play.batch.fewest) {
          wasted = under;
          break;
        }
      }
      expect(wasted, isNot(-1));
      await flip(tester, wasted);
      expect(find.textContaining('more than the'), findsOne);
      expect(find.textContaining('Take the flip back'), findsOne);
    });

    testWidgets('Show me slides the slice where the walk likes',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(state(tester).hints, 1);
      expect(find.textContaining('Slide the slice under'), findsOne);
    });

    testWidgets('Why counts the gaps where they carry the number',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(state(tester).showGaps, isTrue);
      expect(find.textContaining('mends at most one gap'), findsOne);
      expect(find.textContaining('3 is enough'), findsOne);
    });

    testWidgets('and owns the slack where they do not', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(find.textContaining('falls short'), findsOne);
      expect(find.textContaining('walk of every batch of 5'), findsOne);
    });
  });

  group('a batch served', () {
    testWidgets('following the game serves every batch at its fewest',
        (tester) async {
      for (var number = 0; number < Batches.count; number++) {
        await open(tester, which: number);
        await serveItAll(tester);
        final play = state(tester).play;
        expect(play.isServed, isTrue, reason: Batches.at(number).name);
        expect(play.made, Batches.at(number).fewest,
            reason: Batches.at(number).name);
      }
    });

    testWidgets('the card says fewer cannot do it', (tester) async {
      await open(tester, which: 0);
      await serveItAll(tester);
      expect(find.textContaining('fewer cannot do it'), findsOne);
      expect(find.text('served'), findsOne);
    });

    testWidgets('a batch served over the fewest says what it can be done on',
        (tester) async {
      await open(tester, which: 3);
      // The hand's way: biggest to the top, then down, two flips a cake.
      var guard = 0;
      while (!state(tester).play.isServed && guard++ < 12) {
        final play = state(tester).play;
        var biggest = 0;
        for (var at = 1; at < play.cakes.length; at++) {
          if (play.cakes[at] > play.cakes[biggest]) biggest = at;
        }
        final home = play.cakes.length - play.cakes[biggest];
        if (biggest == home) {
          // It sits right; the loose part is above. Find the biggest loose.
          var loose = -1;
          for (var at = 0; at < play.cakes.length; at++) {
            if (play.cakes[at] != play.cakes.length - at) {
              loose = at;
              break;
            }
          }
          var big = loose;
          for (var at = loose; at < play.cakes.length; at++) {
            if (play.cakes[at] > play.cakes[big]) big = at;
          }
          if (big != play.cakes.length - 1) await flip(tester, big);
          await flip(tester, loose);
        } else {
          if (biggest != play.cakes.length - 1) await flip(tester, biggest);
          await flip(tester, home);
        }
      }
      expect(state(tester).play.isServed, isTrue);
      expect(find.textContaining('It can be done on 3'), findsOne);
    });

    testWidgets('Next opens the batch after', (tester) async {
      await open(tester, which: 0);
      await serveItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.batch.name, Batches.at(1).name);
    });
  });
}
