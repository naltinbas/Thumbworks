import 'package:flutter_test/flutter_test.dart';
import 'package:mousewold/best.dart';
import 'package:mousewold/chase/grounds.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/chase.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a ground opened', () {
    testWidgets('stands the beasts and counts the chase down',
        (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      expect(find.text('The Hedgerow'), findsOne);
      expect(find.text('0 rounds'), findsOne);
      expect(
        find.text('${play.toCatch} rounds to the catch'),
        findsOne,
      );
      expect(find.textContaining('Tap a post along a path'), findsOne);
    });

    testWidgets('a step the paths allow moves the cat and the mouse '
        'flees', (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      final to = play.rules.beside[play.cat]
          .firstWhere((post) => post != play.mouse);
      await tapPost(tester, to);
      expect(state(tester).play.cat, to);
      expect(state(tester).play.rounds, 1);
      expect(find.text('1 round'), findsOne);
    });

    testWidgets('a tap with no path from the cat is refused',
        (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      final off = List.generate(play.ground.posts, (post) => post)
          .firstWhere((post) => !play.mayStep(post));
      await tapPost(tester, off);
      expect(state(tester).play.rounds, 0);
      expect(
        find.text('No path runs there from where the cat stands.'),
        findsOne,
      );
    });

    testWidgets('a step that lets the mouse breathe is called out',
        (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      final could = play.toCatch!;
      // Found, not guessed: any legal step after which the count has
      // not fallen.
      final wander = play.rules
          .movesFrom(play.cat)
          .where((to) => to != play.mouse)
          .firstWhere(
        (to) {
          final now = play.step(to).toCatch;
          return now != null && now >= could;
        },
        orElse: () => -1,
      );
      expect(wander, isNot(-1),
          reason: 'no wandering step on this ground');
      await tapPost(tester, wander);
      expect(find.textContaining('let the mouse breathe'), findsOne);
    });

    testWidgets('Back takes a round off the count', (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      final stood = play.cat;
      await tapPost(
          tester,
          play.rules.beside[play.cat]
              .firstWhere((post) => post != play.mouse));
      expect(state(tester).play.rounds, 1);
      await press(tester, 'Back');
      expect(state(tester).play.rounds, 0);
      expect(state(tester).play.cat, stood);
    });

    testWidgets('Again starts the ground over', (tester) async {
      await open(tester, which: 0);
      final play = state(tester).play;
      await tapPost(
          tester,
          play.rules.beside[play.cat]
              .firstWhere((post) => post != play.mouse));
      await press(tester, 'Again');
      expect(state(tester).play.rounds, 0);
      expect(state(tester).play.cat, play.ground.catStart);
    });

    testWidgets('Show me points the step the search closes with',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(
        find.textContaining('the search has read every chase'),
        findsOne,
      );
    });

    testWidgets('Why numbers the folding in gold', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(
        state(tester).folding,
        equals(state(tester).play.rules.folding()),
      );
      expect(
        find.textContaining('folds up corner by corner'),
        findsOne,
      );
      expect(find.textContaining('27,475'), findsOne);
    });

    testWidgets('the catch lands the card, within the worst case',
        (tester) async {
      await open(tester, which: 0);
      await chaseIt(tester);
      expect(find.text('the mouse is cornered'), findsOne);
      expect(
        find.textContaining('within the search\'s worst case of '
            '${Grounds.at(0).rounds}'),
        findsOne,
      );
    });

    testWidgets(
        'every winnable ground is caught within its rounds by '
        'following the pointer', (tester) async {
      for (var number = 0; number < Grounds.count; number++) {
        final ground = Grounds.at(number);
        if (!ground.winnable) continue;
        await open(tester, which: number);
        await chaseIt(tester);
        expect(state(tester).play.rounds,
            lessThanOrEqualTo(ground.rounds!),
            reason: ground.name);
      }
    });

    testWidgets('the catch writes the fewest rounds down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await chaseIt(tester);
      await tester.pump();
      expect(
        best.roundsFor('The Hedgerow'),
        state(tester).play.rounds,
      );
      // A slower chase later keeps the earlier count.
      expect(await best.record('The Hedgerow', 9), isFalse);
    });
  });

  group('the ring fence', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('No chase catches this mouse'),
        findsOne,
      );
      expect(
        find.text('the mouse keeps its lead forever'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the no-corner words', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('no corner to start with'),
        findsOne,
      );
      expect(find.textContaining('27,475'), findsOne);
    });

    testWidgets('eight rounds on and the chase admits it',
        (tester) async {
      await open(tester, which: 4);
      for (var round = 0; round < 8; round++) {
        final play = state(tester).play;
        await tapPost(
            tester,
            play.rules.beside[play.cat]
                .firstWhere((post) => post != play.mouse));
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(find.textContaining('Eight rounds'), findsOne);
      expect(
        find.text('the mouse holds its lead, as it always would'),
        findsOne,
      );
    });
  });
}
