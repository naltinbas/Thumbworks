import 'package:flutter_test/flutter_test.dart';
import 'package:staplemere/yard/deals.dart';

import '../support/yard.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the cart full and the yard empty', (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.standing, 0);
      expect(find.text('0 / 3'), findsOne);
      expect(find.text('9 of 9 bales still on the cart'), findsOne);
    });

    testWidgets('tapping the ground starts a pile', (tester) async {
      await open(tester, which: 2);
      await put(tester, 0);
      expect(state(tester).play.standing, 1);
      expect(find.text('1 / 3'), findsOne);
    });

    testWidgets('a bale may not rest on a lighter one, and the words say why',
        (tester) async {
      await open(tester, which: 0);
      await put(tester, 0);
      await put(tester, 0);
      // The 38 cannot rest on the 22.
      await put(tester, 0);
      expect(state(tester).play.placed, 2);
      expect(find.textContaining('cannot rest on'), findsOne);
      expect(find.textContaining('wool crushes'), findsOne);
    });

    testWidgets('Back puts the bale back on the cart', (tester) async {
      await open(tester, which: 2);
      await put(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.placed, 0);
      expect(state(tester).play.standing, 0);
    });

    testWidgets('Again clears the yard', (tester) async {
      await open(tester, which: 2);
      await put(tester, 0);
      await press(tester, 'Again');
      expect(state(tester).play.standing, 0);
    });
  });

  group('the words under the yard', () {
    testWidgets('a costly placement is called out the moment it costs',
        (tester) async {
      await open(tester, which: 1);
      final walk = costing(state(tester).play);
      expect(walk, isNotNull, reason: 'no placement on this deal ever costs');
      for (final slot in walk!) {
        await put(tester, slot);
      }
      expect(state(tester).saying, contains('more than'));
      expect(find.textContaining('more than'), findsOne);
    });

    testWidgets('Show me points at the snug fit and says why it is right',
        (tester) async {
      await open(tester, which: 1);
      // The 7 and the 37 each start a pile; the 26 has a top to choose.
      await put(tester, 0);
      await put(tester, 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('snuggest top'), findsOne);

      // And the place it points at really does keep the morning at par.
      final play = state(tester).play;
      expect(play.put(state(tester).pointing).couldStillBe, play.deal.fewest);
    });

    testWidgets('and points at the ground when nothing can take the bale',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, state(tester).play.standing);
      expect(find.textContaining('On the ground'), findsOne);
    });

    testWidgets('Why draws the thread and counts it', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(state(tester).showThread, isTrue);
      expect(find.textContaining('marked bales'), findsOne);
      expect(find.textContaining('3 piles at least'), findsOne);
    });

    testWidgets('and the nine tods carry their boundary note', (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Why');
      expect(find.textContaining('Ten always break'), findsOne);
    });
  });

  group('a morning done', () {
    testWidgets('following the game ends every deal on its fewest',
        (tester) async {
      for (var number = 0; number < Deals.count; number++) {
        await open(tester, which: number);
        await pileItAll(tester);
        final play = state(tester).play;
        expect(play.isDone, isTrue, reason: Deals.at(number).name);
        expect(play.standing, Deals.at(number).fewest,
            reason: Deals.at(number).name);
      }
    });

    testWidgets('the card says fewer cannot take it', (tester) async {
      await open(tester, which: 0);
      await pileItAll(tester);
      expect(find.textContaining('fewer cannot take'), findsOne);
      expect(find.text('every bale down'), findsOne);
    });

    testWidgets('a morning gone over says what it can be done in',
        (tester) async {
      await open(tester, which: 0);
      // Every bale on the ground: five piles for a two-pile morning.
      for (var bale = 0; bale < Deals.at(0).many; bale++) {
        await put(tester, state(tester).play.standing);
      }
      expect(state(tester).play.isDone, isTrue);
      expect(find.textContaining('It can be done in 2'), findsOne);
    });

    testWidgets('Next opens the deal after', (tester) async {
      await open(tester, which: 0);
      await pileItAll(tester);
      await press(tester, 'Next');
      expect(state(tester).play.deal.name, Deals.at(1).name);
    });
  });
}
