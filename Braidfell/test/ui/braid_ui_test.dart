import 'package:flutter_test/flutter_test.dart';
import 'package:braidfell/best.dart';
import 'package:braidfell/braid/yards.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/braid.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a yard opened', () {
    testWidgets('lays the bundles out and names the asking',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Three Fleeces'), findsOne);
      expect(find.text('0 of 9'), findsOne);
      expect(find.text('one skein for 9 or less'), findsOne);
      expect(find.textContaining('Tap two bundles'), findsOne);
    });

    testWidgets('two taps braid two bundles at their cost',
        (tester) async {
      await open(tester, which: 0);
      await tapBundle(tester, 0);
      expect(state(tester).armed, 0);
      await tapBundle(tester, 1);
      expect(state(tester).play.bundles, [3, 3]);
      expect(find.text('3 of 9'), findsOne);
    });

    testWidgets('arming the same bundle twice disarms it',
        (tester) async {
      await open(tester, which: 0);
      await tapBundle(tester, 0);
      await tapBundle(tester, 0);
      expect(state(tester).armed, -1);
      expect(state(tester).play.work, 0);
    });

    testWidgets('a braid past the asking is called out',
        (tester) async {
      await open(tester, which: 1);
      // Found, not guessed: a braid after which the floor tops the
      // asking.
      final play = state(tester).play;
      (int, int)? wander;
      for (var one = 0; one < 4 && wander == null; one++) {
        for (var two = one + 1; two < 4 && wander == null; two++) {
          final after = play.braid(one, two);
          final second = after.braid(0, 2);
          if (second.floor > play.yard.asked) {
            // The second braid pairs the joined bundle with a
            // single: that is the wrong turn on even weights.
            wander = (one, two);
          }
        }
      }
      expect(wander, isNotNull);
      await tapBundle(tester, wander!.$1);
      await tapBundle(tester, wander.$2);
      // Now pair the braid with a single.
      await tapBundle(tester, 0);
      await tapBundle(tester, 2);
      expect(
        find.textContaining('That braid costs the yard'),
        findsOne,
      );
    });

    testWidgets('Back unpicks a braid', (tester) async {
      await open(tester, which: 0);
      await tapBundle(tester, 0);
      await tapBundle(tester, 1);
      await press(tester, 'Back');
      expect(state(tester).play.bundles, [1, 2, 3]);
      expect(state(tester).play.work, 0);
    });

    testWidgets('Show me lights the two lightest', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');
      final pair = state(tester).pointing!;
      final play = state(tester).play;
      expect(
        {play.bundles[pair.$1], play.bundles[pair.$2]},
        {2, 3},
      );
      expect(
        find.textContaining('Braid the two lightest'),
        findsOne,
      );
    });

    testWidgets('Why speaks the rule and the sweep', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(
        find.textContaining('all 180 orders'),
        findsOne,
      );
      expect(
        find.textContaining('agree to the pound'),
        findsOne,
      );
    });

    testWidgets('meeting the asking lands the card', (tester) async {
      await open(tester, which: 0);
      await braidIt(tester);
      expect(state(tester).play.met, isTrue);
      expect(
        find.textContaining('the least any order of this yard '
            'allows'),
        findsOne,
      );
    });

    testWidgets('an overrun lands the honest card', (tester) async {
      await open(tester, which: 0);
      await tapBundle(tester, 1);
      await tapBundle(tester, 2);
      await tapBundle(tester, 0);
      await tapBundle(tester, 1);
      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.met, isFalse);
      expect(
        find.textContaining('some braid paid for a heavy bundle '
            'twice'),
        findsOne,
      );
    });

    testWidgets('every winnable yard meets its asking by the '
        'pointer', (tester) async {
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        if (!yard.winnable) continue;
        await open(tester, which: number);
        await braidIt(tester);
        expect(state(tester).play.met, isTrue, reason: yard.name);
        expect(state(tester).play.work, yard.least,
            reason: yard.name);
      }
    });

    testWidgets('the meeting writes the askings down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await braidIt(tester);
      await tester.pump();
      expect(best.askingsFor('The Three Fleeces'), 0);
      expect(await best.record('The Three Fleeces', 9), isFalse);
    });
  });

  group('the fifty-nine', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('every order of this yard costs sixty '
            'or more'),
        findsOne,
      );
      expect(
        find.text('one skein for 59 or less: no order ever does'),
        findsOne,
      );
    });

    testWidgets('why speaks the bottom of the sweep', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('the cheapest finishes at 60'),
        findsOne,
      );
    });

    testWidgets('the cheapest braiding still misses, and the card '
        'admits it', (tester) async {
      await open(tester, which: 4);
      await braidIt(tester);
      expect(state(tester).play.work, 60);
      expect(state(tester).play.met, isFalse);
      expect(
        find.textContaining('fifty-nine was never on the table'),
        findsOne,
      );
      expect(
        find.text('sixty, as the label said it must be'),
        findsOne,
      );
    });
  });
}
