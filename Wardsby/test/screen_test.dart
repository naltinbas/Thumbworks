import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/parishland.dart';

/// One parish on the screen, drawn as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a parish opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('draw the five wards so the Blues win three of the five, the parish being 10 Blue and 15 Red'), findsOneWidget);
    expect(find.text('drawn 0 of 25'), findsOneWidget);
    expect(find.text('Blues 0, Reds 0'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('0 of 25 drawn; tap a household to move it round the wards.'), findsOneWidget);
  });

  testWidgets('a tap moves a household round the wards, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapHouse(tester, 0);
    expect(state(tester).play.wards[0], 0);
    expect(find.text('drawn 1 of 25'), findsOneWidget);
    await tapHouse(tester, 0);
    expect(state(tester).play.wards[0], 1);
    await press(tester, 'Back');
    expect(state(tester).play.wards[0], 0);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the sweep lands by the columns and the card is shown', (tester) async {
    await open(tester, which: 1);
    await draw(tester, [for (var c = 0; c < 25; c++) c % 5]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Drawn.'), findsOneWidget);
    expect(find.text('As asked: the Blues win 5 wards of the five, the Reds 0.'), findsOneWidget);
    expect(find.textContaining('The wards go 3 to 2, 3 to 2, 3 to 2, 3 to 2, 3 to 2 Blue to Red, so the Blues take 5 and the Reds 0, with 15 Blue households of 25'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Drawn.'), findsNothing);
  });

  testWidgets('a drawn parish that is not sound says so', (tester) async {
    await open(tester, which: 1);
    final split = [for (var c = 0; c < 25; c++) c ~/ 5];
    split[0] = 4;
    split[24] = 0;
    await draw(tester, split);
    expect(state(tester).play.assigned, 25);
    expect(find.text('Every household drawn, but a ward is not five in one piece.'), findsOneWidget);
  });

  testWidgets('show me names the household and the taps', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (0, 1));
    expect(find.text('Tap the ringed household once, into ward 1.'), findsOneWidget);
    await tapHouse(tester, 0);
    await press(tester, 'Show me');
    expect(find.text('Tap the ringed household 2 times, into ward 2.'), findsOneWidget);
  });

  testWidgets('the pointer draws the minority\'s win', (tester) async {
    await open(tester, which: 0);
    await drawByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.blueWins, 3);
  });

  testWidgets('the nine by rows', (tester) async {
    await open(tester, which: 3);
    await draw(tester, [for (var c = 0; c < 25; c++) c ~/ 5]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('so the Blues take 3 and the Reds 2, with 9 Blue households of 25'), findsOneWidget);
  });

  testWidgets('the eight admit it', (tester) async {
    await open(tester, which: 4);
    await draw(tester, [for (var c = 0; c < 25; c++) c ~/ 5]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Eight never make three.'), findsOneWidget);
    expect(find.textContaining('three wards take nine, so eight votes make two wards at the most'), findsOneWidget);
  });

  testWidgets('the why counts the drawings', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Every drawing there is, 4,006 of them, is walked'), findsOneWidget);
    expect(find.textContaining('eight Blues win two wards at the most, 1,916 drawings of the 4,006'), findsOneWidget);
  });
}
