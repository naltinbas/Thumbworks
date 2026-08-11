import 'package:bridgeholm/walk/towns.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/walk.dart';

void main() {
  group('the screen', () {
    testWidgets('opens standing nowhere', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.started, isFalse);
      expect(find.text('tap a landing to stand there'), findsOne);
      expect(find.text('0 / 4'), findsOne);
    });

    testWidgets('a landing stands the walk there', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 2);
      expect(state(tester).play.standing, 2);
      expect(find.text('standing at South Bank'), findsOne);
    });

    testWidgets('a bridge before standing asks for a landing first',
        (tester) async {
      await open(tester, which: 0);
      await tapBridge(tester, 0);
      expect(state(tester).play.started, isFalse);
      expect(find.textContaining('Stand somewhere first'), findsOne);
    });

    testWidgets('a crossing moves the walk and counts', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 0);
      await tapBridge(tester, 0);
      expect(state(tester).play.standing, 1);
      expect(find.text('1 / 4'), findsOne);
    });

    testWidgets('a far bridge is refused by name', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 0);
      await tapBridge(tester, 1);
      expect(state(tester).play.crossed, 0);
      expect(find.textContaining('does not touch North Bank'), findsOne);
    });

    testWidgets('a walked bridge is refused with the rule', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 0);
      await tapBridge(tester, 0);
      await tapBridge(tester, 0);
      expect(state(tester).play.crossed, 1);
      expect(find.textContaining('already walked'), findsOne);
    });

    testWidgets('Back unwalks the last crossing', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 0);
      await tapBridge(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.crossed, 0);
      expect(state(tester).play.standing, 0);
    });

    testWidgets('Again clears the town', (tester) async {
      await open(tester, which: 0);
      await tapGround(tester, 0);
      await tapBridge(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.started, isFalse);
    });
  });

  group('the words under the map', () {
    testWidgets('a stranding walk is called out where it stands',
        (tester) async {
      await open(tester, which: 4);
      await tapGround(tester, 0);
      await tapBridge(tester, 0);
      await tapBridge(tester, 1);
      await tapBridge(tester, 2);
      expect(state(tester).play.stuck, isTrue);
      expect(find.textContaining('No unwalked bridge leaves The Green'),
          findsOne);
      expect(find.text('the walk is stranded'), findsOne);
    });

    testWidgets('Show me points at a start, then at a crossing',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointingGround, isNot(-1));
      expect(find.textContaining('complete walks leave'), findsOne);
      await tapGround(tester, state(tester).pointingGround);
      await press(tester, 'Show me');
      expect(state(tester).pointingBridge, isNot(-1));
      expect(state(tester).hints, 2);
      expect(find.textContaining('walked the rest'), findsOne);
    });

    testWidgets('Why tallies the landings and tells the ends',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showOdd, isTrue);
      expect(find.textContaining('one in and one out'), findsOne);
      expect(find.textContaining('Left Gate'), findsOne);
    });

    testWidgets('the seven bridges say so as they open, and Why counts '
        'the odd four', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('no walk crosses every bridge'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointingGround, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('4 odd landings'), findsOne);
      expect(find.textContaining('1736'), findsOne);
    });
  });

  group('a town walked', () {
    testWidgets('following the game walks every walkable town',
        (tester) async {
      for (var number = 0; number < Towns.count; number++) {
        final town = Towns.at(number);
        if (!town.walkable) continue;
        await open(tester, which: number);
        await walkItAll(tester);
        expect(state(tester).play.isDone, isTrue, reason: town.name);
      }
    });

    testWidgets('the round comes home to its own door', (tester) async {
      await open(tester, which: 0);
      await walkItAll(tester);
      expect(find.text('every bridge walked once'), findsOne);
      expect(find.textContaining('back to its own door'), findsOne);
    });

    testWidgets('the mended town ends at the odd pair', (tester) async {
      await open(tester, which: 3);
      await walkItAll(tester);
      expect(find.textContaining('the two odd landings'), findsOne);
    });

    testWidgets('Next opens the town after', (tester) async {
      await open(tester, which: 0);
      await walkItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.town.name, Towns.at(1).name);
    });
  });
}
