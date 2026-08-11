import 'package:charmstead/charm/charms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/charm.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the pins laid', (tester) async {
      await open(tester, which: 3);
      expect(state(tester).play.laid[0], 4);
      expect(find.text('3 of 9 coins laid'), findsOne);
      expect(find.text('0 moved'), findsOne);
    });

    testWidgets('arming a coin and tapping a cell lays it',
        (tester) async {
      await open(tester, which: 0);
      await lay(tester, 4, 5);
      expect(state(tester).play.laid[4], 5);
      expect(find.text('1 moved'), findsOne);
    });

    testWidgets('tapping a laid coin lifts it back', (tester) async {
      await open(tester, which: 0);
      await lay(tester, 4, 5);
      await tapCell(tester, 4);
      expect(state(tester).play.laid[4], isNull);
      expect(state(tester).play.tray, contains(5));
    });

    testWidgets('a pinned coin is held fast', (tester) async {
      await open(tester, which: 1);
      await tapCell(tester, 4);
      expect(state(tester).play.laid[4], 5);
      expect(find.textContaining('held fast'), findsOne);
    });

    testWidgets('a bare cell without an armed coin asks for one',
        (tester) async {
      await open(tester, which: 0);
      await tapCell(tester, 0);
      expect(find.textContaining('Arm a coin'), findsOne);
    });

    testWidgets('Back unmoves the last move', (tester) async {
      await open(tester, which: 0);
      await lay(tester, 0, 2);
      await press(tester, 'Back');
      expect(state(tester).play.laid[0], isNull);
    });

    testWidgets('Again clears the bed to its pins', (tester) async {
      await open(tester, which: 0);
      await lay(tester, 0, 2);
      await lay(tester, 1, 7);
      await press(tester, 'Again');
      expect(state(tester).play.moves, 0);
    });
  });

  group('the words under the bed', () {
    testWidgets('a line finished off the count is called out',
        (tester) async {
      await open(tester, which: 0);
      await lay(tester, 0, 1);
      await lay(tester, 1, 2);
      await lay(tester, 2, 3);
      expect(find.textContaining('finished at 6'), findsOne);
      expect(find.textContaining('finished off the count'), findsOne);
    });

    testWidgets('Show me offers a mend from the nearest charm',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('nearest charm'), findsOne);
    });

    testWidgets('Why speaks the counting and the sweep', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(find.textContaining('forty five'), findsOne);
      expect(find.textContaining('8 charms'), findsOne);
    });

    testWidgets('the heart of one says so as it opens, and Why counts '
        'the heart', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No laying of the coins'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('sixty together'), findsOne);
      expect(find.textContaining('one it can never be'), findsOne);
    });

    testWidgets('the heavy row asks for less than nothing',
        (tester) async {
      await open(tester, which: 5);
      await press(tester, 'Why');
      expect(find.textContaining('seventeen'), findsOne);
      expect(find.textContaining('less than nothing'), findsOne);
    });
  });

  group('a charm held', () {
    testWidgets('following the game holds every winnable charm',
        (tester) async {
      for (var number = 0; number < Charms.count; number++) {
        final charm = Charms.at(number);
        if (!charm.winnable) continue;
        await open(tester, which: number);
        await setItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: charm.name);
      }
    });

    testWidgets('the card owns the ways', (tester) async {
      await open(tester, which: 3);
      await setItAll(tester);
      expect(find.text('every line counts fifteen'), findsOne);
      expect(find.textContaining('the only charm honouring the pins'),
          findsOne);
    });

    testWidgets('Next opens the charm after', (tester) async {
      await open(tester, which: 0);
      await setItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.charm.name, Charms.at(1).name);
    });
  });
}
