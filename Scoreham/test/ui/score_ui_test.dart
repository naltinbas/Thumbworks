import 'package:flutter_test/flutter_test.dart';
import 'package:scoreham/best.dart';
import 'package:scoreham/score/rings.dart';
import 'package:scoreham/score/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/score.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a ring opened', () {
    testWidgets('hangs the ring and names the task', (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Five Marks'), findsOne);
      expect(find.text('0 of 1'), findsOne);
      expect(find.text('find the one good start'), findsOne);
      expect(find.textContaining('Tap a mark to start the walk'),
          findsOne);
    });

    testWidgets('a grounded walk names its dip', (tester) async {
      await open(tester, which: 0);
      // Found, not guessed: a start whose walk grounds.
      final bad = List.generate(5, (at) => at).firstWhere(
          (at) => !Rules.staysAhead(Rings.at(0).marks, at));
      await tapMark(tester, bad);
      expect(state(tester).play.found, isEmpty);
      expect(
        find.textContaining('touches the ground at step'),
        findsOne,
      );
    });

    testWidgets('a good walk is kept and said', (tester) async {
      await open(tester, which: 0);
      await tapMark(tester, 3);
      expect(state(tester).play.found, [3]);
      expect(state(tester).play.isDone, isTrue);
    });

    testWidgets('Back forgets the last try', (tester) async {
      await open(tester, which: 1);
      final bad = List.generate(7, (at) => at).firstWhere(
          (at) => !Rules.staysAhead(Rings.at(1).marks, at));
      await tapMark(tester, bad);
      expect(state(tester).play.tried, isNotEmpty);
      await press(tester, 'Back');
      expect(state(tester).play.tried, isEmpty);
    });

    testWidgets('Show me points past the ebb', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');
      expect(
        state(tester).pointing,
        Rules.pastTheEbb(Rings.at(3).marks),
      );
      expect(
        find.textContaining('last lowest ebb'),
        findsOne,
      );
    });

    testWidgets('Why speaks the ledger and the sweep',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(
        find.textContaining('exactly as many good starts as it '
            'runs ahead'),
        findsOne,
      );
      expect(find.textContaining('8,190'), findsWidgets);
    });

    testWidgets('the settling lands the card', (tester) async {
      await open(tester, which: 0);
      await findIt(tester);
      expect(find.text('every good start is found'), findsOne);
      expect(
        find.textContaining('as the ledger promised'),
        findsOne,
      );
    });

    testWidgets('every winnable ring settles by the pointer',
        (tester) async {
      for (var number = 0; number < Rings.count; number++) {
        final ring = Rings.at(number);
        if (!ring.winnable) continue;
        await open(tester, which: number);
        await findIt(tester);
        expect(state(tester).play.found, hasLength(ring.goods),
            reason: ring.name);
      }
    });

    testWidgets('the settling writes the tries down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await findIt(tester);
      await tester.pump();
      expect(best.triesFor('The Five Marks'), 1);
      expect(await best.record('The Five Marks', 9), isFalse);
    });
  });

  group('the tied vote', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('no good start at all'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the tied ledger', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('runs nothing ahead'),
        findsOne,
      );
    });

    testWidgets('every start tried, every walk grounded, and the '
        'card admits it', (tester) async {
      await open(tester, which: 4);
      for (var start = 0; start < 6; start++) {
        await tapMark(tester, start);
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(
        find.textContaining('a tied ring no good start at all'),
        findsOne,
      );
      expect(
        find.text('every start grounded, as the label said'),
        findsOne,
      );
    });
  });
}
