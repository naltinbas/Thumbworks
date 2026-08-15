import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/byland.dart';

/// One crew on the screen, paid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a crew opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('divide the ten coins among the five pirates so the plan passes and the captain keeps eight or more'),
      findsOneWidget,
    );
    expect(find.text('kept 10 of 10'), findsOneWidget);
    expect(find.text('ayes ? of 5'), findsOneWidget);
    expect(find.text('needs 3'), findsOneWidget);
    expect(find.text('The captain keeps 10 of ten; tap a pirate to give him a coin, then vote.'), findsOneWidget);
  });

  testWidgets('a coin is given, and back takes it back', (tester) async {
    await open(tester, which: 3);
    await tapPirate(tester, 2);
    expect(find.text('kept 9 of 10'), findsOneWidget);
    expect(state(tester).play.shares, [9, 0, 1, 0, 0]);
    await press(tester, 'Back');
    expect(find.text('kept 10 of 10'), findsOneWidget);
  });

  testWidgets('five pirates paid eight, nought, one, nought, one, and the vote passes', (tester) async {
    await open(tester, which: 3);
    await tapAll(tester, [2, 4]);
    await press(tester, 'Vote');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('ayes 3 of 5'), findsOneWidget);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Passed: 3 ayes of 5, and the captain keeps 8.'), findsOneWidget);
    expect(
      find.textContaining('The plan passed, 3 ayes of 5, and the captain keeps 8 coins; 2 given.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a vote lost puts the captain over the side', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Vote');
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Overboard.'), findsOneWidget);
    expect(find.textContaining('The plan failed, 1 aye of 5'), findsOneWidget);
  });

  testWidgets('a vote won too cheap is a poor pass', (tester) async {
    await open(tester, which: 1);
    await tapAll(tester, [2, 2]);
    await press(tester, 'Vote');
    expect(find.text('Passed, but poor.'), findsOneWidget);
    expect(find.text('Passed, 2 ayes of 3, but the captain keeps only 8.'), findsOneWidget);
  });

  testWidgets('show me says give, then vote', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('give', 2));
    expect(find.text('Give the ringed pirate a coin.'), findsOneWidget);
    await tapAll(tester, [2, 4]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('vote', 0));
    expect(find.text('The plan is the best there is: put it to the vote.'), findsOneWidget);
  });

  testWidgets('the pointer pays the four pirates', (tester) async {
    await open(tester, which: 2);
    await payByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('kept 9 of 10'), findsOneWidget);
  });

  testWidgets('the greedy captain goes over', (tester) async {
    await open(tester, which: 4);
    await tapPirate(tester, 2);
    await press(tester, 'Vote');
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nine never passes.'), findsOneWidget);
    expect(
      find.textContaining('one coin buys one aye from a pirate who expects nothing, never two'),
      findsOneWidget,
    );
  });

  testWidgets('the why reckons the crew backwards', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('second 9, third 0, fourth 1, fifth 0'),
      findsOneWidget,
    );
    expect(
      find.textContaining('none keeping 9 passes'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the five counts the plans', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('1 of the 15 keeping 8 or more'),
      findsOneWidget,
    );
  });
}
