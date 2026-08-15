import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rollland.dart';

/// One ask on the screen, rolled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the hoop and the roller so the roller turns exactly twice going round the outside'), findsOneWidget);
    expect(find.text('turns 4'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('hoop 3'), findsOneWidget);
    expect(find.text('roller 1'), findsOneWidget);
    expect(find.text('Round the outside'), findsOneWidget);
    expect(find.text('A hoop of 3 and a roller of 1, round the outside: 4 turns a trip, 3 for the rim and 1 on for the trip.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial, a flip changes the side, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'roller', 1);
    expect(state(tester).play.coin, 2);
    expect(find.text('turns 5/2'), findsOneWidget);
    expect(find.text('A hoop of 3 and a roller of 2, round the outside: 5/2 turns a trip, 3/2 for the rim and 1 on for the trip.'), findsOneWidget);
    await flip(tester);
    expect(find.text('Round the inside'), findsOneWidget);
    expect(find.text('turns 1/2'), findsOneWidget);
    expect(find.text('A hoop of 3 and a roller of 2, round the inside: 1/2 turn a trip, 3/2 for the rim and 1 off for the trip.'), findsNothing);
    expect(find.text('A hoop of 3 and a roller of 2, round the inside: 1/2 turns a trip, 3/2 for the rim and 1 off for the trip.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await turn(tester, 'roller', 1);
    expect(find.text('does not fit'), findsOneWidget);
    expect(find.text('A roller of 3 does not fit inside a hoop of 3.'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('turns 1/2'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('the twice lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setCoins(tester, 3, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Rolled.'), findsOneWidget);
    expect(find.text('As asked. A hoop of 3 and a roller of 3, round the outside: 2 turns a trip, 1 for the rim and 1 on for the trip.'), findsOneWidget);
    expect(find.textContaining('A hoop of three and a roller of three, round the outside: two turns a trip, 1 for the rim and one on for the trip; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Rolled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the side, the dial and the way', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Send it round the other side.'), findsOneWidget);
    await flip(tester);
    await press(tester, 'Show me');
    expect(find.text('Narrow the hoop.'), findsOneWidget);
  });

  testWidgets('the pointer rolls the inside once', (tester) async {
    await open(tester, which: 3);
    await rollByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(find.text('As asked. A hoop of 2 and a roller of 1, round the inside: 1 turn a trip, 2 for the rim and 1 off for the trip.'), findsOneWidget);
  });

  testWidgets('the half, by hand, and a dial at its end stays', (tester) async {
    await open(tester, which: 2);
    await setCoins(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. A hoop of 1 and a roller of 2, round the outside: 3/2 turns a trip, 1/2 for the rim and 1 on for the trip.'), findsOneWidget);
    expect(find.textContaining('three halves of a turn a trip, 1/2 for the rim and one on for the trip; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    await setCoins(tester, 6, 1);
    await turn(tester, 'hoop', 1);
    expect(state(tester).play.hoop, 6);
    expect(find.text('taps 3'), findsOneWidget);
  });

  testWidgets('the once admits it at the nearest setting', (tester) async {
    await open(tester, which: 4);
    await setCoins(tester, 1, 6);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The trip is a turn.'), findsOneWidget);
    expect(find.text('A hoop of one and a roller of six is as near as it comes: 7/6 of a turn, and the trip alone is a turn.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 72 settings finds nothing nearer'), findsOneWidget);
  });

  testWidgets('the why tells the trip and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Roll a coin once round another of the same size and it turns twice'), findsOneWidget);
    expect(find.textContaining('72 settings, tried in full'), findsOneWidget);
  });
}
