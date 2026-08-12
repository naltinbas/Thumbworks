import 'package:flutter_test/flutter_test.dart';
import 'package:quirebeck/best.dart';
import 'package:quirebeck/quire/quires.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/quire.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a quire opened', () {
    testWidgets('lays the stack out and counts the task down',
        (tester) async {
      await open(tester, which: 1);
      expect(find.text('The Fifth Leaf'), findsOne);
      expect(find.text('0 weaves'), findsOne);
      expect(find.text('3 weaves to the task at best'), findsOne);
      expect(find.textContaining('A weave splits the stack'), findsOne);
    });

    testWidgets('an out-weave keeps the plate on top', (tester) async {
      await open(tester, which: 1);
      await weave(tester, false);
      expect(state(tester).play.weaves, 1);
      expect(state(tester).play.plateAt, 0);
      expect(find.text('1 weave'), findsOne);
    });

    testWidgets('an in-weave buries it', (tester) async {
      await open(tester, which: 1);
      await weave(tester, true);
      expect(state(tester).play.plateAt, 1);
    });

    testWidgets('a wandered weave is called out', (tester) async {
      await open(tester, which: 1);
      // Found, not guessed: the weave the walk does not take.
      final wander = !state(tester).play.next!;
      await weave(tester, wander);
      expect(
        find.textContaining('gave the task nothing'),
        findsOne,
      );
    });

    testWidgets('Back unweaves', (tester) async {
      await open(tester, which: 1);
      await weave(tester, true);
      expect(state(tester).play.weaves, 1);
      await press(tester, 'Back');
      expect(state(tester).play.weaves, 0);
      expect(state(tester).play.stack, Quires.at(1).start);
    });

    testWidgets('Again starts the quire over', (tester) async {
      await open(tester, which: 1);
      await weave(tester, true);
      await press(tester, 'Again');
      expect(state(tester).play.weaves, 0);
      expect(state(tester).play.stack, Quires.at(1).start);
    });

    testWidgets('Show me lights the weave the walk closes with',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(
        find.textContaining('the walk of every weaving from here'),
        findsOne,
      );
    });

    testWidgets('Why speaks the seat word', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('in binary is 100'), findsOne);
      expect(find.textContaining('in, out, out'), findsOne);
    });

    testWidgets('the settling lands the card', (tester) async {
      await open(tester, which: 0);
      await weave(tester, true);
      expect(find.text('the plate sits its seat'), findsOne);
      expect(
        find.textContaining('the fewest the walk of every weaving '
            'knows'),
        findsOne,
      );
    });

    testWidgets(
        'every winnable quire settles in its written weaves by '
        'following the pointer', (tester) async {
      for (var number = 0; number < Quires.count; number++) {
        final quire = Quires.at(number);
        if (!quire.winnable) continue;
        await open(tester, which: number);
        await weaveIt(tester);
        expect(state(tester).play.weaves, quire.weaves,
            reason: quire.name);
      }
    });

    testWidgets('the settling writes the fewest weaves down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await weave(tester, true);
      await tester.pump();
      expect(best.weavesFor('The Second Leaf'), 1);
      // A slower weaving later keeps the earlier count.
      expect(await best.record('The Second Leaf', 9), isFalse);
    });
  });

  group('the turned pair', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 5);
      expect(
        find.textContaining('No weaving mends this quire'),
        findsOne,
      );
      expect(find.text('no weaving ever mends this one'), findsOne);
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 5);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why counts the swaps', (tester) async {
      await open(tester, which: 5);
      await press(tester, 'Why');
      expect(find.textContaining('even count of swaps'), findsOne);
      expect(find.textContaining('twenty-four'), findsOne);
    });

    testWidgets('eight weaves on and the quire admits it',
        (tester) async {
      await open(tester, which: 5);
      for (var round = 0; round < 8; round++) {
        await weave(tester, round.isOdd);
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(find.textContaining('the pair stays turned'), findsOne);
      expect(
        find.text('unmended, as the label said it must stay'),
        findsOne,
      );
    });
  });
}
