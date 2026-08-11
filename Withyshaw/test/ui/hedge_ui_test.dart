import 'package:flutter_test/flutter_test.dart';

import '../support/hedge.dart';

void main() {
  group('the screen', () {
    testWidgets('opens as the hedger left it', (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.worth.said, '1/4');
      expect(find.text('worth 1/4'), findsOne);
      expect(find.text('your cut'), findsOne);
    });

    testWidgets('cutting your withy fells everything above', (tester) async {
      await open(tester, which: 4);
      final before = state(tester).play.worth;
      final next = state(tester).play.next!;
      await cut(tester, next.$1, next.$2);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.worth, isNot(before));
    });

    testWidgets('the hedger\'s withy is refused with the rule',
        (tester) async {
      await open(tester, which: 0);
      await cut(tester, 0, 1);
      expect(state(tester).play.made, 0);
      expect(find.textContaining('is the hedger\'s'), findsOne);
    });

    testWidgets('Back returns the whole exchange', (tester) async {
      await open(tester, which: 2);
      final next = state(tester).play.next!;
      await cut(tester, next.$1, next.$2);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
      expect(state(tester).play.worth.said, '1/4');
    });

    testWidgets('Again starts the hedge over', (tester) async {
      await open(tester, which: 2);
      final next = state(tester).play.next!;
      await cut(tester, next.$1, next.$2);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the hedge', () {
    testWidgets('a spendthrift cut is called out as it lands',
        (tester) async {
      await open(tester, which: 2);
      await cut(tester, 1, 1);
      expect(state(tester).play.winnable, isFalse);
      expect(find.textContaining('spent more than it took'), findsOne);
    });

    testWidgets('Show me points at a winning withy', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('keeps the sum with you'), findsOne);
    });

    testWidgets('Why writes the worths and reads the sum', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(state(tester).showWorth, isTrue);
      expect(find.textContaining('3/4, -1/2'), findsOne);
      expect(find.textContaining('sums to 1/4'), findsOne);
    });

    testWidgets('the even hedge owns its nought', (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('whoever cuts '
          'first loses'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('sums to 0'), findsOne);
    });
  });

  group('a hedge settled', () {
    testWidgets('following the game holds every winnable hedge',
        (tester) async {
      for (final number in const [0, 1, 2, 4]) {
        await open(tester, which: number);
        await holdItAll(tester);
        expect(state(tester).play.won, isTrue, reason: 'hedge $number');
        expect(find.textContaining('nothing left to cut'), findsWidgets);
      }
    });

    testWidgets('Next opens the hedge after', (tester) async {
      await open(tester, which: 0);
      await holdItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.hedge.name, 'The Whole and the Half');
    });
  });
}
