import 'package:flutter_test/flutter_test.dart';
import 'package:rindhope/cheese/blocks.dart';

import '../support/cheese.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the block whole', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.made, 0);
      expect(find.text('0 / 5'), findsOne);
      expect(find.text('10 crumbs standing'), findsOne);
    });

    testWidgets('a bite takes the crumb and the mouse answers',
        (tester) async {
      await open(tester, which: 0);
      final next = state(tester).play.next!;
      await bite(tester, next.$1, next.$2);
      expect(state(tester).play.made, 1);
      expect(state(tester).play.theirBite, isNotNull);
      expect(state(tester).play.winnable, isTrue);
    });

    testWidgets('biting the mould loses at once', (tester) async {
      await open(tester, which: 0);
      await bite(tester, 0, 0);
      expect(state(tester).play.isOver, isTrue);
      expect(state(tester).play.won, isFalse);
      expect(find.textContaining('The mould was yours'), findsOne);
    });

    testWidgets('Back returns the whole exchange', (tester) async {
      await open(tester, which: 0);
      final next = state(tester).play.next!;
      await bite(tester, next.$1, next.$2);
      await press(tester, 'Back');
      expect(state(tester).play.made, 0);
      expect(state(tester).play.heights, Blocks.at(0).whole);
    });

    testWidgets('Again starts the block over', (tester) async {
      await open(tester, which: 0);
      final next = state(tester).play.next!;
      await bite(tester, next.$1, next.$2);
      await press(tester, 'Again');
      expect(state(tester).play.made, 0);
    });
  });

  group('the words under the shelf', () {
    testWidgets('a wrong bite is called out the moment the mouse answers',
        (tester) async {
      await open(tester, which: 1);
      await bite(tester, 3, 3);
      expect(state(tester).play.winnable, isFalse);
      expect(find.textContaining('has the block now'), findsOne);
      expect(find.textContaining('Take the bite back'), findsOne);
    });

    testWidgets('Show me points at the winning bite', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, (1, 1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('cannot answer'), findsOne);
    });

    testWidgets('Why tells the stealing argument, and the block its shape',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showWhy, isTrue);
      expect(find.textContaining('bitten first'), findsOne);
      expect(find.textContaining('mirror across the diagonal'), findsOne);
    });

    testWidgets('the long block owns that only the search knows',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(find.textContaining('out of the search'), findsOne);
    });

    testWidgets('the second mouse block says what it is for', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('here to be felt'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
    });
  });

  group('a block settled', () {
    testWidgets('following the game wins every block that can be won, at '
        'par', (tester) async {
      for (var number = 0; number < Blocks.count; number++) {
        final block = Blocks.at(number);
        if (block.hopeless) continue;
        await open(tester, which: number);
        await winItAll(tester);
        expect(state(tester).play.won, isTrue, reason: block.name);
        expect(state(tester).play.made, block.fewest, reason: block.name);
      }
    });

    testWidgets('the card says no play forces it in fewer', (tester) async {
      await open(tester, which: 0);
      await winItAll(tester);
      expect(find.textContaining('no play here forces it in fewer'),
          findsOne);
    });

    testWidgets('Next opens the block after', (tester) async {
      await open(tester, which: 0);
      await winItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.block.name, Blocks.at(1).name);
    });
  });
}
