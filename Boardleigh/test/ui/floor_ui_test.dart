import 'package:boardleigh/floor/rooms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/floor.dart';

void main() {
  group('the screen', () {
    testWidgets('opens bare', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.planks, isEmpty);
      expect(find.text('8 cells bare'), findsOne);
      expect(find.text('0 moved'), findsOne);
    });

    testWidgets('two taps lay a plank, a tap on it lifts it',
        (tester) async {
      await open(tester, which: 0);
      await layPlank(tester, 0, 1);
      expect(state(tester).play.planks, [(0, 1)]);
      await tapCell(tester, 0);
      expect(state(tester).play.planks, isEmpty);
      expect(find.text('2 moved'), findsOne);
    });

    testWidgets('a far pair is refused with the rule', (tester) async {
      await open(tester, which: 0);
      await layPlank(tester, 0, 2);
      expect(state(tester).play.planks, isEmpty);
      expect(find.textContaining('side by side'), findsOne);
    });

    testWidgets('Back unmoves the last move', (tester) async {
      await open(tester, which: 0);
      await layPlank(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.planks, isEmpty);
    });

    testWidgets('Again bares the room', (tester) async {
      await open(tester, which: 0);
      await layPlank(tester, 0, 1);
      await layPlank(tester, 2, 3);
      await press(tester, 'Again');
      expect(state(tester).play.moves, 0);
    });
  });

  group('the words under the room', () {
    testWidgets('a stranding plank is called out the moment it lands',
        (tester) async {
      // In the square parlour, lay along the search until a stranding
      // plank exists, then lay it.
      await open(tester, which: 2);
      var guard = 0;
      var called = false;
      while (guard++ < 8 && !called) {
        final play = state(tester).play;
        (int, int)? stranding;
        for (var one = 0; one < 16 && stranding == null; one++) {
          for (var other = one + 1; other < 16; other++) {
            if (!play.mayLay(one, other)) continue;
            if (!play.lay(one, other).canStill) {
              stranding = (one, other);
              break;
            }
          }
        }
        if (stranding != null) {
          await layPlank(tester, stranding.$1, stranding.$2);
          expect(find.textContaining('strands what is left'), findsOne);
          expect(find.text('the rest is stranded'), findsOne);
          called = true;
        } else {
          final plank = play.next!;
          await layPlank(tester, plank.$1, plank.$2);
        }
      }
      expect(called, isTrue,
          reason: 'no stranding plank ever offered itself');
    });

    testWidgets('Show me points at a plank the count has walked',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the count has been everywhere'),
          findsOne);
    });

    testWidgets('Why tints the colours and counts the ways',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showColours, isTrue);
      expect(find.textContaining('7 and 7'), findsOne);
      expect(find.textContaining('21 full layings'), findsOne);
    });

    testWidgets('the clipped parlour says so as it opens, and Why '
        'counts the colours', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No laying floors this room'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('6 dark and 8 light'), findsOne);
      expect(find.textContaining('found none'), findsOne);
    });
  });

  group('a floor laid', () {
    testWidgets('following the game floors every winnable room',
        (tester) async {
      for (var number = 0; number < Rooms.count; number++) {
        final room = Rooms.at(number);
        if (!room.winnable) continue;
        await open(tester, which: number);
        await floorItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: room.name);
      }
    });

    testWidgets('the card owns the count', (tester) async {
      await open(tester, which: 0);
      await floorItAll(tester);
      expect(find.text('the floor is laid'), findsOne);
      expect(find.textContaining('one of 5 full layings'), findsOne);
    });

    testWidgets('Next opens the room after', (tester) async {
      await open(tester, which: 0);
      await floorItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.room.name, Rooms.at(1).name);
    });
  });
}
