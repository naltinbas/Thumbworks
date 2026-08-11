import 'package:flutter_test/flutter_test.dart';
import 'package:foldbury/fold/folds.dart';

import '../support/fold.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with every lane dark and nobody posted', (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.standing, 0);
      expect(find.text('0 / 3'), findsOne);
      expect(find.text('9 of 9 lanes dark'), findsOne);
    });

    testWidgets('tapping a gate posts a shepherd there', (tester) async {
      await open(tester, which: 2);
      await post(tester, 1);
      expect(state(tester).play.standing, 1);
      expect(find.text('1 / 3'), findsOne);
    });

    testWidgets('tapping it again stands the shepherd down', (tester) async {
      await open(tester, which: 2);
      await post(tester, 1);
      await post(tester, 1);
      expect(state(tester).play.standing, 0);
    });

    testWidgets('Again clears the fold', (tester) async {
      await open(tester, which: 2);
      await post(tester, 1);
      await press(tester, 'Again');
      expect(state(tester).play.standing, 0);
    });
  });

  group('the words under the fold', () {
    testWidgets('a costly post is called out the moment it costs',
        (tester) async {
      await open(tester, which: 2);
      final walk = costing(state(tester).play);
      expect(walk, isNotNull, reason: 'no post on this fold ever costs');
      for (final gate in walk!) {
        await post(tester, gate);
      }
      expect(state(tester).saying, contains('more than'));
      expect(find.textContaining('more than'), findsOne);
    });

    testWidgets('Show me points at a gate that keeps the fewest',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Show me');
      final pointed = state(tester).pointing;
      expect(pointed, isNot(-1));
      expect(state(tester).hints, 1);
      expect(
        find.textContaining(Folds.at(2).gates[pointed].name),
        findsWidgets,
      );

      // And the gate it points at really does keep the night at par.
      final play = state(tester).play;
      expect(play.touch(pointed).couldStillBe, play.fold.fewest);
    });

    testWidgets('Why draws the matching where it carries the number',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(state(tester).showMatching, isTrue);
      expect(find.textContaining('keep apart'), findsOne);
      expect(find.textContaining('3 is the fewest'), findsOne);
    });

    testWidgets('and counts lanes on the ring where it cannot',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showMatching, isFalse);
      expect(find.textContaining('pairing proves nothing'), findsOne);
      expect(find.textContaining('2 is the fewest'), findsOne);
    });
  });

  group('a night watched', () {
    testWidgets('following the game watches every fold on its fewest',
        (tester) async {
      for (var number = 0; number < Folds.count; number++) {
        await open(tester, which: number);
        await watchItAll(tester);
        final play = state(tester).play;
        expect(play.isDone, isTrue, reason: Folds.at(number).name);
        expect(play.standing, Folds.at(number).fewest,
            reason: Folds.at(number).name);
        expect(play.isFewest, isTrue, reason: Folds.at(number).name);
      }
    });

    testWidgets('the card says fewer cannot do it', (tester) async {
      await open(tester, which: 0);
      await watchItAll(tester);
      expect(find.textContaining('fewer cannot do it'), findsOne);
      expect(find.text('no lane is dark'), findsOne);
    });

    testWidgets('a night watched over the fewest says what it can be done on',
        (tester) async {
      await open(tester, which: 0);
      // Post every gate of the drove road: watched on five, not two.
      for (var gate = 0; gate < Folds.at(0).count; gate++) {
        await post(tester, gate);
      }
      expect(state(tester).play.isDone, isTrue);
      expect(find.textContaining('It can be done on 2'), findsOne);
    });

    testWidgets('Next opens the fold after', (tester) async {
      await open(tester, which: 0);
      await watchItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.fold.name, Folds.at(1).name);
    });

    testWidgets('Again after a watched night starts it over', (tester) async {
      await open(tester, which: 0);
      await watchItAll(tester);
      await press(tester, 'Again');
      expect(state(tester).play.standing, 0);
      expect(state(tester).play.isDone, isFalse);
    });
  });
}
