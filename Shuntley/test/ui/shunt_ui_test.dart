import 'package:flutter_test/flutter_test.dart';
import 'package:shuntley/shunt/trays.dart';

import '../support/shunt.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the tray as it is dealt', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.board, [2, 3, 5, 1, 4, 0]);
      expect(find.text('5 tiles out of place'), findsOne);
      expect(find.text('0 shunted'), findsOne);
    });

    testWidgets('a tile beside the gap shunts in and counts',
        (tester) async {
      await open(tester, which: 0);
      await slide(tester, 2);
      expect(state(tester).play.board, [2, 3, 0, 1, 4, 5]);
      expect(find.text('1 shunted'), findsOne);
    });

    testWidgets('a far tile is refused with the rule', (tester) async {
      await open(tester, which: 0);
      await slide(tester, 0);
      expect(state(tester).play.board, [2, 3, 5, 1, 4, 0]);
      expect(find.textContaining('beside the gap'), findsOne);
    });

    testWidgets('Back takes the last shunt off', (tester) async {
      await open(tester, which: 0);
      await slide(tester, 2);
      await press(tester, 'Back');
      expect(state(tester).play.board, [2, 3, 5, 1, 4, 0]);
      expect(find.text('0 shunted'), findsOne);
    });

    testWidgets('Again lays the tray over', (tester) async {
      await open(tester, which: 0);
      await slide(tester, 2);
      await slide(tester, 1);
      await press(tester, 'Again');
      expect(state(tester).play.board, [2, 3, 5, 1, 4, 0]);
      expect(state(tester).play.shunts, 0);
    });
  });

  group('the words under the tray', () {
    testWidgets('a wandering shunt is called out with the live number',
        (tester) async {
      await open(tester, which: 1);
      // The dealt gap sits last; shunting the tile above it wanders.
      await slide(tester, 5);
      expect(find.textContaining('wandered'), findsOne);
      expect(find.textContaining('rose to 11'), findsOne);
    });

    testWidgets('Show me points at a shunt the walk has measured',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.next);
      expect(state(tester).hints, 1);
      expect(find.textContaining('shortest way'), findsOne);
    });

    testWidgets('Why speaks the walk\'s count on a winnable tray',
        (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(find.textContaining('181,440'), findsOne);
      expect(find.textContaining('thirty one shunts from home'), findsOne);
    });

    testWidgets('the swindle says so as it opens, and Why rims the pair',
        (tester) async {
      await open(tester, which: 5);
      expect(find.textContaining('never comes home, and the label'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(state(tester).swindled, isTrue);
      expect(find.textContaining('odd count'), findsOne);
      expect(find.textContaining('thousand dollars'), findsOne);
    });
  });

  group('a tray brought home', () {
    testWidgets('following the game brings every winnable tray home',
        (tester) async {
      for (var number = 0; number < Trays.count; number++) {
        final tray = Trays.at(number);
        if (!tray.winnable) continue;
        await open(tester, which: number);
        await shuntItHome(tester);
        expect(state(tester).play.isHome, isTrue, reason: tray.name);
        expect(state(tester).play.shunts, tray.fewest, reason: tray.name);
      }
    });

    testWidgets('the card owns the fewest when it is beaten',
        (tester) async {
      await open(tester, which: 0);
      // Two wasted shunts, there and straight back, before following
      // the game home.
      await slide(tester, 2);
      await slide(tester, 5);
      await shuntItHome(tester);
      expect(find.text('every tile home'), findsOne);
      expect(find.textContaining('The fewest is 6'), findsOne);
    });

    testWidgets('the card at the fewest credits the walk', (tester) async {
      await open(tester, which: 0);
      await shuntItHome(tester);
      expect(find.textContaining('none of them was wasted'), findsOne);
    });

    testWidgets('Next opens the tray after', (tester) async {
      await open(tester, which: 0);
      await shuntItHome(tester);
      await press(tester, 'Next');
      expect(state(tester).play.tray.name, Trays.at(1).name);
    });
  });
}
