import 'package:flutter_test/flutter_test.dart';
import 'package:copestone/best.dart';
import 'package:copestone/wall/pitches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/wall.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a pitch opened', () {
    testWidgets('lays the ground and names the asking',
        (tester) async {
      await open(tester, which: 1);
      expect(find.text('The Eight Courses'), findsOne);
      expect(find.text('0 of 8'), findsOne);
      expect(
        find.text('raise 8 courses, no run laid twice over'),
        findsOne,
      );
      expect(find.textContaining('Lay a course from one of the '
          'heaps'), findsOne);
    });

    testWidgets('a heap lays its course', (tester) async {
      await open(tester, which: 1);
      await lay(tester, 0);
      expect(state(tester).play.courses, [0]);
      expect(find.text('1 of 8'), findsOne);
    });

    testWidgets('a doubling course is refused and the run marked',
        (tester) async {
      await open(tester, which: 1);
      await lay(tester, 0);
      await lay(tester, 0);
      expect(state(tester).play.courses, [0]);
      expect(state(tester).doubled, (0, 1));
      expect(
        find.textContaining('lays a run of 1 twice over'),
        findsOne,
      );
      await lay(tester, 1);
      await lay(tester, 0);
      await lay(tester, 1);
      expect(state(tester).play.courses, hasLength(3));
      expect(state(tester).doubled, (0, 2));
    });

    testWidgets('the penned wall lands the honest card',
        (tester) async {
      await open(tester, which: 1);
      for (final kind in const [0, 1, 0, 2, 0, 1, 0]) {
        await lay(tester, kind);
      }
      expect(state(tester).play.pennedIn, isTrue);
      expect(
        find.textContaining('Some walls close themselves'),
        findsOne,
      );
    });

    testWidgets('Back lifts the last course', (tester) async {
      await open(tester, which: 1);
      await lay(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.courses, isEmpty);
    });

    testWidgets('Show me lights a kind that keeps the height',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(
        find.textContaining('the height stays in reach'),
        findsOne,
      );
    });

    testWidgets('Why speaks the rule and the sweep', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(
        find.textContaining('lays every wall there is'),
        findsOne,
      );
      expect(find.textContaining('144 sound walls'), findsOne);
    });

    testWidgets('the standing wall lands the card', (tester) async {
      await open(tester, which: 0);
      await raiseIt(tester);
      expect(find.text('the wall stands at its height'), findsOne);
      expect(
        find.textContaining('from footing to cope'),
        findsOne,
      );
    });

    testWidgets('every winnable pitch stands by the walk',
        (tester) async {
      for (var number = 0; number < Pitches.count; number++) {
        final pitch = Pitches.at(number);
        if (!pitch.winnable) continue;
        await open(tester, which: number);
        await raiseIt(tester);
        expect(state(tester).play.isDone, isTrue,
            reason: pitch.name);
      }
    });

    testWidgets('the coping writes the askings down', (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await raiseIt(tester);
      await tester.pump();
      expect(best.askingsFor('The Two Kinds'), 0);
      expect(await best.record('The Two Kinds', 9), isFalse);
    });
  });

  group('the fourth course', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('two kinds die at the third'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the sixteen walls', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('all sixteen walls of four courses'),
        findsOne,
      );
    });

    testWidgets('the wall pens at three and the card admits it',
        (tester) async {
      await open(tester, which: 4);
      await lay(tester, 0);
      await lay(tester, 1);
      await lay(tester, 0);
      expect(state(tester).play.pennedIn, isTrue);
      expect(
        find.textContaining('three is as high as the fell goes'),
        findsOne,
      );
      expect(
        find.text('penned at three, as the label said'),
        findsOne,
      );
    });
  });
}
