import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// One asking on the screen, wound as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an asking opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('holding exactly 3 odd numbers'),
      findsOneWidget,
    );
    expect(find.text('odds 1, asked 3'), findsOneWidget);
    expect(find.text('row 0'), findsOneWidget);
  });

  testWidgets('a wind climbs and the chips follow', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'wind down');
    expect(state(tester).play.at, 1);
    expect(find.text('row 1'), findsOneWidget);
    expect(find.text('odds 2, asked 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.at, 0);
  });

  testWidgets('the four odds land and show the card',
      (tester) async {
    await open(tester, which: 1);
    await windTo(tester, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Wound home.'), findsOneWidget);
    expect(
      find.textContaining('the three counts agreeing'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Wound home.'), findsNothing);
    expect(state(tester).play.at, 0);
  });

  testWidgets('show me names the way', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Wind down the wall'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer winds the full row home', (tester) async {
    await open(tester, which: 3);
    await windByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.at, 15);
  });

  testWidgets('the hopeless asking cracks at twelve winds',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 12; dither++) {
      await press(
          tester, dither.isEven ? 'wind down' : 'wind up');
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('The doubling allows no three.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('three is no power of two'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the bit rule and the tally',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('bits fit inside the row'),
      findsOneWidget,
    );
    expect(
      find.textContaining('tally 1, 4, 6, 4 and 1'),
      findsOneWidget,
    );
  });
}
