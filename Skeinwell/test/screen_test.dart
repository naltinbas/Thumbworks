import 'package:flutter_test/flutter_test.dart';
import 'package:skeinwell/skein/rules.dart';

import 'support/fonts.dart';
import 'support/skeinland.dart';

/// One ask on the screen, the lanes laid as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining(
            'lay lanes so that one of them takes exactly half the stringings'),
        findsOneWidget);
    expect(find.text('shares 4'), findsOneWidget);
    expect(find.text('stringings 1'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('The village strings 1 way, and the shares add to 4.'),
        findsOneWidget);
  });

  testWidgets('a tap lays a lane and another lifts it', (tester) async {
    await open(tester, which: 3);
    await tapLane(tester, 0);
    expect(Rules.laidLanes(state(tester).play.village), [0, 3, 6, 8, 9]);
    expect(find.text('stringings 3'), findsOneWidget);
    await tapLane(tester, 0);
    expect(Rules.laidLanes(state(tester).play.village), [3, 6, 8, 9]);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('a lift that would cut a green off is refused and says so',
      (tester) async {
    await open(tester, which: 3);
    await tapLane(tester, 3);
    expect(Rules.laidLanes(state(tester).play.village), [3, 6, 8, 9]);
    expect(find.text('taps 0'), findsOneWidget);
    expect(
        find.text('Lifting the lane from 1 to 5 would cut a green off, so it '
            'stays.'),
        findsOneWidget);
  });

  testWidgets('the half lane lands in two taps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await setVillage(tester, [0, 1, 3, 6, 8, 9]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Strung.'), findsOneWidget);
    expect(find.text('As asked. The village strings 8 ways, and the shares '
        'add to 4.'), findsOneWidget);
    expect(
        find.textContaining(
            'The village 1 to 2, 1 to 3, 1 to 5, 2 to 5, 3 to 5, 4 to 5 '
            'strings 8 ways, and the shares 5/8, 5/8, 1/2, 5/8, 5/8, 1 add '
            'to 4, counted lane by lane and carried through again as '
            'traffic; one of 200 villages of the 728 that land it; 2 taps.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Strung.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the lane, and the pointer lands the even ring',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Lay the lane from 1 to 4.'), findsOneWidget);
    expect(state(tester).pointing, (2, true));
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(Rules.laidLanes(state(tester).play.village), [2, 3, 4, 6, 8, 9]);
    expect(state(tester).play.moves, 2);
    expect(
        find.textContaining('the shares 2/3, 2/3, 2/3, 2/3, 2/3, 2/3 add to 4'),
        findsOneWidget);
  });

  testWidgets('the two halves takes three taps', (tester) async {
    await open(tester, which: 2);
    await setVillage(tester, [0, 1, 3, 4, 6, 8, 9]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.textContaining('one of 20 villages of the 728 that land it; '
        '3 taps.'), findsOneWidget);
  });

  testWidgets('the full skein takes six and every share is two fifths',
      (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(state(tester).play.stringings, 125);
    expect(
        find.textContaining('one of 1 village of the 728 that lands it; '
            '6 taps.'),
        findsOneWidget);
  });

  testWidgets('a village short of the ask says what it strings',
      (tester) async {
    await open(tester, which: 2);
    await setVillage(tester, [0, 3, 4, 7, 9]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('stringings 5'), findsOneWidget);
    expect(find.text('shares 4'), findsOneWidget);
  });

  testWidgets('more than four gives itself up after four villages',
      (tester) async {
    await open(tester, which: 4);
    await setVillage(tester, [0, 1, 3, 4, 5, 6, 8, 9]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Four, whatever you lay.'), findsOneWidget);
    expect(
        find.textContaining(
            'Every stringing takes four lanes, so the shares count four '
            'lanes for each stringing'),
        findsOneWidget);
    expect(
        find.textContaining(
            'four lanes are what it takes to join five greens without '
            'closing a loop'),
        findsOneWidget);
  });

  testWidgets('the why tells Foster and the two voices', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Ronald Foster published this in 1949'),
        findsOneWidget);
    expect(
        find.textContaining(
            'once by counting the stringings one at a time, and once by '
            'putting a unit of traffic in at one end of a lane'),
        findsOneWidget);
  });
}
