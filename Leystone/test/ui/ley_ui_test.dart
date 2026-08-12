import 'package:flutter_test/flutter_test.dart';
import 'package:leystone/best.dart';
import 'package:leystone/ley/greens.dart';
import 'package:leystone/ley/rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/ley.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a green opened', () {
    testWidgets('lays the berths out and asks for the ring',
        (tester) async {
      await open(tester, which: 1);
      expect(find.text('The Six Stones'), findsOne);
      expect(find.text('0 of 6'), findsOne);
      expect(find.text('raise 6 with no three on a line'), findsOne);
      expect(find.textContaining('Tap a berth to raise'), findsOne);
    });

    testWidgets('stones go up and come down where they are tapped',
        (tester) async {
      await open(tester, which: 1);
      await tapBerth(tester, (0, 1));
      await tapBerth(tester, (1, 0));
      expect(state(tester).play.stones, [(0, 1), (1, 0)]);
      await tapBerth(tester, (0, 1));
      expect(state(tester).play.stones, [(1, 0)]);
    });

    testWidgets('a berth on a ley is refused and the line drawn',
        (tester) async {
      await open(tester, which: 1);
      await tapBerth(tester, (0, 0));
      await tapBerth(tester, (1, 1));
      await tapBerth(tester, (2, 2));
      expect(state(tester).play.stones, hasLength(2));
      expect(state(tester).ley, isNotNull);
      expect(
        find.textContaining('stands on the ley through'),
        findsOne,
      );
    });

    testWidgets('a stranding pair is called out', (tester) async {
      await open(tester, which: 1);
      // Sound together, but a stone on each diagonal leaves no ring.
      await tapBerth(tester, (0, 0));
      await tapBerth(tester, (2, 0));
      expect(state(tester).play.stones, hasLength(2));
      expect(
        find.textContaining('No full ring grows from those stones'),
        findsOne,
      );
    });

    testWidgets('Back takes the last raising off', (tester) async {
      await open(tester, which: 1);
      await tapBerth(tester, (0, 1));
      await press(tester, 'Back');
      expect(state(tester).play.stones, isEmpty);
    });

    testWidgets('Again clears the green', (tester) async {
      await open(tester, which: 1);
      await tapBerth(tester, (0, 1));
      await press(tester, 'Again');
      expect(state(tester).play.stones, isEmpty);
    });

    testWidgets('Show me points the next stone of a full ring',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(
        find.textContaining('a full ring of 6 grows through it'),
        findsOne,
      );
    });

    testWidgets('Why counts both ways', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(
        find.textContaining('two stones a row at most'),
        findsOne,
      );
      expect(find.textContaining('finds 2 of 6'), findsOne);
    });

    testWidgets('the standing ring lands the card', (tester) async {
      await open(tester, which: 1);
      await raiseIt(tester);
      expect(find.text('the ring stands'), findsOne);
      expect(
        find.textContaining('one of 2 the whole green holds'),
        findsOne,
      );
    });

    testWidgets('every winnable green stands by the pointer',
        (tester) async {
      for (var number = 0; number < Greens.count; number++) {
        final green = Greens.at(number);
        if (!green.winnable) continue;
        await open(tester, which: number);
        await raiseIt(tester);
        expect(state(tester).play.isDone, isTrue, reason: green.name);
      }
    });

    testWidgets('the standing writes the askings down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await raiseIt(tester);
      await tester.pump();
      expect(best.askingsFor('The Close'), 0);
      expect(await best.record('The Close', 9), isFalse);
    });
  });

  group('the odd stone', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('seven never stand'),
        findsWidgets,
      );
    });

    testWidgets('show me from the empty green has nothing',
        (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the counting', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('some row holds three'),
        findsOne,
      );
      expect(find.textContaining('all 36 of them'), findsOne);
    });

    testWidgets('six stand, every berth leys, and the card admits '
        'it', (tester) async {
      await open(tester, which: 4);
      for (final berth in Rules.complete(3, const [], 6)!) {
        await tapBerth(tester, berth);
      }
      expect(state(tester).stuck, isTrue);
      expect(
        find.textContaining('the seventh has nowhere'),
        findsOne,
      );
      expect(
        find.text('six stand and every berth leys, as the label '
            'said'),
        findsOne,
      );
    });
  });
}
