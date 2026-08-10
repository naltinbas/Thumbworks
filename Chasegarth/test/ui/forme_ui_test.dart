import 'package:flutter_test/flutter_test.dart';
import 'package:chasegarth/forme/chases.dart';

import '../support/forme.dart';

void main() {
  testWidgets('a forme opens as it was handed over', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.made, 0);
    expect(play.stands, Formes.at(1).start);
    expect(find.text(Formes.at(1).name), findsOneWidget);
    expect(find.textContaining('reads "'), findsOneWidget);
  });

  testWidgets('tapping a letter beside the empty cell slides it in',
      (tester) async {
    await open(tester, which: 1);
    final cell = state(tester).play.canSlide.first;
    await slide(tester, cell);

    expect(state(tester).play.made, 1);
    expect(state(tester).play.sortIn(cell), -1);
  });

  testWidgets('tapping one away from it says so', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;
    final away = [
      for (var cell = 0; cell < play.chase.cells; cell++)
        if (!play.canSlide.contains(cell) && play.sortIn(cell) >= 0) cell,
    ].first;
    await slide(tester, away);

    expect(state(tester).play.made, 0);
    expect(find.textContaining('beside the empty cell'), findsOneWidget);
  });

  testWidgets('a wrong slide is called out at once', (tester) async {
    await open(tester, which: 1);
    final good = state(tester).play.next!;
    final bad =
        state(tester).play.canSlide.firstWhere((cell) => cell != good);
    await slide(tester, bad);

    expect(find.textContaining('more than the'), findsOneWidget);
  });

  testWidgets('Again puts the type back', (tester) async {
    await open(tester, which: 1);
    await slide(tester, state(tester).play.canSlide.first);
    await press(tester, 'Again');
    expect(state(tester).play.made, 0);
    expect(state(tester).play.stands, Formes.at(1).start);
  });

  testWidgets('Show me points at a letter and says how many are left',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(find.textContaining('more after that'), findsOneWidget);

    await slide(tester, screen.pointing);
    expect(state(tester).play.couldFinishIn, Formes.at(1).fewest);
  });

  testWidgets('Why counts the pairs out of order', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(find.textContaining('pairs of letters are out of'), findsOneWidget);
    expect(find.textContaining('can still be slid right'), findsOneWidget);
  });

  testWidgets('the dropped forme says it cannot be done, and why',
      (tester) async {
    final dropped = Formes.all.indexWhere((forme) => forme.dropped);
    await open(tester, which: dropped);

    expect(find.textContaining('cannot be made to read right'), findsOneWidget);
    expect(state(tester).play.canBeLocked, isFalse);

    await press(tester, 'Why');
    expect(find.textContaining('There is no way'), findsOneWidget);
  });

  testWidgets('and swapping the pair back mends it', (tester) async {
    final dropped = Formes.all.indexWhere((forme) => forme.dropped);
    await open(tester, which: dropped);
    await press(tester, 'Swap them');

    expect(state(tester).play.canBeLocked, isTrue);
    expect(state(tester).play.mended, isTrue);
    expect(find.textContaining('right way round again'), findsOneWidget);

    await lockItAll(tester);
    expect(state(tester).play.made, Formes.at(dropped).fewest);
  });

  testWidgets('every forme that can be locked can be locked in the fewest '
      'through the screen', (tester) async {
    // The proof that the game is playable: every forme slid by tapping type,
    // in as few slides as there are from where it starts.
    for (var which = 0; which < Formes.count; which++) {
      final forme = Formes.at(which);
      if (forme.dropped) continue;
      await open(tester, which: which);
      await lockItAll(tester);

      final play = state(tester).play;
      expect(play.isLocked, isTrue, reason: forme.name);
      expect(play.made, forme.fewest, reason: forme.name);
      expect(play.isFewest, isTrue, reason: forme.name);
      expect(find.bySemanticsLabel('the forme is locked'), findsOneWidget,
          reason: forme.name);
    }
  });
}
