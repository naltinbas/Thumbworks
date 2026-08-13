import 'package:flutter_test/flutter_test.dart';

import 'support/feastland.dart';
import 'support/fonts.dart';

/// One feast on the screen, clinked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a feast opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('till all 5 counts differ'),
      findsOneWidget,
    );
    expect(find.text('counts 1, asked 5'), findsOneWidget);
    expect(find.text('clinks 0'), findsOneWidget);
  });

  testWidgets('a clink raises and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapWire(tester, 0);
    expect(state(tester).play.clinked[0], isTrue);
    expect(find.text('clinks 1'), findsOneWidget);
    expect(find.text('counts 2, asked 5'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.clinked[0], isFalse);
  });

  testWidgets('the four counts land and show the card',
      (tester) async {
    await open(tester, which: 2);
    await feastByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Feasted.'), findsOneWidget);
    expect(
      find.textContaining('4 different'),
      findsWidgets,
    );
    await press(tester, 'Again');
    expect(find.text('Feasted.'), findsNothing);
  });

  testWidgets('show me rings a pair and says which way',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Clink the ringed pair'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer feasts the three of four home',
      (tester) async {
    await open(tester, which: 3);
    await feastByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.distinct, 3);
  });

  testWidgets('the hopeless feast cracks at fourteen moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 14; dither++) {
      await tapWire(tester, dither % 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('Two always clink alike.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('cannot share a feast'),
      findsOneWidget,
    );
  });

  testWidgets('the why names the wallflower and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the wallflower clinked nobody at all'),
      findsOneWidget,
    );
    expect(find.textContaining('1,024'), findsWidgets);
  });
}
