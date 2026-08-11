import 'package:flutter_test/flutter_test.dart';

import '../support/garth.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the beds bare', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.planted, 0);
      expect(find.text('0 / 9'), findsOne);
      expect(find.text('no repeats in a line, no pairing twice'),
          findsOne);
    });

    testWidgets('arming then tapping plants a posy', (tester) async {
      await open(tester, which: 0);
      await plant(tester, 0, 1, 2);
      expect(state(tester).play.beds[0], (1, 2));
      expect(find.text('1 / 9'), findsOne);
    });

    testWidgets('a bare bed without an armed posy asks for one',
        (tester) async {
      await open(tester, which: 0);
      await tapBed(tester, 0);
      expect(find.textContaining('Arm a posy first'), findsOne);
    });

    testWidgets('a clash is refused with its reason', (tester) async {
      await open(tester, which: 0);
      await plant(tester, 0, 1, 2);
      // Flower 1 stays armed from the planting; swap only the colour.
      await armColour(tester, 0);
      await tapBed(tester, 1);
      expect(find.textContaining('that flower is in this row'), findsOne);
    });

    testWidgets('a seeded bed stays', (tester) async {
      await open(tester, which: 4);
      await armFlower(tester, 4);
      await armColour(tester, 4);
      await tapBed(tester, 0);
      expect(find.textContaining('seeded before you came'), findsOne);
    });

    testWidgets('Back digs the last posy up', (tester) async {
      await open(tester, which: 0);
      await plant(tester, 0, 1, 2);
      await press(tester, 'Back');
      expect(state(tester).play.planted, 0);
    });

    testWidgets('Again clears the garth', (tester) async {
      await open(tester, which: 0);
      await plant(tester, 0, 1, 2);
      await press(tester, 'Again');
      expect(state(tester).play.planted, 0);
    });
  });

  group('the words under the garden', () {
    testWidgets('Show me arms the posy and points at the bed',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).armedFlower, isNot(-1));
      expect(state(tester).armedColour, isNot(-1));
      expect(find.textContaining('the search has checked it'), findsOne);
    });

    testWidgets('Why lays the planting as ghosts', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(state(tester).showPlanting, isTrue);
      expect(find.textContaining('two-line planting'), findsOne);
    });

    testWidgets('the four beds credit the doubling instead',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('doubled square'), findsOne);
    });

    testWidgets('the pair of pairs owns its sweep', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('No planting of this garth exists'),
          findsOne);
      await press(tester, 'Why');
      expect(state(tester).showPlanting, isFalse);
      expect(find.textContaining('every one repeats a posy'), findsOne);
    });
  });

  group('a garth bloomed', () {
    testWidgets('following the game blooms every garth that can bloom',
        (tester) async {
      for (final number in const [0, 4]) {
        await open(tester, which: number);
        await bloomItAll(tester);
        expect(state(tester).play.isBloomed, isTrue,
            reason: 'garth $number');
      }
    });

    testWidgets('the card names the officers', (tester) async {
      await open(tester, which: 0);
      await bloomItAll(tester);
      expect(find.textContaining('all the officers ever wanted'),
          findsOne);
    });

    testWidgets('Next opens the garth after', (tester) async {
      await open(tester, which: 0);
      await bloomItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.garth.name, 'The Four Beds');
    });
  });
}
