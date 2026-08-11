import 'package:flutter_test/flutter_test.dart';
import 'package:ringmarsh/ring/watches.dart';

import '../support/ring.dart';

void main() {
  group('the screen', () {
    testWidgets('opens dark with the words counted', (tester) async {
      await open(tester, which: 1);
      expect(state(tester).play.ring, 0);
      expect(find.text('1 of 8 watchwords spelt'), findsOne);
      expect(find.text('0 turned'), findsOne);
    });

    testWidgets('a tap turns a lantern and counts', (tester) async {
      await open(tester, which: 1);
      await turn(tester, 3);
      expect(state(tester).play.lit(3), isTrue);
      expect(find.text('1 turned'), findsOne);
    });

    testWidgets('a held lantern is refused', (tester) async {
      await open(tester, which: 2);
      await turn(tester, 0);
      expect(state(tester).play.turns, 0);
      expect(find.textContaining('held fast'), findsOne);
    });

    testWidgets('Back unturns the last lantern', (tester) async {
      await open(tester, which: 1);
      await turn(tester, 3);
      await press(tester, 'Back');
      expect(state(tester).play.ring, 0);
    });

    testWidgets('Again darkens the ring', (tester) async {
      await open(tester, which: 1);
      await turn(tester, 3);
      await turn(tester, 5);
      await press(tester, 'Again');
      expect(state(tester).play.turns, 0);
    });
  });

  group('the words under the road', () {
    testWidgets('a wandering turn is called out with the live number',
        (tester) async {
      await open(tester, which: 2);
      final away = state(tester).play.fewestFromHere!;
      // The one answer wants lantern seven dark: turning it wanders.
      await turn(tester, 7);
      expect(state(tester).play.fewestFromHere, away + 1);
      expect(find.textContaining('wandered'), findsOne);
    });

    testWidgets('Show me points at a lantern toward the nearest watch',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('nearest full watch'), findsOne);
    });

    testWidgets('Why chords the clashes and counts the ways',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showClashes, isTrue);
      expect(find.textContaining('16 full'), findsOne);
      expect(find.textContaining('shift-walk'), findsOne);
    });

    testWidgets('the short ring says so as it opens, and Why counts it',
        (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No ring of these lanterns'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('at most 7 words'), findsOne);
      expect(find.textContaining('asks 8'), findsOne);
    });
  });

  group('a watch set full', () {
    testWidgets('following the game sets every winnable watch',
        (tester) async {
      for (var number = 0; number < Watches.count; number++) {
        final watch = Watches.at(number);
        if (!watch.winnable) continue;
        await open(tester, which: number);
        await setItFull(tester);
        expect(state(tester).play.isFull, isTrue, reason: watch.name);
      }
    });

    testWidgets('the locked watch owns its uniqueness', (tester) async {
      await open(tester, which: 2);
      await setItFull(tester);
      expect(find.text('every watchword spelt'), findsOne);
      expect(find.textContaining('the only ring that does it'),
          findsOne);
    });

    testWidgets('Next opens the watch after', (tester) async {
      await open(tester, which: 0);
      await setItFull(tester);
      await press(tester, 'Next');
      expect(state(tester).play.watch.name, Watches.at(1).name);
    });
  });
}
