import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/roadland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('dial the crowd so that, with the shortcut shut, every driver takes 65 minutes'), findsOneWidget);
    expect(find.text('crowd 20'), findsOneWidget);
    expect(find.text('Shortcut shut'), findsOneWidget);
    expect(find.text('everyone 55 min'), findsOneWidget);
    expect(find.text('shortcut helps here'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Twenty hundred drivers, shortcut shut: ten hundred go by the top and ten hundred by the bottom, 45 + 10 = 55 minutes each way.'), findsOneWidget);
  });

  testWidgets('a tap turns the crowd, the button turns the shortcut, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 1);
    expect(state(tester).play.crowd, 22);
    expect(find.text('crowd 22'), findsOneWidget);
    expect(find.text('everyone 56 min'), findsOneWidget);
    await toggle(tester);
    expect(state(tester).play.open, isTrue);
    expect(find.text('Shortcut open'), findsOneWidget);
    expect(find.text('everyone 44 min'), findsOneWidget);
    expect(find.text('Twenty-two hundred drivers, shortcut open: all go top, across and bottom, 22 + 22 = 44 minutes, 12 fewer than with it shut.'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.open, isFalse);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the sixty-five lands on forty hundred shut and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 40, false);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 10);
    expect(find.text('Settled.'), findsOneWidget);
    expect(find.text('As asked. Forty hundred drivers, shortcut shut: twenty hundred go by the top and twenty hundred by the bottom, 45 + 20 = 65 minutes each way.'), findsOneWidget);
    expect(find.textContaining('Forty hundred drivers, the shortcut shut: twenty hundred go by the top and twenty hundred by the bottom, and everyone takes 65 minutes, 15 fewer than with it open; one of 1 setting of the 60; 10 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Settled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer lands the eighty', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Turn the crowd up.'), findsOneWidget);
    expect(state(tester).pointing, (0, 1));
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.crowd, state(tester).play.open, state(tester).play.moves), (40, true, 11));
    expect(find.text('As asked. Forty hundred drivers, shortcut open: all go top, across and bottom, 40 + 40 = 80 minutes, 15 more than with it shut.'), findsOneWidget);
    expect(find.textContaining('all forty hundred go top, across and bottom, and everyone takes 80 minutes, 15 more than with it shut; one of 1 setting of the 60; 11 taps.'), findsOneWidget);
  });

  testWidgets('show me says to open the shortcut when the crowd is set', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 2, false);
    await press(tester, 'Show me');
    expect(find.text('Open the shortcut.'), findsOneWidget);
    expect(state(tester).pointing, (1, 1));
    await toggle(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Two hundred drivers, shortcut open: all go top, across and bottom, 2 + 2 = 4 minutes, 42 fewer than with it shut.'), findsOneWidget);
  });

  testWidgets('the break-even at thirty hundred, either way', (tester) async {
    await open(tester, which: 3);
    await setDials(tester, 30, false);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Thirty hundred drivers, shortcut shut: fifteen hundred go by the top and fifteen hundred by the bottom, 45 + 15 = 60 minutes each way.'), findsOneWidget);
    expect(find.textContaining('everyone takes 60 minutes, the same as with it open; one of 2 settings of the 60; 5 taps.'), findsOneWidget);
  });

  testWidgets('a big crowd with the shortcut open splits three ways', (tester) async {
    await open(tester, which: 0);
    // Open first: shut, the crowd would land forty hundred on the way.
    await toggle(tester);
    await setDials(tester, 50, true);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Fifty hundred drivers, shortcut open: five hundred go by the top, five hundred by the bottom and forty hundred across, 90 minutes each way, 20 more than with it shut.'), findsOneWidget);
    expect(find.text('shortcut hurts here'), findsOneWidget);
  });

  testWidgets('the big crowd helped admits it at thirty-two hundred open', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 32, true);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('A road that slows everyone.'), findsOneWidget);
    expect(find.text('Thirty-two hundred drivers, shortcut open: all go top, across and bottom, 32 + 32 = 64 minutes, 3 more than with it shut. Past thirty hundred the shortcut only hurts.'), findsOneWidget);
    expect(find.textContaining('Here thirty-two hundred take 64 with it open and 61 with it shut'), findsOneWidget);
  });

  testWidgets('the why tells Braess and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Braess found it in 1968'), findsOneWidget);
    expect(find.textContaining('settled both ways'), findsOneWidget);
  });
}
