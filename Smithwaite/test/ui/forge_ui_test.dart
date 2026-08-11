import 'package:flutter_test/flutter_test.dart';
import 'package:smithwaite/forge/puzzles.dart';

import '../support/forge.dart';

void main() {
  group('the screen', () {
    testWidgets('opens as the smith hands it over', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.made, 0);
      expect(find.text('0 / 5'), findsOne);
      expect(find.text('3 rings on the bar'), findsOne);
    });

    testWidgets('tapping a bright ring works it', (tester) async {
      await open(tester, which: 0);
      await move(tester, 0);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.isOn(0), isFalse);
    });

    testWidgets('a ring the cords hold is refused with the reason',
        (tester) async {
      await open(tester, which: 0);
      await move(tester, 2);
      expect(state(tester).play.made, 0);
      expect(find.textContaining('The cords hold'), findsOne);
    });

    testWidgets('Back returns the rings as they lay', (tester) async {
      await open(tester, which: 0);
      await move(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
      expect(state(tester).play.state, Puzzles.at(0).start);
    });

    testWidgets('Again starts the puzzle over', (tester) async {
      await open(tester, which: 0);
      await move(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the bench', () {
    testWidgets('the backwards move is called out the moment it costs',
        (tester) async {
      await open(tester, which: 2);
      await move(tester, state(tester).play.next!);
      await move(tester, state(tester).play.next!);
      // Of the two legal moves, take the one the game did not point at.
      final play = state(tester).play;
      final wrong = [
        for (var ring = 0; ring < play.puzzle.rings; ring++)
          if (play.mayMove(ring) && ring != play.next) ring,
      ].single;
      await move(tester, wrong);
      expect(find.textContaining('goes backwards'), findsOne);
      expect(find.textContaining('2 more than'), findsOne);
    });

    testWidgets('Show me points at the one move that goes forward',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(state(tester).hints, 1);
      expect(find.textContaining('goes forward'), findsOne);
    });

    testWidgets('Why writes the figures and reads the count', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(state(tester).showCount, isTrue);
      expect(find.textContaining('binary number: 5'), findsOne);
      expect(find.textContaining('flip at every ring that is on'), findsOne);
    });

    testWidgets('and the tangle carries its own sentence', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(find.textContaining('farthest state five rings have'), findsOne);
    });
  });

  group('a bar freed', () {
    testWidgets('following the game frees every puzzle at its fewest',
        (tester) async {
      for (var number = 0; number < Puzzles.count; number++) {
        await open(tester, which: number);
        await freeItAll(tester);
        final play = state(tester).play;
        expect(play.isFree, isTrue, reason: Puzzles.at(number).name);
        expect(play.made, Puzzles.at(number).fewest,
            reason: Puzzles.at(number).name);
      }
    });

    testWidgets('the card says fewer cannot do it', (tester) async {
      await open(tester, which: 0);
      await freeItAll(tester);
      expect(find.textContaining('fewer cannot do it'), findsOne);
      expect(find.text('the bar is free'), findsOne);
    });

    testWidgets('a bar freed over the fewest says what it can be done on',
        (tester) async {
      await open(tester, which: 0);
      // One step forward, one back, then the whole way: two moves wasted.
      final forward = state(tester).play.next!;
      await move(tester, forward);
      await move(tester, forward);
      await freeItAll(tester);
      expect(find.textContaining('It can be done on 5'), findsOne);
    });

    testWidgets('Next opens the puzzle after', (tester) async {
      await open(tester, which: 0);
      await freeItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.puzzle.name, Puzzles.at(1).name);
    });
  });
}
