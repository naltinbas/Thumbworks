import 'package:flutter_test/flutter_test.dart';
import 'package:mottlemoor/herd/moors.dart';

import '../support/herd.dart';

void main() {
  group('the screen', () {
    testWidgets('opens as dealt', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.herds, (2, 2, 2));
      expect(find.text('2 meetings from settling'), findsOne);
      expect(find.text('0 met'), findsOne);
    });

    testWidgets('two taps make a meeting', (tester) async {
      await open(tester, which: 0);
      await meet(tester, 0, 1);
      expect(state(tester).play.herds, (1, 1, 4));
      expect(find.text('1 met'), findsOne);
    });

    testWidgets('arming and disarming meets nobody', (tester) async {
      await open(tester, which: 0);
      await tapPatch(tester, 1);
      expect(state(tester).armed, 1);
      await tapPatch(tester, 1);
      expect(state(tester).armed, -1);
      expect(state(tester).play.meetingsMade, 0);
    });

    testWidgets('an empty herd is refused', (tester) async {
      await open(tester, which: 1);
      // Russet holds one: meet it away, then try to use it again.
      await meet(tester, 0, 1);
      await tapPatch(tester, 0);
      expect(find.text('That herd is empty.'), findsOne);
    });

    testWidgets('Back unmeets the last meeting', (tester) async {
      await open(tester, which: 0);
      await meet(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.herds, (2, 2, 2));
    });

    testWidgets('Again restores the moor', (tester) async {
      await open(tester, which: 0);
      await meet(tester, 0, 1);
      await press(tester, 'Again');
      expect(state(tester).play.meetingsMade, 0);
    });
  });

  group('the words under the moor', () {
    testWidgets('a wandering meeting is called out with the live '
        'number', (tester) async {
      await open(tester, which: 2);
      final before = state(tester).play.fewestFromHere!;
      // Find a wandering meeting rather than guess one.
      (int, int)? wander;
      for (final pair
          in state(tester).play.rules.meetings(state(tester).play.herds)) {
        final after =
            state(tester).play.meet(pair.$1, pair.$2).fewestFromHere!;
        if (after > before) {
          wander = pair;
          break;
        }
      }
      expect(wander, isNotNull,
          reason: 'no first meeting wanders on the fifteen');
      await meet(tester, wander!.$1, wander.$2);
      expect(find.textContaining('wandered'), findsOne);
    });

    testWidgets('Show me points at the walk\'s meeting',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('steps one nearer'), findsOne);
    });

    testWidgets('Why speaks the remainders', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(find.textContaining('nought or three'), findsOne);
      expect(find.textContaining('every herding of 16'), findsOne);
    });

    testWidgets('the famous herd says so as it opens, and Why counts '
        'the remainders', (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('never settles'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('13, 15 and 17'), findsOne);
      expect(find.textContaining('level at nought'), findsOne);
    });
  });

  group('a moor settled', () {
    testWidgets('following the game settles every winnable moor at '
        'its fewest', (tester) async {
      for (var number = 0; number < Moors.count; number++) {
        final moor = Moors.at(number);
        if (!moor.winnable) continue;
        await open(tester, which: number);
        await settleIt(tester);
        expect(state(tester).play.isSettled, isTrue, reason: moor.name);
        expect(state(tester).play.meetingsMade, moor.fewest,
            reason: moor.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten',
        (tester) async {
      await open(tester, which: 2);
      // A wandering start, found rather than guessed, then follow
      // home.
      final before = state(tester).play.fewestFromHere!;
      (int, int)? wander;
      for (final pair
          in state(tester).play.rules.meetings(state(tester).play.herds)) {
        if (state(tester).play.meet(pair.$1, pair.$2).fewestFromHere! >
            before) {
          wander = pair;
          break;
        }
      }
      await meet(tester, wander!.$1, wander.$2);
      await settleIt(tester);
      expect(find.text('the moor wears one colour'), findsOne);
      expect(find.textContaining('The fewest is 5'), findsOne);
    });

    testWidgets('Next opens the moor after', (tester) async {
      await open(tester, which: 0);
      await settleIt(tester);
      await press(tester, 'Next');
      expect(state(tester).play.moor.name, Moors.at(1).name);
    });
  });
}
