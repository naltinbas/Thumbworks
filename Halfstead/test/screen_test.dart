import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stepland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('get within a hundredth of the wall, covering half of what is left at every step'), findsOneWidget);
    expect(find.text('half'), findsOneWidget);
    expect(find.text('steps 1'), findsOneWidget);
    expect(find.text('covered 1/2'), findsOneWidget);
    expect(find.text('to go 1/2'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('1 step, each half of what is left: 1/2 of the way covered, 1/2 to go.'), findsOneWidget);
  });

  testWidgets('a tap adds a step, and back takes it off', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'steps', 1);
    expect(state(tester).play.steps, 2);
    expect(find.text('steps 2'), findsOneWidget);
    expect(find.text('covered 3/4'), findsOneWidget);
    expect(find.text('2 steps, each half of what is left: 3/4 of the way covered, 1/4 to go.'), findsOneWidget);
    await turn(tester, 'share', 1);
    expect(find.text('a third'), findsOneWidget);
    expect(find.text('2 steps, each a third of what is left: 5/9 of the way covered, 4/9 to go.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.shareIndex, 0);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the hundredth lands at seven halvings and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 0, 7);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Stopped there.'), findsOneWidget);
    expect(find.text('As asked. 7 steps, each half of what is left: 127/128 of the way covered, 1/128 to go.'), findsOneWidget);
    expect(find.textContaining('7 steps of half, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128, add to 127/128, and 1 less 1/128 agrees; one of 34 settings of the 200; 6 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Stopped there.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer lands the quarter left', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Add a step.'), findsOneWidget);
    expect(state(tester).pointing, (1, 1));
    await runByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 1);
    expect(find.text('As asked. 2 steps, each half of what is left: 3/4 of the way covered, 1/4 to go.'), findsOneWidget);
    expect(find.textContaining('2 steps of half, 1/2, 1/4, add to 3/4, and 1 less 1/4 agrees; one of 2 settings of the 200; 1 tap.'), findsOneWidget);
  });

  testWidgets('the thousandth by tenths', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Turn the share up.'), findsOneWidget);
    await setDials(tester, 4, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 3 steps, each nine tenths of what is left: 999/1,000 of the way covered, 1/1,000 to go.'), findsOneWidget);
    expect(find.textContaining('3 steps of nine tenths, 9/10, 9/100, 9/1,000, add to 999/1,000, and 1 less 1/1,000 agrees; one of 38 settings of the 200; 6 taps.'), findsOneWidget);
  });

  testWidgets('the sixty-fourth by three quarters', (tester) async {
    await open(tester, which: 3);
    await setDials(tester, 3, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 3 steps, each three quarters of what is left: 63/64 of the way covered, 1/64 to go.'), findsOneWidget);
    expect(find.textContaining('3 steps of three quarters, 3/4, 3/16, 3/64, add to 63/64, and 1 less 1/64 agrees; one of 2 settings of the 200; 5 taps.'), findsOneWidget);
  });

  testWidgets('the wall admits it at twenty halvings', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 0, 20);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never the wall.'), findsOneWidget);
    expect(find.text('20 steps, each half of what is left: 1,048,575/1,048,576 of the way covered, 1/1,048,576 to go. And there is always something to go: a share of something leaves something.'), findsOneWidget);
    expect(find.textContaining('after 20 steps of half 1/1,048,576 is left'), findsOneWidget);
  });

  testWidgets('the why tells Zeno and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Zeno set it as a paradox'), findsOneWidget);
    expect(find.textContaining('added out in full'), findsOneWidget);
  });
}
