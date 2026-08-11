import 'package:flutter_test/flutter_test.dart';

import '../support/hold.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with every rope free', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.chosenCount, 0);
      expect(find.text('0 / 8'), findsOne);
      expect(find.text('one rope each to each line'), findsOne);
    });

    testWidgets('a tap gives a rope to north-south, another to east-west',
        (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0, 0);
      expect(state(tester).play.serves(0, 0), 'ns');
      await tapChip(tester, 0, 0);
      expect(state(tester).play.serves(0, 0), 'ew');
      await tapChip(tester, 0, 0);
      expect(state(tester).play.serves(0, 0), isNull);
    });

    testWidgets('a crate with both lines served refuses its third rope',
        (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0, 0);
      await tapChip(tester, 0, 1);
      await tapChip(tester, 0, 2);
      expect(find.textContaining('Both lines are served'), findsOne);
    });

    testWidgets('Back returns the last choice', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0, 0);
      await press(tester, 'Back');
      expect(state(tester).play.chosenCount, 0);
    });

    testWidgets('Again frees everything', (tester) async {
      await open(tester, which: 0);
      await tapChip(tester, 0, 0);
      await press(tester, 'Again');
      expect(state(tester).play.chosenCount, 0);
    });
  });

  group('the words under the yard', () {
    testWidgets('Show me points at a rope and names its line',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the search has checked it'), findsOne);
    });

    testWidgets('Why strings the posts and tells the turning',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(state(tester).showRopes, isTrue);
      expect(find.textContaining('walking them nose to tail'), findsOne);
    });

    testWidgets('the short consignment counts its proof', (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('No stacking of this consignment'),
          findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('only 2'), findsOne);
      expect(find.textContaining('Count the faces'), findsWidgets);
    });
  });

  group('a stack standing', () {
    testWidgets('following the game stacks every consignment that can',
        (tester) async {
      for (final number in const [0, 1, 4]) {
        await open(tester, which: number);
        await stackItAll(tester);
        expect(state(tester).play.isStacked, isTrue,
            reason: 'consignment $number');
      }
    });

    testWidgets('the tight consignment stands too, both ways being one',
        (tester) async {
      await open(tester, which: 2);
      await stackItAll(tester);
      expect(find.textContaining('2 ways in the 1,296'), findsOne);
    });

    testWidgets('Next opens the consignment after', (tester) async {
      await open(tester, which: 0);
      await stackItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.consignment.name, 'The Fair Set');
    });
  });
}
