import 'package:flutter_test/flutter_test.dart';
import 'package:turnstead/green/greens.dart';

import '../support/green.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with round one in hand', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.matchesMade, 0);
      expect(find.text('0 / 6'), findsOne);
      expect(find.text('round 1 of 3'), findsOne);
    });

    testWidgets('two taps make a match', (tester) async {
      await open(tester, which: 0);
      await pair(tester, 0, 2);
      expect(state(tester).play.current, [(0, 2)]);
      expect(find.text('1 / 6'), findsOne);
    });

    testWidgets('a full round closes and the next is announced',
        (tester) async {
      await open(tester, which: 0);
      await pair(tester, 0, 1);
      await pair(tester, 2, 3);
      expect(state(tester).play.roundInHand, 2);
      expect(find.textContaining('Round 2 begins'), findsOne);
    });

    testWidgets('sides that have met are refused with the rule',
        (tester) async {
      await open(tester, which: 0);
      await pair(tester, 0, 1);
      await pair(tester, 2, 3);
      await pick(tester, 0);
      await pick(tester, 1);
      expect(find.textContaining('have already met'), findsOne);
    });

    testWidgets('Back unwinds the last pairing', (tester) async {
      await open(tester, which: 0);
      await pair(tester, 0, 2);
      await press(tester, 'Back');
      expect(state(tester).play.matchesMade, 0);
    });

    testWidgets('Again clears the card', (tester) async {
      await open(tester, which: 0);
      await pair(tester, 0, 2);
      await press(tester, 'Again');
      expect(state(tester).play.matchesMade, 0);
    });
  });

  group('the words under the green', () {
    testWidgets('Show me points at a pairing that still writes',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the search has checked it'), findsOne);
    });

    testWidgets('Why strings the wheel as ghosts', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showWheel, isTrue);
      expect(find.textContaining('turn the rim one notch'), findsOne);
    });

    testWidgets('the short card says its one breath', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('cannot be written'), findsOne);
      await press(tester, 'Why');
      expect(state(tester).showWheel, isFalse);
      expect(find.textContaining('five rounds at the least'), findsOne);
    });
  });

  group('a card written', () {
    testWidgets('following the game writes every writable card',
        (tester) async {
      for (final number in const [0, 1, 3]) {
        await open(tester, which: number);
        await writeItAll(tester);
        expect(state(tester).play.isWritten, isTrue,
            reason: Greens.at(number).name);
      }
    });

    testWidgets('the card credits the pigeonhole least', (tester) async {
      await open(tester, which: 0);
      await writeItAll(tester);
      expect(find.textContaining('fewest the pigeonhole allows'),
          findsOne);
    });

    testWidgets('Next opens the green after', (tester) async {
      await open(tester, which: 0);
      await writeItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.green.name, Greens.at(1).name);
    });
  });
}
