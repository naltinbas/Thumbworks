import 'package:flutter_test/flutter_test.dart';
import 'package:peckhollow/best.dart';
import 'package:peckhollow/yard/yards.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/yard.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a yard opened', () {
    testWidgets('stands the birds and names the task',
        (tester) async {
      await open(tester, which: 1);
      expect(find.text('The Bantam'), findsOne);
      expect(find.text('0 flips'), findsOne);
      expect(
        find.text('crown the bantam alone; 1 crowned now'),
        findsOne,
      );
      expect(
        find.textContaining('Every arrow shows who pecks whom'),
        findsOne,
      );
    });

    testWidgets('a tapped arrow turns and counts', (tester) async {
      await open(tester, which: 0);
      final before = state(tester).play.pecksOf(0, 1);
      await tapArrow(tester, 0);
      expect(state(tester).play.flips, 1);
      expect(state(tester).play.pecksOf(0, 1), !before);
      expect(find.text('1 flip'), findsOne);
    });

    testWidgets('a wandered flip is called out', (tester) async {
      await open(tester, which: 1);
      // Found, not guessed: a flip after which the fewest does not
      // fall.
      final play = state(tester).play;
      final could = play.toDone;
      int? wander;
      for (var arrow = 0; arrow < 6; arrow++) {
        if (play.flip(arrow).toDone >= could) {
          wander = arrow;
          break;
        }
      }
      expect(wander, isNotNull,
          reason: 'every flip shortens this yard');
      await tapArrow(tester, wander!);
      expect(find.textContaining('That flip went nowhere'), findsOne);
    });

    testWidgets('Back unflips', (tester) async {
      await open(tester, which: 0);
      await tapArrow(tester, 2);
      expect(state(tester).play.flips, 1);
      await press(tester, 'Back');
      expect(state(tester).play.flips, 0);
      expect(state(tester).play.arrows, Yards.at(0).start);
    });

    testWidgets('Again starts the yard over', (tester) async {
      await open(tester, which: 0);
      await tapArrow(tester, 2);
      await press(tester, 'Again');
      expect(state(tester).play.flips, 0);
      expect(state(tester).play.arrows, Yards.at(0).start);
    });

    testWidgets('Show me lights a shortest flip', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(
        find.textContaining('a shortest crowning runs through it'),
        findsOne,
      );
    });

    testWidgets('Why speaks the winner-king and the sweep',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(
        find.textContaining('the biggest winner is always a king'),
        findsOne,
      );
      expect(find.textContaining('all 64 yards'), findsOne);
    });

    testWidgets('the crowning lands the card', (tester) async {
      await open(tester, which: 0);
      await crownIt(tester);
      expect(find.text('the crowning stands'), findsOne);
      expect(
        find.textContaining('the fewest any flipping needs'),
        findsOne,
      );
    });

    testWidgets('every winnable yard crowns in its par by the '
        'pointer', (tester) async {
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        if (!yard.winnable) continue;
        await open(tester, which: number);
        await crownIt(tester);
        expect(state(tester).play.flips, yard.par,
            reason: yard.name);
      }
    });

    testWidgets('the crowning writes the flips down', (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await crownIt(tester);
      await tester.pump();
      expect(best.flipsFor('The Three'), 1);
      expect(await best.record('The Three', 9), isFalse);
    });
  });

  group('the two kings', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('no yard wears exactly two'),
        findsOne,
      );
      expect(
        find.text('crown exactly 2: no yard ever wears it'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the peckers', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('a second crown always drags a third'),
        findsOne,
      );
      expect(find.textContaining('all 64 yards'), findsOne);
    });

    testWidgets('eight flips and the yard admits it', (tester) async {
      await open(tester, which: 4);
      for (var flip = 0; flip < 8; flip++) {
        await tapArrow(tester, flip % 6);
        expect(state(tester).play.kings.length, isNot(2));
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(
        find.textContaining('never two crowns'),
        findsOne,
      );
      expect(find.text('never two, as the label said'), findsOne);
    });
  });
}
