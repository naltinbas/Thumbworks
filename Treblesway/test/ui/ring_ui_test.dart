import 'package:flutter_test/flutter_test.dart';
import 'package:treblesway/ring/peals.dart';
import 'package:treblesway/ring/tower.dart';

import '../support/ring.dart';

void main() {
  testWidgets('a peal opens at rounds', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.made, 0);
    expect(Tower.spoken(play.at), '1234');
    expect(find.text(Peals.at(2).name), findsOneWidget);
    expect(find.textContaining('1 of 24 rows have sounded'), findsOneWidget);
  });

  testWidgets('ringing a change brings a new row', (tester) async {
    await open(tester, which: 2);
    await ring(tester, 'cross');

    expect(Tower.spoken(state(tester).play.at), '2143');
    expect(state(tester).play.made, 1);
  });

  testWidgets('a repeated row is refused with its name', (tester) async {
    await open(tester, which: 2);
    await ring(tester, 'cross');
    await ring(tester, 'near');
    await ring(tester, 'near');

    expect(state(tester).play.made, 2);
    expect(find.textContaining('again, and a row may sound only once'),
        findsOneWidget);
  });

  testWidgets('rounds may not come home early', (tester) async {
    await open(tester, which: 2);
    await ring(tester, 'cross');
    await ring(tester, 'cross');

    expect(state(tester).play.made, 1);
    expect(find.textContaining('bring rounds home early'), findsOneWidget);
  });

  testWidgets('Take back and Again put the ropes down', (tester) async {
    await open(tester, which: 2);
    await ring(tester, 'cross');
    await press(tester, 'Take back');
    expect(state(tester).play.made, 0);

    await ring(tester, 'cross');
    await press(tester, 'Again');
    expect(state(tester).play.made, 0);
  });

  testWidgets('Show me names a change that keeps the peal alive',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNotNull);
    expect(find.textContaining('can still come round after it'),
        findsOneWidget);
  });

  testWidgets('Why on the split tower tells the invariant', (tester) async {
    await open(tester, which: 4);
    expect(find.textContaining('cannot ring the twenty four'), findsOneWidget);

    await press(tester, 'Why');
    expect(find.textContaining('never hold anything but bells 1 and 2'),
        findsOneWidget);
  });

  testWidgets('and on the plain hunt it tells the forced road',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(find.textContaining('The road is forced'), findsOneWidget);
  });

  testWidgets('a stranded peal says so the moment it happens', (tester) async {
    // On the full peal, ringing greedily by the first legal change strands
    // rows before long, and the ledger goes red.
    await open(tester, which: 2);
    var guard = 0;
    while (state(tester).play.canStillRing && guard++ < 30) {
      final play = state(tester).play;
      final legal =
          play.tower.changes.where(play.mayRing).toList();
      await ring(tester, legal.first.name);
    }
    expect(state(tester).play.canStillRing, isFalse);
    expect(find.textContaining('cannot come round from here'),
        findsOneWidget);
  });

  testWidgets('every ringable peal can be rung through the screen',
      (tester) async {
    // The proof that the game is playable: every peal rung to rounds by
    // tapping changes, every row once.
    for (var which = 0; which < Peals.count; which++) {
      final peal = Peals.at(which);
      if (peal.hopeless) continue;
      await open(tester, which: which);
      await ringItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: peal.name);
      expect(play.made, peal.goalRows, reason: peal.name);
      expect(find.bySemanticsLabel('the peal has come round'), findsOneWidget,
          reason: peal.name);
    }
  });
}
