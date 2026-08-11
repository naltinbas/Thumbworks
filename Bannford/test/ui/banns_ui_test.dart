import 'package:bannford/banns/parties.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/banns.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with everyone single', (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.unwedded, 4);
      expect(find.text('4 still to wed'), findsOne);
      expect(find.text('0 banns'), findsOne);
    });

    testWidgets('two taps wed a couple', (tester) async {
      await open(tester, which: 2);
      await wed(tester, 0, 1);
      expect(state(tester).play.wedded, [1, 0, null, null]);
      expect(find.text('1 banns'), findsOne);
    });

    testWidgets('arming and disarming weds nobody', (tester) async {
      await open(tester, which: 2);
      await tapChip(tester, 0);
      expect(state(tester).armed, 0);
      await tapChip(tester, 0);
      expect(state(tester).armed, -1);
      expect(state(tester).play.weddings, 0);
    });

    testWidgets('tapping a standing couple parts it', (tester) async {
      await open(tester, which: 2);
      await wed(tester, 0, 1);
      await wed(tester, 0, 1);
      expect(state(tester).play.wedded, [null, null, null, null]);
    });

    testWidgets('Back returns the party as it stood', (tester) async {
      await open(tester, which: 2);
      await wed(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.wedded, [null, null, null, null]);
    });

    testWidgets('Again clears the hall', (tester) async {
      await open(tester, which: 2);
      await wed(tester, 0, 1);
      await wed(tester, 2, 3);
      await press(tester, 'Again');
      expect(state(tester).play.weddings, 0);
    });
  });

  group('the words under the hall', () {
    testWidgets('a wedding that leaves a red cord is called out',
        (tester) async {
      await open(tester, which: 2);
      // Ada with Cy and Bea with Dot: Ada and Bea both want each
      // other more.
      await wed(tester, 0, 2);
      await wed(tester, 1, 3);
      expect(state(tester).play.eloping, isNotEmpty);
      expect(find.textContaining('would both rather have each other'),
          findsOne);
      expect(find.textContaining('would elope'), findsOne);
    });

    testWidgets('Show me points at a couple from a settled pairing',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('judged settled'), findsOne);
    });

    testWidgets('Why counts the pairings and the settled ones',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(find.textContaining('105 pairings'), findsOne);
      expect(find.textContaining('4 settle'), findsOne);
      expect(find.textContaining('asking-round'), findsOne);
    });

    testWidgets('the odd house says so as it opens, and Why walks it',
        (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No pairing of this house settles'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('each breaks'), findsOne);
      expect(find.textContaining('nobody wants Dot'), findsOne);
    });

    testWidgets('the odd house breaks however it is wed', (tester) async {
      await open(tester, which: 4);
      await wed(tester, 0, 1);
      await wed(tester, 2, 3);
      expect(state(tester).play.unwedded, 0);
      expect(state(tester).play.isSettled, isFalse);
      expect(state(tester).play.eloping, isNotEmpty);
      expect(find.text('1 pair would elope'), findsOne);
    });
  });

  group('a party settled', () {
    testWidgets('following the game settles every winnable party',
        (tester) async {
      for (var number = 0; number < Parties.count; number++) {
        final party = Parties.at(number);
        if (!party.winnable) continue;
        await open(tester, which: number);
        await settleItAll(tester);
        expect(state(tester).play.isSettled, isTrue, reason: party.name);
      }
    });

    testWidgets('settling by hand needs no asking at all', (tester) async {
      await open(tester, which: 2);
      await wed(tester, 0, 1);
      await wed(tester, 2, 3);
      expect(state(tester).play.isSettled, isTrue);
      expect(find.text('all wed, and nobody would leave'), findsOne);
      expect(find.textContaining('asked for nothing'), findsOne);
    });

    testWidgets('the card owns when other pairings settle too',
        (tester) async {
      await open(tester, which: 1);
      await settleItAll(tester);
      expect(find.textContaining('one of 4 that settle'), findsOne);
    });

    testWidgets('Next opens the party after', (tester) async {
      await open(tester, which: 0);
      await settleItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.party.name, Parties.at(1).name);
    });
  });
}
