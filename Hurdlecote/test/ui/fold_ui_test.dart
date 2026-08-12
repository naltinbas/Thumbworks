import 'package:flutter_test/flutter_test.dart';
import 'package:hurdlecote/best.dart';
import 'package:hurdlecote/fold/greens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fold.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a green opened', () {
    testWidgets('lays the green out and names the task',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Half Acre'), findsOne);
      expect(find.text('0 hurdles'), findsOne);
      expect(find.text('pen half an acre'), findsOne);
      expect(find.textContaining('Tap crossings to set hurdles'),
          findsOne);
    });

    testWidgets('hurdles go up where they are tapped', (tester) async {
      await open(tester, which: 0);
      await tapCross(tester, (1, 1));
      await tapCross(tester, (3, 1));
      expect(state(tester).play.posts, [(1, 1), (3, 1)]);
      expect(find.text('2 hurdles'), findsOne);
    });

    testWidgets('a rail through a standing hurdle is refused',
        (tester) async {
      await open(tester, which: 0);
      await tapCross(tester, (0, 0));
      await tapCross(tester, (2, 0));
      // Doubling straight back over the rail just laid.
      await tapCross(tester, (1, 0));
      expect(state(tester).play.posts, hasLength(2));
      expect(
        find.textContaining('A rail cannot cross the fence'),
        findsOne,
      );
    });

    testWidgets('tapping the first hurdle closes the fence',
        (tester) async {
      await open(tester, which: 0);
      for (final spot in const [(1, 1), (1, 2), (2, 1)]) {
        await tapCross(tester, spot);
      }
      await tapCross(tester, (1, 1));
      expect(state(tester).play.closed, isTrue);
      expect(state(tester).play.isDone, isTrue);
      expect(find.text('the task is penned'), findsOne);
    });

    testWidgets('a wrong fence is told its numbers', (tester) async {
      await open(tester, which: 0);
      for (final spot in const [(0, 0), (2, 0), (2, 2), (0, 2)]) {
        await tapCross(tester, spot);
      }
      await tapCross(tester, (0, 0));
      expect(state(tester).play.closed, isTrue);
      expect(state(tester).play.isDone, isFalse);
      expect(
        find.textContaining('That fence pens 4 acres and swallows 1'),
        findsOne,
      );
      await press(tester, 'Back');
      expect(state(tester).play.closed, isFalse);
      expect(state(tester).play.posts, hasLength(4));
    });

    testWidgets('a stranding hurdle is called out', (tester) async {
      await open(tester, which: 3);
      // Found, not guessed: a first hurdle from which no fence
      // swallowing nine grows.
      final play = state(tester).play;
      (int, int)? strands;
      for (var x = 0; x < 5 && strands == null; x++) {
        for (var y = 0; y < 5 && strands == null; y++) {
          final after = play.set((x, y));
          if (after.finished == null) strands = (x, y);
        }
      }
      expect(strands, isNotNull,
          reason: 'every first hurdle still grows a fence');
      await tapCross(tester, strands!);
      expect(
        find.textContaining('No fence settling the task grows'),
        findsOne,
      );
    });

    testWidgets('Again clears the green', (tester) async {
      await open(tester, which: 0);
      await tapCross(tester, (1, 1));
      await press(tester, 'Again');
      expect(state(tester).play.posts, isEmpty);
    });

    testWidgets('Show me points the next hurdle, then the close',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      final pointed = state(tester).pointing;
      expect(pointed, isNotNull);
      expect(
        find.textContaining('Set a hurdle there'),
        findsOne,
      );
      // Follow it all the way; the last asking points the close.
      while (!state(tester).play.mayClose) {
        await tapCross(tester, state(tester).pointing!);
        await press(tester, 'Show me');
      }
      expect(state(tester).pointing, state(tester).play.posts.first);
      expect(find.textContaining('Close it'), findsOne);
    });

    testWidgets('Why counts both ways', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(find.textContaining('18,934'), findsOne);
      expect(find.textContaining('swallowed + walked/2 - 1'), findsOne);
      expect(find.textContaining('1,096 of those fences'), findsOne);
    });

    testWidgets(
        'every winnable green settles in its fewest hurdles by '
        'following the pointer', (tester) async {
      for (var number = 0; number < Greens.count; number++) {
        final green = Greens.at(number);
        if (!green.winnable) continue;
        await open(tester, which: number);
        await fenceIt(tester);
        expect(state(tester).play.posts, hasLength(green.posts!),
            reason: green.name);
      }
    });

    testWidgets('the settling writes the fewest hurdles down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await fenceIt(tester);
      await tester.pump();
      expect(best.hurdlesFor('The Half Acre'), 3);
      expect(await best.record('The Half Acre', 9), isFalse);
    });
  });

  group('the third acre', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No fence pens this'), findsOne);
      expect(
        find.text('pen a third of an acre: no fence ever will'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the halves', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('twice a third of an acre is not'),
        findsOne,
      );
      expect(find.textContaining('18,934'), findsOne);
    });

    testWidgets('three misses and the green admits it',
        (tester) async {
      await open(tester, which: 4);
      for (var miss = 0; miss < Greens.missesAllowed; miss++) {
        for (final spot in const [(0, 0), (1, 0), (0, 1)]) {
          await tapCross(tester, spot);
        }
        await tapCross(tester, (0, 0));
        if (miss + 1 < Greens.missesAllowed) {
          expect(state(tester).gaveUp, isFalse);
          await press(tester, 'Back');
          await press(tester, 'Back');
          await press(tester, 'Back');
          await press(tester, 'Back');
        }
      }
      expect(state(tester).gaveUp, isTrue);
      expect(
        find.textContaining('Every fence closed here penned'),
        findsOne,
      );
      expect(
        find.text('unpenned, as the label said it must stay'),
        findsOne,
      );
    });
  });
}
