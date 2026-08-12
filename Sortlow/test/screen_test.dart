import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lowland.dart';

/// One load on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a load opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('exactly 8 turns from the stone'),
      findsOneWidget,
    );
    expect(find.text('load 1000'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and the road follows',
      (tester) async {
    await open(tester, which: 0);
    await tapDial(tester, 0);
    expect(state(tester).play.number, 3026);
    await press(tester, 'Back');
    expect(state(tester).play.number, 2026);
  });

  testWidgets('the standstill lands and shows the card',
      (tester) async {
    await open(tester, which: 3);
    await dialTo(tester, 0, 6);
    await dialTo(tester, 1, 1);
    await dialTo(tester, 2, 7);
    await dialTo(tester, 3, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Dialled home.').first, findsOneWidget);
    expect(
      find.textContaining('walk and table agreeing'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(state(tester).play.number, 1000);
  });

  testWidgets('a repdigit shows barred', (tester) async {
    await open(tester, which: 4);
    await dialTo(tester, 1, 1);
    await dialTo(tester, 2, 1);
    await dialTo(tester, 3, 1);
    expect(state(tester).play.barred, isTrue);
    expect(find.text('barred'), findsOneWidget);
    expect(
      find.textContaining('the mill bars the door'),
      findsOneWidget,
    );
  });

  testWidgets('show me rings a dial', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Tap the ringed dial'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer grinds the three turns home',
      (tester) async {
    await open(tester, which: 1);
    await grindByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.steps, 3);
  });

  testWidgets('the hopeless load cracks at sixteen taps',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 16; dither++) {
      await tapDial(tester, dither % 4);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('Seven is the whole road.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('arrives by the seventh'),
      findsWidgets,
    );
  });

  testWidgets('the why speaks both measures and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('seven layers'),
      findsOneWidget,
    );
    expect(find.textContaining('9,990'), findsWidgets);
  });
}
