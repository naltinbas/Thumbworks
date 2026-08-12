import 'package:flutter_test/flutter_test.dart';
import 'package:marrowden/best.dart';
import 'package:marrowden/show/rules.dart';
import 'package:marrowden/show/shows.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/show.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

List<List<int>>? Function(int) fixed(List<List<int>> deals) =>
    (number) => deals;

void main() {
  group('a bench opened', () {
    testWidgets('raises the bench and counts the asked wins',
        (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      expect(find.text('The Four Marrows'), findsOne);
      expect(find.text('0 won'), findsOne);
      expect(find.text('won 0 of the 5 asked, 0 sat'), findsOne);
      expect(find.textContaining('One marrow up at a time'), findsOne);
    });

    testWidgets('a take ends the sitting with its verdict',
        (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      await press(tester, 'Wave it by');
      await press(tester, 'Take it');
      expect(state(tester).play.sittingWon, isTrue);
      expect(
        find.text('The best of the bench, taken at seat 2.'),
        findsOne,
      );
      expect(find.text('Next sitting'), findsOne);
      expect(find.text('1 won'), findsOne);
    });

    testWidgets('a lost sitting names the seats', (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [3, 2, 1, 0],
      ]));
      await press(tester, 'Wave it by');
      await press(tester, 'Take it');
      expect(state(tester).play.sittingWon, isFalse);
      expect(
        find.text('The best sat seat 1; the one taken stood 2nd '
            'of the 4.'),
        findsOne,
      );
    });

    testWidgets('the last marrow cannot be waved', (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [0, 1, 2, 3],
      ]));
      for (var waves = 0; waves < 3; waves++) {
        await press(tester, 'Wave it by');
      }
      expect(state(tester).play.shown, 4);
      await press(tester, 'Wave it by');
      expect(state(tester).play.shown, 4);
      expect(state(tester).play.judging, isTrue);
    });

    testWidgets('Back un-waves within the sitting only',
        (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      await press(tester, 'Back');
      expect(
        find.textContaining('Nothing to take back'),
        findsOne,
      );
      await press(tester, 'Wave it by');
      expect(state(tester).play.shown, 2);
      await press(tester, 'Back');
      expect(state(tester).play.shown, 1);
    });

    testWidgets('Show me lights the rule\'s button', (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      await press(tester, 'Show me');
      expect(state(tester).pointing, isFalse);
      expect(
        find.textContaining('the rule waves 1 past'),
        findsOne,
      );
      await press(tester, 'Wave it by');
      await press(tester, 'Show me');
      expect(state(tester).pointing, isTrue);
      expect(
        find.textContaining('past the waved-by and the best yet'),
        findsOne,
      );
    });

    testWidgets('Why speaks the rule and the sweep', (tester) async {
      await open(tester, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      await press(tester, 'Why');
      expect(
        find.textContaining('lands the true best in 11'),
        findsOne,
      );
      expect(
        find.textContaining('all 64 rank-based rules'),
        findsOne,
      );
    });

    testWidgets('five wins close the bench and write the record',
        (tester) async {
      final best = await keeper();
      await open(tester,
          which: 0,
          best: best,
          deals: fixed(Rules.allSittings(4)));
      await judgeIt(tester);
      final play = state(tester).play;
      expect(play.benchWon, isTrue);
      expect(play.won, 5);
      expect(
        find.textContaining('against odds of 11 in 24'),
        findsOne,
      );
      await tester.pump();
      expect(best.sittingsFor('The Four Marrows'), play.played);
    });

    testWidgets('every winnable bench closes by the rule',
        (tester) async {
      for (var number = 0; number < Shows.count; number++) {
        final show = Shows.at(number);
        if (show.sure) continue;
        await open(tester,
            which: number,
            deals: fixed(Rules.allSittings(show.marrows)));
        await judgeIt(tester);
        expect(state(tester).play.benchWon, isTrue,
            reason: show.name);
      }
    });
  });

  group('the sure pick', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4, deals: fixed(const [
        [3, 2, 1, 0],
      ]));
      expect(
        find.textContaining('no rule does'),
        findsOne,
      );
      expect(
        find.text('every sitting must land the best'),
        findsOne,
      );
    });

    testWidgets('the first miss ends it with the fork words',
        (tester) async {
      await open(tester, which: 4, deals: fixed(const [
        [3, 2, 1, 0],
      ]));
      await judgeIt(tester);
      expect(state(tester).play.benchLost, isTrue);
      expect(
        find.textContaining('as some sitting must'),
        findsOne,
      );
      expect(
        find.textContaining('Eleven of twenty-four is the ceiling'),
        findsOne,
      );
    });

    testWidgets('why speaks the fork', (tester) async {
      await open(tester, which: 4, deals: fixed(const [
        [3, 2, 1, 0],
      ]));
      await press(tester, 'Why');
      expect(
        find.textContaining('hide the true best in different seats'),
        findsOne,
      );
      expect(find.textContaining('ceiling at 11 of 24'), findsOne);
    });

    testWidgets('a clean sweep closes it won, for what luck is '
        'worth', (tester) async {
      final lucky = Rules.allSittings(4).where((sitting) {
        var best = -1;
        for (var at = 0; at < 4; at++) {
          final record = sitting[at] > best;
          if (record) best = sitting[at];
          if (Rules.takes(1, at + 1, record, 4)) {
            return sitting[at] == 3;
          }
        }
        return false;
      }).toList();
      expect(lucky, hasLength(11));
      await open(tester, which: 4, deals: fixed(lucky));
      await judgeIt(tester);
      expect(state(tester).play.benchWon, isTrue);
      expect(find.textContaining('Luck bowed today'), findsOne);
    });
  });
}
