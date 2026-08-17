import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/beatland.dart';

/// One ask on the screen, the throws laid as a thumb would lay them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('lay 1, 2, 3, 4, 5 on the beats'), findsWidgets);
    expect(find.text('throws 15'), findsOneWidget);
    expect(find.text('juggles 15 of 120'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.textContaining('5 throws still on the rack'), findsOneWidget);
  });

  testWidgets('a throw is taken, laid, and taken back', (tester) async {
    await open(tester, which: 1);
    await takeThrow(tester, 3);
    expect(state(tester).play.held, 3);
    expect(find.textContaining('A throw of 3 in the hand'), findsOneWidget);
    await tapBeat(tester, 0);
    expect(state(tester).play.laid[0], 3);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.laid[0], -1);
  });

  testWidgets('a throw that would drop is refused and the beat is named',
      (tester) async {
    await open(tester, which: 1);
    await lay(tester, 3, 0);
    await takeThrow(tester, 2);
    await tapBeat(tester, 1);
    expect(state(tester).play.laid[1], -1);
    expect(
        find.textContaining('comes down on beat 3, where a ball comes down '
            'already'),
        findsOneWidget);
  });

  testWidgets('tapping the chart above the beats lays nothing', (tester) async {
    await open(tester, which: 1);
    await tester.tapAt(skyAt(tester));
    await tester.pumpAndSettle();
    expect(state(tester).play.taps, 0);
    expect(find.textContaining('Tap a throw on the rack'), findsOneWidget);
  });

  testWidgets('a laid throw lifts off when its beat is tapped',
      (tester) async {
    await open(tester, which: 1);
    await lay(tester, 3, 0);
    await tapBeat(tester, 0);
    expect(state(tester).play.laid[0], -1);
  });

  testWidgets('the rest beat juggles in ten taps and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await juggleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 10);
    expect(find.text('Juggled.'), findsOneWidget);
    expect(find.textContaining('One of 20 layings of the 120'), findsOneWidget);
    expect(find.textContaining('so 3 balls'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Juggled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the seven juggles five ways', (tester) async {
    await open(tester, which: 3);
    await juggleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.aloft.toSet(), {3});
    expect(find.textContaining('One of 5 layings of the 30'), findsOneWidget);
  });

  testWidgets('show me names a throw and then a beat', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('off the rack, for beat'), findsOneWidget);
  });

  testWidgets('the raised throw gives itself up on the arithmetic',
      (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 20; k++) {
      if (state(tester).play.gaveUp) break;
      await takeThrow(tester, 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('It will not go round.'), findsOneWidget);
    expect(find.textContaining('16 into 5 will not go'), findsWidgets);
  });

  testWidgets('the why names the average and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the plain average of the throws'),
        findsOneWidget);
    expect(find.textContaining('100,000'), findsOneWidget);
  });
}
