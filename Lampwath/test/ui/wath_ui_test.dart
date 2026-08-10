import 'package:flutter_test/flutter_test.dart';
import 'package:lampwath/wath/bridges.dart';

import '../support/wath.dart';

void main() {
  testWidgets('a night opens with everybody near', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.over, 0);
    expect(play.spent, 0);
    expect(find.text(Bridges.at(2).name), findsOneWidget);
    expect(find.textContaining('the lantern is on the near bank'),
        findsOneWidget);
  });

  testWidgets('picking two and crossing costs the slower pace',
      (tester) async {
    await open(tester, which: 2);
    await pick(tester, 0);
    await pick(tester, 1);
    expect(find.textContaining('the next crossing takes 2'), findsOneWidget);

    await crossNow(tester);
    expect(state(tester).play.spent, 2);
    expect(state(tester).play.lampFar, isTrue);
  });

  testWidgets('a third pick is refused with a word', (tester) async {
    await open(tester, which: 2);
    await pick(tester, 0);
    await pick(tester, 1);
    await pick(tester, 2);

    expect(state(tester).play.chosenCount, 2);
    expect(find.textContaining('carries two at most'), findsOneWidget);
  });

  testWidgets('a walker across the water cannot be picked', (tester) async {
    await open(tester, which: 2);
    await pick(tester, 0);
    await pick(tester, 1);
    await crossNow(tester);
    await pick(tester, 2);

    expect(state(tester).play.chosenCount, 0);
    expect(find.textContaining('cannot cross in the dark'), findsOneWidget);
  });

  testWidgets('crossing with nobody picked asks for somebody', (tester) async {
    await open(tester, which: 2);
    await crossNow(tester);
    expect(find.textContaining('Pick somebody'), findsOneWidget);
  });

  testWidgets('the slow pair first is called out at once', (tester) async {
    await open(tester, which: 2);
    await pick(tester, 2);
    await pick(tester, 3);
    await crossNow(tester);

    expect(find.textContaining('more than the 17 it takes'), findsOneWidget);
  });

  testWidgets('Take back undoes a crossing and Again empties the night',
      (tester) async {
    await open(tester, which: 2);
    await pick(tester, 0);
    await pick(tester, 1);
    await crossNow(tester);
    await press(tester, 'Take back');
    expect(state(tester).play.spent, 0);

    await pick(tester, 0);
    await pick(tester, 1);
    await crossNow(tester);
    await press(tester, 'Again');
    expect(state(tester).play.done, isEmpty);
  });

  testWidgets('Show me names the party', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNot(0));
    expect(find.textContaining('cross together'), findsOneWidget);
  });

  testWidgets('Why tells the trade with this bridge numbers', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(find.textContaining('17 against 19'), findsOneWidget);
  });

  testWidgets('and on the even pace it says the trade buys nothing',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(find.textContaining('buys nothing here'), findsOneWidget);
  });

  testWidgets('every bridge can be crossed at par through the screen',
      (tester) async {
    // The proof that the game is playable: every night crossed by tapping
    // walkers, in as few minutes as the bridge allows.
    for (var which = 0; which < Bridges.count; which++) {
      final bridge = Bridges.at(which);
      await open(tester, which: which);
      await crossItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: bridge.name);
      expect(play.spent, bridge.fewest, reason: bridge.name);
      expect(play.isFewest, isTrue, reason: bridge.name);
      expect(find.bySemanticsLabel('the night is over'), findsOneWidget,
          reason: bridge.name);
    }
  });
}
