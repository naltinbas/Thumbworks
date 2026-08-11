import 'package:flutter_test/flutter_test.dart';
import 'package:lockhithe/quay/stow.dart';

import '../support/quay.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with every door shut', (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      expect(state(tester).play.opened, isEmpty);
      expect(find.text('0 / 4'), findsOne);
      expect(find.text('you are sailor 1: find your chit'), findsOne);
    });

    testWidgets('a look opens the door and reads the chit', (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      await look(tester, 0);
      expect(state(tester).play.opened, [0]);
      expect(find.textContaining('Sailor 5\'s chit'), findsOne);
    });

    testWidgets('Again deals the round fresh', (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      await look(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.opened, isEmpty);
    });
  });

  group('the words under the store', () {
    testWidgets('Show me starts at your own locker and stays on the loop',
        (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 0);
      expect(find.textContaining('Your own locker first'), findsOne);
      await look(tester, 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 4);
      expect(find.textContaining('Stay on the loop'), findsOne);
    });

    testWidgets('Why ropes the loops and reads their lengths',
        (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      await press(tester, 'Why');
      expect(state(tester).showLoops, isTrue);
      expect(find.textContaining('run 3, 3, 2'), findsOne);
      expect(find.textContaining('safe before anyone opens'), findsOne);
    });

    testWidgets('and reads a cruel stow the other way', (tester) async {
      await open(tester, which: 2, dealt: cruelStow);
      await press(tester, 'Why');
      expect(find.textContaining('sunk before anyone opened'), findsOne);
    });
  });

  group('a round settled', () {
    testWidgets('following the chits brings a kind stow through',
        (tester) async {
      await open(tester, which: 2, dealt: kindStow);
      await followItOut(tester);
      final play = state(tester).play;
      expect(play.found, isTrue);
      expect(play.through, isTrue);
      expect(find.text('the crew is through'), findsOne);
      expect(find.textContaining('307 in 840'), findsOne);
    });

    testWidgets('a cruel stow sinks the crew and the card owns it',
        (tester) async {
      await open(tester, which: 2, dealt: cruelStow);
      await followItOut(tester);
      expect(state(tester).play.found, isFalse);
      expect(find.text('the crew is sunk'), findsOne);
      expect(find.textContaining('fails only when it must'), findsOne);
    });

    testWidgets('wandering can leave the crew sunk by somebody else',
        (tester) async {
      // Open lockers off your loop: you fail; sunkBy is you.
      await open(tester, which: 2, dealt: kindStow);
      await look(tester, 1);
      await look(tester, 3);
      await look(tester, 5);
      await look(tester, 6);
      expect(state(tester).play.isOver, isTrue);
      expect(state(tester).play.found, isFalse);
    });

    testWidgets('Next opens the berth after', (tester) async {
      await open(tester, which: 0, dealt: const Stow([1, 0, 3, 2]));
      await followItOut(tester);
      expect(state(tester).play.through, isTrue);
      await press(tester, 'Next');
      expect(state(tester).play.berth.name, 'The Six Lockers');
    });
  });
}
