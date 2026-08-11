import 'package:flutter_test/flutter_test.dart';

import '../support/cloth.dart';

void main() {
  group('the screen', () {
    testWidgets('opens as the mercer left it', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.long, 25);
      expect(find.text('25 : 7'), findsOne);
      expect(find.text('the short bolt fits 3 times'), findsOne);
    });

    testWidgets('taps mark lengths and wrap past the quotient',
        (tester) async {
      await open(tester, which: 0);
      await markOne(tester);
      await markOne(tester);
      expect(state(tester).pending, 2);
      expect(find.text('cutting 2 of up to 3'), findsOne);
      await markOne(tester);
      await markOne(tester);
      expect(state(tester).pending, 1);
    });

    testWidgets('Cut commits and the mercer answers', (tester) async {
      await open(tester, which: 0);
      await cut(tester, 2);
      expect(state(tester).play.made, 1);
      expect(find.textContaining('The mercer cuts'), findsOne);
    });

    testWidgets('Back returns the whole exchange', (tester) async {
      await open(tester, which: 0);
      await cut(tester, 2);
      await press(tester, 'Back');
      expect(state(tester).play.long, 25);
    });

    testWidgets('Again starts the bench over', (tester) async {
      await open(tester, which: 0);
      await cut(tester, 2);
      await press(tester, 'Again');
      expect(state(tester).play.long, 25);
      expect(state(tester).pending, 0);
    });
  });

  group('the words under the bench', () {
    testWidgets('a wrong cut is called out the moment it is answered',
        (tester) async {
      await open(tester, which: 0);
      await cut(tester, 1);
      expect(state(tester).play.winnable, isFalse);
      expect(find.textContaining('The bench is the mercer\'s now'),
          findsOne);
    });

    testWidgets('Show me marks the winning cut', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pending, 2);
      expect(find.textContaining('inside the gap'), findsOne);
    });

    testWidgets('Why does the whole-number arithmetic for the bench',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(state(tester).showGap, isTrue);
      expect(find.textContaining('1156'), findsOne);
      expect(find.textContaining('1155'), findsOne);
    });

    testWidgets('the golden bench owns its lostness', (tester) async {
      await open(tester, which: 3);
      expect(find.textContaining('mercer holds it before a cut'),
          findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('3025'), findsOne);
      expect(find.textContaining('falls short'), findsOne);
    });
  });

  group('a bench settled', () {
    testWidgets('following the gap holds every winnable bench',
        (tester) async {
      for (final number in const [0, 1, 2, 4]) {
        await open(tester, which: number);
        await holdItAll(tester);
        expect(state(tester).play.won, isTrue, reason: 'bench $number');
        expect(find.textContaining('The last cut was yours'), findsOne);
      }
    });

    testWidgets('Next opens the bench after', (tester) async {
      await open(tester, which: 0);
      await holdItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.bench.name, 'The Long Bolt');
    });
  });
}
