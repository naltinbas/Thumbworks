import 'package:flutter_test/flutter_test.dart';
import 'package:trodstow/link/parishes.dart';

import '../support/link.dart';

void main() {
  testWidgets('a parish opens with nothing cut', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.cut, isEmpty);
    expect(play.yards, 0);
    expect(find.text(Rounds.at(0).name), findsOneWidget);
    expect(find.textContaining('5 pieces still'), findsOneWidget);
  });

  testWidgets('tapping a path cuts it, and again fills it in', (tester) async {
    await open(tester, which: 0);
    await cut(tester, 1);
    expect(state(tester).play.has(1), isTrue);
    await cut(tester, 1);
    expect(state(tester).play.has(1), isFalse);
  });

  testWidgets('a path that would close a loop says so', (tester) async {
    await open(tester, which: 0);
    await cut(tester, 1);
    await cut(tester, 4);
    await cut(tester, 0);

    expect(state(tester).play.has(0), isFalse);
    expect(find.textContaining('would close a loop'), findsOneWidget);
  });

  testWidgets('it says when the cheapest has been thrown away', (tester) async {
    await open(tester, which: 0);
    await cut(tester, 0);

    expect(state(tester).play.couldStillCost,
        greaterThan(Rounds.at(0).yards));
    expect(find.textContaining('The least this can now be joined for'),
        findsOneWidget);
  });

  testWidgets('Again fills everything in', (tester) async {
    await open(tester, which: 0);
    await cut(tester, 1);
    await press(tester, 'Again');
    expect(state(tester).play.cut, isEmpty);
  });

  testWidgets('Show me points at a path and says what it costs',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.marking.pointing, isNonNegative);
    expect(find.textContaining(' yards.'), findsOneWidget);
  });

  testWidgets('Why draws the line a path is the cheapest across',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    await press(tester, 'Why');

    final marking = state(tester).marking;
    expect(marking.thisSide, isNotEmpty);
    expect(marking.thatSide, isNotEmpty);
    expect(marking.crossing, contains(marking.pointing));
    expect(find.textContaining('is the cheapest of them'), findsOneWidget);
  });

  testWidgets('and the loop a path outside the answer is dearest on',
      (tester) async {
    await open(tester, which: 2);
    // The dearest path in the parish is in no cheapest network.
    final parish = Rounds.at(2).parish;
    var dearest = 0;
    for (var trod = 0; trod < parish.many; trod++) {
      if (parish[trod].yards > parish[dearest].yards) dearest = trod;
    }
    await cut(tester, dearest);
    await press(tester, 'Why');

    expect(state(tester).marking.loop, contains(dearest));
    expect(find.textContaining('is in no cheapest network at all'),
        findsOneWidget);
  });

  testWidgets('and with nothing to go on it says so', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(find.textContaining('Cut a path, or ask to be shown one'),
        findsOneWidget);
  });

  testWidgets('a parish joined up the dear way says so at the end',
      (tester) async {
    await open(tester, which: 0);
    await cut(tester, 0);
    await joinItAll(tester);

    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.isCheapest, isFalse);
    expect(find.textContaining('It can be done on'), findsOneWidget);
  });

  testWidgets('every parish can be joined up for the cheapest through the '
      'screen', (tester) async {
    // The proof that the game is playable: every parish joined by tapping
    // paths, on as few yards as it can be done on.
    for (var which = 0; which < Rounds.count; which++) {
      final round = Rounds.at(which);
      await open(tester, which: which);
      await joinItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: round.name);
      expect(play.isCheapest, isTrue, reason: round.name);
      expect(play.yards, round.yards, reason: round.name);
      expect(find.bySemanticsLabel('the parish is joined up'), findsOneWidget,
          reason: round.name);
    }
  });
}
