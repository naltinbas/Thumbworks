import 'package:flutter_test/flutter_test.dart';
import 'package:millgreave/moor/moors.dart';

import '../support/moor.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the moor bare', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.standing, 0);
      expect(find.text('0 / 4'), findsOne);
      expect(find.text('a mill in every file, no wind shared'), findsOne);
    });

    testWidgets('tapping a clear plot raises a mill', (tester) async {
      await open(tester, which: 0);
      await raise(tester, 0, 1);
      expect(state(tester).play.standing, 1);
      expect(find.text('1 / 4'), findsOne);
    });

    testWidgets('a stolen plot is refused and the thief is named',
        (tester) async {
      await open(tester, which: 0);
      await raise(tester, 0, 1);
      await raise(tester, 1, 1);
      expect(state(tester).play.standing, 1);
      expect(find.textContaining('file 1, row 2'), findsOne);
      expect(find.textContaining('steals that plot'), findsOne);
    });

    testWidgets('a filled file is refused with the rule', (tester) async {
      await open(tester, which: 0);
      await raise(tester, 0, 1);
      await raise(tester, 0, 3);
      expect(state(tester).play.standing, 1);
      expect(find.textContaining('has its mill already'), findsOne);
    });

    testWidgets('Back takes the last mill down', (tester) async {
      await open(tester, which: 0);
      await raise(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.standing, 0);
    });

    testWidgets('Again clears the moor', (tester) async {
      await open(tester, which: 0);
      await raise(tester, 0, 1);
      await press(tester, 'Again');
      expect(state(tester).play.standing, 0);
    });
  });

  group('the words under the moor', () {
    testWidgets('a stranding mill is called out at once', (tester) async {
      await open(tester, which: 3);
      final play = state(tester).play;
      var strander = (-1, -1);
      for (var row = 0; row < 6 && strander.$1 < 0; row++) {
        if (!play.mayRaise(0, row)) continue;
        if (!play.raise(0, row).canStill) strander = (0, row);
      }
      expect(strander.$1, isNot(-1));
      await raise(tester, strander.$1, strander.$2);
      expect(find.textContaining('strands the moor'), findsOne);
    });

    testWidgets('Show me points at a plot the search has checked',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the search has checked it'), findsOne);
    });

    testWidgets('Why raises the built rows as ghosts', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showBuilt, isTrue);
      expect(find.textContaining('written straight down'), findsOne);
    });

    testWidgets('the three mills walk their cases instead', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('No setting exists'), findsOne);
      await press(tester, 'Why');
      expect(state(tester).showBuilt, isFalse);
      expect(find.textContaining('Walk the cases'), findsOne);
    });
  });

  group('a moor set', () {
    testWidgets('following the game sets every possible moor',
        (tester) async {
      for (var number = 0; number < Moors.count; number++) {
        final moor = Moors.at(number);
        if (!moor.possible) continue;
        await open(tester, which: number);
        await setItAll(tester);
        expect(state(tester).play.isSet, isTrue, reason: moor.name);
      }
    });

    testWidgets('the card counts the settings', (tester) async {
      await open(tester, which: 0);
      await setItAll(tester);
      expect(find.textContaining('can be set 2 ways'), findsOne);
      expect(find.text('every mill keeps its wind'), findsOne);
    });

    testWidgets('Next opens the moor after', (tester) async {
      await open(tester, which: 0);
      await setItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.moor.name, Moors.at(1).name);
    });
  });
}
