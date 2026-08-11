import 'package:flutter_test/flutter_test.dart';
import 'package:skittlemere/alley/frames.dart';

import '../support/alley.dart';

void main() {
  group('the screen', () {
    testWidgets('opens standing with the count told', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.segments, [5]);
      expect(find.text('the count stands at 4'), findsOne);
      expect(find.text('0 knocked'), findsOne);
    });

    testWidgets('arm and tap again knocks a single, and the house '
        'replies', (tester) async {
      await open(tester, which: 0);
      await knockOne(tester, 0, 0);
      // Two knocks stand: the player's and the house's reply.
      expect(state(tester).play.knocks, 2);
      expect(find.textContaining('The house knocks'), findsOne);
    });

    testWidgets('a pair falls together', (tester) async {
      await open(tester, which: 2);
      await knockTwo(tester, 0, 3, 4);
      expect(state(tester).play.knocks, 2);
    });

    testWidgets('a far pair is refused with the rule', (tester) async {
      await open(tester, which: 0);
      await tapPin(tester, 0, 0);
      await tapPin(tester, 0, 2);
      expect(state(tester).play.knocks, 0);
      expect(find.textContaining('shoulder to shoulder'), findsOne);
    });

    testWidgets('Back takes the round back, house reply and all',
        (tester) async {
      await open(tester, which: 0);
      await knockOne(tester, 0, 0);
      await press(tester, 'Back');
      expect(state(tester).play.knocks, 0);
      expect(state(tester).play.segments, [5]);
    });

    testWidgets('Again restands the alley', (tester) async {
      await open(tester, which: 0);
      await knockOne(tester, 0, 0);
      await press(tester, 'Again');
      expect(state(tester).play.knocks, 0);
    });
  });

  group('the words under the lane', () {
    testWidgets('the house says where it knocked and the count',
        (tester) async {
      await open(tester, which: 1);
      await knockOne(tester, 1, 0);
      expect(find.textContaining('the count stands at'),
          findsNWidgets(2));
    });

    testWidgets('Show me points at the zeroing knock', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the house inherits nothing'),
          findsOne);
    });

    testWidgets('Why chips the runs gold and speaks the arithmetic',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(state(tester).showCounts, isTrue);
      expect(find.textContaining('carry-less'), findsOne);
      expect(find.textContaining('added the carry-less way'),
          findsOne);
    });

    testWidgets('the even alley says so as it opens, and Why gives '
        'the mirror', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('counts nought before the first'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('No knock zeroes the count'),
          findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('mirror'), findsOne);
    });
  });

  group('an alley settled', () {
    testWidgets('following the zeroing knock wins every winnable '
        'alley', (tester) async {
      for (var number = 0; number < Frames.count; number++) {
        final frame = Frames.at(number);
        if (!frame.winnable) continue;
        await open(tester, which: number);
        await bowlItHome(tester);
        expect(state(tester).won, isTrue, reason: frame.name);
        expect(find.text('the last skittle was yours'), findsOne);
      }
    });

    testWidgets('the even alley is lost however it is bowled',
        (tester) async {
      await open(tester, which: 4);
      var guard = 0;
      while (!state(tester).lost) {
        if (guard++ > 12) fail('the even alley never settled');
        final knock = state(tester).play.allKnocks.first;
        final (row, pin, other) = knock;
        if (other < 0) {
          await knockOne(tester, row, pin);
        } else {
          await knockTwo(tester, row, pin, other);
        }
      }
      expect(find.text('the last skittle was the house\'s'), findsOne);
      expect(find.textContaining('as the label said'), findsOne);
    });

    testWidgets('Next opens the alley after', (tester) async {
      await open(tester, which: 0);
      await bowlItHome(tester);
      await press(tester, 'Next');
      expect(state(tester).play.frame.name, Frames.at(1).name);
    });
  });
}
