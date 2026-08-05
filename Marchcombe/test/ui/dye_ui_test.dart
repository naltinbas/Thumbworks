import 'package:flutter_test/flutter_test.dart';
import 'package:marchcombe/dye/lands.dart';

import '../support/dye.dart';

void main() {
  testWidgets('a map opens with every field bare', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.done, 0);
    expect(play.isDone, isFalse);
    expect(find.text(Estates.at(2).name), findsOneWidget);
    expect(find.textContaining('0 of 8 fields painted'), findsOneWidget);
  });

  testWidgets('tapping a field puts the picked dye on it', (tester) async {
    await open(tester, which: 2);
    await paint(tester, 0, 1);

    expect(state(tester).play.dyeOf(0), 1);
    expect(state(tester).play.done, 1);
  });

  testWidgets('and tapping it again in the same dye rubs it out',
      (tester) async {
    await open(tester, which: 2);
    await paint(tester, 0, 1);
    await put(tester, 0);
    expect(state(tester).play.dyeOf(0), -1);
  });

  testWidgets('two fields sharing a hedge in one dye is named as a clash',
      (tester) async {
    await open(tester, which: 1);
    final land = Estates.at(1).land;
    final (one, other) = land.hedges.first;
    await paint(tester, one, 0);
    await put(tester, other);

    expect(state(tester).play.clashes, hasLength(1));
    expect(find.textContaining('share a hedge and are both red'),
        findsOneWidget);
    expect(find.textContaining('the same dye on both sides'), findsOneWidget);
  });

  testWidgets('it says when the fewest dyes has been thrown away',
      (tester) async {
    // The spare pot is one more dye than the map can possibly need, so using
    // it at all throws the fewest away.
    await open(tester, which: 1);
    await paint(tester, 0, Estates.at(1).fewest);

    expect(state(tester).play.canStillDoIt, isFalse);
    expect(find.textContaining('cannot be finished on 3 now'), findsOneWidget);
  });

  testWidgets('Again wipes the map', (tester) async {
    await open(tester, which: 2);
    await paint(tester, 0, 0);
    await paint(tester, 1, 1);
    await press(tester, 'Again');

    expect(state(tester).play.done, 0);
  });

  testWidgets('Show me names a field and a dye, and picks the dye up',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(screen.dye, isNonNegative);
    expect(find.textContaining(', in '), findsOneWidget);

    await put(tester, screen.pointing);
    expect(state(tester).play.canStillDoIt, isTrue);
  });

  testWidgets('Why marks the fields that all share a hedge with each other',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');

    expect(state(tester).showRing, isTrue);
    expect(find.textContaining('all share a hedge with each other'),
        findsOneWidget);
    expect(find.textContaining('That is 3 dyes before anything else'),
        findsOneWidget);
  });

  testWidgets('every estate can be painted on the fewest through the screen',
      (tester) async {
    // The proof that the game is playable: every map painted by tapping
    // fields, on as few dyes as it can be done on.
    for (var which = 0; which < Estates.count; which++) {
      final estate = Estates.at(which);
      await open(tester, which: which);
      await paintItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: estate.name);
      expect(play.isFewest, isTrue, reason: estate.name);
      expect(play.used, hasLength(estate.fewest), reason: estate.name);
      expect(find.bySemanticsLabel('the estate is painted'), findsOneWidget,
          reason: estate.name);
    }
  });
}
