import 'package:flutter_test/flutter_test.dart';
import 'package:tilthway/tilth/tilths.dart';

import '../support/tilth.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the board as the level lays it', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.board, [1, 1, 3]);
      expect(find.text('0 / 5'), findsOne);
      expect(find.text('a furrow sows holding exactly its number'), findsOne);
    });

    testWidgets('sowing a full furrow moves its seeds along', (tester) async {
      await open(tester, which: 0);
      await sow(tester, 1);
      expect(state(tester).play.board, [0, 1, 3]);
      expect(find.text('1 / 5'), findsOne);
    });

    testWidgets('a furrow not holding its number is refused with the rule', (
      tester,
    ) async {
      await open(tester, which: 0);
      await sow(tester, 2);
      expect(state(tester).play.board, [1, 1, 3]);
      expect(
        find.textContaining('may be sown only holding exactly 2'),
        findsOne,
      );
    });

    testWidgets('Back unsows the last furrow', (tester) async {
      await open(tester, which: 0);
      await sow(tester, 1);
      await press(tester, 'Back');
      expect(state(tester).play.board, [1, 1, 3]);
    });

    testWidgets('Again lays the board over', (tester) async {
      await open(tester, which: 0);
      await sow(tester, 1);
      await sow(tester, 2);
      await press(tester, 'Again');
      expect(state(tester).play.board, [1, 1, 3]);
      expect(state(tester).play.barned, 0);
    });
  });

  group('the words under the strip', () {
    testWidgets('a sowing that overfills a furrow is called out at once', (
      tester,
    ) async {
      await open(tester, which: 0);
      // Sowing furrow three of [1,1,3] drops the board to [2,2]: furrow
      // one holds two, more than its number, and can never empty.
      await sow(tester, 3);
      expect(state(tester).play.trapped, [1]);
      expect(find.textContaining('can never leave'), findsOne);
      expect(find.text('seeds are trapped'), findsOne);
    });

    testWidgets('Show me points at the sowing the search has checked', (
      tester,
    ) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      // The search names furrow one: sowing three first drops the board
      // to the dead pair, and the hint has checked that.
      expect(state(tester).pointing, 1);
      expect(state(tester).hints, 1);
      expect(find.textContaining('the way home stays open'), findsOne);
    });

    testWidgets('Why rims the sowable furrows and tells the uniqueness', (
      tester,
    ) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showSowable, isTrue);
      expect(find.textContaining('exactly one'), findsOne);
      expect(find.textContaining('unsowing'), findsOne);
    });

    testWidgets('the dead board says so as it opens', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('dead where it lies'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('holding more than its number'),
          findsOne);
    });
  });

  group('seeds brought home', () {
    testWidgets('following the game sows every live tilth home', (
      tester,
    ) async {
      for (var number = 0; number < Tilths.count; number++) {
        final tilth = Tilths.at(number);
        if (!tilth.winnable) continue;
        await open(tester, which: number);
        await sowItAllHome(tester);
        expect(state(tester).play.isHome, isTrue, reason: tilth.name);
      }
    });

    testWidgets('the card says the board was the only one', (tester) async {
      await open(tester, which: 0);
      await sowItAllHome(tester);
      expect(find.text('every seed is home'), findsOne);
      expect(find.textContaining('the only one that could do it'), findsOne);
    });

    testWidgets('Next opens the tilth after', (tester) async {
      await open(tester, which: 0);
      await sowItAllHome(tester);
      await press(tester, 'Next');
      expect(state(tester).play.tilth.name, Tilths.at(1).name);
    });
  });
}
