import 'package:beaconholt/watch/countries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/watch.dart';

void main() {
  testWidgets('a country opens with every hill dark', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.beacons, isEmpty);
    expect(play.dark, hasLength(play.count));
    expect(find.text(Watchlands.at(1).name), findsOneWidget);
    expect(find.textContaining('still dark'), findsOneWidget);
  });

  testWidgets('tapping a hill lights a beacon on it', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0);

    final play = state(tester).play;
    expect(play.hasBeacon(0), isTrue);
    expect(play.isLit(0), isTrue);
  });

  testWidgets('and tapping it again puts it out', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0);
    await light(tester, 0);
    expect(state(tester).play.beacons, isEmpty);
  });

  testWidgets('the game names a hill nothing can see', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0);
    expect(find.textContaining('among them'), findsOneWidget);

    // And down to the last one it names it on its own.
    final play = state(tester).play;
    for (final hill in play.answer.where) {
      if (!play.hasBeacon(hill)) await light(tester, hill);
    }
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('Again puts every beacon out', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0);
    await light(tester, 1);
    await press(tester, 'Again');

    expect(state(tester).play.beacons, isEmpty);
    expect(state(tester).play.changes, 0);
  });

  testWidgets('Show me names a hill that is in an answer', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, isNonNegative);
    expect(screen.hints, 1);
    expect(screen.play.answer.where, contains(screen.pointing));
    expect(find.textContaining('has a beacon in one of the sets of'),
        findsOneWidget);
  });

  testWidgets('every country can be watched on the fewest through the screen',
      (tester) async {
    // The proof that the game is playable: every country lit by tapping
    // hills, on the fewest beacons there are.
    for (var which = 0; which < Watchlands.count; which++) {
      await open(tester, which: which);
      await lightItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Watchlands.at(which).name);
      expect(play.isFewest, isTrue, reason: Watchlands.at(which).name);
      expect(find.bySemanticsLabel('the whole country is watched'),
          findsOneWidget, reason: Watchlands.at(which).name);
    }
  });
}
