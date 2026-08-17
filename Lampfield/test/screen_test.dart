import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lampland.dart';

/// One ask on the screen, the lamps lit as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining(
            'light the lamps so the sum comes to nothing over nine'),
        findsOneWidget);
    expect(find.text('adds to 21'), findsOneWidget);
    expect(find.text('over nine 3'), findsOneWidget);
    expect(find.text('lamps 0'), findsOneWidget);
    expect(
        find.textContaining('The places add to 21, which is 3 over nine'),
        findsOneWidget);
  });

  testWidgets('a tap lights a lamp, and back puts it out', (tester) async {
    await open(tester, which: 3);
    await tapLamp(tester, 1);
    expect(state(tester).play.message[0], 1);
    expect(find.text('adds to 22'), findsOneWidget);
    expect(find.text('lamps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.message[0], 0);
    expect(find.text('lamps 0'), findsOneWidget);
  });

  testWidgets('the dark line lands in three lamps and the card is shown',
      (tester) async {
    await open(tester, which: 2);
    await setMessage(tester, [0, 0, 0, 0, 0, 0, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Sent.'), findsOneWidget);
    expect(
        find.text('As asked. The places add to 0, which is 0 over nine, and '
            '8 of the eight lamps can go out and be put back.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'Lamps none alight, so the places add to 0, which is 0 over '
            'nine. The message is in the code, and the reader gets it back '
            'whichever of the eight lamps goes out. One of 1 message of the '
            '256 that lands it; 3 lamps changed.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Sent.'), findsNothing);
    expect(find.text('lamps 0'), findsOneWidget);
  });

  testWidgets('show me names the lamp, and the pointer lands the code',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.textContaining('lamp '), findsWidgets);
    await sendByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(state(tester).play.inCode, isTrue);
    expect(find.textContaining('One of 30 messages of the 256'), findsOneWidget);
  });

  testWidgets('all alight is in the code as well', (tester) async {
    await open(tester, which: 3);
    await setMessage(tester, [1, 1, 1, 1, 1, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(state(tester).play.weight, 36);
    expect(state(tester).play.mended, 8);
    expect(find.textContaining('One of 1 message of the 256'), findsOneWidget);
  });

  testWidgets('four alight lands eight ways', (tester) async {
    await open(tester, which: 1);
    await setMessage(tester, [0, 0, 1, 1, 1, 1, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.lit, 4);
    expect(find.textContaining('One of 8 messages of the 256'), findsOneWidget);
  });

  testWidgets('a message out of the code loses lamps', (tester) async {
    await open(tester, which: 1);
    await tapLamp(tester, 1);
    expect(state(tester).play.inCode, isFalse);
    expect(state(tester).play.mended, lessThan(8));
  });

  testWidgets('fooling the reader gives itself up after four messages',
      (tester) async {
    await open(tester, which: 4);
    for (final lamp in [1, 2, 3, 4]) {
      await tapLamp(tester, lamp);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The reader is never fooled.'), findsOneWidget);
    expect(
        find.text('No two messages in the code look the same with a lamp '
            'out, so the reader never has a choice to make.'),
        findsOneWidget);
    expect(
        find.textContaining('240 readings, and the reader got every one of '
            'them back'),
        findsOneWidget);
  });

  testWidgets('the why tells the code and its two voices', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Varshamov and Tenengolts'), findsOneWidget);
    expect(
        find.textContaining(
            'once by going through all 256 messages and keeping the ones in '
            'the code'),
        findsOneWidget);
  });
}
