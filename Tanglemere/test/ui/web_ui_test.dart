import 'package:flutter_test/flutter_test.dart';
import 'package:tanglemere/web/webs.dart';

import '../support/web.dart';

void main() {
  group('the screen', () {
    testWidgets('opens bare on the first seat', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.woven, 0);
      expect(find.text('the search reads the weave even'), findsOne);
      expect(find.text('0 woven'), findsOne);
    });

    testWidgets('the house opens where it weaves first',
        (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.woven, 1);
      expect(find.text('1 woven'), findsOne);
    });

    testWidgets('a tap weaves a thread and the house replies',
        (tester) async {
      await open(tester, which: 0);
      await tapThread(tester, state(tester).play.next!);
      expect(state(tester).play.woven, 2);
    });

    testWidgets('a woven thread is refused', (tester) async {
      await open(tester, which: 0);
      final thread = state(tester).play.next!;
      await tapThread(tester, thread);
      await tapThread(tester, thread);
      expect(state(tester).play.woven, 2);
      expect(find.textContaining('woven already'), findsOne);
    });

    testWidgets('Back takes the round back', (tester) async {
      await open(tester, which: 0);
      await tapThread(tester, state(tester).play.next!);
      await press(tester, 'Back');
      expect(state(tester).play.woven, 0);
    });

    testWidgets('Again clears the loom', (tester) async {
      await open(tester, which: 0);
      await tapThread(tester, state(tester).play.next!);
      await press(tester, 'Again');
      expect(state(tester).play.woven, 0);
    });
  });

  group('the words under the loom', () {
    testWidgets('Show me points at the search\'s thread',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('keeps your standing'), findsOne);
    });

    testWidgets('Why speaks the Ramsey pair', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(find.textContaining('32,768'), findsOne);
      expect(find.textContaining('counting argument'), findsOne);
    });

    testWidgets('the five posts speak their twelve rings',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(find.textContaining('twelve finished webs'), findsOne);
      expect(find.textContaining('ring of each colour'), findsOne);
    });

    testWidgets('the first thread says so as it opens', (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('before your first thread'),
          findsOne);
      expect(find.text('the search reads the web the house\'s'),
          findsOne);
    });
  });

  group('a weave settled', () {
    testWidgets('following the search draws the five posts',
        (tester) async {
      await open(tester, which: 0);
      await weaveItOut(tester);
      expect(state(tester).play.isDrawn, isTrue);
      expect(find.text('the web holds, nobody caught'), findsOne);
      expect(find.textContaining('twelve safe paintings'), findsOne);
    });

    testWidgets('following the search wins the six posts second seat',
        (tester) async {
      await open(tester, which: 2);
      await weaveItOut(tester);
      expect(state(tester).play.playerWon, isTrue);
      expect(find.text('the house closed its triangle'), findsOne);
    });

    testWidgets('the first thread closes on the player, as the label '
        'said', (tester) async {
      await open(tester, which: 3);
      await weaveItOut(tester);
      expect(state(tester).play.lostBy, isTrue);
      expect(find.textContaining('as the label said'), findsOne);
    });

    testWidgets('Next opens the web after', (tester) async {
      await open(tester, which: 0);
      await weaveItOut(tester);
      await press(tester, 'Next');
      expect(state(tester).play.web.name, Webs.at(1).name);
    });
  });
}
