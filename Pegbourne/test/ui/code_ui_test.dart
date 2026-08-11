import 'package:flutter_test/flutter_test.dart';
import 'package:pegbourne/code/riddles.dart';

import '../support/code.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the slots empty', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.isComplete, isFalse);
      expect(find.text('0 of 4 pegs set'), findsOne);
      expect(find.text('0 turned'), findsOne);
    });

    testWidgets('a tap turns a slot through the colours',
        (tester) async {
      await open(tester, which: 0);
      await tapSlot(tester, 0);
      expect(state(tester).play.slots[0], 0);
      await tapSlot(tester, 0);
      expect(state(tester).play.slots[0], 1);
      expect(find.text('2 turned'), findsOne);
    });

    testWidgets('Back unturns the last turn', (tester) async {
      await open(tester, which: 0);
      await tapSlot(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.slots[0], -1);
    });

    testWidgets('Again empties the slots', (tester) async {
      await open(tester, which: 0);
      await tapSlot(tester, 0);
      await tapSlot(tester, 1);
      await press(tester, 'Again');
      expect(state(tester).play.moves, 0);
    });
  });

  group('the words under the table', () {
    testWidgets('a wrong finished code is called out by row',
        (tester) async {
      await open(tester, which: 0);
      for (var slot = 0; slot < 4; slot++) {
        await setSlot(tester, slot, 3);
      }
      expect(state(tester).play.broken, isNotEmpty);
      expect(find.textContaining('would not mark your pegs'),
          findsOne);
      expect(find.textContaining('disagree'), findsNWidgets(2));
    });

    testWidgets('Show me names the colour a slot wants',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the sweep counted'), findsOne);
    });

    testWidgets('Why speaks the sweep', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('all 256 codes'), findsOne);
      expect(find.textContaining('exactly one'), findsOne);
    });

    testWidgets('the two minds show each answer in turn',
        (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('More than one code'), findsOne);
      await press(tester, 'Why');
      final first = state(tester).other;
      expect(first, isNotNull);
      await press(tester, 'Why');
      expect(state(tester).other, isNot(first));
    });

    testWidgets('the liar says so as it opens, and Why counts',
        (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No code earns every row'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('cannot hold both'), findsOne);
    });
  });

  group('a riddle answered', () {
    testWidgets('following the mend answers every winnable riddle',
        (tester) async {
      for (var number = 0; number < Riddles.count; number++) {
        final riddle = Riddles.at(number);
        if (!riddle.winnable) continue;
        await open(tester, which: number);
        await answerIt(tester);
        expect(state(tester).play.isDone, isTrue, reason: riddle.name);
      }
    });

    testWidgets('the card owns the ways', (tester) async {
      await open(tester, which: 0);
      await answerIt(tester);
      expect(find.text('every row agrees'), findsOne);
      expect(find.textContaining('the only one that does'), findsOne);
    });

    testWidgets('Next opens the riddle after', (tester) async {
      await open(tester, which: 0);
      await answerIt(tester);
      await press(tester, 'Next');
      expect(state(tester).play.riddle.name, Riddles.at(1).name);
    });
  });
}
