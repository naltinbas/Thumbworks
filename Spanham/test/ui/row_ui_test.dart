import 'package:flutter_test/flutter_test.dart';
import 'package:spanham/row/levels.dart';

import '../support/row.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the biggest pair in hand', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.placing, 3);
      expect(find.text('0 / 3'), findsOne);
      expect(find.text('the 3 pair in hand'), findsOne);
    });

    testWidgets('tapping a seat sets the pair down', (tester) async {
      await open(tester, which: 0);
      await place(tester, 0);
      expect(state(tester).play.row[0], 3);
      expect(state(tester).play.row[4], 3);
      expect(state(tester).play.placing, 2);
    });

    testWidgets('a seat that cannot take the pair is refused with the '
        'rule', (tester) async {
      await open(tester, which: 0);
      await place(tester, 0);
      await place(tester, 1);
      expect(state(tester).play.placing, 2);
      expect(find.textContaining('cannot sit there'), findsOne);
    });

    testWidgets('Back returns the pair to hand', (tester) async {
      await open(tester, which: 0);
      await place(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.placing, 3);
    });

    testWidgets('Again empties the shelf', (tester) async {
      await open(tester, which: 0);
      await place(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.placing, 3);
    });
  });

  group('the words under the shelf', () {
    testWidgets('a stranding placement is called out at once',
        (tester) async {
      await open(tester, which: 3);
      var called = false;
      var guard = 0;
      while (!called && guard++ < 8) {
        final play = state(tester).play;
        var strander = -1;
        for (var seat = 0; seat < play.level.seats; seat++) {
          if (!play.mayPlace(seat)) continue;
          if (!play.place(seat).canStill) {
            strander = seat;
            break;
          }
        }
        if (strander >= 0) {
          await place(tester, strander);
          expect(find.textContaining('strands the shelf'), findsOne);
          called = true;
        } else {
          await place(tester, play.next!);
        }
      }
      expect(called, isTrue);
    });

    testWidgets('Show me points at a seat the search has checked',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('the search has checked it'), findsOne);
    });

    testWidgets('Why does the arithmetic for this very shelf',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(state(tester).showSums, isTrue);
      expect(find.textContaining('add them: 55'), findsOne);
      expect(find.textContaining('35: odd'), findsOne);
    });

    testWidgets('and comes out even where the shelf can be set',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(find.textContaining('even, and the shelf can be set'),
          findsOne);
    });

    testWidgets('the impossible shelf says what it is for', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('No setting exists'), findsOne);
      await press(tester, 'Show me');
      expect(find.textContaining('nothing to show'), findsOne);
    });
  });

  group('a shelf set', () {
    testWidgets('following the game sets every shelf that can be set',
        (tester) async {
      for (var number = 0; number < Levels.count; number++) {
        final level = Levels.at(number);
        if (!level.possible) continue;
        await open(tester, which: number);
        await setItAll(tester);
        expect(state(tester).play.isSet, isTrue, reason: level.name);
      }
    });

    testWidgets('the card counts the settings', (tester) async {
      await open(tester, which: 0);
      await setItAll(tester);
      expect(find.textContaining('can be set 2 ways'), findsOne);
      expect(find.text('every pair its number apart'), findsOne);
    });

    testWidgets('Next opens the shelf after', (tester) async {
      await open(tester, which: 0);
      await setItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.level.name, Levels.at(1).name);
    });
  });
}
