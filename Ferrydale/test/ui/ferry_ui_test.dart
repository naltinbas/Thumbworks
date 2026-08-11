import 'package:ferrydale/ferry/ferries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ferry.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with everyone on the near bank', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.crossings, 0);
      expect(find.text('7 crossings from the landing'), findsOne);
      expect(find.text('0 rowed'), findsOne);
    });

    testWidgets('a tap boards, another disembarks', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 2);
      expect(state(tester).play.isAboard(2), isTrue);
      await tapChip(tester, 2);
      expect(state(tester).play.isAboard(2), isFalse);
    });

    testWidgets('a full boat refuses another boarder', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await tapChip(tester, 1);
      expect(state(tester).play.aboard, hasLength(2));
      expect(find.text('The boat is full.'), findsOne);
    });

    testWidgets('rowing an empty boat is refused in words',
        (tester) async {
      await open(tester, which: 0);
      await rowBoat(tester);
      expect(state(tester).play.crossings, 0);
      expect(find.text('Nobody is aboard.'), findsOne);
    });

    testWidgets('a dangerous landing is refused by name',
        (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await rowBoat(tester);
      expect(state(tester).play.crossings, 0);
      expect(find.text('The wolf would be left with the goat.'),
          findsOne);
    });

    testWidgets('a good crossing rows, and Back returns it',
        (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      expect(state(tester).play.crossings, 1);
      await press(tester, 'Back');
      expect(state(tester).play.crossings, 0);
    });

    testWidgets('Again empties the river', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      await press(tester, 'Again');
      expect(state(tester).play.crossings, 0);
      expect(state(tester).play.boatFar, isFalse);
    });
  });

  group('the words under the river', () {
    testWidgets('a wandering crossing is called out with the live '
        'number', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      // Rowing the goat straight back wanders.
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      expect(find.textContaining('wandered'), findsOne);
    });

    testWidgets('Show me names the load', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotEmpty);
      expect(state(tester).hints, 1);
      expect(find.textContaining('aboard and row'), findsOne);
    });

    testWidgets('Why speaks the walk', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('all 64'), findsOne);
      expect(find.textContaining('11 from the first bank'), findsOne);
    });

    testWidgets('the four and four say so as they open, and Why '
        'counts the walk', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('never lands everyone'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isEmpty);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('all 98 of them'), findsOne);
      expect(find.textContaining('no trick left untried'), findsOne);
    });
  });

  group('a ferry landed', () {
    testWidgets('following the game lands every winnable ferry at its '
        'fewest', (tester) async {
      for (var number = 0; number < Ferries.count; number++) {
        final ferry = Ferries.at(number);
        if (!ferry.winnable) continue;
        await open(tester, which: number);
        await rowItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: ferry.name);
        expect(state(tester).play.crossings, ferry.fewest,
            reason: ferry.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten',
        (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      await tapChip(tester, 0);
      await tapChip(tester, 2);
      await rowBoat(tester);
      await rowItAll(tester);
      expect(find.text('everyone is across'), findsOne);
      expect(find.textContaining('The fewest is 7'), findsOne);
    });

    testWidgets('Next opens the ferry after', (tester) async {
      await open(tester, which: 0);
      await rowItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.ferry.name, Ferries.at(1).name);
    });
  });
}
