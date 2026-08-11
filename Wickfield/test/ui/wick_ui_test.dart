import 'package:flutter_test/flutter_test.dart';
import 'package:wickfield/wick/wicks.dart';

import '../support/wick.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the board as the wick lays it', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.board, 0xBA);
      expect(find.text('5 lamps lit'), findsOne);
      expect(find.text('0 pressed'), findsOne);
    });

    testWidgets('a press flips the cross and counts', (tester) async {
      await open(tester, which: 1);
      await lamp(tester, 0);
      expect(state(tester).play.board, 0x145 ^ 0x0B);
      expect(find.text('1 pressed'), findsOne);
    });

    testWidgets('Back takes the last press off', (tester) async {
      await open(tester, which: 1);
      await lamp(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.board, 0x145);
      expect(find.text('0 pressed'), findsOne);
    });

    testWidgets('Again lays the board over', (tester) async {
      await open(tester, which: 1);
      await lamp(tester, 0);
      await lamp(tester, 5);
      await press(tester, 'Again');
      expect(state(tester).play.board, 0x145);
      expect(state(tester).play.pressed, 0);
    });
  });

  group('the words under the board', () {
    testWidgets('a wandering press is called out with the live number',
        (tester) async {
      await open(tester, which: 1);
      // The corners want their four corners pressed; the middle is not
      // among them, and the fewest from there rises to five.
      await lamp(tester, 4);
      expect(find.textContaining('wandered'), findsOne);
      expect(find.textContaining('rose to 5'), findsOne);
    });

    testWidgets('Show me points at a press off a lightest answer',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 4);
      expect(state(tester).hints, 1);
      expect(find.textContaining('lightest answer'), findsOne);
    });

    testWidgets('Why rims a whole answer on a winnable board',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(state(tester).answer, isNot(0));
      expect(state(tester).quiet, 0);
      expect(find.textContaining('16 press-sets'), findsOne);
    });

    testWidgets('the dead lamp says so as it opens, and Why shows the '
        'quiet pattern', (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('No pressing darkens'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(state(tester).quiet, isNot(0));
      expect(find.textContaining('odd it stays'), findsOne);
    });
  });

  group('a board gone dark', () {
    testWidgets('following the game darkens every winnable wick',
        (tester) async {
      for (var number = 0; number < Wicks.count; number++) {
        final wick = Wicks.at(number);
        if (!wick.winnable) continue;
        await open(tester, which: number);
        await pressItDark(tester);
        expect(state(tester).play.isDark, isTrue, reason: wick.name);
        expect(state(tester).play.pressed, wick.fewest, reason: wick.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten', (tester) async {
      await open(tester, which: 0);
      // Three presses where one would do: press a corner, unpress it,
      // then the middle.
      await lamp(tester, 0);
      await lamp(tester, 0);
      await lamp(tester, 4);
      expect(find.text('the board is dark'), findsOne);
      expect(find.textContaining('The fewest is 1'), findsOne);
    });

    testWidgets('the card at the fewest says no press-set beats it',
        (tester) async {
      await open(tester, which: 0);
      await pressItDark(tester);
      expect(find.textContaining('no press-set there is does it in fewer'),
          findsOne);
    });

    testWidgets('Next opens the wick after', (tester) async {
      await open(tester, which: 0);
      await pressItDark(tester);
      await press(tester, 'Next');
      expect(state(tester).play.wick.name, Wicks.at(1).name);
    });
  });
}
