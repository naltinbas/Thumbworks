import 'package:flutter_test/flutter_test.dart';

import '../support/hoard.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the hoard whole', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.nuts, 20);
      expect(find.text('20'), findsOne);
      expect(find.text('20 nuts, take up to 19'), findsOne);
    });

    testWidgets('taps mark nuts and the ledger counts them', (tester) async {
      await open(tester, which: 0);
      await mark(tester);
      await mark(tester);
      expect(state(tester).pending, 2);
      expect(find.text('taking 2 of up to 19'), findsOne);
    });

    testWidgets('Take commits and the grey squirrel answers',
        (tester) async {
      await open(tester, which: 0);
      await take(tester, 2);
      expect(state(tester).play.made, 1);
      expect(find.textContaining('The grey squirrel takes'), findsOne);
    });

    testWidgets('Back returns the whole exchange', (tester) async {
      await open(tester, which: 0);
      await take(tester, 2);
      await press(tester, 'Back');
      expect(state(tester).play.nuts, 20);
    });

    testWidgets('Again starts the hoard over', (tester) async {
      await open(tester, which: 0);
      await take(tester, 2);
      await press(tester, 'Again');
      expect(state(tester).play.nuts, 20);
      expect(state(tester).pending, 0);
    });
  });

  group('the words under the pile', () {
    testWidgets('a wrong take is called out the moment it is answered',
        (tester) async {
      await open(tester, which: 0);
      await take(tester, 5);
      expect(state(tester).play.winnable, isFalse);
      expect(find.textContaining('handed the split over'), findsOne);
    });

    testWidgets('Show me marks the smallest cluster', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pending, 2);
      expect(find.textContaining('smallest cluster of the split'),
          findsOne);
    });

    testWidgets('Why rings the clusters and reads the verdict',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why');
      expect(state(tester).showClusters, isTrue);
      expect(find.textContaining('13 and 5 and 2'), findsOne);
      expect(find.textContaining('take exactly that'), findsWidgets);
    });

    testWidgets('the fibonacci hoard owns its lostness', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('lost before the first nut'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('out of reach'), findsOne);
    });
  });

  group('a hoard settled', () {
    testWidgets('following the split wins every winnable hoard',
        (tester) async {
      for (final number in const [0, 1, 3, 4]) {
        await open(tester, which: number);
        await winItAll(tester);
        expect(state(tester).play.won, isTrue, reason: 'hoard $number');
        expect(find.textContaining('The last nut is yours'), findsOne);
      }
    });

    testWidgets('Next opens the hoard after', (tester) async {
      await open(tester, which: 0);
      await winItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.hoard.name, 'The Thirty');
    });
  });
}
