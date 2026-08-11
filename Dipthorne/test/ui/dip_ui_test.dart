import 'package:flutter_test/flutter_test.dart';
import 'package:dipthorne/ring/rings.dart';

import '../support/dip.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with everyone in and a seat to choose', (tester) async {
      await open(tester, which: 1);
      expect(state(tester).play.hasChosen, isFalse);
      expect(find.text('choose a seat'), findsOne);
      expect(find.text('13 of 13 still in'), findsOne);
    });

    testWidgets('tapping a seat takes it', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 11);
      expect(state(tester).play.chosen, 11);
      expect(find.text('seat 11'), findsOne);
      expect(find.textContaining('the rhyme begins'), findsOne);
    });

    testWidgets('Count chants once and somebody steps out', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 11);
      await press(tester, 'Count');
      expect(state(tester).play.out, hasLength(1));
      expect(find.textContaining('steps out'), findsOne);
      expect(find.textContaining('"Ip, dip"'), findsOne);
    });

    testWidgets('Again empties the yard for a new choice', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 3);
      await press(tester, 'Count');
      await press(tester, 'Again');
      expect(state(tester).play.hasChosen, isFalse);
      expect(state(tester).play.out, isEmpty);
    });
  });

  group('the words under the yard', () {
    testWidgets('Show me points at the safe seat before the rhyme',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, Rings.at(1).safe);
      expect(state(tester).hints, 1);
      expect(find.textContaining('cannot find it'), findsOne);
    });

    testWidgets('and at the next landing once it runs', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 11);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.landsOn);
      expect(find.textContaining('lands next on'), findsOne);
    });

    testWidgets('Why turns the binary on a two-beat ring', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showSafe, isTrue);
      expect(find.textContaining('1101 turns to 1011'), findsOne);
      expect(find.textContaining('which is 11'), findsOne);
    });

    testWidgets('and climbs the reckoning on a long rhyme', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(find.textContaining('wearing new numbers'), findsOne);
      expect(find.textContaining('lands on seat 9'), findsOne);
    });

    testWidgets('ip dip carries the power-of-two note', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(find.textContaining('power of two'), findsOne);
    });
  });

  group('a dip ended', () {
    testWidgets('standing in the safe seat survives every ring',
        (tester) async {
      for (var number = 0; number < Rings.count; number++) {
        await open(tester, which: number);
        await stand(tester, Rings.at(number).safe);
        await countItOut(tester);
        expect(state(tester).play.won, isTrue,
            reason: Rings.at(number).name);
      }
    });

    testWidgets('the card says which seat it always was', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 11);
      await countItOut(tester);
      expect(find.textContaining('Seat 11 is the one'), findsOne);
      expect(find.text('last in'), findsOne);
    });

    testWidgets('standing wrong, the rhyme finds you and the card says '
        'where was safe', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 2);
      await press(tester, 'Count');
      expect(state(tester).play.isOver, isTrue);
      expect(find.textContaining('the 1st to go'), findsOne);
      expect(find.textContaining('The safe seat was 11'), findsOne);
    });

    testWidgets('tapping the yard mid-count chants too', (tester) async {
      await open(tester, which: 1);
      await stand(tester, 11);
      await stand(tester, 5);
      expect(state(tester).play.out, hasLength(1));
    });

    testWidgets('Next opens the ring after', (tester) async {
      await open(tester, which: 0);
      await stand(tester, 1);
      await countItOut(tester);
      expect(state(tester).play.won, isTrue);
      await press(tester, 'Next');
      expect(state(tester).play.ring.name, Rings.at(1).name);
    });
  });
}
